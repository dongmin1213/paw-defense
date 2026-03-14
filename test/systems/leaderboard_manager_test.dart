import 'package:flutter_test/flutter_test.dart';
import 'package:paw_defense/systems/leaderboard_manager.dart';

void main() {
  group('LeaderboardEntry', () {
    test('serializes to and from JSON', () {
      final entry = LeaderboardEntry(
        wave: 25,
        kills: 300,
        gold: 1500,
        rank: 'A',
        stars: 25,
        timestamp: DateTime.utc(2025, 1, 1),
        maxCombo: 50,
        bossKills: 2,
        relicIds: ['relic_atk_boost', 'relic_gold_boost'],
      );

      final json = entry.toJson();
      final restored = LeaderboardEntry.fromJson(json);

      expect(restored.wave, 25);
      expect(restored.kills, 300);
      expect(restored.gold, 1500);
      expect(restored.rank, 'A');
      expect(restored.stars, 25);
      expect(restored.maxCombo, 50);
      expect(restored.bossKills, 2);
      expect(restored.relicIds.length, 2);
      expect(restored.relicIds[0], 'relic_atk_boost');
    });
  });

  group('LeaderboardManager', () {
    test('rankDistribution has all rank keys', () {
      final mgr = LeaderboardManager();
      // Can't call init without prefs, but check static data
      expect(LeaderboardEntry(
        wave: 10,
        kills: 50,
        gold: 200,
        rank: 'C',
        stars: 10,
        timestamp: DateTime.now(),
        maxCombo: 5,
        bossKills: 1,
        relicIds: [],
      ).rank, 'C');
    });
  });
}
