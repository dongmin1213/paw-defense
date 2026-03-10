import 'package:flutter_test/flutter_test.dart';
import 'package:paw_defense/data/hybrid_unit_data.dart';

void main() {
  group('HybridDatabase', () {
    test('has 28 recipes (all C(8,2) combinations)', () {
      expect(HybridDatabase.recipes.length, 28);
    });

    test('has 28 hybrid unit data entries', () {
      expect(HybridDatabase.all.length, 28);
    });

    test('all hybrid IDs are unique', () {
      final ids = HybridDatabase.all.map((h) => h.id).toSet();
      expect(ids.length, 28);
    });

    test('every recipe has matching data', () {
      for (final recipe in HybridDatabase.recipes) {
        final data = HybridDatabase.get(recipe.hybridId);
        expect(data, isNotNull,
            reason: 'Recipe ${recipe.hybridId} has no matching data');
      }
    });

    test('no duplicate recipes (same pair)', () {
      final pairs = <String>{};
      for (final recipe in HybridDatabase.recipes) {
        final sorted = [recipe.parentA, recipe.parentB]..sort();
        final key = '${sorted[0]}_${sorted[1]}';
        expect(pairs.contains(key), false,
            reason: 'Duplicate recipe: $key');
        pairs.add(key);
      }
    });
  });

  group('HybridRecipe.matches', () {
    test('matches in both orders', () {
      final recipe = HybridDatabase.recipes.first; // cat+fox
      expect(recipe.matches(recipe.parentA, recipe.parentB), true);
      expect(recipe.matches(recipe.parentB, recipe.parentA), true);
    });

    test('does not match wrong types', () {
      final recipe = HybridDatabase.recipes.first;
      expect(recipe.matches('cat_archer', 'bear_tanker'), false);
    });
  });

  group('HybridDatabase.findRecipe', () {
    test('finds recipe for valid pair', () {
      final recipe = HybridDatabase.findRecipe('cat_archer', 'fox_assassin');
      expect(recipe, isNotNull);
      expect(recipe!.hybridId, 'hybrid_flame_hunter');
    });

    test('finds recipe in reverse order', () {
      final recipe = HybridDatabase.findRecipe('fox_assassin', 'cat_archer');
      expect(recipe, isNotNull);
      expect(recipe!.hybridId, 'hybrid_flame_hunter');
    });

    test('returns null for same type', () {
      expect(HybridDatabase.findRecipe('cat_archer', 'cat_archer'), isNull);
    });

    test('returns null for invalid type', () {
      expect(HybridDatabase.findRecipe('cat_archer', 'dragon'), isNull);
    });
  });

  group('HybridDatabase.isHybrid', () {
    test('identifies hybrid IDs', () {
      expect(HybridDatabase.isHybrid('hybrid_flame_hunter'), true);
      expect(HybridDatabase.isHybrid('hybrid_iron_warrior'), true);
    });

    test('rejects base unit IDs', () {
      expect(HybridDatabase.isHybrid('cat_archer'), false);
      expect(HybridDatabase.isHybrid('dog_warrior'), false);
    });
  });

  group('HybridUnitData stats', () {
    test('all hybrids have positive stats', () {
      for (final h in HybridDatabase.all) {
        expect(h.baseAtk, greaterThan(0), reason: '${h.id} baseAtk');
        expect(h.baseAtkSpeed, greaterThan(0), reason: '${h.id} baseAtkSpeed');
        expect(h.range, greaterThan(0), reason: '${h.id} range');
      }
    });

    test('all hybrids have valid parent references', () {
      final baseTypes = [
        'cat_archer', 'dog_warrior', 'rabbit_mage', 'bear_tanker',
        'fox_assassin', 'bird_scout', 'turtle_healer', 'owl_wizard',
      ];
      for (final h in HybridDatabase.all) {
        expect(baseTypes.contains(h.parentA), true,
            reason: '${h.id} has invalid parentA: ${h.parentA}');
        expect(baseTypes.contains(h.parentB), true,
            reason: '${h.id} has invalid parentB: ${h.parentB}');
      }
    });
  });
}
