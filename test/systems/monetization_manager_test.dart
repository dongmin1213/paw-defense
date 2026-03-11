import 'package:flutter_test/flutter_test.dart';
import 'package:paw_defense/systems/monetization_manager.dart';

void main() {
  group('MonetizationManager data', () {
    test('castle skins include default', () {
      expect(
        MonetizationManager.castleSkins.any((s) => s.id == 'default'),
        isTrue,
      );
    });

    test('castle skins have at least 5 options', () {
      expect(MonetizationManager.castleSkins.length, greaterThanOrEqualTo(5));
    });

    test('particle themes include default', () {
      expect(
        MonetizationManager.particleThemes.any((s) => s.id == 'default'),
        isTrue,
      );
    });

    test('particle themes have at least 5 options', () {
      expect(
          MonetizationManager.particleThemes.length, greaterThanOrEqualTo(5));
    });

    test('default items are free', () {
      final defaultCastle =
          MonetizationManager.castleSkins.firstWhere((s) => s.id == 'default');
      expect(defaultCastle.gemCost, 0);
      expect(defaultCastle.rarity, CosmeticRarity.free);

      final defaultParticle = MonetizationManager.particleThemes
          .firstWhere((s) => s.id == 'default');
      expect(defaultParticle.gemCost, 0);
      expect(defaultParticle.rarity, CosmeticRarity.free);
    });

    test('all non-free skins have positive gem cost', () {
      for (final s in MonetizationManager.castleSkins) {
        if (s.rarity != CosmeticRarity.free) {
          expect(s.gemCost, greaterThan(0),
              reason: '${s.id} should have gem cost');
        }
      }
    });

    test('all cosmetic items have unique IDs', () {
      final castleIds =
          MonetizationManager.castleSkins.map((s) => s.id).toSet();
      expect(castleIds.length, MonetizationManager.castleSkins.length);

      final particleIds =
          MonetizationManager.particleThemes.map((s) => s.id).toSet();
      expect(particleIds.length, MonetizationManager.particleThemes.length);
    });

    test('all cosmetic items have non-empty names', () {
      for (final s in MonetizationManager.castleSkins) {
        expect(s.name, isNotEmpty, reason: '${s.id} should have a name');
      }
      for (final s in MonetizationManager.particleThemes) {
        expect(s.name, isNotEmpty, reason: '${s.id} should have a name');
      }
    });
  });

  group('Rewarded ad slots', () {
    test('has at least 3 ad reward types', () {
      expect(
          MonetizationManager.rewardedAdSlots.length, greaterThanOrEqualTo(3));
    });

    test('all slots have unique IDs', () {
      final ids =
          MonetizationManager.rewardedAdSlots.map((s) => s.id).toSet();
      expect(ids.length, MonetizationManager.rewardedAdSlots.length);
    });

    test('all slots have positive max per day', () {
      for (final s in MonetizationManager.rewardedAdSlots) {
        expect(s.maxPerDay, greaterThan(0));
      }
    });

    test('max daily rewarded ads is reasonable', () {
      expect(MonetizationManager.maxDailyRewardedAds, greaterThan(0));
      expect(MonetizationManager.maxDailyRewardedAds, lessThanOrEqualTo(10));
    });
  });

  group('IAP product IDs', () {
    test('all product IDs are non-empty', () {
      expect(MonetizationManager.iapRemoveAds, isNotEmpty);
      expect(MonetizationManager.iapGems100, isNotEmpty);
      expect(MonetizationManager.iapGems500, isNotEmpty);
      expect(MonetizationManager.iapGems1200, isNotEmpty);
      expect(MonetizationManager.iapBattlePass, isNotEmpty);
      expect(MonetizationManager.iapStarterPack, isNotEmpty);
    });

    test('product IDs are unique', () {
      final ids = {
        MonetizationManager.iapRemoveAds,
        MonetizationManager.iapGems100,
        MonetizationManager.iapGems500,
        MonetizationManager.iapGems1200,
        MonetizationManager.iapBattlePass,
        MonetizationManager.iapStarterPack,
      };
      expect(ids.length, 6, reason: 'All IAP product IDs should be unique');
    });
  });

  group('Battle pass rewards', () {
    test('xp per level is positive', () {
      expect(MonetizationManager.xpPerLevel, greaterThan(0));
    });

    test('max battle pass level is reasonable', () {
      expect(MonetizationManager.maxBattlePassLevel, greaterThanOrEqualTo(20));
      expect(MonetizationManager.maxBattlePassLevel, lessThanOrEqualTo(100));
    });

    test('rewards at every level', () {
      for (int level = 1; level <= MonetizationManager.maxBattlePassLevel;
          level++) {
        final reward = MonetizationManager.getReward(level);
        expect(reward.amount, greaterThan(0),
            reason: 'Level $level reward should have positive amount');
        expect(reward.label, isNotEmpty,
            reason: 'Level $level reward should have a label');
      }
    });

    test('level 10, 20, 30 give gem rewards', () {
      for (final level in [10, 20, 30]) {
        final reward = MonetizationManager.getReward(level);
        expect(reward.type, BattlePassRewardType.gems,
            reason: 'Level $level should give gems');
        expect(reward.amount, greaterThanOrEqualTo(100),
            reason: 'Level $level should give >= 100 gems');
      }
    });

    test('level 5, 15, 25 give skin rewards', () {
      for (final level in [5, 15, 25]) {
        final reward = MonetizationManager.getReward(level);
        expect(reward.type, BattlePassRewardType.skin,
            reason: 'Level $level should give skin');
        expect(reward.skinId, isNotNull,
            reason: 'Level $level skin should have ID');
      }
    });
  });

  group('CosmeticRarity', () {
    test('has 5 tiers', () {
      expect(CosmeticRarity.values.length, 5);
    });

    test('includes free tier', () {
      expect(CosmeticRarity.values.contains(CosmeticRarity.free), isTrue);
    });
  });
}
