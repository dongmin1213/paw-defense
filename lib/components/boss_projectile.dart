import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../game/runner_game.dart';
import '../utils/constants.dart';
import 'runner_player.dart';

/// Boss projectile that the player must dodge
class BossProjectile extends PositionComponent
    with HasGameReference<RunnerGame>, CollisionCallbacks {
  final double speed;
  final double damage;
  final Color color;
  final ProjectilePattern pattern;
  double _timer = 0;
  final double _startY;

  BossProjectile({
    required Vector2 spawnPosition,
    this.speed = -250,
    this.damage = 1,
    required this.color,
    this.pattern = ProjectilePattern.straight,
  })  : _startY = spawnPosition.y,
        super(
          position: spawnPosition,
          size: Vector2(10, 10),
          priority: 8,
        );

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
    position.x += speed * dt;

    switch (pattern) {
      case ProjectilePattern.straight:
        break;
      case ProjectilePattern.sine:
        position.y = _startY + sin(_timer * 6) * 30;
        break;
      case ProjectilePattern.falling:
        position.y += 150 * dt;
        break;
    }

    // Despawn
    final cameraX = game.camera.viewfinder.position.x;
    if (position.x < cameraX - 50 ||
        position.x > cameraX + GameConstants.worldWidth + 50 ||
        position.y > GameConstants.groundY + 20) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is RunnerPlayer) {
      other.applySlowdown();
      game.gameFeel.onObstacleHit();
      game.soundManager.playObstacleHit();
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final t = _timer * 4;
    final glow = (sin(t) * 0.3 + 0.7).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = color.withValues(alpha: glow)
      ..isAntiAlias = false;

    // Core
    canvas.drawRect(Rect.fromLTWH(2, 2, 6, 6), paint);

    // Trail
    final trail = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..isAntiAlias = false;
    canvas.drawRect(Rect.fromLTWH(7, 3, 4, 4), trail);
    canvas.drawRect(Rect.fromLTWH(10, 4, 3, 2), trail);
  }
}

enum ProjectilePattern { straight, sine, falling }
