import 'dart:ui';
import 'dart:math';
import 'package:flame/components.dart';

import '../game/runner_game.dart';
import '../data/region_data.dart';
import '../utils/constants.dart';

/// A single parallax background layer that scrolls at a fraction of camera speed.
class ParallaxLayer extends PositionComponent with HasGameReference<RunnerGame> {
  final double scrollFactor;
  final int layerIndex; // 0=far, 1=mid, 2=near
  double _lastCameraX = 0;

  ParallaxLayer({
    required this.scrollFactor,
    required this.layerIndex,
  }) : super(
          position: Vector2.zero(),
          size: Vector2(GameConstants.worldWidth, GameConstants.worldHeight),
          priority: -10 + layerIndex,
        );

  @override
  void update(double dt) {
    super.update(dt);
    final cameraX = game.camera.viewfinder.position.x;
    position.x = cameraX;
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

  /// Far layer: gradient sky + sun/moon + distant mountains + clouds
  void _renderFarLayer(Canvas canvas, RegionData region, double offset) {
    final paint = Paint()..isAntiAlias = false;

    // Sky gradient (smooth-ish pixelated bands)
    final skyTop = region.skyColor;
    final skyBottom = region.farBgColor;
    const bands = 20;
    final bandH = size.y * 0.75 / bands;
    for (var i = 0; i < bands; i++) {
      final t = i / (bands - 1);
      // Ease-in curve for smoother gradient
      final et = t * t;
      final r = (skyTop.red + (skyBottom.red - skyTop.red) * et).round().clamp(0, 255);
      final g = (skyTop.green + (skyBottom.green - skyTop.green) * et).round().clamp(0, 255);
      final b = (skyTop.blue + (skyBottom.blue - skyTop.blue) * et).round().clamp(0, 255);
      paint.color = Color.fromARGB(255, r, g, b);
      canvas.drawRect(Rect.fromLTWH(0, i * bandH, size.x, bandH + 1), paint);
    }

    // Fill rest with farBgColor
    paint.color = region.farBgColor;
    canvas.drawRect(Rect.fromLTWH(0, bands * bandH, size.x, size.y), paint);

    // Sun/Moon (region-dependent)
    _drawCelestialBody(canvas, region, offset);

    // Multiple cloud layers (far = small, mid = medium)
    _drawCloudLayer(canvas, offset * 0.15, size, 0.5, 4.0, 3);
    _drawCloudLayer(canvas, offset * 0.25, size, 0.7, 5.0, 5);

    // Distant mountains (back range)
    _drawMountainRange(canvas, region.farBgColor, offset, 0.40, 0.70, 200.0, 10.0, 0.85);

    // Closer mountains (front range, darker)
    final darkerMountain = Color.fromARGB(255,
      (region.farBgColor.red * 0.75).round().clamp(0, 255),
      (region.farBgColor.green * 0.75).round().clamp(0, 255),
      (region.farBgColor.blue * 0.75).round().clamp(0, 255),
    );
    _drawMountainRange(canvas, darkerMountain, offset * 1.3, 0.45, 0.70, 140.0, 8.0, 0.9);
  }

  void _drawCelestialBody(Canvas canvas, RegionData region, double offset) {
    final paint = Paint()..isAntiAlias = false;
    final px = 4.0;

    // Position sun relative to slow scroll
    final sunX = (size.x * 0.7 - offset * 0.02) % size.x;
    final sunY = 50.0;

    if (region.id == 'volcano') {
      // Red sun for volcano
      paint.color = const Color(0xFFFF4444);
      _drawPixelCircle(canvas, sunX, sunY, 16, px, paint);
      paint.color = const Color(0x44FF2222);
      _drawPixelCircle(canvas, sunX, sunY, 24, px, paint);
    } else if (region.id == 'snowfield') {
      // Pale moon
      paint.color = const Color(0xFFE8E8F0);
      _drawPixelCircle(canvas, sunX, sunY, 14, px, paint);
      // Moon crater
      paint.color = const Color(0xFFD0D0E0);
      canvas.drawRect(Rect.fromLTWH(sunX + 2 * px, sunY - px, px * 2, px * 2), paint);
    } else {
      // Normal sun
      paint.color = const Color(0xFFFFE44D);
      _drawPixelCircle(canvas, sunX, sunY, 14, px, paint);
      // Glow
      paint.color = const Color(0x33FFDD00);
      _drawPixelCircle(canvas, sunX, sunY, 22, px, paint);
      // Rays (4 pixel lines)
      paint.color = const Color(0x44FFE44D);
      canvas.drawRect(Rect.fromLTWH(sunX - 28, sunY - px, 56, px * 2), paint);
      canvas.drawRect(Rect.fromLTWH(sunX - px, sunY - 28, px * 2, 56), paint);
    }
  }

  void _drawPixelCircle(Canvas canvas, double cx, double cy, double radius, double px, Paint paint) {
    final steps = (radius / px).ceil();
    for (var dy = -steps; dy <= steps; dy++) {
      for (var dx = -steps; dx <= steps; dx++) {
        if (dx * dx + dy * dy <= steps * steps) {
          canvas.drawRect(
            Rect.fromLTWH(cx + dx * px, cy + dy * px, px, px),
            paint,
          );
        }
      }
    }
  }

  void _drawCloudLayer(Canvas canvas, double offset, Vector2 size, double opacity, double px, int count) {
    final paint = Paint()..isAntiAlias = false;

    for (var i = 0; i < count; i++) {
      final seed = (i * 137 + 42) % 200;
      final cloudX = ((seed * 15.0 + i * 280) - (offset % (size.x * 3))) % (size.x * 3) - size.x * 0.5;
      final cloudY = 20.0 + (seed % 80);
      final variant = seed % 3;

      paint.color = Color.fromRGBO(255, 255, 255, opacity * 0.8);

      if (variant == 0) {
        // Wide flat cloud
        canvas.drawRect(Rect.fromLTWH(cloudX, cloudY, px * 8, px * 2), paint);
        canvas.drawRect(Rect.fromLTWH(cloudX + px * 2, cloudY - px, px * 4, px), paint);
        canvas.drawRect(Rect.fromLTWH(cloudX - px, cloudY + px, px * 2, px), paint);
        canvas.drawRect(Rect.fromLTWH(cloudX + px * 7, cloudY + px, px * 2, px), paint);
        // Highlight
        paint.color = Color.fromRGBO(255, 255, 255, opacity);
        canvas.drawRect(Rect.fromLTWH(cloudX + px * 2, cloudY - px, px * 2, px), paint);
        // Shadow
        paint.color = Color.fromRGBO(200, 210, 230, opacity * 0.5);
        canvas.drawRect(Rect.fromLTWH(cloudX + px, cloudY + px * 2, px * 6, px), paint);
      } else if (variant == 1) {
        // Tall puffy cloud
        canvas.drawRect(Rect.fromLTWH(cloudX, cloudY, px * 6, px * 3), paint);
        canvas.drawRect(Rect.fromLTWH(cloudX + px, cloudY - px, px * 4, px), paint);
        canvas.drawRect(Rect.fromLTWH(cloudX + px * 2, cloudY - px * 2, px * 2, px), paint);
        paint.color = Color.fromRGBO(200, 210, 230, opacity * 0.4);
        canvas.drawRect(Rect.fromLTWH(cloudX + px, cloudY + px * 2, px * 4, px), paint);
      } else {
        // Small cloud
        canvas.drawRect(Rect.fromLTWH(cloudX, cloudY, px * 4, px * 2), paint);
        canvas.drawRect(Rect.fromLTWH(cloudX + px, cloudY - px, px * 2, px), paint);
      }
    }
  }

  void _drawMountainRange(Canvas canvas, Color baseColor, double offset,
      double peakMin, double baseYFrac, double segWidth, double pixelH, double darkMult) {
    final paint = Paint()..isAntiAlias = false;
    final numSegs = (size.x / segWidth).ceil() + 2;
    final startSeg = (offset / segWidth).floor();

    final darkColor = Color.fromARGB(255,
      (baseColor.red * darkMult).round().clamp(0, 255),
      (baseColor.green * darkMult).round().clamp(0, 255),
      (baseColor.blue * darkMult).round().clamp(0, 255),
    );
    final lightColor = Color.fromARGB(255,
      min(255, baseColor.red + 15),
      min(255, baseColor.green + 15),
      min(255, baseColor.blue + 15),
    );

    for (var i = 0; i <= numSegs; i++) {
      final segX = (startSeg + i) * segWidth - (offset % segWidth);
      final seed = ((startSeg + i) * 7 + 13) % 100;
      final peakY = size.y * (peakMin + seed / 350.0);
      final baseY = size.y * baseYFrac;

      // Draw stepped mountain
      for (var py = peakY; py < baseY; py += pixelH) {
        final progress = (py - peakY) / (baseY - peakY);
        final halfW = segWidth * 0.12 + segWidth * 0.38 * progress;
        final cx = segX + segWidth * 0.5;

        // Main body
        paint.color = baseColor;
        canvas.drawRect(Rect.fromLTWH(cx - halfW, py, halfW * 2, pixelH), paint);

        // Left highlight (sun side)
        if (py < peakY + (baseY - peakY) * 0.5) {
          paint.color = lightColor;
          canvas.drawRect(Rect.fromLTWH(cx - halfW, py, pixelH * 2, pixelH), paint);
        }

        // Right shadow
        paint.color = darkColor;
        canvas.drawRect(Rect.fromLTWH(cx + halfW - pixelH * 2, py, pixelH * 2, pixelH), paint);
      }

      // Snow cap on tall mountains (meadow/snowfield only)
      if (seed % 2 == 0 && (peakY < size.y * 0.45)) {
        paint.color = const Color(0xDDFFFFFF);
        final capH = (baseY - peakY) * 0.15;
        for (var py = peakY; py < peakY + capH; py += pixelH) {
          final progress = (py - peakY) / (baseY - peakY);
          final halfW = segWidth * 0.12 + segWidth * 0.38 * progress;
          final cx = segX + segWidth * 0.5;
          canvas.drawRect(Rect.fromLTWH(cx - halfW, py, halfW * 2, pixelH), paint);
        }
      }
    }
  }

  /// Mid layer: rolling hills with trees and detail
  void _renderMidLayer(Canvas canvas, RegionData region, double offset) {
    final paint = Paint()..isAntiAlias = false;
    final pixelH = 6.0;

    // Draw two hill ranges for depth
    _drawHillRange(canvas, region.midBgColor, offset, 0.62, 140.0, pixelH, true, region);

    final darkerHill = Color.fromARGB(255,
      (region.midBgColor.red * 0.85).round().clamp(0, 255),
      (region.midBgColor.green * 0.85).round().clamp(0, 255),
      (region.midBgColor.blue * 0.85).round().clamp(0, 255),
    );
    _drawHillRange(canvas, darkerHill, offset * 1.2, 0.67, 100.0, pixelH, false, region);
  }

  void _drawHillRange(Canvas canvas, Color color, double offset,
      double baseYFrac, double segWidth, double pixelH, bool drawTrees, RegionData region) {
    final paint = Paint()..color = color..isAntiAlias = false;
    final numSegs = (size.x / segWidth).ceil() + 2;
    final startSeg = (offset / segWidth).floor();

    for (var i = 0; i <= numSegs; i++) {
      final segX = (startSeg + i) * segWidth - (offset % segWidth);
      final seed = ((startSeg + i) * 11 + 37) % 100;
      final baseY = size.y * baseYFrac;
      final peakY = baseY - 20 - seed * 0.5;

      // Stepped hill with sine-like curve
      for (var py = peakY; py < size.y; py += pixelH) {
        final progress = (py - peakY) / (size.y - peakY);
        final halfW = segWidth * 0.15 + segWidth * 0.35 * progress;
        final cx = segX + segWidth * 0.5;
        paint.color = color;
        canvas.drawRect(Rect.fromLTWH(cx - halfW, py, halfW * 2, pixelH), paint);
      }

      // Trees on hills
      if (drawTrees) {
        if (seed % 3 == 0) {
          _drawTree(canvas, segX + segWidth * 0.3 + (seed % 30), peakY + 5, region);
        }
        if (seed % 4 == 0) {
          _drawTree(canvas, segX + segWidth * 0.6 + (seed % 20), peakY + 10, region);
        }
        // Bushes
        if (seed % 2 == 0) {
          _drawBush(canvas, segX + segWidth * 0.5 + (seed % 25), peakY + 15, color);
        }
      }
    }
  }

  void _drawTree(Canvas canvas, double x, double y, RegionData region) {
    final paint = Paint()..isAntiAlias = false;
    const px = 4.0;

    // Trunk
    final trunkColor = Color.fromARGB(255,
      (region.midBgColor.red * 0.6).round().clamp(0, 255),
      (region.midBgColor.green * 0.5).round().clamp(0, 255),
      (region.midBgColor.blue * 0.5).round().clamp(0, 255),
    );
    paint.color = trunkColor;
    canvas.drawRect(Rect.fromLTWH(x, y + px * 3, px, px * 4), paint);

    // Canopy (layered triangles)
    final canopyColor = Color.fromARGB(255,
      (region.midBgColor.red * 0.75).round().clamp(0, 255),
      min(255, (region.midBgColor.green * 0.9).round()),
      (region.midBgColor.blue * 0.75).round().clamp(0, 255),
    );
    final canopyLight = Color.fromARGB(255,
      (region.midBgColor.red * 0.85).round().clamp(0, 255),
      min(255, (region.midBgColor.green * 1.05).round()),
      (region.midBgColor.blue * 0.85).round().clamp(0, 255),
    );

    // Bottom layer
    paint.color = canopyColor;
    canvas.drawRect(Rect.fromLTWH(x - px * 2, y + px * 2, px * 5, px), paint);
    canvas.drawRect(Rect.fromLTWH(x - px * 1.5, y + px, px * 4, px), paint);
    // Top layer
    paint.color = canopyLight;
    canvas.drawRect(Rect.fromLTWH(x - px, y, px * 3, px), paint);
    canvas.drawRect(Rect.fromLTWH(x - px * 0.5, y - px, px * 2, px), paint);
  }

  void _drawBush(Canvas canvas, double x, double y, Color hillColor) {
    final paint = Paint()..isAntiAlias = false;
    const px = 4.0;

    final bushColor = Color.fromARGB(255,
      (hillColor.red * 0.8).round().clamp(0, 255),
      min(255, (hillColor.green * 1.05).round()),
      (hillColor.blue * 0.8).round().clamp(0, 255),
    );
    paint.color = bushColor;
    canvas.drawRect(Rect.fromLTWH(x - px, y, px * 3, px * 2), paint);
    canvas.drawRect(Rect.fromLTWH(x - px * 0.5, y - px, px * 2, px), paint);
  }

  /// Near layer: foreground grass and decorations
  void _renderNearLayer(Canvas canvas, RegionData region, double offset) {
    final paint = Paint()..isAntiAlias = false;
    final baseY = size.y * 0.78;
    final px = 4.0;

    // Fill from baseY to ground
    paint.color = region.nearBgColor;
    canvas.drawRect(Rect.fromLTWH(0, baseY, size.x, size.y - baseY), paint);

    // Top edge highlight
    final nearLight = Color.fromARGB(255,
      min(255, region.nearBgColor.red + 20),
      min(255, region.nearBgColor.green + 30),
      min(255, region.nearBgColor.blue + 10),
    );
    paint.color = nearLight;
    canvas.drawRect(Rect.fromLTWH(0, baseY, size.x, 2), paint);

    // Detailed grass blades on top edge
    final grassDark = Color.fromARGB(255,
      (region.nearBgColor.red * 0.85).round().clamp(0, 255),
      (region.nearBgColor.green * 0.9).round().clamp(0, 255),
      (region.nearBgColor.blue * 0.85).round().clamp(0, 255),
    );

    final numBlades = (size.x / px).ceil() + 2;
    final startBlade = (offset / px).floor();

    for (var i = 0; i <= numBlades; i++) {
      final bladeX = (startBlade + i) * px - (offset % px);
      final seed = ((startBlade + i) * 13 + 7) % 100;
      final bladeH = 6.0 + (seed % 4) * px;

      // Grass color variation
      if (seed % 5 == 0) {
        paint.color = nearLight;
      } else if (seed % 3 == 0) {
        paint.color = grassDark;
      } else {
        paint.color = region.nearBgColor;
      }

      canvas.drawRect(Rect.fromLTWH(bladeX, baseY - bladeH, px, bladeH), paint);
    }

    // Tall grass tufts
    final tuftColor = Color.fromARGB(255,
      min(255, region.nearBgColor.red + 25),
      min(255, region.nearBgColor.green + 35),
      min(255, region.nearBgColor.blue + 15),
    );
    final tuftSpacing = 30.0;
    final numTufts = (size.x / tuftSpacing).ceil() + 2;
    final startTuft = (offset / tuftSpacing).floor();
    for (var i = 0; i <= numTufts; i++) {
      final tx = (startTuft + i) * tuftSpacing - (offset % tuftSpacing);
      final seed2 = ((startTuft + i) * 23 + 11) % 100;
      if (seed2 % 3 != 0) continue;

      paint.color = tuftColor;
      canvas.drawRect(Rect.fromLTWH(tx, baseY - 16, px, 16), paint);
      canvas.drawRect(Rect.fromLTWH(tx - px, baseY - 12, px, 12), paint);
      canvas.drawRect(Rect.fromLTWH(tx + px, baseY - 13, px, 13), paint);

      // Occasional flower on tuft
      if (seed2 % 7 == 0) {
        final flowerColors = [
          const Color(0xFFFF6B6B),
          const Color(0xFFFFD93D),
          const Color(0xFFFF9FF3),
        ];
        paint.color = flowerColors[seed2 % flowerColors.length];
        canvas.drawRect(Rect.fromLTWH(tx, baseY - 18, px, px), paint);
      }
    }

    // Decorative elements per region
    _drawRegionDecorations(canvas, region, offset, baseY);
  }

  void _drawRegionDecorations(Canvas canvas, RegionData region, double offset, double baseY) {
    final paint = Paint()..isAntiAlias = false;
    final px = 4.0;
    final spacing = 100.0;
    final numDecos = (size.x / spacing).ceil() + 2;
    final startDeco = (offset / spacing).floor();

    for (var i = 0; i <= numDecos; i++) {
      final dx = (startDeco + i) * spacing - (offset % spacing);
      final seed = ((startDeco + i) * 41 + 17) % 100;
      if (seed % 5 != 0) continue;

      switch (region.id) {
        case 'meadow':
          // Butterfly or dandelion
          if (seed % 2 == 0) {
            paint.color = const Color(0xFFFFE082);
            canvas.drawRect(Rect.fromLTWH(dx, baseY - 24, px, px), paint);
            canvas.drawRect(Rect.fromLTWH(dx - px, baseY - 22, px, px), paint);
            canvas.drawRect(Rect.fromLTWH(dx + px, baseY - 22, px, px), paint);
            // Stem
            paint.color = const Color(0xFF66BB6A);
            canvas.drawRect(Rect.fromLTWH(dx, baseY - 20, px, 20), paint);
          }
          break;
        case 'forest':
          // Mushroom
          paint.color = const Color(0xFFE57373);
          canvas.drawRect(Rect.fromLTWH(dx - px, baseY - 10, px * 3, px), paint);
          canvas.drawRect(Rect.fromLTWH(dx, baseY - 14, px, px), paint);
          paint.color = const Color(0xFFF5E6D0);
          canvas.drawRect(Rect.fromLTWH(dx, baseY - 6, px, px * 2), paint);
          // White spots
          paint.color = const Color(0xFFFFFFFF);
          canvas.drawRect(Rect.fromLTWH(dx - px, baseY - 10, px * 0.5, px * 0.5), paint);
          break;
        case 'desert':
          // Cactus
          paint.color = const Color(0xFF4CAF50);
          canvas.drawRect(Rect.fromLTWH(dx, baseY - 20, px, 20), paint);
          canvas.drawRect(Rect.fromLTWH(dx - px * 2, baseY - 14, px * 2, px), paint);
          canvas.drawRect(Rect.fromLTWH(dx - px * 2, baseY - 18, px, px * 4), paint);
          canvas.drawRect(Rect.fromLTWH(dx + px, baseY - 10, px * 2, px), paint);
          canvas.drawRect(Rect.fromLTWH(dx + px * 2, baseY - 14, px, px * 4), paint);
          break;
        case 'snowfield':
          // Snowman
          paint.color = const Color(0xFFFFFFFF);
          _drawPixelCircle(canvas, dx, baseY - 6, 6, px * 0.5, paint);
          _drawPixelCircle(canvas, dx, baseY - 14, 4, px * 0.5, paint);
          paint.color = const Color(0xFF333333);
          canvas.drawRect(Rect.fromLTWH(dx - 1, baseY - 15, 2, 2), paint);
          break;
        case 'volcano':
          // Lava crack
          paint.color = const Color(0xFFFF6600);
          canvas.drawRect(Rect.fromLTWH(dx, baseY - 2, px * 3, 2), paint);
          paint.color = const Color(0xFFFF4400);
          canvas.drawRect(Rect.fromLTWH(dx + px, baseY - 4, px, 2), paint);
          break;
      }
    }
  }
}
