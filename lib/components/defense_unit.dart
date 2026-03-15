import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../data/unit_data.dart';
import '../data/balance_config.dart';
import '../data/hybrid_unit_data.dart';
import '../game/defense_game.dart';
import '../renderers/unit_renderer.dart';
import 'defense_enemy.dart';
import 'projectile.dart';
import 'unit_slot.dart' as slot_comp;

/// A defensive unit placed in a [UnitSlot] that automatically attacks enemies.
/// Units can be leveled up via merging (two same-type, same-level units → level+1).
class DefenseUnit extends PositionComponent
    with HasGameReference<DefenseGame> {
  final String unitTypeId;
  int level;
  bool isEvolved;
  int slotIndex;

  double _attackTimer = 0;
  double _animTimer = 0;
  DefenseEnemy? _target;
  double _targetSearchTimer = 0;
  static const double _targetSearchInterval = 0.15; // search every 150ms instead of every frame

  // Stats from UnitData
  final double baseAtk;
  final double baseAtkSpeed;
  final double baseRange;
  final bool isSplash;
  final bool isPiercing;
  final bool isMelee;
  final bool canHitAir;

  static final Random _random = Random();

  /// Mapping from string unitTypeId to UnitType enum.
  static const Map<String, UnitType> _typeMap = {
    'cat_archer': UnitType.catArcher,
    'dog_warrior': UnitType.dogWarrior,
    'rabbit_mage': UnitType.rabbitMage,
    'bear_tanker': UnitType.bearTanker,
    'fox_assassin': UnitType.foxAssassin,
    'bird_scout': UnitType.birdScout,
    'turtle_healer': UnitType.turtleHealer,
    'owl_wizard': UnitType.owlWizard,
  };

  /// Whether this is a hybrid unit.
  bool get isHybrid => HybridDatabase.isHybrid(unitTypeId);

  DefenseUnit({
    required this.unitTypeId,
    this.level = 1,
    this.isEvolved = false,
    this.slotIndex = -1,
  })  : baseAtk = _lookupAtk(unitTypeId),
        baseAtkSpeed = _lookupAtkSpeed(unitTypeId),
        baseRange = _lookupRange(unitTypeId),
        isSplash = _lookupSplash(unitTypeId),
        isPiercing = _lookupPierce(unitTypeId),
        isMelee = _lookupMelee(unitTypeId),
        canHitAir = _lookupAir(unitTypeId),
        super(
          size: Vector2(24, 24),
          anchor: Anchor.center,
          priority: 15,
        );

  // ── Stat lookups (support both normal and hybrid units) ──

  static double _lookupAtk(String typeId) {
    final hybrid = HybridDatabase.get(typeId);
    if (hybrid != null) return hybrid.baseAtk;
    return _lookupData(typeId)?.baseAtk ?? 10;
  }

  static double _lookupAtkSpeed(String typeId) {
    final hybrid = HybridDatabase.get(typeId);
    if (hybrid != null) return hybrid.baseAtkSpeed;
    return _lookupData(typeId)?.baseAtkSpeed ?? 1.0;
  }

  static double _lookupRange(String typeId) {
    final hybrid = HybridDatabase.get(typeId);
    if (hybrid != null) return hybrid.range;
    return _lookupData(typeId)?.range ?? 80;
  }

  static bool _lookupSplash(String typeId) {
    final hybrid = HybridDatabase.get(typeId);
    if (hybrid != null) return hybrid.isSplash;
    return _lookupData(typeId)?.isSplash ?? false;
  }

  static bool _lookupPierce(String typeId) {
    final hybrid = HybridDatabase.get(typeId);
    if (hybrid != null) return hybrid.isPiercing;
    return _lookupData(typeId)?.isPiercing ?? false;
  }

  static bool _lookupMelee(String typeId) {
    final hybrid = HybridDatabase.get(typeId);
    if (hybrid != null) return hybrid.isMelee;
    return _lookupData(typeId)?.isMelee ?? false;
  }

  static bool _lookupAir(String typeId) {
    final hybrid = HybridDatabase.get(typeId);
    if (hybrid != null) return hybrid.canHitAir;
    return _lookupData(typeId)?.canHitAir ?? false;
  }

  /// Look up UnitData by string unitTypeId. Returns null if not found.
  static UnitData? _lookupData(String typeId) {
    final unitType = _typeMap[typeId];
    if (unitType == null) return null;
    return UnitDatabase.get(unitType);
  }

  /// Attack power scales exponentially with level, plus reward/relic/upgrade bonuses.
  /// Includes evolved multiplier, berserker (wall HP < 30% → x2) and reverse.
  double get atk {
    double base = baseAtk * pow(BalanceConfig.unitAtkLevelBase, level - 1);
    // Evolved units get additional ATK multiplier (2.5x~3.0x defined in EvolvedUnitData)
    if (isEvolved && !isHybrid) {
      final unitType = _typeMap[unitTypeId];
      if (unitType != null) {
        final evo = UnitDatabase.getEvolution(unitType);
        if (evo != null) {
          base *= evo.atkMultiplier;
        }
      }
    }
    final wallHpPct = game.wall.hpPercent;
    // Skill: war_cry gives +50% ATK while active
    final skillAtkMult = game.skillManager.isEffectActive('war_cry') ? 1.5 : 1.0;
    return base *
        game.rewardAtkMultiplier *
        game.relicManager.atkMultiplier *
        game.upgradeManager.unitAtkMultiplier *
        (isHybrid ? game.upgradeManager.hybridAtkMultiplier : 1.0) *
        game.relicManager.berserkerMultiplier(wallHpPct) *
        game.relicManager.reverseMultiplier(wallHpPct) *
        skillAtkMult;
  }

  /// Attack speed improves per level, plus reward/relic/upgrade bonuses.
  /// Evolved units get +20% attack speed bonus.
  double get atkSpeed {
    double base = baseAtkSpeed *
        (1.0 + (level - 1) * BalanceConfig.unitAtkSpeedPerLevel);
    if (isEvolved && !isHybrid) base *= 1.2;
    return base *
        game.rewardAtkSpeedMultiplier *
        game.relicManager.atkSpeedMultiplier *
        game.upgradeManager.unitAtkSpeedMultiplier;
  }

  /// Range grows per level, plus reward and relic bonuses.
  /// Evolved units get +20% range bonus.
  double get range {
    double base = baseRange + (level - 1) * BalanceConfig.unitRangePerLevel;
    if (isEvolved && !isHybrid) base *= 1.2;
    return base * game.rewardRangeMultiplier * game.relicManager.rangeMultiplier;
  }

  /// Interval between attacks in seconds.
  double get attackInterval => 1.0 / atkSpeed;

  /// Muzzle flash color per unit type.
  static const Map<String, Color> _muzzleColors = {
    'cat_archer': Color(0xFFFFD700),    // gold
    'dog_warrior': Color(0xFFB0BEC5),   // silver
    'rabbit_mage': Color(0xFF9C27B0),   // purple
    'bear_tanker': Color(0xFF8D6E63),   // brown
    'fox_assassin': Color(0xFFFF3D00),  // red
    'bird_scout': Color(0xFF42A5F5),    // blue
    'turtle_healer': Color(0xFF66BB6A), // green
    'owl_wizard': Color(0xFF651FFF),    // indigo
  };

  Color get _muzzleColor {
    if (isEvolved) return const Color(0xFFFFD700); // gold for evolved
    if (isHybrid) return const Color(0xFFE040FB);  // purple for hybrid
    return _muzzleColors[unitTypeId] ?? const Color(0xFFFFD700);
  }

  /// Whether this unit can merge with another (same type, same level, below max).
  bool canMergeWith(DefenseUnit other) =>
      unitTypeId == other.unitTypeId &&
      level == other.level &&
      level < 5 &&
      !isEvolved &&
      !other.isEvolved;

  /// Merge this unit with [other], leveling up this unit. Returns true if merged.
  bool mergeWith(DefenseUnit other) {
    if (!canMergeWith(other)) return false;
    level++;
    // Check evolution at max level
    if (level >= 5) {
      isEvolved = true;
    }
    game.particleEffect.spawnMerge(position.x, position.y, level: level);
    return true;
  }

  /// Find the closest enemy within range.
  void _findTarget() {
    _target = null;
    double closestDist = range;

    for (final enemy in game.livingEnemies) {
      // Skip flying enemies if this unit can't hit air
      if (enemy.isFlying && !canHitAir) continue;
      final dist = position.distanceTo(enemy.position);
      if (dist < closestDist) {
        closestDist = dist;
        _target = enemy;
      }
    }
  }

  /// Fire a projectile at the current target, or melee attack directly.
  void _attack() {
    if (_target == null || _target!.isDead) return;

    // Calculate damage with crit chance (fox/hybrid base + relic bonus)
    double dmg = atk;
    double baseCritChance = 0.0;
    if (unitTypeId == 'fox_assassin') baseCritChance = BalanceConfig.foxCritChance;
    if (unitTypeId == 'hybrid_flame_hunter') baseCritChance = 0.20;
    if (unitTypeId == 'hybrid_shadow_sage') baseCritChance = 0.30;
    if (unitTypeId == 'hybrid_wolf_blade') baseCritChance = 0.25;

    // Active skill: assassin_mark forces 100% crit
    final assassinMark = game.skillManager.isEffectActive('assassin_mark');
    final critChance = assassinMark
        ? 1.0
        : baseCritChance +
            game.relicManager.critChanceBonus +
            game.upgradeManager.baseCritChance;
    if (critChance > 0 && _random.nextDouble() < critChance) {
      dmg *= game.relicManager.critDamageMultiplier;
    }

    // Turtle healer / hybrid healer: heal wall on each attack
    if ((unitTypeId == 'turtle_healer' ||
        unitTypeId == 'hybrid_holy_knight' ||
        unitTypeId == 'hybrid_mystic_sage' ||
        unitTypeId == 'hybrid_mountain_guard') &&
        !game.wall.isDestroyed) {
      final healFrac = unitTypeId == 'hybrid_mystic_sage' ? 0.03 : BalanceConfig.turtleHealerHealFraction;
      game.wall.heal(dmg * healFrac);
    }

    // Muzzle flash effect on attack
    game.particleEffect.spawnMuzzleFlash(
      position.x, position.y, _muzzleColor, level: level);

    if (isMelee) {
      // Melee: directly damage all enemies within range
      for (final enemy in game.livingEnemies) {
        final dist = position.distanceTo(enemy.position);
        if (dist <= range) {
          enemy.takeDamage(dmg, sourcePosition: position);
          // Bear tanker + bear hybrids: slow enemies on hit
          if (unitTypeId == 'bear_tanker' ||
              unitTypeId == 'hybrid_iron_warrior' ||
              unitTypeId == 'hybrid_mountain_guard' ||
              unitTypeId == 'hybrid_wise_bear') {
            final slowIntensity = unitTypeId == 'hybrid_wise_bear' ? 0.40 : BalanceConfig.bearSlowIntensity;
            enemy.applySlow(
              slowIntensity,
              BalanceConfig.bearSlowDuration,
            );
          }
        }
      }
    } else {
      // Ranged: fire a projectile
      final dir = (_target!.position - position).normalized();

      final projSpeed = BalanceConfig.projectileSpeed *
          game.relicManager.projectileSpeedMultiplier;
      game.world.add(Projectile(
        spawnPosition: position.clone(),
        velocity: dir * projSpeed,
        damage: dmg,
        isPiercing: isPiercing || isEvolved || game.relicManager.hasPierceAll,
        isSplash: isSplash || game.relicManager.hasSplash,
        splashRadius: (isSplash || game.relicManager.hasSplash)
            ? BalanceConfig.splashRadius
            : 0,
        ownerTypeId: unitTypeId,
        level: level,
        isEvolved: isEvolved,
        isHybrid: isHybrid,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isPlaying) return;
    _animTimer += dt;
    _attackTimer += dt;
    if (_recoilTimer > 0) _recoilTimer -= dt;
    if (_beamTimer > 0) _beamTimer -= dt;

    // Follow orbit position from slot
    if (slotIndex >= 0) {
      final wallPos = game.wall.position;
      final totalSlots = game.maxSlots;
      final angle =
          game.orbitAngle + (2 * pi * slotIndex / totalSlots) - (pi / 2);
      position.x = wallPos.x + cos(angle) * slot_comp.UnitSlot.slotRadius;
      position.y = wallPos.y + sin(angle) * slot_comp.UnitSlot.slotRadius;
    }

    // Re-acquire target: immediately if no valid target, throttled otherwise
    if (_target == null || _target!.isDead || !_target!.isMounted) {
      _findTarget();
      _targetSearchTimer = 0;
    } else {
      _targetSearchTimer += dt;
      if (_targetSearchTimer >= _targetSearchInterval) {
        _targetSearchTimer = 0;
        // Check if target moved out of range
        final dist = position.distanceTo(_target!.position);
        if (dist > range * 1.2) {
          _findTarget();
        }
      }
    }

    // Attack when cooldown elapsed and target exists
    if (_attackTimer >= attackInterval && _target != null) {
      _attackTimer = 0;
      _recoilTimer = _recoilDuration;
      _beamTimer = _beamDuration;
      _attack();
    }
  }

  // Attack recoil animation
  double _recoilTimer = 0;
  static const double _recoilDuration = 0.15;

  // Beam visibility timer (longer than recoil for visual clarity)
  double _beamTimer = 0;
  static const double _beamDuration = 0.25;

  // Cached Paint objects for render()
  static final Paint _glowPaint = Paint();
  static final Paint _shimmerPaint = Paint();
  static final Paint _dotPaint = Paint()..isAntiAlias = false;
  static final Paint _beamPaint = Paint()..isAntiAlias = false;
  static final Paint _beamGlowPaint = Paint()..isAntiAlias = false;

  // Attack beam colors per unit type
  static const Map<String, Color> _beamColors = {
    'cat_archer': Color(0xFFFFD700),    // gold
    'dog_warrior': Color(0xFFB0BEC5),   // silver
    'rabbit_mage': Color(0xFF9C27B0),   // purple
    'bear_tanker': Color(0xFF8D6E63),   // brown
    'fox_assassin': Color(0xFFFF3D00),  // red-orange
    'bird_scout': Color(0xFF42A5F5),    // sky blue
    'turtle_healer': Color(0xFF66BB6A), // green
    'owl_wizard': Color(0xFF651FFF),    // indigo
  };

  Color get _beamColor {
    if (isEvolved) return const Color(0xFFFFD700);
    if (isHybrid) return const Color(0xFFE040FB);
    return _beamColors[unitTypeId] ?? const Color(0xFFFFD700);
  }

  /// Whether the unit should show attack beam.
  bool get _isAttacking => _beamTimer > 0;

  /// Sine approximation for idle bob animation.
  double _sin(double x) {
    x = x % 6.2832;
    if (x < 0) x += 6.2832;
    if (x > 3.1416) {
      x -= 3.1416;
      return -(x * (4 - x * 1.2732) * 0.405 + x * (4 - x * 1.2732) * 0.595);
    }
    return x * (4 - x * 1.2732) * 0.405 + x * (4 - x * 1.2732) * 0.595;
  }

  @override
  void render(Canvas canvas) {
    canvas.save();

    // Flip sprite when orbiting leftward (moving left)
    bool _flipX = false;
    if (slotIndex >= 0 && game.isPlaying) {
      final totalSlots = game.maxSlots;
      final angle =
          game.orbitAngle + (2 * pi * slotIndex / totalSlots) - (pi / 2);
      // Tangent direction: if sin(angle) > 0, unit moves left → flip
      _flipX = sin(angle) > 0;
    }
    if (_flipX) {
      canvas.translate(size.x, 0);
      canvas.scale(-1, 1);
    }

    // Idle bobbing animation when no target (breathing effect)
    if (_target == null) {
      final bob = _sin(_animTimer * 2.5) * 1.5;
      canvas.translate(0, bob);
    }

    // Apply recoil effect when attacking
    if (_recoilTimer > 0) {
      final recoilT = _recoilTimer / _recoilDuration;
      final recoilOffset = recoilT * 2.0;
      if (_target != null) {
        final dir = (_target!.position - position).normalized();
        canvas.translate(-dir.x * recoilOffset, -dir.y * recoilOffset);
      }
      // Attack squash-and-stretch
      final squash = 1.0 + recoilT * 0.15;
      final stretch = 1.0 - recoilT * 0.1;
      canvas.translate(size.x / 2, size.y / 2);
      canvas.scale(stretch, squash);
      canvas.translate(-size.x / 2, -size.y / 2);
    }

    UnitRenderer.render(
      canvas,
      size.toSize(),
      unitTypeId: unitTypeId,
      level: level,
      isEvolved: isEvolved,
      animTimer: _animTimer,
      hasTarget: _target != null,
    );

    canvas.restore();

    // Evolved unit glow aura
    if (isEvolved) {
      final glowAlpha = (25 + 15 * _sin(_animTimer * 3).abs()).toInt();
      _glowPaint.color = Color.fromARGB(glowAlpha, 255, 215, 0);
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        size.x * 0.55,
        _glowPaint,
      );
    }

    // Hybrid unit purple shimmer
    if (isHybrid && !isEvolved) {
      final shimmerAlpha = (18 + 12 * _sin(_animTimer * 4).abs()).toInt();
      _shimmerPaint.color = Color.fromARGB(shimmerAlpha, 224, 64, 251);
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        size.x * 0.5,
        _shimmerPaint,
      );
    }

    // Level indicator dots below unit
    if (level > 1) {
      final dotY = size.y + 2;
      final totalWidth = (level - 1) * 3.0;
      final startX = (size.x - totalWidth) / 2;
      _dotPaint.color = isEvolved
          ? const Color(0xFFFFD700) // gold for evolved
          : isHybrid
              ? const Color(0xFFE040FB) // purple for hybrid
              : const Color(0xFFFFFFFF); // white for normal
      for (int i = 0; i < level - 1; i++) {
        canvas.drawRect(
          Rect.fromLTWH(startX + i * 3.0, dotY, 2, 2),
          _dotPaint,
        );
      }
    }

    // ── Attack beam / laser line ──
    // Draw beam from unit center to target (in component-local coordinate space)
    if (_isAttacking && _target != null && !_target!.isDead) {
      // Both points in component-local space (relative to this component's position)
      final unitCenter = Offset(size.x / 2, size.y / 2);
      final targetLocal = Offset(
        _target!.position.x - position.x,
        _target!.position.y - position.y,
      );

      final beamColor = _beamColor;
      final beamT = (_beamTimer / _beamDuration).clamp(0.0, 1.0);
      final beamAlpha = beamT * 0.9;

      // Outer glow (wider, semi-transparent)
      final glowWidth = 3.0 + level * 1.0 + (isEvolved ? 2.0 : 0.0);
      _beamGlowPaint
        ..color = beamColor.withValues(alpha: beamAlpha * 0.3)
        ..strokeWidth = glowWidth
        ..style = PaintingStyle.stroke;
      canvas.drawLine(unitCenter, targetLocal, _beamGlowPaint);

      // Core beam (thinner, brighter)
      final coreWidth = 1.0 + level * 0.4 + (isEvolved ? 1.0 : 0.0);
      _beamPaint
        ..color = beamColor.withValues(alpha: beamAlpha * 0.8)
        ..strokeWidth = coreWidth
        ..style = PaintingStyle.stroke;
      canvas.drawLine(unitCenter, targetLocal, _beamPaint);

      // Bright center line (1px, full brightness)
      _beamPaint
        ..color = const Color(0xFFFFFFFF).withValues(alpha: beamAlpha * 0.6)
        ..strokeWidth = 0.5;
      canvas.drawLine(unitCenter, targetLocal, _beamPaint);
    }
  }
}
