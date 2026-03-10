import 'package:flutter_test/flutter_test.dart';
import 'package:paw_defense/systems/synergy_manager.dart';
import 'package:paw_defense/systems/merge_manager.dart';

void main() {
  late SynergyManager manager;

  setUp(() {
    manager = SynergyManager();
  });

  List<UnitSlot> _makeSlots(List<DefenseUnit> units) {
    return units
        .asMap()
        .entries
        .map((e) => UnitSlot(slotIndex: e.key, unit: e.value))
        .toList();
  }

  group('No synergy', () {
    test('empty slots has no synergy', () {
      manager.recalculate([]);
      expect(manager.hasAnySynergy, false);
      expect(manager.atkMultiplier, 1.0);
    });

    test('single unit has no synergy', () {
      final slots = _makeSlots([
        const DefenseUnit(unitTypeId: 'cat_archer', level: 1),
      ]);
      manager.recalculate(slots);
      expect(manager.hasAnySynergy, false);
    });

    test('two different types (no pair) has no tribe synergy', () {
      final slots = _makeSlots([
        const DefenseUnit(unitTypeId: 'cat_archer', level: 1),
        const DefenseUnit(unitTypeId: 'dog_warrior', level: 1),
      ]);
      manager.recalculate(slots);
      expect(manager.hasAnySynergy, false);
    });
  });

  group('Tribe synergies', () {
    test('2 cats activates tier 1 (atkSpeed +15%)', () {
      final slots = _makeSlots([
        const DefenseUnit(unitTypeId: 'cat_archer', level: 1),
        const DefenseUnit(unitTypeId: 'cat_archer', level: 2),
      ]);
      manager.recalculate(slots);
      expect(manager.hasAnySynergy, true);
      expect(manager.atkSpeedMultiplier, closeTo(1.15, 0.001));
    });

    test('3 cats activates tier 2 (atkSpeed +30%)', () {
      final slots = _makeSlots([
        const DefenseUnit(unitTypeId: 'cat_archer', level: 1),
        const DefenseUnit(unitTypeId: 'cat_archer', level: 1),
        const DefenseUnit(unitTypeId: 'cat_archer', level: 2),
      ]);
      manager.recalculate(slots);
      expect(manager.atkSpeedMultiplier, closeTo(1.30, 0.001));
    });

    test('2 foxes gives crit +10%', () {
      final slots = _makeSlots([
        const DefenseUnit(unitTypeId: 'fox_assassin', level: 1),
        const DefenseUnit(unitTypeId: 'fox_assassin', level: 1),
      ]);
      manager.recalculate(slots);
      expect(manager.critBonus, closeTo(0.10, 0.001));
    });

    test('3 rabbits gives ATK +40%', () {
      final slots = _makeSlots([
        const DefenseUnit(unitTypeId: 'rabbit_mage', level: 1),
        const DefenseUnit(unitTypeId: 'rabbit_mage', level: 1),
        const DefenseUnit(unitTypeId: 'rabbit_mage', level: 2),
      ]);
      manager.recalculate(slots);
      expect(manager.atkMultiplier, closeTo(1.40, 0.001));
    });

    test('2 bears gives wallDefenseBonus +10%', () {
      final slots = _makeSlots([
        const DefenseUnit(unitTypeId: 'bear_tanker', level: 1),
        const DefenseUnit(unitTypeId: 'bear_tanker', level: 1),
      ]);
      manager.recalculate(slots);
      expect(manager.wallDefenseBonus, closeTo(0.10, 0.001));
    });

    test('2 turtles gives healBonus +20%', () {
      final slots = _makeSlots([
        const DefenseUnit(unitTypeId: 'turtle_healer', level: 1),
        const DefenseUnit(unitTypeId: 'turtle_healer', level: 1),
      ]);
      manager.recalculate(slots);
      expect(manager.healBonus, closeTo(0.20, 0.001));
    });
  });

  group('Multiple tribe synergies stack', () {
    test('2 cats + 2 foxes = both active', () {
      final slots = _makeSlots([
        const DefenseUnit(unitTypeId: 'cat_archer', level: 1),
        const DefenseUnit(unitTypeId: 'cat_archer', level: 1),
        const DefenseUnit(unitTypeId: 'fox_assassin', level: 1),
        const DefenseUnit(unitTypeId: 'fox_assassin', level: 1),
      ]);
      manager.recalculate(slots);
      expect(manager.activeSynergies.length, greaterThanOrEqualTo(2));
      expect(manager.atkSpeedMultiplier, closeTo(1.15, 0.001));
      expect(manager.critBonus, closeTo(0.10, 0.001));
    });
  });

  group('Diversity synergies', () {
    test('4 different types gives ATK +10%', () {
      final slots = _makeSlots([
        const DefenseUnit(unitTypeId: 'cat_archer', level: 1),
        const DefenseUnit(unitTypeId: 'dog_warrior', level: 1),
        const DefenseUnit(unitTypeId: 'rabbit_mage', level: 1),
        const DefenseUnit(unitTypeId: 'bear_tanker', level: 1),
      ]);
      manager.recalculate(slots);
      expect(manager.atkMultiplier, closeTo(1.10, 0.001));
    });

    test('6 different types gives ATK +20% and gold +15%', () {
      final slots = _makeSlots([
        const DefenseUnit(unitTypeId: 'cat_archer', level: 1),
        const DefenseUnit(unitTypeId: 'dog_warrior', level: 1),
        const DefenseUnit(unitTypeId: 'rabbit_mage', level: 1),
        const DefenseUnit(unitTypeId: 'bear_tanker', level: 1),
        const DefenseUnit(unitTypeId: 'fox_assassin', level: 1),
        const DefenseUnit(unitTypeId: 'bird_scout', level: 1),
      ]);
      manager.recalculate(slots);
      expect(manager.atkMultiplier, closeTo(1.20, 0.001));
      expect(manager.goldMultiplier, closeTo(1.15, 0.001));
    });

    test('8 different types gives max diversity bonus', () {
      final slots = _makeSlots([
        const DefenseUnit(unitTypeId: 'cat_archer', level: 1),
        const DefenseUnit(unitTypeId: 'dog_warrior', level: 1),
        const DefenseUnit(unitTypeId: 'rabbit_mage', level: 1),
        const DefenseUnit(unitTypeId: 'bear_tanker', level: 1),
        const DefenseUnit(unitTypeId: 'fox_assassin', level: 1),
        const DefenseUnit(unitTypeId: 'bird_scout', level: 1),
        const DefenseUnit(unitTypeId: 'turtle_healer', level: 1),
        const DefenseUnit(unitTypeId: 'owl_wizard', level: 1),
      ]);
      manager.recalculate(slots);
      expect(manager.atkMultiplier, closeTo(1.30, 0.001));
      expect(manager.goldMultiplier, closeTo(1.20, 0.001));
      expect(manager.atkSpeedMultiplier, closeTo(1.15, 0.001));
    });
  });

  group('Hybrid unit counting', () {
    test('hybrid counts toward both parent types', () {
      manager.setHybridParents({
        'hybrid_flame_hunter': ('cat_archer', 'fox_assassin'),
      });
      final slots = _makeSlots([
        const DefenseUnit(unitTypeId: 'hybrid_flame_hunter', level: 3),
        const DefenseUnit(unitTypeId: 'cat_archer', level: 1),
      ]);
      manager.recalculate(slots);
      // hybrid_flame_hunter counts as cat_archer + fox_assassin
      // cat_archer: 2 (hybrid + actual) → cat tier 1 active
      expect(manager.atkSpeedMultiplier, closeTo(1.15, 0.001));
    });
  });

  group('Reset', () {
    test('reset clears all synergies', () {
      final slots = _makeSlots([
        const DefenseUnit(unitTypeId: 'cat_archer', level: 1),
        const DefenseUnit(unitTypeId: 'cat_archer', level: 1),
      ]);
      manager.recalculate(slots);
      expect(manager.hasAnySynergy, true);

      manager.reset();
      expect(manager.hasAnySynergy, false);
      expect(manager.atkMultiplier, 1.0);
      expect(manager.atkSpeedMultiplier, 1.0);
    });
  });
}
