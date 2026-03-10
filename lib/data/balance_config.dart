/// Central balance configuration for castle defense.
/// ALL tunable game numbers live here. Edit this file to adjust difficulty.
class BalanceConfig {
  // ══════════════════════════════════════
  // Enemy Scaling
  // ══════════════════════════════════════

  /// Enemy HP multiplier per wave: baseHp * pow(this, wave).
  static const double enemyHpWaveScale = 1.08;

  /// Enemy HP bonus per placed unit: baseHp * (1 + units * this).
  static const double enemyHpUnitScale = 0.12;

  /// Enemy speed bonus per placed unit: baseSpeed * (1 + units * this).
  static const double enemySpeedUnitScale = 0.02;

  /// Enemy speed bonus per wave after wave 30: baseSpeed * (1 + max(0, wave-30) * this).
  static const double enemySpeedLateWaveScale = 0.005;

  /// Late wave speed scaling starts at this wave.
  static const int enemySpeedLateWaveStart = 30;

  // ══════════════════════════════════════
  // Wave System
  // ══════════════════════════════════════

  /// Duration of each wave in seconds.
  static const double waveDuration = 20.0;

  /// Pause between waves in seconds.
  static const double betweenWavePause = 3.0;

  /// Min spawn interval (max spawn rate).
  static const double minSpawnInterval = 0.15;

  /// Max spawn interval (min spawn rate).
  static const double maxSpawnInterval = 3.0;

  /// Boss appears every N waves.
  static const int bossInterval = 10;

  /// Reward selection every N waves.
  static const int rewardInterval = 5;

  /// Base enemy count per wave tier: [maxWave, count].
  static const List<List<int>> baseEnemyCountTiers = [
    [5, 5],
    [10, 7],
    [20, 10],
    [30, 13],
  ];

  /// Default base enemy count for waves beyond all tiers.
  static const int baseEnemyCountDefault = 16;

  /// Enemy count scales with wave: base + wave * this.
  static const double enemyCountWaveScale = 0.8;

  /// Enemy count scales with units: count * (1 + units * this).
  static const double enemyCountUnitScale = 0.04;

  /// Max enemies per wave (hard cap).
  static const int maxEnemiesPerWave = 200;

  // ══════════════════════════════════════
  // Unit Stats & Scaling
  // ══════════════════════════════════════

  /// Unit ATK multiplier per level: baseAtk * pow(this, level - 1).
  static const double unitAtkLevelBase = 2.0;

  /// Unit ATK speed bonus per level: baseSpeed * (1 + (level-1) * this).
  static const double unitAtkSpeedPerLevel = 0.1;

  /// Unit range bonus per level (px).
  static const double unitRangePerLevel = 5.0;

  /// Max unit level (via merging).
  static const int maxUnitLevel = 5;

  /// Units required to merge (3 same → 1 higher).
  static const int mergeCount = 3;

  // ══════════════════════════════════════
  // Economy
  // ══════════════════════════════════════

  /// Base cost for first unit.
  static const int baseUnitCost = 10;

  /// Unit cost scaling per purchase: cost * pow(this, purchased).
  static const double unitCostScale = 1.15;

  /// Sell refund percentage (0.5 = 50%).
  static const double sellRefundRate = 0.5;

  /// Reroll cost in gold.
  static const int rerollCost = 20;

  /// Perfect wave bonus gold per consecutive count.
  static const int perfectWaveGoldPerStreak = 5;

  /// Base star reward = wave number * starMultiplier.
  static const double baseStarMultiplier = 1.0;

  // ══════════════════════════════════════
  // Boss
  // ══════════════════════════════════════

  /// Boss base HP.
  static const double bossBaseHp = 200.0;

  /// Boss speed.
  static const double bossSpeed = 20.0;

  /// Boss damage.
  static const double bossDamage = 20.0;

  /// Boss attack speed.
  static const double bossAtkSpeed = 0.5;

  /// Boss gold drop.
  static const int bossGoldDrop = 50;

  // ══════════════════════════════════════
  // Wall
  // ══════════════════════════════════════

  /// Wall base HP.
  static const double wallBaseHp = 100.0;

  /// Wall HP per level.
  static const double wallHpPerLevel = 30.0;

  // ══════════════════════════════════════
  // Relic Bonuses
  // ══════════════════════════════════════

  /// Max relics per run.
  static const int maxRelics = 3;

  static const double relicAtkBonus = 0.15;
  static const double relicAtkSpeedBonus = 0.15;
  static const double relicGoldBonus = 0.30;
  static const double relicWallDefenseBonus = 0.20;
  static const double relicCritBonus = 0.10;
  static const double relicLifestealPercent = 0.02;
  static const double relicStarBonus = 0.20;

  // ══════════════════════════════════════
  // Reward Buffs (Wave Rewards)
  // ══════════════════════════════════════

  /// Duration of temporary reward buffs in waves.
  static const int rewardBuffDurationWaves = 999; // lasts entire run

  /// Common reward: ATK bonus.
  static const double rewardAtkBonus = 0.10;

  /// Common reward: wall heal percent.
  static const double rewardWallHealPercent = 0.10;

  /// Common reward: gold bonus.
  static const double rewardGoldBonus = 0.15;

  /// Common reward: ATK speed bonus.
  static const double rewardAtkSpeedBonus = 0.10;

  /// Common reward: range bonus.
  static const double rewardRangeBonus = 0.15;

  /// Rare reward: unit cost discount.
  static const double rewardUnitCostDiscount = 0.20;

  /// Rare reward: wall defense bonus.
  static const double rewardWallDefenseBonus = 0.20;

  /// Epic reward: large ATK bonus.
  static const double rewardAtkBonusLarge = 0.25;

  /// Epic reward: wall auto-regen per second.
  static const double rewardWallAutoRegen = 1.0;

  /// Epic reward: unit cost discount large.
  static const double rewardUnitCostDiscountLarge = 0.30;

  // ══════════════════════════════════════
  // Fox Assassin
  // ══════════════════════════════════════

  /// Fox crit chance.
  static const double foxCritChance = 0.20;

  /// Fox crit multiplier.
  static const double foxCritMultiplier = 2.0;

  // ══════════════════════════════════════
  // Turtle Healer
  // ══════════════════════════════════════

  /// Fraction of attack damage healed to wall per turtle healer hit.
  static const double turtleHealerHealFraction = 0.5;

  // ══════════════════════════════════════
  // Bear Tanker Slow
  // ══════════════════════════════════════

  /// Slow intensity applied by bear tanker on hit (0.3 = 30% slow).
  static const double bearSlowIntensity = 0.3;

  /// Duration of bear tanker slow in seconds.
  static const double bearSlowDuration = 2.5;

  // ══════════════════════════════════════
  // Relic Slow Aura
  // ══════════════════════════════════════

  /// Slow intensity for relic_slow_aura near wall (0.2 = 20% slow).
  static const double relicSlowAuraIntensity = 0.2;

  /// Radius of relic slow aura around wall.
  static const double relicSlowAuraRadius = 80.0;

  // ══════════════════════════════════════
  // Bomber
  // ══════════════════════════════════════

  /// Bomber explosion damage multiplier.
  static const double bomberExplosionMultiplier = 2.0;

  // ══════════════════════════════════════
  // Projectile
  // ══════════════════════════════════════

  /// Default projectile speed.
  static const double projectileSpeed = 200.0;

  /// Splash radius for splash units.
  static const double splashRadius = 40.0;

  // ══════════════════════════════════════
  // Viewport
  // ══════════════════════════════════════

  /// Game viewport width (portrait).
  static const double gameWidth = 400;

  /// Game viewport height (portrait).
  static const double gameHeight = 700;
}
