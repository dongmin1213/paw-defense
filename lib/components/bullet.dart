import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/boss_rush_game.dart';
import '../bosses/boss_base.dart';
import '../utils/constants.dart';

class Bullet extends RectangleComponent with HasGameRef<BossRushGame>, CollisionCallbacks {
  final int direction;
  final bool isSpecial;
  final double damage;

  Bullet({
    required this.direction,
    required Vector2 startPosition,
    this.isSpecial = false,
  })  : damage = isSpecial ? GameConstants.specialDamage : GameConstants.bulletDamage,
        super(
          position: startPosition,
          size: isSpecial ? Vector2(30, 16) : Vector2(12, 6),
          paint: Paint()
            ..color = isSpecial
                ? Colors.orangeAccent
                : GameConstants.bulletColor,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x += direction * GameConstants.bulletSpeed * dt;

    // Remove if out of bounds
    if (position.x < -50 || position.x > GameConstants.worldWidth + 50) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is BossBase) {
      other.takeDamage(damage);
      gameRef.addSpecialGauge(GameConstants.specialGaugePerHit);
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (isSpecial) {
      // Special attack - glowing effect
      final glowPaint = Paint()
        ..color = Colors.orange.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawRect(Rect.fromLTWH(-4, -4, size.x + 8, size.y + 8), glowPaint);
    }
    super.render(canvas);
  }
}
