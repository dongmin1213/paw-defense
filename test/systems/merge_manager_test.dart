import 'package:flutter_test/flutter_test.dart';
import 'package:paw_defense/systems/merge_manager.dart';

void main() {
  group('DefenseUnit', () {
    test('equality works correctly', () {
      const a = DefenseUnit(unitTypeId: 'cat_archer', level: 1);
      const b = DefenseUnit(unitTypeId: 'cat_archer', level: 1);
      expect(a, equals(b));
    });

    test('different level means not equal', () {
      const a = DefenseUnit(unitTypeId: 'cat_archer', level: 1);
      const b = DefenseUnit(unitTypeId: 'cat_archer', level: 2);
      expect(a, isNot(equals(b)));
    });

    test('isHybrid detects hybrid IDs', () {
      const hybrid = DefenseUnit(unitTypeId: 'hybrid_flame_hunter', level: 3);
      const base = DefenseUnit(unitTypeId: 'cat_archer', level: 1);
      expect(hybrid.isHybrid, true);
      expect(base.isHybrid, false);
    });

    test('toMap/fromMap roundtrip', () {
      const unit = DefenseUnit(unitTypeId: 'fox_assassin', level: 3, isEvolved: true);
      final map = unit.toMap();
      final restored = DefenseUnit.fromMap(map);
      expect(restored, equals(unit));
      expect(restored.isEvolved, true);
    });

    test('copyWith works', () {
      const unit = DefenseUnit(unitTypeId: 'cat_archer', level: 1);
      final leveled = unit.copyWith(level: 2);
      expect(leveled.level, 2);
      expect(leveled.unitTypeId, 'cat_archer');
    });
  });

  group('UnitSlot', () {
    test('isEmpty and isOccupied', () {
      final slot = UnitSlot(slotIndex: 0);
      expect(slot.isEmpty, true);
      expect(slot.isOccupied, false);

      slot.place(const DefenseUnit(unitTypeId: 'cat_archer', level: 1));
      expect(slot.isEmpty, false);
      expect(slot.isOccupied, true);
    });

    test('clear removes unit', () {
      final slot = UnitSlot(
        slotIndex: 0,
        unit: const DefenseUnit(unitTypeId: 'cat_archer', level: 1),
      );
      slot.clear();
      expect(slot.isEmpty, true);
    });

    test('toMap/fromMap roundtrip', () {
      final slot = UnitSlot(
        slotIndex: 3,
        unit: const DefenseUnit(unitTypeId: 'dog_warrior', level: 2),
      );
      final map = slot.toMap();
      final restored = UnitSlot.fromMap(map);
      expect(restored.slotIndex, 3);
      expect(restored.unit, isNotNull);
      expect(restored.unit!.unitTypeId, 'dog_warrior');
      expect(restored.unit!.level, 2);
    });

    test('toMap/fromMap with empty slot', () {
      final slot = UnitSlot(slotIndex: 0);
      final map = slot.toMap();
      final restored = UnitSlot.fromMap(map);
      expect(restored.isEmpty, true);
    });
  });

  group('MergeManager.canMerge', () {
    test('same type same level can merge', () {
      const a = DefenseUnit(unitTypeId: 'cat_archer', level: 1);
      const b = DefenseUnit(unitTypeId: 'cat_archer', level: 1);
      expect(MergeManager.canMerge(a, b), true);
    });

    test('different type cannot merge', () {
      const a = DefenseUnit(unitTypeId: 'cat_archer', level: 1);
      const b = DefenseUnit(unitTypeId: 'dog_warrior', level: 1);
      expect(MergeManager.canMerge(a, b), false);
    });

    test('different level cannot merge', () {
      const a = DefenseUnit(unitTypeId: 'cat_archer', level: 1);
      const b = DefenseUnit(unitTypeId: 'cat_archer', level: 2);
      expect(MergeManager.canMerge(a, b), false);
    });

    test('max level cannot merge', () {
      const a = DefenseUnit(unitTypeId: 'cat_archer', level: 5);
      const b = DefenseUnit(unitTypeId: 'cat_archer', level: 5);
      expect(MergeManager.canMerge(a, b), false);
    });
  });

  group('MergeManager.tryMerge', () {
    test('merges 3 same type/level units', () {
      final units = [
        const DefenseUnit(unitTypeId: 'cat_archer', level: 1),
        const DefenseUnit(unitTypeId: 'cat_archer', level: 1),
        const DefenseUnit(unitTypeId: 'cat_archer', level: 1),
      ];
      final result = MergeManager.tryMerge(units);
      expect(result, isNotNull);
      expect(result!.unitTypeId, 'cat_archer');
      expect(result.level, 2);
      expect(units.length, 1); // 3 removed, 1 added
    });

    test('no merge with only 2 units', () {
      final units = [
        const DefenseUnit(unitTypeId: 'cat_archer', level: 1),
        const DefenseUnit(unitTypeId: 'cat_archer', level: 1),
      ];
      final result = MergeManager.tryMerge(units);
      expect(result, isNull);
      expect(units.length, 2);
    });

    test('no merge with mixed types', () {
      final units = [
        const DefenseUnit(unitTypeId: 'cat_archer', level: 1),
        const DefenseUnit(unitTypeId: 'dog_warrior', level: 1),
        const DefenseUnit(unitTypeId: 'cat_archer', level: 1),
      ];
      final result = MergeManager.tryMerge(units);
      expect(result, isNull);
    });

    test('no merge at max level', () {
      final units = [
        const DefenseUnit(unitTypeId: 'cat_archer', level: 5),
        const DefenseUnit(unitTypeId: 'cat_archer', level: 5),
        const DefenseUnit(unitTypeId: 'cat_archer', level: 5),
      ];
      final result = MergeManager.tryMerge(units);
      expect(result, isNull);
    });

    test('merges correct group when multiple types present', () {
      final units = [
        const DefenseUnit(unitTypeId: 'cat_archer', level: 1),
        const DefenseUnit(unitTypeId: 'dog_warrior', level: 1),
        const DefenseUnit(unitTypeId: 'cat_archer', level: 1),
        const DefenseUnit(unitTypeId: 'cat_archer', level: 1),
      ];
      final result = MergeManager.tryMerge(units);
      expect(result, isNotNull);
      expect(result!.unitTypeId, 'cat_archer');
      expect(result.level, 2);
      expect(units.length, 2); // 4 - 3 + 1 = 2
    });
  });

  group('MergeManager.findPossibleMerges', () {
    test('finds merge group with 3+ same units', () {
      final slots = [
        UnitSlot(slotIndex: 0, unit: const DefenseUnit(unitTypeId: 'cat_archer', level: 1)),
        UnitSlot(slotIndex: 1, unit: const DefenseUnit(unitTypeId: 'cat_archer', level: 1)),
        UnitSlot(slotIndex: 2, unit: const DefenseUnit(unitTypeId: 'cat_archer', level: 1)),
      ];
      final merges = MergeManager.findPossibleMerges(slots);
      expect(merges.length, 1);
      expect(merges.first.length, 3);
    });

    test('skips empty slots', () {
      final slots = [
        UnitSlot(slotIndex: 0, unit: const DefenseUnit(unitTypeId: 'cat_archer', level: 1)),
        UnitSlot(slotIndex: 1),
        UnitSlot(slotIndex: 2, unit: const DefenseUnit(unitTypeId: 'cat_archer', level: 1)),
      ];
      final merges = MergeManager.findPossibleMerges(slots);
      expect(merges, isEmpty);
    });

    test('double merge with mergeCount=2', () {
      final slots = [
        UnitSlot(slotIndex: 0, unit: const DefenseUnit(unitTypeId: 'cat_archer', level: 1)),
        UnitSlot(slotIndex: 1, unit: const DefenseUnit(unitTypeId: 'cat_archer', level: 1)),
      ];
      final merges = MergeManager.findPossibleMerges(slots, mergeCount: 2);
      expect(merges.length, 1);
      expect(merges.first.length, 2);
    });
  });

  group('MergeManager.canEvolve', () {
    test('Lv5 with matching relic can evolve', () {
      const unit = DefenseUnit(unitTypeId: 'cat_archer', level: 5);
      expect(MergeManager.canEvolve(unit, ['evolve_cat_archer']), true);
    });

    test('Lv4 cannot evolve', () {
      const unit = DefenseUnit(unitTypeId: 'cat_archer', level: 4);
      expect(MergeManager.canEvolve(unit, ['evolve_cat_archer']), false);
    });

    test('Lv5 without relic cannot evolve', () {
      const unit = DefenseUnit(unitTypeId: 'cat_archer', level: 5);
      expect(MergeManager.canEvolve(unit, []), false);
    });

    test('Lv5 with wrong relic cannot evolve', () {
      const unit = DefenseUnit(unitTypeId: 'cat_archer', level: 5);
      expect(MergeManager.canEvolve(unit, ['evolve_dog_warrior']), false);
    });
  });

  group('MergeManager.tryEvolve', () {
    test('returns evolved unit', () {
      const unit = DefenseUnit(unitTypeId: 'cat_archer', level: 5);
      final result = MergeManager.tryEvolve(unit, ['evolve_cat_archer']);
      expect(result, isNotNull);
      expect(result!.level, 6);
      expect(result.isEvolved, true);
      expect(result.unitTypeId, 'cat_archer');
    });

    test('returns null when conditions not met', () {
      const unit = DefenseUnit(unitTypeId: 'cat_archer', level: 3);
      expect(MergeManager.tryEvolve(unit, ['evolve_cat_archer']), isNull);
    });
  });

  group('MergeManager cross-breed', () {
    test('canCrossBreed: different types, same level, Lv3+', () {
      const cat = DefenseUnit(unitTypeId: 'cat_archer', level: 3);
      const fox = DefenseUnit(unitTypeId: 'fox_assassin', level: 3);
      expect(MergeManager.canCrossBreed(cat, fox), true);
    });

    test('canCrossBreed: same type fails', () {
      const a = DefenseUnit(unitTypeId: 'cat_archer', level: 3);
      const b = DefenseUnit(unitTypeId: 'cat_archer', level: 3);
      expect(MergeManager.canCrossBreed(a, b), false);
    });

    test('canCrossBreed: different levels fails', () {
      const cat = DefenseUnit(unitTypeId: 'cat_archer', level: 3);
      const fox = DefenseUnit(unitTypeId: 'fox_assassin', level: 4);
      expect(MergeManager.canCrossBreed(cat, fox), false);
    });

    test('canCrossBreed: below Lv3 fails', () {
      const cat = DefenseUnit(unitTypeId: 'cat_archer', level: 2);
      const fox = DefenseUnit(unitTypeId: 'fox_assassin', level: 2);
      expect(MergeManager.canCrossBreed(cat, fox), false);
    });

    test('canCrossBreed: hybrid unit fails', () {
      const hybrid = DefenseUnit(unitTypeId: 'hybrid_flame_hunter', level: 3);
      const fox = DefenseUnit(unitTypeId: 'fox_assassin', level: 3);
      expect(MergeManager.canCrossBreed(hybrid, fox), false);
    });

    test('findCrossBreedMerges returns valid merges', () {
      final slots = [
        UnitSlot(slotIndex: 0, unit: const DefenseUnit(unitTypeId: 'cat_archer', level: 3)),
        UnitSlot(slotIndex: 1, unit: const DefenseUnit(unitTypeId: 'fox_assassin', level: 3)),
        UnitSlot(slotIndex: 2, unit: const DefenseUnit(unitTypeId: 'dog_warrior', level: 1)),
      ];
      final merges = MergeManager.findCrossBreedMerges(slots);
      expect(merges.length, 1);
      expect(merges.first.hybridId, 'hybrid_flame_hunter');
    });

    test('performCrossBreed returns hybrid unit', () {
      const merge = CrossBreedMerge(
        slotIndexA: 0, slotIndexB: 1,
        hybridId: 'hybrid_flame_hunter', level: 3,
      );
      final result = MergeManager.performCrossBreed(merge);
      expect(result.unitTypeId, 'hybrid_flame_hunter');
      expect(result.level, 3);
      expect(result.isHybrid, true);
    });
  });
}
