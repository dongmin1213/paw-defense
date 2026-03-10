import 'package:flutter_test/flutter_test.dart';
import 'package:paw_defense/data/unit_data.dart';

void main() {
  group('UnitDatabase', () {
    test('has exactly 8 base unit types', () {
      expect(UnitDatabase.all.length, 8);
    });

    test('covers all UnitType enum values', () {
      for (final type in UnitType.values) {
        final unit = UnitDatabase.get(type);
        expect(unit.type, type);
      }
    });

    test('all units have positive stats', () {
      for (final unit in UnitDatabase.all) {
        expect(unit.baseAtk, greaterThan(0), reason: '${unit.id} baseAtk');
        expect(unit.baseAtkSpeed, greaterThan(0), reason: '${unit.id} baseAtkSpeed');
        expect(unit.range, greaterThanOrEqualTo(0), reason: '${unit.id} range');
      }
    });

    test('all unit IDs are unique', () {
      final ids = UnitDatabase.all.map((u) => u.id).toSet();
      expect(ids.length, UnitDatabase.all.length);
    });

    test('melee units have short range', () {
      for (final unit in UnitDatabase.all) {
        if (unit.isMelee) {
          expect(unit.range, lessThanOrEqualTo(60),
              reason: '${unit.id} is melee but has long range');
        }
      }
    });
  });

  group('Evolutions', () {
    test('has exactly 8 evolved forms', () {
      expect(UnitDatabase.evolutions.length, 8);
    });

    test('every base type has an evolution', () {
      for (final type in UnitType.values) {
        final evo = UnitDatabase.getEvolution(type);
        expect(evo, isNotNull, reason: '$type has no evolution');
      }
    });

    test('evolution relic IDs follow naming convention', () {
      for (final evo in UnitDatabase.evolutions) {
        expect(evo.requiredRelicId, startsWith('evolve_'),
            reason: '${evo.id} relic ID should start with evolve_');
      }
    });

    test('evolution ATK multipliers are > 1', () {
      for (final evo in UnitDatabase.evolutions) {
        expect(evo.atkMultiplier, greaterThan(1.0),
            reason: '${evo.id} atkMultiplier');
      }
    });
  });
}
