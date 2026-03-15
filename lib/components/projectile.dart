import 'dart:math' show Random, pi, cos, sin;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../data/balance_config.dart';
import '../game/defense_game.dart';
import '../data/hybrid_unit_data.dart';
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
  final int level;
  final bool isEvolved;
  final bool isHybrid;
  final bool _isSplit; // true if this is a child split projectile (prevents recursion)

  double _lifeTime = 0;

  /// Track already-hit enemies to avoid double damage on piercing projectiles.
  final Set<DefenseEnemy> _hitEnemies = {};

  // ── Trail system (ring buffer, length scales with level) ──
  late final int _trailLength;
  late final List<double> _trailX;
  late final List<double> _trailY;
  int _trailHead = 0;
  int _trailCount = 0;

  /// Visual scale factor based on level/evolved/hybrid status.
  late final double _visualScale;

  /// Cached profile to avoid per-frame HybridDatabase lookups.
  late final _ProjProfile _cachedProfile;

  Projectile({
    required Vector2 spawnPosition,
    required this.velocity,
    required this.damage,
    this.isPiercing = false,
    this.isSplash = false,
    this.splashRadius = 0,
    this.ownerTypeId = '',
    this.level = 1,
    this.isEvolved = false,
    this.isHybrid = false,
    bool isSplit = false,
  })  : _isSplit = isSplit,
        super(
          position: spawnPosition,
          size: Vector2(6, 6),
          anchor: Anchor.center,
          priority: 14,
        ) {
    _visualScale = BalanceConfig.projectileVisualScaleBase +
        (level - 1) * BalanceConfig.projectileVisualScalePerLevel +
        (isEvolved ? BalanceConfig.projectileVisualScaleEvolved : 0.0) +
        (isHybrid ? BalanceConfig.projectileVisualScaleHybrid : 0.0);
    _trailLength = (BalanceConfig.projectileTrailBase + level * BalanceConfig.projectileTrailPerLevel + (isEvolved ? BalanceConfig.projectileTrailEvolved : 0)).clamp(BalanceConfig.projectileTrailMin, BalanceConfig.projectileTrailMax);
    // Pre-allocate ring buffer for trail
    _trailX = List<double>.filled(_trailLength, 0);
    _trailY = List<double>.filled(_trailLength, 0);
    // Update component size for hitbox
    size = Vector2(6 * _visualScale, 6 * _visualScale);
    // Cache profile at construction time
    _cachedProfile = _computeProfile();
  }

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(isSolid: true));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isPlaying) return;

    // Record trail position in ring buffer (O(1) instead of O(n) removeAt)
    _trailX[_trailHead] = position.x;
    _trailY[_trailHead] = position.y;
    _trailHead = (_trailHead + 1) % _trailLength;
    if (_trailCount < _trailLength) _trailCount++;

    // Move along velocity
    position.add(velocity * dt);

    _lifeTime += dt;

    // Remove if off screen or exceeded lifetime
    if (_lifeTime >= BalanceConfig.projectileMaxLifeTime ||
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
    final speed = velocity.length * BalanceConfig.splitShotSpeedMult;
    final baseAngle = velocity.screenAngle();
    const splitAngle = pi / 4; // 45 degrees

    for (final angleDelta in [-splitAngle, splitAngle]) {
      final angle = baseAngle + angleDelta;
      final dir = Vector2(0, -1)..rotate(angle);
      game.world.add(Projectile(
        spawnPosition: impactPos.clone(),
        velocity: dir * speed,
        damage: damage * BalanceConfig.splitShotDamageMult,
        isPiercing: false,
        isSplash: false,
        ownerTypeId: ownerTypeId,
        level: level,
        isEvolved: isEvolved,
        isHybrid: isHybrid,
        isSplit: true,
      ));
    }
  }

  static final Random _rng = Random();

  // Cached Paint objects for render()
  static final Paint _trailPaint = Paint()..isAntiAlias = false;
  static final Paint _glowPaint = Paint()
    ..isAntiAlias = false
    ..color = const Color(0x44FFD700);
  static final Paint _mainPaint = Paint()..isAntiAlias = false;
  static final Paint _corePaintCached = Paint()..isAntiAlias = false;
  static final Paint _hybridDotPaint = Paint()
    ..isAntiAlias = false
    ..color = const Color(0xAAE040FB);
  static final Paint _mageSparkPaint = Paint()
    ..isAntiAlias = false
    ..color = const Color(0x88FFFFFF);

  /// Elemental: apply random fire/ice/poison effect.
  void _applyElementalEffect(DefenseEnemy enemy) {
    final roll = _rng.nextInt(3);
    switch (roll) {
      case 0: // Fire DoT
        enemy.applyDot(damage * BalanceConfig.elementalFireDotPercent, BalanceConfig.elementalFireDuration, 'fire');
        break;
      case 1: // Ice slow
        enemy.applySlow(BalanceConfig.elementalIceSlowPercent, BalanceConfig.elementalIceDuration);
        break;
      case 2: // Poison DoT
        enemy.applyDot(damage * BalanceConfig.elementalPoisonDotPercent, BalanceConfig.elementalPoisonDuration, 'poison');
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
        final splashDmg = damage * BalanceConfig.splashDamageFalloffMult * falloff;
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

  _ProjProfile get _profile => _cachedProfile;

  _ProjProfile _computeProfile() {
    // Piercing/splash override color but keep trail
    if (isPiercing && !isHybrid && !isEvolved) {
      return const _ProjProfile(
          color: Color(0xFFE040FB),
          trailColor: Color(0xFFEA80FC));
    }
    if (isSplash && !isHybrid && !isEvolved) {
      return const _ProjProfile(
          color: Color(0xFFFF6600),
          trailColor: Color(0xFFFF9800));
    }

    // Hybrid: blend both parent colors
    if (isHybrid) {
      final hybrid = HybridDatabase.get(ownerTypeId);
      if (hybrid != null) {
        final pA = _profiles[hybrid.parentA];
        final pB = _profiles[hybrid.parentB];
        if (pA != null && pB != null) {
          // Blend parent colors
          final r = ((pA.color.red + pB.color.red) ~/ 2).clamp(0, 255);
          final g = ((pA.color.green + pB.color.green) ~/ 2).clamp(0, 255);
          final b = ((pA.color.blue + pB.color.blue) ~/ 2).clamp(0, 255);
          final tr = ((pA.trailColor.red + pB.trailColor.red) ~/ 2).clamp(0, 255);
          final tg = ((pA.trailColor.green + pB.trailColor.green) ~/ 2).clamp(0, 255);
          final tb = ((pA.trailColor.blue + pB.trailColor.blue) ~/ 2).clamp(0, 255);
          return _ProjProfile(
            color: Color.fromARGB(255, r, g, b),
            trailColor: Color.fromARGB(255, tr, tg, tb),
            trailAlpha: 0.7,
          );
        }
      }
    }

    // Evolved: brighten the base color
    if (isEvolved) {
      final base = _profiles[ownerTypeId];
      if (base != null) {
        final r = (base.color.red + 40).clamp(0, 255);
        final g = (base.color.green + 40).clamp(0, 255);
        final b = (base.color.blue + 40).clamp(0, 255);
        return _ProjProfile(
          color: Color.fromARGB(255, r, g, b),
          trailColor: const Color(0xFFFFD700), // gold trail for evolved
          trailAlpha: 0.8,
        );
      }
    }

    return _profiles[ownerTypeId] ??
        const _ProjProfile(
            color: Color(0xFFFFD700), trailColor: Color(0xFFFFD700));
  }

  @override
  void render(Canvas canvas) {
    final profile = _profile;
    final s = _visualScale;

    // ── Draw trail from ring buffer (scaled by level) ──
    // Render every other segment to halve draw calls while keeping visual quality
    if (_trailCount > 0) {
      final len = _trailCount;
      final start = (_trailHead - _trailCount + _trailLength) % _trailLength;
      final step = len > 8 ? 2 : 1;
      for (int i = 0; i < len; i += step) {
        final idx = (start + i) % _trailLength;
        final t = i / len; // 0.0 = oldest, ~1.0 = newest
        final alpha = (t * profile.trailAlpha).clamp(0.0, 1.0);
        if (alpha < 0.05) continue; // skip invisible segments
        final trailSize = (2.0 + t * 4.0) * s;
        final dx = _trailX[idx] - position.x;
        final dy = _trailY[idx] - position.y;
        _trailPaint.color = profile.trailColor.withValues(alpha: alpha);
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(dx + size.x / 2, dy + size.y / 2),
            width: trailSize,
            height: trailSize,
          ),
          _trailPaint,
        );
      }
    }

    // ── Evolved glow outline ──
    if (isEvolved) {
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(size.x / 2, size.y / 2),
          width: size.x + 3,
          height: size.y + 3,
        ),
        _glowPaint,
      );
    }

    // ── Draw projectile shape per unit type (scaled) ──
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.scale(s, s);
    canvas.translate(-3, -3); // center of original 6x6

    _mainPaint.color = profile.color;
    // Lv3+ brighter core, Lv5 pure white core
    _corePaintCached.color = level >= 5
        ? const Color(0xFFFFFFFF)
        : level >= 3
            ? const Color(0xFFFFFFCC)
            : const Color(0xFFFFFFFF);

    _renderShape(canvas, _mainPaint, _corePaintCached);
    canvas.restore();

    // ── Hybrid center dot ──
    if (isHybrid) {
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(size.x / 2, size.y / 2),
          width: 2 * s,
          height: 2 * s,
        ),
        _hybridDotPaint,
      );
    }
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
        canvas.drawRect(Rect.fromLTWH(0, 3, 1, 1), _mageSparkPaint);
        canvas.drawRect(Rect.fromLTWH(5, 2, 1, 1), _mageSparkPaint);
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
