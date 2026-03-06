import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/boss_rush_game.dart';
import '../bosses/boss_base.dart';
import '../utils/constants.dart';
import 'enemy.dart';

/// Knight melee slash - short range wide arc
class MeleeSlash extends PositionComponent
    with HasGameReference<BossRushGame>, CollisionCallbacks {
  final double damage;
  final int direction;
  double _lifetime = 0.15;

  MeleeSlash({
    required this.damage,
    required this.direction,
    required Vector2 startPosition,
  }) : super(
          position: startPosition,
          size: Vector2(50, 40),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    _lifetime -= dt;
    if (_lifetime <= 0) removeFromParent();
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is BossBase) {
      other.takeDamage(damage);
      game.addSpecialGauge(GameConstants.specialGaugePerHit);
    } else if (other is Enemy) {
      other.takeDamage(damage);
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: _lifetime / 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    // Arc slash effect
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final startAngle = direction > 0 ? -0.5 : 2.0;
    canvas.drawArc(rect, startAngle, 1.2, false, paint);
  }
}

/// Assassin dagger - fast short range
class DaggerStrike extends PositionComponent
    with HasGameReference<BossRushGame>, CollisionCallbacks {
  final double damage;
  final int direction;
  double _lifetime = 0.08;

  DaggerStrike({
    required this.damage,
    required this.direction,
    required Vector2 startPosition,
  }) : super(
          position: startPosition,
          size: Vector2(30, 20),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x += direction * 600 * dt;
    _lifetime -= dt;
    if (_lifetime <= 0) removeFromParent();
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is BossBase) {
      other.takeDamage(damage);
      game.addSpecialGauge(GameConstants.specialGaugePerHit * 0.5);
    } else if (other is Enemy) {
      other.takeDamage(damage);
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.purple.withValues(alpha: 0.8);
    // Dagger shape
    final path = Path()
      ..moveTo(0, size.y / 2)
      ..lineTo(size.x * 0.7, 0)
      ..lineTo(size.x, size.y / 2)
      ..lineTo(size.x * 0.7, size.y)
      ..close();
    canvas.drawPath(path, paint);
  }
}

/// Arrow projectile for Archer
class Arrow extends PositionComponent
    with HasGameReference<BossRushGame>, CollisionCallbacks {
  final double damage;
  final int direction;
  final bool isCharged;
  bool _hasHit = false;

  Arrow({
    required this.damage,
    required this.direction,
    required Vector2 startPosition,
    this.isCharged = false,
  }) : super(
          position: startPosition,
          size: isCharged ? Vector2(20, 8) : Vector2(14, 4),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x += direction * (isCharged ? 500 : 380) * dt;
    if (position.x < -50 || position.x > GameConstants.worldWidth + 50) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is BossBase && !_hasHit) {
      _hasHit = true;
      other.takeDamage(damage);
      game.addSpecialGauge(GameConstants.specialGaugePerHit);
      if (!isCharged) removeFromParent();
    } else if (other is Enemy) {
      other.takeDamage(damage);
      if (!isCharged) removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final color = isCharged ? Colors.greenAccent : Colors.green;
    final paint = Paint()..color = color;

    // Arrow shaft
    canvas.drawRect(Rect.fromLTWH(0, size.y * 0.3, size.x * 0.8, size.y * 0.4), paint);

    // Arrow head
    final headPaint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.x * 0.7, 0)
      ..lineTo(size.x, size.y / 2)
      ..lineTo(size.x * 0.7, size.y)
      ..close();
    canvas.drawPath(path, headPaint);

    if (isCharged) {
      final glow = Paint()
        ..color = Colors.greenAccent.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawRect(Rect.fromLTWH(-3, -3, size.x + 6, size.y + 6), glow);
    }
  }
}

/// Magic bolt for Mage - piercing
class MagicBolt extends PositionComponent
    with HasGameReference<BossRushGame>, CollisionCallbacks {
  final double damage;
  final int direction;
  final bool isFire; // true = fire, false = ice
  final Set<int> _hitBosses = {};

  MagicBolt({
    required this.damage,
    required this.direction,
    required Vector2 startPosition,
    this.isFire = true,
  }) : super(
          position: startPosition,
          size: Vector2(16, 16),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x += direction * 350 * dt;
    if (position.x < -50 || position.x > GameConstants.worldWidth + 50) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is BossBase && !_hitBosses.contains(other.hashCode)) {
      _hitBosses.add(other.hashCode);
      other.takeDamage(damage);
      game.addSpecialGauge(GameConstants.specialGaugePerHit);
    } else if (other is Enemy) {
      other.takeDamage(damage);
    }
  }

  @override
  void render(Canvas canvas) {
    final color = isFire ? Colors.orange : Colors.cyanAccent;
    final paint = Paint()..color = color;

    // Magic orb
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);

    // Glow
    final glow = Paint()
      ..color = (isFire ? Colors.orange : Colors.cyan).withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2 + 3, glow);
  }
}

/// Cannonball for Gunner - explosive
class Cannonball extends PositionComponent
    with HasGameReference<BossRushGame>, CollisionCallbacks {
  final double damage;
  final int direction;

  Cannonball({
    required this.damage,
    required this.direction,
    required Vector2 startPosition,
  }) : super(
          position: startPosition,
          size: Vector2(14, 14),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x += direction * 300 * dt;
    if (position.x < -50 || position.x > GameConstants.worldWidth + 50) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is BossBase) {
      other.takeDamage(damage);
      game.addSpecialGauge(GameConstants.specialGaugePerHit);
      game.world.add(Explosion(

        center: position + size / 2,
        damage: damage * 0.5,
      ));
      removeFromParent();
    } else if (other is Enemy) {
      other.takeDamage(damage);
      game.world.add(Explosion(
        center: position + size / 2,
        damage: damage * 0.5,
      ));
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.grey.shade800;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);

    // Fuse spark
    final spark = Paint()..color = Colors.orange;
    canvas.drawCircle(Offset(size.x / 2, 0), 2, spark);
  }
}

/// Explosion AoE for Gunner cannonball
class Explosion extends PositionComponent
    with HasGameReference<BossRushGame>, CollisionCallbacks {
  final double damage;
  double _lifetime = 0.2;
  bool _hasDamaged = false;

  Explosion({
    required Vector2 center,
    required this.damage,
  }) : super(
          position: center - Vector2(30, 30),
          size: Vector2(60, 60),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    _lifetime -= dt;
    if (_lifetime <= 0) removeFromParent();
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (!_hasDamaged) {
      if (other is BossBase) {
        _hasDamaged = true;
        other.takeDamage(damage);
      } else if (other is Enemy) {
        _hasDamaged = true;
        other.takeDamage(damage);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final t = _lifetime / 0.2;
    final radius = 30.0 * (1.0 - t * 0.3);

    final paint = Paint()
      ..color = Colors.orange.withValues(alpha: t * 0.7);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), radius, paint);

    final inner = Paint()
      ..color = Colors.yellow.withValues(alpha: t * 0.5);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), radius * 0.5, inner);
  }
}

/// Arrow Rain - Archer special attack
class ArrowRain extends PositionComponent with HasGameReference<BossRushGame> {
  double _timer = 0;
  final double _duration = 1.5;
  int _wavesFired = 0;
  final double damage;
  final Random _rng = Random();

  ArrowRain({required this.damage}) : super();

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;

    // Fire arrows from sky every 0.15 seconds
    if (_timer > _wavesFired * 0.15) {
      _wavesFired++;
      final x = _rng.nextDouble() * GameConstants.worldWidth;
      game.world.add(Arrow(
        damage: damage * 0.4,
        direction: 0,
        startPosition: Vector2(x, -20),
        isCharged: false,
      )..size = Vector2(4, 14));
      // These arrows fall instead
      game.world.add(_FallingArrow(
        damage: damage * 0.4,
        startPosition: Vector2(x, -20),
      ));
    }

    if (_timer >= _duration) removeFromParent();
  }
}

class _FallingArrow extends PositionComponent
    with HasGameReference<BossRushGame>, CollisionCallbacks {
  final double damage;
  bool _hasHit = false;

  _FallingArrow({
    required this.damage,
    required Vector2 startPosition,
  }) : super(position: startPosition, size: Vector2(4, 14));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += 400 * dt;
    if (position.y > GameConstants.groundY) removeFromParent();
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is BossBase && !_hasHit) {
      _hasHit = true;
      other.takeDamage(damage);
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.greenAccent;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);
    // Arrow tip
    final path = Path()
      ..moveTo(0, size.y)
      ..lineTo(size.x / 2, size.y + 4)
      ..lineTo(size.x, size.y)
      ..close();
    canvas.drawPath(path, paint);
  }
}

/// Meteor - Mage special attack
class Meteor extends PositionComponent
    with HasGameReference<BossRushGame>, CollisionCallbacks {
  final double damage;
  double _lifetime = 0.5;
  bool _hasDamaged = false;

  Meteor({
    required this.damage,
    required Vector2 center,
  }) : super(
          position: center - Vector2(50, 50),
          size: Vector2(100, 100),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    _lifetime -= dt;
    if (_lifetime <= 0) removeFromParent();
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is BossBase && !_hasDamaged) {
      _hasDamaged = true;
      other.takeDamage(damage);
    }
  }

  @override
  void render(Canvas canvas) {
    final t = _lifetime / 0.5;
    final radius = 50.0 * (1.2 - t * 0.3);

    // Outer fire
    final firePaint = Paint()
      ..color = Colors.deepOrange.withValues(alpha: t * 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), radius, firePaint);

    // Inner core
    final core = Paint()
      ..color = Colors.yellow.withValues(alpha: t * 0.8);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), radius * 0.4, core);
  }
}
