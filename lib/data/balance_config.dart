import 'dart:math';

class BalanceConfig {
  // === 경제 ===
  static const double upgradeCostMultiplier = 1.15;
  static const double airEnemyCoinMultiplier = 3.0;
  static const double offlineEfficiency = 0.3;

  // === 콤보 ===
  static const double comboMultiplierPerStack = 0.05;
  static const double comboResetTime = 3.0;
  static const int jumpKillComboBonus = 2;
  static const int groundKillComboBonus = 1;

  // === 적 ===
  static const double enemySpawnInterval = 1.5; // seconds worth of distance
  static const double airEnemyChance = 0.35; // 35% air, 65% ground
  static const double goldenEnemyChance = 0.02;

  // === 장애물 ===
  static const double obstacleSpawnChance = 0.3;
  static const double obstacleSlowdownFactor = 0.5;
  static const double obstacleSlowdownDuration = 2.0;

  // === 속도 ===
  static double speedMultiplier(double distance) {
    return 1.0 + 0.25 * log(1.0 + distance / 150.0);
  }

  // === 초월 ===
  static double ascensionCoinThreshold(int count) {
    return 10000.0 * pow(3, count).toDouble();
  }

  static int soulReward(double totalCoins) {
    if (totalCoins <= 1000) return 1;
    return max(1, (log(totalCoins) / ln10 - 3).floor());
  }

  // === 업그레이드 비용 ===
  static double upgradeCost(double baseCost, int currentLevel) {
    return baseCost * pow(upgradeCostMultiplier, currentLevel).toDouble();
  }

  // === 방치/적극 모드 ===
  static const double idleDetectionTime = 5.0; // 5초 무입력 = 방치 모드
  static const double activePlayCoinBonus = 1.5; // 적극 플레이 시 코인 보너스
}
