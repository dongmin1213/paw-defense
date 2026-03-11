import 'package:flutter_test/flutter_test.dart';
import 'package:paw_defense/data/unit_data.dart';
import 'package:paw_defense/data/hybrid_unit_data.dart';
import 'package:paw_defense/data/enemy_data.dart';
import 'package:paw_defense/data/relic_data.dart';

void main() {
  group('Codex content completeness', () {
    test('all base units are discoverable', () {
      expect(UnitDatabase.all.length, 8);
      for (final u in UnitDatabase.all) {
        expect(u.id, isNotEmpty);
        expect(u.emoji, isNotEmpty);
      }
    });

    test('all hybrid units are discoverable', () {
      expect(HybridDatabase.all.length, 28);
      for (final h in HybridDatabase.all) {
        expect(h.id, isNotEmpty);
        expect(h.emoji, isNotEmpty);
        expect(h.name, isNotEmpty);
      }
    });

    test('all enemies are discoverable', () {
      expect(EnemyDatabase.all.length, greaterThanOrEqualTo(10));
      for (final e in EnemyDatabase.all) {
        expect(e.id, isNotEmpty);
      }
    });

    test('all relics are discoverable', () {
      expect(RelicDatabase.all.length, greaterThanOrEqualTo(50));
      for (final r in RelicDatabase.all) {
        expect(r.id, isNotEmpty);
        expect(r.name, isNotEmpty);
      }
    });

    test('base units have 8 evolutions', () {
      int evoCount = 0;
      for (final t in UnitType.values) {
        if (UnitDatabase.getEvolution(t) != null) evoCount++;
      }
      expect(evoCount, 8);
    });

    test('codex total items exceed 100', () {
      final total = UnitDatabase.all.length +
          HybridDatabase.all.length +
          EnemyDatabase.all.length +
          RelicDatabase.all.length;
      expect(total, greaterThan(100));
    });
  });

  group('Hybrid recipes completeness', () {
    test('all C(8,2)=28 combinations exist', () {
      final recipes = HybridDatabase.allRecipes;
      expect(recipes.length, 28);
    });

    test('every recipe has valid parent types', () {
      for (final r in HybridDatabase.allRecipes) {
        expect(r.parentA, isNotEmpty);
        expect(r.parentB, isNotEmpty);
        expect(r.parentA, isNot(r.parentB),
            reason: 'Hybrid parents must be different types');
      }
    });

    test('hybrid lookup is bidirectional', () {
      for (final r in HybridDatabase.allRecipes) {
        final ab = HybridDatabase.findHybrid(r.parentA, r.parentB);
        final ba = HybridDatabase.findHybrid(r.parentB, r.parentA);
        expect(ab, isNotNull,
            reason: '${r.parentA}+${r.parentB} should find hybrid');
        expect(ba, isNotNull,
            reason: '${r.parentB}+${r.parentA} should find hybrid (reverse)');
        expect(ab!.id, ba!.id,
            reason: 'Bidirectional lookup should return same hybrid');
      }
    });
  });
}
