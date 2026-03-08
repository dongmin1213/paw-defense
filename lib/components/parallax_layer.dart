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

  /// Far layer: gradient sky + distant shapes (mountains/clouds)
  void _renderFarLayer(Canvas canvas, RegionData region, double offset) {
    // Sky gradient
    final skyPaint = Paint()
      ..shader = Gradient.linear(
        const Offset(0, 0),
        Offset(0, size.y * 0.7),
        [region.skyColor, region.farBgColor],
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y * 0.7), skyPaint);

    // Distant mountains/hills
    final mountainPaint = Paint()..color = region.farBgColor;
    final path = Path();
    path.moveTo(0, size.y * 0.7);

    final segWidth = 200.0;
    final numSegs = (size.x / segWidth).ceil() + 2;
    final startSeg = (offset / segWidth).floor();

    for (var i = 0; i <= numSegs; i++) {
      final segX = (startSeg + i) * segWidth - (offset % segWidth);
      final seed = ((startSeg + i) * 7 + 13) % 100;
      final h = size.y * (0.45 + seed / 200.0);
      path.lineTo(segX, h);
      path.lineTo(segX + segWidth * 0.5, h - 20 - seed * 0.3);
      path.lineTo(segX + segWidth, h + 5);
    }
    path.lineTo(size.x, size.y * 0.7);
    path.close();
    canvas.drawPath(path, mountainPaint);
  }

  /// Mid layer: hills/trees silhouettes
  void _renderMidLayer(Canvas canvas, RegionData region, double offset) {
    final paint = Paint()..color = region.midBgColor;
    final path = Path();
    path.moveTo(0, size.y * 0.75);

    final segWidth = 120.0;
    final numSegs = (size.x / segWidth).ceil() + 2;
    final startSeg = (offset / segWidth).floor();

    for (var i = 0; i <= numSegs; i++) {
      final segX = (startSeg + i) * segWidth - (offset % segWidth);
      final seed = ((startSeg + i) * 11 + 37) % 100;
      final baseY = size.y * 0.65;

      // Tree/hill shape
      final h = 15 + seed * 0.4;
      path.lineTo(segX, baseY);
      path.lineTo(segX + segWidth * 0.3, baseY - h);
      path.lineTo(segX + segWidth * 0.5, baseY - h + 5);
      path.lineTo(segX + segWidth * 0.7, baseY - h - 3);
      path.lineTo(segX + segWidth, baseY + 3);
    }
    path.lineTo(size.x, size.y);
    path.lineTo(0, size.y);
    path.close();
    canvas.drawPath(path, paint);
  }

  /// Near layer: bushes/rocks close to ground
  void _renderNearLayer(Canvas canvas, RegionData region, double offset) {
    final paint = Paint()..color = region.nearBgColor;
    final path = Path();
    final baseY = size.y * 0.78;
    path.moveTo(0, baseY);

    final segWidth = 80.0;
    final numSegs = (size.x / segWidth).ceil() + 2;
    final startSeg = (offset / segWidth).floor();

    for (var i = 0; i <= numSegs; i++) {
      final segX = (startSeg + i) * segWidth - (offset % segWidth);
      final seed = ((startSeg + i) * 17 + 53) % 100;
      final h = 8 + seed * 0.2;

      path.lineTo(segX, baseY);
      path.quadraticBezierTo(
        segX + segWidth * 0.5,
        baseY - h,
        segX + segWidth,
        baseY + (seed % 5 - 2),
      );
    }
    path.lineTo(size.x, size.y);
    path.lineTo(0, size.y);
    path.close();
    canvas.drawPath(path, paint);
  }
}
