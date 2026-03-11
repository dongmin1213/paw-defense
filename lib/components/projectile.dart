import 'dart:math' show pi;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../game/defense_game.dart';
import 'defense_enemy.dart';

/// A projectile fired by a [DefenseUnit] toward an enemy.
/// Moves in a straight line, deals damage on collision, then is removed
/// (unless piercing, in which case it continues through enemies).
class Projectile extends PositionComponent
    with HasGameReference<DefenseGame>, CollisionCallbacks {
  final Vector2 velocity;
  final double damage;
  final bool isPiercing;
  final bool isSplash;
  final double splashRadius;
  final String ownerTypeId;
  final bool _isSplit; // true if this is a child split projectile (prevents recursion)

  double _lifeTime = 0;
  static const double maxLifeTime = 3.0;

  /// Track already-hit enemies to avoid double damage on piercing projectiles.
  final Set<DefenseEnemy> _hitEnemies = {};

  Projectile({
    required Vector2 spawnPosition,
    required this.velocity,
    required this.damage,
    this.isPiercing = false,
    this.isSplash = false,
    this.splashRadius = 0,
    this.ownerTypeId = '',
    bool isSplit = false,
  }) : _isSplit = isSplit, super(
          position: spawnPosition,
          size: Vector2(6, 6),
          anchor: Anchor.center,
          priority: 14,
        );

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(isSolid: true));
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move along velocity
    position.add(velocity * dt);

    _lifeTime += dt;

    // Remove if off screen or exceeded lifetime
    if (_lifeTime >= maxLifeTime ||
        position.x < -20 ||
        position.x > 420 ||
        position.y < -20 ||
        position.y > 720) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);

    if (other is DefenseEnemy && !other.isDead) {
      if (_hitEnemies.contains(other)) return;
      _hitEnemies.add(other);

      other.takeDamage(damage, sourcePosition: position.clone());

      // Hit impact particle
      game.particleEffect.spawnProjectileHit(
        other.position.x, other.position.y, _projectileColor);

      if (isSplash && splashRadius > 0) {
        _applySplashDamage(other.position);
      }

      // Relic: split shot — spawn 2 child projectiles at ±45°
      if (!_isSplit && game.relicManager.hasSplitShot) {
        _spawnSplitProjectiles(other.position);
      }

      // Relic: elemental — apply random elemental effect
      if (game.relicManager.hasElemental) {
        _applyElementalEffect(other);
      }

      if (!isPiercing) {
        removeFromParent();
      }
    }
  }

  /// Split shot: spawn 2 child projectiles at ±45 degrees.
  void _spawnSplitProjectiles(Vector2 impactPos) {
    final speed = velocity.length * 0.7;
    final baseAngle = velocity.screenAngle();
    const splitAngle = pi / 4; // 45 degrees

    for (final angleDelta in [-splitAngle, splitAngle]) {
      final angle = baseAngle + angleDelta;
      final dir = Vector2(0, -1)..rotate(angle);
      game.world.add(Projectile(
        spawnPosition: impactPos.clone(),
        velocity: dir * speed,
        damage: damage * 0.5,
        isPiercing: false,
        isSplash: false,
        ownerTypeId: ownerTypeId,
        isSplit: true,
      ));
    }
  }

  /// Elemental: apply random fire/ice/poison effect.
  void _applyElementalEffect(DefenseEnemy enemy) {
    final roll = DateTime.now().microsecond % 3;
    switch (roll) {
      case 0: // Fire: 30% DoT for 3 seconds
        enemy.applyDot(damage * 0.30, 3.0, 'fire');
        break;
      case 1: // Ice: 40% slow for 2 seconds
        enemy.applySlow(0.40, 2.0);
        break;
      case 2: // Poison: 15% DoT for 5 seconds
        enemy.applyDot(damage * 0.15, 5.0, 'poison');
        break;
    }
  }

  /// Deal reduced splash damage to enemies near the impact point.
  void _applySplashDamage(Vector2 impactPos) {
    for (final enemy in game.livingEnemies) {
      if (_hitEnemies.contains(enemy)) continue;
      final dist = impactPos.distanceTo(enemy.position);
      if (dist <= splashRadius) {
        // Damage falls off with distance
        final falloff = 1.0 - (dist / splashRadius);
        final splashDmg = damage * 0.5 * falloff;
        enemy.takeDamage(splashDmg, sourcePosition: impactPos);
        _hitEnemies.add(enemy);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..isAntiAlias = false
      ..color = _projectileColor;

    // Simple pixel-art projectile: a small square with a bright core
    canvas.drawRect(
      Rect.fromLTWH(1, 1, size.x - 2, size.y - 2),
      paint,
    );

    // Bright core pixel
    final corePaint = Paint()
      ..isAntiAlias = false
      ..color = const Color(0xFFFFFFFF);
    canvas.drawRect(
      Rect.fromLTWH(2, 2, 2, 2),
      corePaint,
    );
  }

  Color get _projectileColor {
    if (isPiercing) return const Color(0xFFE040FB); // purple for piercing
    if (isSplash) return const Color(0xFFFF6600); // orange for splash
    return const Color(0xFFFFD700); // gold default
  }
}
