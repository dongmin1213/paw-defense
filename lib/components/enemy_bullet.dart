import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/boss_rush_game.dart';
import '../components/player.dart';
import '../utils/constants.dart';

enum EnemyBulletPattern {
  straight,
  sine,
  aimed,
  falling,
}

class EnemyBullet extends CircleComponent with HasGameRef<BossRushGame>, CollisionCallbacks {
  final Vector2 velocity;
  final EnemyBulletPattern pattern;
  double _lifetime = 0;
  final double _initialY;

  EnemyBullet({
    required Vector2 startPosition,
    required this.velocity,
    this.pattern = EnemyBulletPattern.straight,
    double radius = 5,
  })  : _initialY = startPosition.y,
        super(
          position: startPosition,
          radius: radius,
          paint: Paint()..color = GameConstants.enemyBulletColor,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    _lifetime += dt;

    switch (pattern) {
      case EnemyBulletPattern.straight:
        position += velocity * dt;
        break;
      case EnemyBulletPattern.sine:
        position.x += velocity.x * dt;
        position.y = _initialY + sin(_lifetime * 5) * 40;
        break;
      case EnemyBulletPattern.aimed:
        position += velocity * dt;
        break;
      case EnemyBulletPattern.falling:
        position.x += velocity.x * dt;
        position.y += velocity.y * dt + (GameConstants.gravity * 0.3 * _lifetime * dt);
        break;
    }

    // Remove if out of bounds
    if (position.x < -50 ||
        position.x > GameConstants.worldWidth + 50 ||
        position.y < -50 ||
        position.y > GameConstants.worldHeight + 50) {
      removeFromParent();
    }

    // Max lifetime
    if (_lifetime > 8) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Player) {
      gameRef.onPlayerHit();
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    // Glow effect
    final glowPaint = Paint()
      ..color = GameConstants.enemyBulletColor.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset.zero, radius + 3, glowPaint);
    super.render(canvas);
  }
}
