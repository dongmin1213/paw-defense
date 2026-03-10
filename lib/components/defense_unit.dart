import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../data/unit_data.dart';
import '../data/balance_config.dart';
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

  DefenseUnit({
    required this.unitTypeId,
    this.level = 1,
    this.isEvolved = false,
    this.slotIndex = -1,
  })  : baseAtk = _lookupData(unitTypeId)?.baseAtk ?? 10,
        baseAtkSpeed = _lookupData(unitTypeId)?.baseAtkSpeed ?? 1.0,
        baseRange = _lookupData(unitTypeId)?.range ?? 80,
        isSplash = _lookupData(unitTypeId)?.isSplash ?? false,
        isPiercing = _lookupData(unitTypeId)?.isPiercing ?? false,
        isMelee = _lookupData(unitTypeId)?.isMelee ?? false,
        canHitAir = _lookupData(unitTypeId)?.canHitAir ?? false,
        super(
          size: Vector2(24, 24),
          anchor: Anchor.center,
          priority: 15,
        );

  /// Look up UnitData by string unitTypeId. Returns null if not found.
  static UnitData? _lookupData(String typeId) {
    final unitType = _typeMap[typeId];
    if (unitType == null) return null;
    return UnitDatabase.get(unitType);
  }

  /// Attack power scales exponentially with level, plus reward/relic/upgrade bonuses.
  double get atk {
    final base = baseAtk * pow(BalanceConfig.unitAtkLevelBase, level - 1);
    return base *
        game.rewardAtkMultiplier *
        game.relicManager.atkMultiplier *
        game.upgradeManager.unitAtkMultiplier;
  }

  /// Attack speed improves per level, plus reward/relic/upgrade bonuses.
  double get atkSpeed {
    final base = baseAtkSpeed *
        (1.0 + (level - 1) * BalanceConfig.unitAtkSpeedPerLevel);
    return base *
        game.rewardAtkSpeedMultiplier *
        game.relicManager.atkSpeedMultiplier *
        game.upgradeManager.unitAtkSpeedMultiplier;
  }

  /// Range grows per level, plus reward bonus.
  double get range {
    final base = baseRange + (level - 1) * BalanceConfig.unitRangePerLevel;
    return base * game.rewardRangeMultiplier;
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

    // Calculate damage with crit chance (fox base + relic bonus)
    double dmg = atk;
    final critChance = (unitTypeId == 'fox_assassin'
            ? BalanceConfig.foxCritChance
            : 0.0) +
        game.relicManager.critChanceBonus;
    if (critChance > 0 && _random.nextDouble() < critChance) {
      dmg *= BalanceConfig.foxCritMultiplier;
    }

    // Turtle healer: heal wall on each attack
    if (unitTypeId == 'turtle_healer' && !game.wall.isDestroyed) {
      game.wall.heal(dmg * BalanceConfig.turtleHealerHealFraction);
    }

    if (isMelee) {
      // Melee: directly damage all enemies within range
      final enemies = game.world.children.whereType<DefenseEnemy>().toList();
      for (final enemy in enemies) {
        if (enemy.isDead) continue;
        final dist = position.distanceTo(enemy.position);
        if (dist <= range) {
          enemy.takeDamage(dmg, sourcePosition: position);
          // Bear tanker: slow enemies on hit
          if (unitTypeId == 'bear_tanker') {
            enemy.applySlow(
              BalanceConfig.bearSlowIntensity,
              BalanceConfig.bearSlowDuration,
            );
          }
        }
      }
    } else {
      // Ranged: fire a projectile
      final dir = (_target!.position - position).normalized();

      game.world.add(Projectile(
        spawnPosition: position.clone(),
        velocity: dir * BalanceConfig.projectileSpeed,
        damage: dmg,
        isPiercing: isPiercing || isEvolved,
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
