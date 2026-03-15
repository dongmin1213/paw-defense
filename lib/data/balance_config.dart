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

  /// Maximum enemy speed multiplier (caps late-game speed scaling).
  static const double enemySpeedMaxMultiplier = 3.0;

  // ══════════════════════════════════════
  // Wave System
  // ══════════════════════════════════════

  /// Duration of each wave in seconds.
  static const double waveDuration = 20.0;

  /// Pause between waves in seconds.
  static const double betweenWavePause = 3.0;

  /// Min spawn interval (max spawn rate) — very fast for swarm density.
  static const double minSpawnInterval = 0.03;

  /// Max spawn interval (min spawn rate).
  static const double maxSpawnInterval = 1.5;

  /// Boss appears every N waves.
  static const int bossInterval = 10;

  /// Reward selection every N waves.
  static const int rewardInterval = 5;

  /// Base enemy count per wave tier: [maxWave, count].
  /// Massive density from wave 1 for screen-filling spectacle — compensated by swarmHpMultiplier.
  static const List<List<int>> baseEnemyCountTiers = [
    [3, 40],
    [5, 55],
    [10, 70],
    [20, 90],
    [30, 120],
  ];

  /// Default base enemy count for waves beyond all tiers.
  static const int baseEnemyCountDefault = 150;

  /// Enemy count scales with wave: base + wave * this.
  static const double enemyCountWaveScale = 1.2;

  /// Enemy count scales with units: count * (1 + units * this).
  static const double enemyCountUnitScale = 0.04;

  /// Max enemies per wave (hard cap).
  static const int maxEnemiesPerWave = 300;

  /// HP multiplier for swarm mode — lower HP per enemy, same total wave HP.
  /// Balanced so wave 1 enemies take 2-4 hits (not 1-shot).
  static const double swarmHpMultiplier = 0.30;

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

  /// Max relics per run (base, can be increased by relic_infinity +2).
  static const int maxRelics = 5;

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

  /// Duration of reward buffs in waves — intentionally set to full run duration.
  /// Reward buffs are run-scoped and reset on new run, not per-wave temporary.
  static const int rewardBuffDurationWaves = 999;

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
  // Unit Orbit
  // ══════════════════════════════════════

  /// Base orbit speed in radians/sec (one full rotation ≈ 20 seconds).
  static const double orbitBaseSpeed = 0.3;

  /// Orbit speed bonus per wave: speed *= (1 + wave * this).
  static const double orbitWaveScale = 0.02;

  /// Orbit speed bonus per placed unit: speed *= (1 + units * this).
  static const double orbitUnitScale = 0.05;

  // ══════════════════════════════════════
  // Viewport
  // ══════════════════════════════════════

  /// Game viewport width (portrait).
  static const double gameWidth = 400;

  /// Game viewport height (portrait).
  static const double gameHeight = 700;

  // ══════════════════════════════════════
  // Pity System
  // ══════════════════════════════════════

  /// Pity counter: guaranteed epic+ relic after this many consecutive non-epic drops.
  static const int pityEpicThreshold = 5;

  /// Pity counter: guaranteed legendary+ after this many consecutive non-legendary drops.
  static const int pityLegendaryThreshold = 10;

  // ══════════════════════════════════════
  // Late-game Scaling Improvements
  // ══════════════════════════════════════

  /// Wave at which enemy HP soft cap kicks in.
  static const double enemyHpSoftCapWave = 40;

  /// HP scaling multiplier after soft cap wave (reduces exponential growth).
  static const double enemyHpSoftCapMultiplier = 0.7;

  /// Catch-up gold multiplier for players falling behind.
  static const double catchUpGoldMultiplier = 1.5;

  /// Number of waves behind expected progress to trigger catch-up bonus.
  static const int catchUpWaveThreshold = 5;

  // ══════════════════════════════════════
  // New Game+ (Ascension)
  // ══════════════════════════════════════

  /// Enemy HP multiplier per ascension level.
  static const double ascensionEnemyHpScale = 1.25;

  /// Bonus starting gold per ascension level.
  static const int ascensionBonusGold = 20;

  /// Bonus star multiplier per ascension level.
  static const double ascensionStarMultiplier = 0.15;

  // ══════════════════════════════════════
  // Leaderboard
  // ══════════════════════════════════════

  /// Maximum local leaderboard entries stored.
  static const int maxLeaderboardEntries = 50;

  // ══════════════════════════════════════
  // Story Milestones
  // ══════════════════════════════════════

  /// Waves at which story events trigger.
  static const List<int> storyMilestoneWaves = [5, 10, 15, 20, 30, 40, 50];

  // ══════════════════════════════════════
  // Particle Counts
  // ══════════════════════════════════════

  /// Enemy death burst particle count.
  static const int particleEnemyDeath = 25;

  /// Bomber death burst particle count.
  static const int particleBomberDeath = 40;

  /// Enemy death — white core flash count.
  static const int particleDeathCoreFlash = 2;

  /// Boss explosion particle count.
  static const int particleBossExplosion = 60;

  /// Merge effect base count (+ level * mergePerLevel).
  static const int particleMergeBase = 10;

  /// Merge effect per-level bonus.
  static const int particleMergePerLevel = 5;

  /// Merge evolution (Lv5) extra gold burst count.
  static const int particleMergeEvolution = 12;

  /// Wall hit impact sparks.
  static const int particleWallHit = 6;

  /// Wave start celebration burst.
  static const int particleWaveStart = 12;

  /// Critical hit base count (scaled by combo).
  static const int particleCriticalHit = 12;

  /// Chain kill lightning arc steps.
  static const int particleChainKill = 8;

  /// Hybrid merge two-color swirl count.
  static const int particleHybridMerge = 25;

  /// Combo milestone flash burst count.
  static const int particleComboFlash = 80;

  /// Projectile hit impact burst.
  static const int particleProjectileHit = 8;

  /// Skill activation radial burst.
  static const int particleSkillActivation = 70;

  /// Heal sparkle effect.
  static const int particleHealEffect = 10;

  /// Wall damage directional sparks.
  static const int particleWallDamage = 10;

  /// Evolution golden spiral burst.
  static const int particleEvolution = 30;

  /// Skill ring burst.
  static const int particleSkillRing = 40;

  /// Scaled death base count (multiplied by combo scale).
  static const int particleScaledDeathBase = 25;

  /// Scaled death clamp min.
  static const int particleScaledDeathMin = 12;

  /// Scaled death clamp max.
  static const int particleScaledDeathMax = 80;

  /// Shockwave ring count.
  static const int particleShockwaveRing = 48;

  /// Muzzle flash base count (+ level * 2).
  static const int particleMuzzleFlashBase = 2;

  /// Muzzle flash per-level bonus.
  static const int particleMuzzleFlashPerLevel = 2;

  /// Gold collect burst.
  static const int particleGoldCollect = 8;

  /// Gold scatter min count.
  static const int particleGoldScatterMin = 5;

  /// Gold scatter max count.
  static const int particleGoldScatterMax = 20;

  /// Skill activation radial burst (duplicate for skill_manager usage).
  static const int particleSkillRingCount = 40;

  /// Global particle hard cap.
  static const int particleHardCap = 2000;

  /// Ground mark cap.
  static const int groundMarkCap = 150;

  /// Ground mark keep count after trim.
  static const int groundMarkKeep = 120;

  /// Background ambient star count.
  static const int backgroundStarCount = 120;
}
