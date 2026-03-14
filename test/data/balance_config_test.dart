import 'package:flutter_test/flutter_test.dart';
import 'package:paw_defense/data/balance_config.dart';

void main() {
  group('BalanceConfig', () {
    test('enemy scaling values are reasonable', () {
      expect(BalanceConfig.enemyHpWaveScale, greaterThan(1.0));
      expect(BalanceConfig.enemyHpWaveScale, lessThan(1.5));
      expect(BalanceConfig.enemyHpUnitScale, greaterThan(0));
      expect(BalanceConfig.enemySpeedUnitScale, greaterThan(0));
    });

    test('wave system values are reasonable', () {
      expect(BalanceConfig.waveDuration, greaterThan(0));
      expect(BalanceConfig.bossInterval, 10);
      expect(BalanceConfig.rewardInterval, 5);
      expect(BalanceConfig.minSpawnInterval, lessThan(BalanceConfig.maxSpawnInterval));
    });

    test('unit merge count is 3', () {
      expect(BalanceConfig.mergeCount, 3);
    });

    test('max unit level is 5', () {
      expect(BalanceConfig.maxUnitLevel, 5);
    });

    test('economy values are reasonable', () {
      expect(BalanceConfig.baseUnitCost, greaterThan(0));
      expect(BalanceConfig.unitCostScale, greaterThan(1.0));
      expect(BalanceConfig.sellRefundRate, greaterThan(0));
      expect(BalanceConfig.sellRefundRate, lessThanOrEqualTo(1.0));
      expect(BalanceConfig.rerollCost, greaterThan(0));
    });

    test('viewport dimensions match portrait 400x700', () {
      expect(BalanceConfig.gameWidth, 400);
      expect(BalanceConfig.gameHeight, 700);
    });

    test('max relics is 5', () {
      expect(BalanceConfig.maxRelics, 5);
    });

    test('base enemy count tiers are sorted', () {
      int prevWave = 0;
      for (final tier in BalanceConfig.baseEnemyCountTiers) {
        expect(tier[0], greaterThan(prevWave));
        expect(tier[1], greaterThan(0));
        prevWave = tier[0];
      }
    });

    test('enemy speed cap is reasonable', () {
      expect(BalanceConfig.enemySpeedMaxMultiplier, greaterThan(1.0));
      expect(BalanceConfig.enemySpeedMaxMultiplier, lessThanOrEqualTo(5.0));
    });

    test('pity system thresholds are reasonable', () {
      expect(BalanceConfig.pityEpicThreshold, greaterThan(0));
      expect(BalanceConfig.pityLegendaryThreshold, greaterThan(BalanceConfig.pityEpicThreshold));
    });

    test('late-game soft cap values are reasonable', () {
      expect(BalanceConfig.enemyHpSoftCapWave, greaterThan(30));
      expect(BalanceConfig.enemyHpSoftCapMultiplier, greaterThan(0));
      expect(BalanceConfig.enemyHpSoftCapMultiplier, lessThan(1.0));
    });

    test('catch-up system values are reasonable', () {
      expect(BalanceConfig.catchUpGoldMultiplier, greaterThan(1.0));
      expect(BalanceConfig.catchUpWaveThreshold, greaterThan(0));
    });

    test('battle pass constants exist', () {
      expect(BalanceConfig.battlePassSeasonDays, 30);
      expect(BalanceConfig.battlePassTiers, 30);
      expect(BalanceConfig.battlePassXpPerTier, greaterThan(0));
    });

    test('leaderboard max entries is reasonable', () {
      expect(BalanceConfig.maxLeaderboardEntries, greaterThanOrEqualTo(20));
    });
  });
}
