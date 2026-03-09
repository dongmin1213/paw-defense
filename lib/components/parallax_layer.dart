import 'dart:ui';
import 'dart:math';
import 'package:flame/components.dart';

import '../game/runner_game.dart';
import '../data/region_data.dart';
import '../utils/constants.dart';

/// A single parallax background layer that scrolls at a fraction of camera speed.
class ParallaxLayer extends PositionComponent with HasGameReference<RunnerGame> {
  final double scrollFactor; // 0.0 = static, 1.0 = same as camera
  final int layerIndex; // 0=far, 1=mid, 2=near
  double _lastCameraX = 0;

  ParallaxLayer({
    required this.scrollFactor,
    required this.layerIndex,
  }) : super(
          position: Vector2.zero(),
          size: Vector2(GameConstants.worldWidth, GameConstants.worldHeight),
          priority: -10 + layerIndex, // render behind everything
        );

  @override
  void update(double dt) {
    super.update(dt);
    final cameraX = game.camera.viewfinder.position.x;
    position.x = cameraX; // keep layer at camera position
    _lastCameraX = cameraX;
  }

  @override
  void render(Canvas canvas) {
    final region = game.currentRegion;
    final scrollOffset = _lastCameraX * scrollFactor;

    switch (layerIndex) {
      case 0:
        _renderFarLayer(canvas, region, scrollOffset);
        break;
      case 1:
        _renderMidLayer(canvas, region, scrollOffset);
        break;
      case 2:
        _renderNearLayer(canvas, region, scrollOffset);
        break;
    }
  }

  /// Far layer: gradient sky + distant mountains + clouds
  void _renderFarLayer(Canvas canvas, RegionData region, double offset) {
    final paint = Paint()..isAntiAlias = false;

    // Sky gradient (pixelated bands)
    final skyTop = region.skyColor;
    final skyBottom = region.farBgColor;
    const bands = 12;
    final bandH = size.y * 0.7 / bands;
    for (var i = 0; i < bands; i++) {
      final t = i / (bands - 1);
      final r = (skyTop.red + (skyBottom.red - skyTop.red) * t).round().clamp(0, 255);
      final g = (skyTop.green + (skyBottom.green - skyTop.green) * t).round().clamp(0, 255);
      final b = (skyTop.blue + (skyBottom.blue - skyTop.blue) * t).round().clamp(0, 255);
      paint.color = Color.fromARGB(255, r, g, b);
      canvas.drawRect(Rect.fromLTWH(0, i * bandH, size.x, bandH + 1), paint);
    }

    // Clouds (pixel-art style rectangles)
    _drawClouds(canvas, offset, size);

    // Distant mountains as stepped pixel silhouettes
    final mountainColor = region.farBgColor;
    final mPaint = Paint()..color = mountainColor..isAntiAlias = false;
    final pixelH = 8.0;
    final segWidth = 160.0;
    final numSegs = (size.x / segWidth).ceil() + 2;
    final startSeg = (offset / segWidth).floor();

    for (var i = 0; i <= numSegs; i++) {
      final segX = (startSeg + i) * segWidth - (offset % segWidth);
      final seed = ((startSeg + i) * 7 + 13) % 100;
      final peakY = size.y * (0.38 + seed / 300.0);
      final baseY = size.y * 0.7;

      // Draw stepped mountain shape
      for (var py = peakY; py < baseY; py += pixelH) {
        final progress = (py - peakY) / (baseY - peakY);
        final halfW = segWidth * 0.15 + segWidth * 0.35 * progress;
        final cx = segX + segWidth * 0.5;
        canvas.drawRect(
          Rect.fromLTWH(cx - halfW, py, halfW * 2, pixelH),
          mPaint,
        );
      }
    }
  }

  void _drawClouds(Canvas canvas, double offset, Vector2 size) {
    final cloudPaint = Paint()..isAntiAlias = false;
    final cloudOffset = offset * 0.3; // clouds move slower
    final px = 6.0;

    // Cloud pattern — draw a few procedural clouds
    for (var i = 0; i < 5; i++) {
      final seed = (i * 137 + 42) % 200;
      final cloudX = ((seed * 12.0 + i * 250) - (cloudOffset % (size.x * 3))) % (size.x * 3) - size.x * 0.5;
      final cloudY = 30.0 + (seed % 60);

      // Cloud is a cluster of pixel blocks
      cloudPaint.color = const Color(0xCCFFFFFF);
      // Main body
      canvas.drawRect(Rect.fromLTWH(cloudX, cloudY, px * 6, px * 2), cloudPaint);
      canvas.drawRect(Rect.fromLTWH(cloudX + px, cloudY - px, px * 4, px), cloudPaint);
      canvas.drawRect(Rect.fromLTWH(cloudX - px, cloudY + px, px * 2, px), cloudPaint);
      canvas.drawRect(Rect.fromLTWH(cloudX + px * 5, cloudY + px, px * 2, px), cloudPaint);

      // Highlight
      cloudPaint.color = const Color(0x44FFFFFF);
      canvas.drawRect(Rect.fromLTWH(cloudX + px, cloudY - px, px * 2, px), cloudPaint);
    }
  }

  /// Mid layer: hills/trees silhouettes with stepped pixel edges
  void _renderMidLayer(Canvas canvas, RegionData region, double offset) {
    final paint = Paint()..color = region.midBgColor..isAntiAlias = false;
    final pixelH = 6.0;
    final segWidth = 120.0;
    final numSegs = (size.x / segWidth).ceil() + 2;
    final startSeg = (offset / segWidth).floor();

    for (var i = 0; i <= numSegs; i++) {
      final segX = (startSeg + i) * segWidth - (offset % segWidth);
      final seed = ((startSeg + i) * 11 + 37) % 100;
      final baseY = size.y * 0.65;
      final peakY = baseY - 15 - seed * 0.4;

      // Stepped hill
      for (var py = peakY; py < size.y; py += pixelH) {
        final progress = (py - peakY) / (size.y - peakY);
        final halfW = segWidth * 0.2 + segWidth * 0.3 * progress;
        final cx = segX + segWidth * 0.5;
        canvas.drawRect(
          Rect.fromLTWH(cx - halfW, py, halfW * 2, pixelH),
          paint,
        );
      }

      // Occasional tree silhouettes on hills
      if (seed % 3 == 0) {
        final treeX = segX + segWidth * 0.3 + (seed % 40);
        final treeY = peakY + 5;
        _drawTreeSilhouette(canvas, treeX, treeY, region.midBgColor);
      }
    }
  }

  void _drawTreeSilhouette(Canvas canvas, double x, double y, Color baseColor) {
    final dark = Color.fromARGB(255,
      (baseColor.red * 0.8).round().clamp(0, 255),
      (baseColor.green * 0.8).round().clamp(0, 255),
      (baseColor.blue * 0.8).round().clamp(0, 255),
    );
    final p = Paint()..color = dark..isAntiAlias = false;
    const px = 4.0;
    // Trunk
    canvas.drawRect(Rect.fromLTWH(x, y + px * 2, px, px * 3), p);
    // Crown (triangle-ish)
    canvas.drawRect(Rect.fromLTWH(x - px, y + px, px * 3, px), p);
    canvas.drawRect(Rect.fromLTWH(x - px * 0.5, y, px * 2, px), p);
  }

  /// Near layer: grass/bushes close to ground with pixel-art grass blades
  void _renderNearLayer(Canvas canvas, RegionData region, double offset) {
    final paint = Paint()..color = region.nearBgColor..isAntiAlias = false;
    final baseY = size.y * 0.78;

    // Fill from baseY to bottom
    canvas.drawRect(Rect.fromLTWH(0, baseY, size.x, size.y - baseY), paint);

    // Pixel grass blades on top edge
    final grassPaint = Paint()..isAntiAlias = false;
    final px = 4.0;
    final numBlades = (size.x / px).ceil() + 2;
    final startBlade = (offset / px).floor();

    for (var i = 0; i <= numBlades; i++) {
      final bladeX = (startBlade + i) * px - (offset % px);
      final seed = ((startBlade + i) * 13 + 7) % 100;
      final bladeH = 4.0 + (seed % 3) * px;

      // Vary grass color slightly
      if (seed % 4 == 0) {
        final r = (region.nearBgColor.red * 0.85).round().clamp(0, 255);
        final g = (region.nearBgColor.green * 1.1).round().clamp(0, 255);
        final b = (region.nearBgColor.blue * 0.85).round().clamp(0, 255);
        grassPaint.color = Color.fromARGB(255, r, g, b);
      } else if (seed % 3 == 0) {
        final r = (region.nearBgColor.red * 0.9).round().clamp(0, 255);
        final g = (region.nearBgColor.green * 0.95).round().clamp(0, 255);
        final b = (region.nearBgColor.blue * 0.9).round().clamp(0, 255);
        grassPaint.color = Color.fromARGB(255, r, g, b);
      } else {
        grassPaint.color = region.nearBgColor;
      }

      canvas.drawRect(
        Rect.fromLTWH(bladeX, baseY - bladeH, px, bladeH),
        grassPaint,
      );
    }

    // Occasional decorative grass tufts (taller, lighter)
    final tuftPaint = Paint()..isAntiAlias = false;
    final tuftColor = Color.fromARGB(255,
      min(255, region.nearBgColor.red + 20),
      min(255, region.nearBgColor.green + 30),
      min(255, region.nearBgColor.blue + 10),
    );
    tuftPaint.color = tuftColor;

    final tuftSpacing = 40.0;
    final numTufts = (size.x / tuftSpacing).ceil() + 2;
    final startTuft = (offset / tuftSpacing).floor();
    for (var i = 0; i <= numTufts; i++) {
      final tx = (startTuft + i) * tuftSpacing - (offset % tuftSpacing);
      final seed2 = ((startTuft + i) * 23 + 11) % 100;
      if (seed2 % 3 != 0) continue;

      // Tuft: 3 tall pixel blades
      canvas.drawRect(Rect.fromLTWH(tx, baseY - 14, px, 14), tuftPaint);
      canvas.drawRect(Rect.fromLTWH(tx - px, baseY - 10, px, 10), tuftPaint);
      canvas.drawRect(Rect.fromLTWH(tx + px, baseY - 11, px, 11), tuftPaint);
    }
  }
}
