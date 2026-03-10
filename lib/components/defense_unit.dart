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
    game.particleEffect.spawnMerge(position.x, position.y);
    return true;
  }

  /// Find the closest enemy within range.
  void _findTarget() {
    _target = null;
    double closestDist = range;

    final enemies = game.world.children.whereType<DefenseEnemy>();
    for (final enemy in enemies) {
      if (enemy.isDead) continue;
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

    if (isMelee) {
      // Melee: directly damage all enemies within range
      final enemies = game.world.children.whereType<DefenseEnemy>().toList();
      for (final enemy in enemies) {
        if (enemy.isDead) continue;
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
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _animTimer += dt;
    _attackTimer += dt;

    // Re-acquire target periodically or if target is dead/gone
    if (_target == null || _target!.isDead || !_target!.isMounted) {
      _findTarget();
    } else {
      // Check if target moved out of range
      final dist = position.distanceTo(_target!.position);
      if (dist > range * 1.2) {
        _findTarget();
      }
    }

    // Attack when cooldown elapsed and target exists
    if (_attackTimer >= attackInterval && _target != null) {
      _attackTimer = 0;
      _attack();
    }
  }

  @override
  void render(Canvas canvas) {
    UnitRenderer.render(
      canvas,
      size.toSize(),
      unitTypeId: unitTypeId,
      level: level,
      isEvolved: isEvolved,
      animTimer: _animTimer,
      hasTarget: _target != null,
    );

    // Draw range circle when highlighted (e.g., during placement)
    // This is a debug/UX aid
  }
}
