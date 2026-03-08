import 'dart:ui';
import 'package:flame/components.dart';

import '../game/runner_game.dart';
import '../data/region_data.dart';
import '../utils/constants.dart';

class GroundSegment extends PositionComponent with HasGameReference<RunnerGame> {
  final RegionData region;

  GroundSegment({
    required double startX,
    required this.region,
  }) : super(
          position: Vector2(startX, GameConstants.groundY),
          size: Vector2(GameConstants.groundSegmentWidth, GameConstants.groundHeight),
        );

  @override
  void update(double dt) {
    super.update(dt);

    // Recycle: if segment is far behind camera, move it ahead
    final cameraX = game.camera.viewfinder.position.x;
    if (position.x + size.x < cameraX - GameConstants.despawnBehindDistance) {
      // Find the rightmost ground segment position
      final aheadX = cameraX + GameConstants.worldWidth + GameConstants.spawnAheadDistance;
      position.x = aheadX;
    }
  }

  @override
  void render(Canvas canvas) {
    // Main ground fill
    final groundPaint = Paint()..color = region.groundColor;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      groundPaint,
    );

    // Top grass line
    final grassPaint = Paint()
      ..color = region.groundAccentColor
      ..strokeWidth = 3;
    canvas.drawLine(
      const Offset(0, 1),
      Offset(size.x, 1),
      grassPaint,
    );

    // Texture lines
    final texturePaint = Paint()
      ..color = region.groundAccentColor.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    for (var i = 0; i < 3; i++) {
      final y = 15.0 + i * 25.0;
      canvas.drawLine(
        Offset(10 + i * 20.0, y),
        Offset(size.x - 10 - i * 15.0, y),
        texturePaint,
      );
    }
  }
}
