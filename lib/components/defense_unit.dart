import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../data/unit_data.dart';
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

  /// Attack power scales exponentially with level.
  double get atk => baseAtk * pow(2.0, level - 1);

  /// Attack speed improves slightly per level.
  double get atkSpeed => baseAtkSpeed * (1.0 + (level - 1) * 0.1);

  /// Range grows marginally with level.
  double get range => baseRange + (level - 1) * 5.0;

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

    // Calculate damage with fox assassin crit chance
    double dmg = atk;
    if (unitTypeId == 'fox_assassin' && _random.nextDouble() < 0.20) {
      dmg *= 2.0; // 20% chance for 2x crit damage
    }

    if (isMelee) {
      // Melee: directly damage all enemies within range
      final enemies = game.world.children.whereType<DefenseEnemy>().toList();
      for (final enemy in enemies) {
        if (enemy.isDead) continue;
        final dist = position.distanceTo(enemy.position);
        if (dist <= range) {
          enemy.takeDamage(dmg, sourcePosition: position);
        }
      }
    } else {
      // Ranged: fire a projectile
      final direction = (_target!.position - position).normalized();
      final speed = 200.0;

      game.world.add(Projectile(
        spawnPosition: position.clone(),
        velocity: direction * speed,
        damage: dmg,
        isPiercing: isPiercing || isEvolved, // unit data piercing OR evolved
        isSplash: isSplash,
        splashRadius: isSplash ? 40.0 : 0,
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
