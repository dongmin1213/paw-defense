/// Castle defense balance configuration.
/// All formulas and tuning constants in one place.

import 'dart:math';

class DefenseBalance {
  // === Enemy Scaling ===

  /// Enemy HP scales with wave and number of units placed.
  /// HP = baseHP * pow(1.08, wave) * (1 + unitCount * 0.12)
  static double enemyHp(double baseHp, int wave, int unitCount) {
    return baseHp * pow(1.08, wave) * (1.0 + unitCount * 0.12);
  }

  /// Number of enemies per wave.
  /// count = (baseCount + (wave * 0.8).floor()) * (1 + unitCount * 0.04)
  static int enemyCount(int baseCount, int wave, int unitCount) {
    final raw = (baseCount + (wave * 0.8).floor()) * (1.0 + unitCount * 0.04);
    return raw.floor();
  }

  /// Enemy speed scales slightly with unit count and late waves.
  /// speed = baseSpeed * (1 + unitCount * 0.02) * (1 + max(0, wave - 30) * 0.005)
  static double enemySpeed(double baseSpeed, int wave, int unitCount) {
    return baseSpeed *
        (1.0 + unitCount * 0.02) *
        (1.0 + max(0, wave - 30) * 0.005);
  }

  // === Boss Scaling ===

  /// Boss HP = 100 * pow(1.15, wave) * (1 + unitCount * 0.08)
  static double bossHp(int wave, int unitCount) {
    return 100.0 * pow(1.15, wave) * (1.0 + unitCount * 0.08);
  }

  // === Unit Scaling ===

  /// Unit DPS doubles per level: baseATK * pow(2.0, level - 1)
  static double unitDps(double baseAtk, int level) {
    return baseAtk * pow(2.0, level - 1);
  }

  /// Cost to place the next unit: 10 + (currentUnitCount * 3)
  static int unitPlacementCost(int currentUnitCount) {
    return 10 + (currentUnitCount * 3);
  }

  // === Rewards ===

  /// Star reward after a run: floor(maxWave * 1.5) + bossKills * 10
  static int starReward(int maxWave, int bossKills) {
    return (maxWave * 1.5).floor() + bossKills * 10;
  }

  // === Permanent Upgrade Cost ===

  /// Upgrade cost = baseCost * pow(1.12, level)
  static const double upgradeCostMultiplier = 1.12;

  static double upgradeCost(double baseCost, int currentLevel) {
    return baseCost * pow(upgradeCostMultiplier, currentLevel);
  }

  // === Ascension ===

  /// Ascension threshold = 5000 * pow(3, ascensionCount)
  static double ascensionThreshold(int ascensionCount) {
    return 5000.0 * pow(3, ascensionCount).toDouble();
  }

  // === Wave Timing ===

  /// Seconds between waves.
  static const double waveInterval = 20.0;

  /// Seconds before next wave can be fast-forwarded.
  static const double waveFastForwardDelay = 5.0;

  // === Idle / Offline ===

  /// Seconds of no input before idle mode activates.
  static const double idleDetectionTime = 10.0;

  /// Maximum offline reward hours.
  static const double maxOfflineHours = 12.0;

  /// Offline reward efficiency (fraction of active earnings).
  static const double offlineEfficiency = 0.3;

  // === Unit Limits ===

  /// Base max unit slots on field.
  static const int baseMaxUnits = 6;

  /// Max unit level (before evolution).
  static const int maxUnitLevel = 5;

  /// Evolution requires max level + matching relic.
  static const int evolutionRequiredLevel = 5;

  // === Wall ===

  /// Base wall HP at the start of a run.
  static const double baseWallHp = 100.0;

  /// Wall regen per second (base, before upgrades).
  static const double baseWallRegen = 0.0;

  // === Gold ===

  /// Starting gold per run.
  static const int startingGold = 20;

  /// Gold multiplier for active play (tap bonus).
  static const double activePlayGoldBonus = 1.5;
}
