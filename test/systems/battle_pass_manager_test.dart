import 'package:flutter_test/flutter_test.dart';
import 'package:paw_defense/systems/battle_pass_manager.dart';

void main() {
  group('BattlePassManager', () {
    test('has exactly 30 reward tiers', () {
      expect(BattlePassManager.rewards.length, 30);
    });

    test('reward tiers are sequential 1-30', () {
      for (int i = 0; i < BattlePassManager.rewards.length; i++) {
        expect(BattlePassManager.rewards[i].tier, i + 1);
      }
    });

    test('all rewards have positive amounts', () {
      for (final reward in BattlePassManager.rewards) {
        expect(reward.amount, greaterThan(0), reason: 'Tier ${reward.tier}');
      }
    });

    test('XP per tier escalates', () {
      final xp1 = BattlePassManager.xpForTier(1);
      final xp10 = BattlePassManager.xpForTier(10);
      final xp30 = BattlePassManager.xpForTier(30);
      expect(xp10, greaterThan(xp1));
      expect(xp30, greaterThan(xp10));
    });

    test('totalXpForTier is cumulative', () {
      final t1 = BattlePassManager.totalXpForTier(1);
      final t2 = BattlePassManager.totalXpForTier(2);
      expect(t2, t1 + BattlePassManager.xpForTier(2));
    });

    test('currentSeason returns a positive value', () {
      expect(BattlePassManager.currentSeason(), greaterThan(0));
    });

    test('maxTier is 30', () {
      expect(BattlePassManager.maxTier, 30);
    });

    test('XP constants are positive', () {
      expect(BattlePassManager.xpPerKill, greaterThan(0));
      expect(BattlePassManager.xpPerWave, greaterThan(0));
      expect(BattlePassManager.xpPerBossKill, greaterThan(0));
      expect(BattlePassManager.xpPerMerge, greaterThan(0));
    });
  });
}
