import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../game/runner_game.dart';
import '../utils/constants.dart';

class Obstacle extends PositionComponent
    with HasGameReference<RunnerGame>, CollisionCallbacks {
  Obstacle({
    required Vector2 spawnPosition,
  }) : super(
          position: spawnPosition,
          size: Vector2(24, 28),
        );

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Cleanup if behind camera
    final cameraX = game.camera.viewfinder.position.x;
    if (position.x < cameraX - GameConstants.despawnBehindDistance) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    // Rock/spike shape (triangle)
    final paint = Paint()..color = const Color(0xFF696969);

    final path = Path()
      ..moveTo(size.x / 2, 0) // top center
      ..lineTo(size.x, size.y) // bottom right
      ..lineTo(0, size.y) // bottom left
      ..close();
    canvas.drawPath(path, paint);

    // Darker accent
    final accentPaint = Paint()..color = const Color(0xFF505050);
    final accentPath = Path()
      ..moveTo(size.x / 2, 0)
      ..lineTo(size.x * 0.7, size.y)
      ..lineTo(size.x * 0.3, size.y)
      ..close();
    canvas.drawPath(accentPath, accentPaint);

    // Highlight
    final highlightPaint = Paint()
      ..color = const Color(0x30FFFFFF)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.x / 2, 2),
      Offset(size.x * 0.3, size.y * 0.6),
      highlightPaint,
    );
  }
}
