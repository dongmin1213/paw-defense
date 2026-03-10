import 'package:flutter_test/flutter_test.dart';
import 'package:paw_defense/data/relic_data.dart';

void main() {
  group('RelicDatabase', () {
    test('has 58 relics total', () {
      expect(RelicDatabase.all.length, 58);
    });

    test('all relic IDs are unique', () {
      final ids = RelicDatabase.allIds.toSet();
      expect(ids.length, RelicDatabase.all.length);
    });

    test('get() returns correct relic', () {
      final relic = RelicDatabase.get('relic_atk_boost');
      expect(relic, isNotNull);
      expect(relic!.name, '분노의 부적');
    });

    test('get() returns null for unknown ID', () {
      expect(RelicDatabase.get('nonexistent'), isNull);
    });

    test('has 8 evolution relics', () {
      final evoRelics = RelicDatabase.all
          .where((r) => r.id.startsWith('evolve_'))
          .toList();
      expect(evoRelics.length, 8);
    });

    test('evolution relics are rare rarity', () {
      final evoRelics = RelicDatabase.all
          .where((r) => r.id.startsWith('evolve_'));
      for (final r in evoRelics) {
        expect(r.rarity, RelicRarity.rare,
            reason: '${r.id} should be rare');
      }
    });

    test('byRarity filters correctly', () {
      final commons = RelicDatabase.byRarity(RelicRarity.common);
      expect(commons.length, 15);

      // 15 + 8 evo = 23 rare
      final rares = RelicDatabase.byRarity(RelicRarity.rare);
      expect(rares.length, 23);

      final epics = RelicDatabase.byRarity(RelicRarity.epic);
      expect(epics.length, 12);

      final legendaries = RelicDatabase.byRarity(RelicRarity.legendary);
      expect(legendaries.length, 6);

      final mythics = RelicDatabase.byRarity(RelicRarity.mythic);
      expect(mythics.length, 2);
    });

    test('rarity distribution sums to 58', () {
      int total = 0;
      for (final rarity in RelicRarity.values) {
        total += RelicDatabase.byRarity(rarity).length;
      }
      expect(total, 58);
    });
  });

  group('RelicRarity', () {
    test('weights are defined correctly', () {
      expect(RelicRarity.common.weight, 40);
      expect(RelicRarity.rare.weight, 30);
      expect(RelicRarity.epic.weight, 20);
      expect(RelicRarity.legendary.weight, 8);
      expect(RelicRarity.mythic.weight, 2);
    });

    test('total weight is 100', () {
      final totalWeight = RelicRarity.values
          .fold<int>(0, (sum, r) => sum + r.weight);
      expect(totalWeight, 100);
    });
  });
}
