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
  }) : super(
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

      if (isSplash && splashRadius > 0) {
        _applySplashDamage(other.position);
      }

      if (!isPiercing) {
        removeFromParent();
      }
    }
  }

  /// Deal reduced splash damage to enemies near the impact point.
  void _applySplashDamage(Vector2 impactPos) {
    final enemies = game.world.children.whereType<DefenseEnemy>();
    for (final enemy in enemies) {
      if (enemy.isDead || _hitEnemies.contains(enemy)) continue;
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
