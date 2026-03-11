import 'dart:math' show Random, pi, cos, sin;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../game/defense_game.dart';
import 'defense_enemy.dart';

/// Visual profile for each unit type's projectile.
class _ProjProfile {
  final Color color;
  final Color trailColor;
  final double trailAlpha;

  const _ProjProfile({
    required this.color,
    required this.trailColor,
    this.trailAlpha = 0.6,
  });
}

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

  // ── Trail system ──
  static const int _trailLength = 8;
  final List<double> _trailX = [];
  final List<double> _trailY = [];

  Projectile({
    required Vector2 spawnPosition,
    required this.velocity,
    required this.damage,
    this.isPiercing = false,
    this.isSplash = false,
    this.splashRadius = 0,
    this.ownerTypeId = '',
    bool isSplit = false,
  })  : _isSplit = isSplit,
        super(
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

    // Record trail position before moving
    _trailX.add(position.x);
    _trailY.add(position.y);
    if (_trailX.length > _trailLength) {
      _trailX.removeAt(0);
      _trailY.removeAt(0);
    }

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
      game.particleEffect
          .spawnProjectileHit(other.position.x, other.position.y, _profile.color);

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

  static final Random _rng = Random();

  /// Elemental: apply random fire/ice/poison effect.
  void _applyElementalEffect(DefenseEnemy enemy) {
    final roll = _rng.nextInt(3);
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

  // ══════════════════════════════════════
  // Visual Profile Per Unit Type
  // ══════════════════════════════════════

  static const Map<String, _ProjProfile> _profiles = {
    'cat_archer': _ProjProfile(
        color: Color(0xFFFFD700), trailColor: Color(0xFFFFD700)),
    'dog_warrior': _ProjProfile(
        color: Color(0xFFB0BEC5), trailColor: Color(0xFF90A4AE)),
    'rabbit_mage': _ProjProfile(
        color: Color(0xFF9C27B0), trailColor: Color(0xFFCE93D8)),
    'bear_tanker': _ProjProfile(
        color: Color(0xFF8D6E63), trailColor: Color(0xFFA1887F)),
    'fox_assassin': _ProjProfile(
        color: Color(0xFFFF3D00), trailColor: Color(0xFFFF6E40)),
    'bird_scout': _ProjProfile(
        color: Color(0xFF42A5F5), trailColor: Color(0xFF90CAF9)),
    'turtle_healer': _ProjProfile(
        color: Color(0xFF66BB6A), trailColor: Color(0xFFA5D6A7)),
    'owl_wizard': _ProjProfile(
        color: Color(0xFF651FFF), trailColor: Color(0xFFB388FF)),
  };

  _ProjProfile get _profile {
    // Piercing/splash override color but keep trail
    if (isPiercing) {
      return _ProjProfile(
          color: const Color(0xFFE040FB),
          trailColor: const Color(0xFFEA80FC));
    }
    if (isSplash) {
      return _ProjProfile(
          color: const Color(0xFFFF6600),
          trailColor: const Color(0xFFFF9800));
    }
    return _profiles[ownerTypeId] ??
        const _ProjProfile(
            color: Color(0xFFFFD700), trailColor: Color(0xFFFFD700));
  }

  @override
  void render(Canvas canvas) {
    final profile = _profile;

    // ── Draw trail ──
    if (_trailX.isNotEmpty) {
      final trailPaint = Paint()..isAntiAlias = false;
      final len = _trailX.length;
      for (int i = 0; i < len; i++) {
        final t = i / len; // 0.0 = oldest, ~1.0 = newest
        final alpha = (t * profile.trailAlpha).clamp(0.0, 1.0);
        final trailSize = 1.5 + t * 2.5;
        final dx = _trailX[i] - position.x;
        final dy = _trailY[i] - position.y;
        trailPaint.color = profile.trailColor.withValues(alpha: alpha);
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(dx + size.x / 2, dy + size.y / 2),
            width: trailSize,
            height: trailSize,
          ),
          trailPaint,
        );
      }
    }

    // ── Draw projectile shape per unit type ──
    final paint = Paint()
      ..isAntiAlias = false
      ..color = profile.color;
    final corePaint = Paint()
      ..isAntiAlias = false
      ..color = const Color(0xFFFFFFFF);

    _renderShape(canvas, paint, corePaint);
  }

  void _renderShape(Canvas canvas, Paint paint, Paint corePaint) {
    switch (ownerTypeId) {
      case 'cat_archer':
        // Arrow: elongated vertical
        canvas.drawRect(Rect.fromLTWH(2, 0, 2, 6), paint);
        canvas.drawRect(Rect.fromLTWH(1, 0, 4, 2), corePaint);
        break;
      case 'dog_warrior':
        // Sword slash: wide horizontal
        canvas.drawRect(Rect.fromLTWH(0, 2, 6, 2), paint);
        canvas.drawRect(Rect.fromLTWH(4, 2, 2, 2), corePaint);
        break;
      case 'rabbit_mage':
        // Magic orb: rounded glow
        canvas.drawRect(Rect.fromLTWH(1, 1, 4, 4), paint);
        canvas.drawRect(Rect.fromLTWH(2, 2, 2, 2), corePaint);
        // Side sparkle pixels
        final sparkPaint = Paint()
          ..isAntiAlias = false
          ..color = const Color(0x88FFFFFF);
        canvas.drawRect(Rect.fromLTWH(0, 3, 1, 1), sparkPaint);
        canvas.drawRect(Rect.fromLTWH(5, 2, 1, 1), sparkPaint);
        break;
      case 'bear_tanker':
        // Rock: big square
        canvas.drawRect(Rect.fromLTWH(0, 0, 6, 6), paint);
        canvas.drawRect(Rect.fromLTWH(1, 1, 2, 2), corePaint);
        break;
      case 'fox_assassin':
        // Shuriken: X shape
        canvas.drawRect(Rect.fromLTWH(0, 2, 6, 2), paint);
        canvas.drawRect(Rect.fromLTWH(2, 0, 2, 6), paint);
        canvas.drawRect(Rect.fromLTWH(2, 2, 2, 2), corePaint);
        break;
      case 'bird_scout':
        // Feather: diagonal slant
        canvas.drawRect(Rect.fromLTWH(1, 0, 2, 5), paint);
        canvas.drawRect(Rect.fromLTWH(3, 1, 2, 3), paint);
        canvas.drawRect(Rect.fromLTWH(2, 1, 2, 2), corePaint);
        break;
      case 'turtle_healer':
        // Heal bolt: + shape
        canvas.drawRect(Rect.fromLTWH(2, 0, 2, 6), paint);
        canvas.drawRect(Rect.fromLTWH(0, 2, 6, 2), paint);
        canvas.drawRect(Rect.fromLTWH(2, 2, 2, 2), corePaint);
        break;
      case 'owl_wizard':
        // Arcane star: cross + X
        canvas.drawRect(Rect.fromLTWH(2, 0, 2, 6), paint);
        canvas.drawRect(Rect.fromLTWH(0, 2, 6, 2), paint);
        canvas.drawRect(Rect.fromLTWH(1, 1, 1, 1), paint);
        canvas.drawRect(Rect.fromLTWH(4, 1, 1, 1), paint);
        canvas.drawRect(Rect.fromLTWH(1, 4, 1, 1), paint);
        canvas.drawRect(Rect.fromLTWH(4, 4, 1, 1), paint);
        canvas.drawRect(Rect.fromLTWH(2, 2, 2, 2), corePaint);
        break;
      default:
        // Default: simple square with bright core
        canvas.drawRect(Rect.fromLTWH(1, 1, 4, 4), paint);
        canvas.drawRect(Rect.fromLTWH(2, 2, 2, 2), corePaint);
        break;
    }
  }
}
