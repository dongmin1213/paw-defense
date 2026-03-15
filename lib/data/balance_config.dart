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

  /// Min spawn interval (max spawn rate).
  static const double minSpawnInterval = 0.08;

  /// Max spawn interval (min spawn rate).
  static const double maxSpawnInterval = 1.5;

  /// Boss appears every N waves.
  static const int bossInterval = 10;

  /// Reward selection every N waves.
  static const int rewardInterval = 5;

  /// Base enemy count per wave tier: [maxWave, count].
  /// Massive density from wave 1 for screen-filling spectacle — compensated by swarmHpMultiplier.
  static const List<List<int>> baseEnemyCountTiers = [
    [3, 25],
    [5, 35],
    [10, 45],
    [20, 55],
    [30, 70],
  ];

  /// Default base enemy count for waves beyond all tiers.
  static const int baseEnemyCountDefault = 80;

  /// Enemy count scales with wave: base + wave * this.
  static const double enemyCountWaveScale = 1.2;

  /// Enemy count scales with units: count * (1 + units * this).
  static const double enemyCountUnitScale = 0.04;

  /// Max enemies per wave (hard cap).
  static const int maxEnemiesPerWave = 150;

  /// HP multiplier for swarm mode — lower HP per enemy, same total wave HP.
  /// Balanced so wave 1 enemies take 2-4 hits (not 1-shot).
  static const double swarmHpMultiplier = 0.55;

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
  static const int particleEnemyDeath = 10;

  /// Bomber death burst particle count.
  static const int particleBomberDeath = 18;

  /// Enemy death — white core flash count.
  static const int particleDeathCoreFlash = 2;

  /// Boss explosion particle count.
  static const int particleBossExplosion = 25;

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
  static const int particleComboFlash = 25;

  /// Projectile hit impact burst.
  static const int particleProjectileHit = 8;

  /// Skill activation radial burst.
  static const int particleSkillActivation = 25;

  /// Heal sparkle effect.
  static const int particleHealEffect = 10;

  /// Wall damage directional sparks.
  static const int particleWallDamage = 10;

  /// Evolution golden spiral burst.
  static const int particleEvolution = 15;

  /// Skill ring burst.
  static const int particleSkillRing = 20;

  /// Scaled death base count (multiplied by combo scale).
  static const int particleScaledDeathBase = 25;

  /// Scaled death clamp min.
  static const int particleScaledDeathMin = 12;

  /// Scaled death clamp max.
  static const int particleScaledDeathMax = 30;

  /// Shockwave ring count.
  static const int particleShockwaveRing = 20;

  /// Muzzle flash base count (+ level * 2).
  static const int particleMuzzleFlashBase = 2;

  /// Muzzle flash per-level bonus.
  static const int particleMuzzleFlashPerLevel = 2;

  /// Gold collect burst.
  static const int particleGoldCollect = 8;

  /// Gold scatter min count.
  static const int particleGoldScatterMin = 5;

  /// Gold scatter max count.
  static const int particleGoldScatterMax = 8;

  /// Skill activation radial burst (duplicate for skill_manager usage).
  static const int particleSkillRingCount = 20;

  /// Global particle hard cap.
  static const int particleHardCap = 500;

  /// Ground mark cap.
  static const int groundMarkCap = 60;

  /// Ground mark keep count after trim.
  static const int groundMarkKeep = 40;

  /// Background ambient star count.
  static const int backgroundStarCount = 40;

  // ══════════════════════════════════════
  // Combo System
  // ══════════════════════════════════════

  /// Base time window to maintain combo (seconds).
  static const double comboWindowBase = 2.0;

  /// Bonus gold every N combos.
  static const int comboGoldBonusInterval = 10;

  /// Gold amount per combo interval step (step * this).
  static const int comboGoldPerInterval = 5;

  /// Combo tier change display time (seconds).
  static const double comboTierChangeDisplayTime = 1.5;

  // ══════════════════════════════════════
  // Skill System
  // ══════════════════════════════════════

  /// Default skill max charge.
  static const int skillDefaultMaxCharge = 20;

  /// Default skill effect duration (seconds).
  static const double skillEffectDuration = 5.0;

  /// Skill cooldown after use (seconds).
  static const double skillCooldown = 1.0;

  /// Skill effect overlay max particles.
  static const int skillMaxParticles = 25;

  // ══════════════════════════════════════
  // Wave Modifiers
  // ══════════════════════════════════════

  /// Wave modifiers start from this wave.
  static const int waveModifierStartWave = 10;

  /// Elite modifier: enemy count multiplier.
  static const double modifierEliteCountMult = 0.5;

  /// Elite modifier: enemy HP multiplier.
  static const double modifierEliteHpMult = 3.0;

  /// Swarm modifier: enemy count multiplier.
  static const double modifierSwarmCountMult = 3.0;

  /// Swarm modifier: enemy HP multiplier.
  static const double modifierSwarmHpMult = 0.5;

  /// Speed run modifier: enemy speed multiplier.
  static const double modifierSpeedRunSpeedMult = 2.0;

  /// Golden modifier: gold drop multiplier.
  static const double modifierGoldenGoldMult = 3.0;

  /// Speed run modifier: gold drop multiplier.
  static const double modifierSpeedRunGoldMult = 1.5;

  /// Fog modifier: unit range multiplier.
  static const double modifierFogRangeMult = 0.6;

  // ══════════════════════════════════════
  // Projectile Visual
  // ══════════════════════════════════════

  /// Projectile max life time (seconds).
  static const double projectileMaxLifeTime = 3.0;

  /// Projectile visual scale base at Lv1.
  static const double projectileVisualScaleBase = 1.2;

  /// Projectile visual scale per level.
  static const double projectileVisualScalePerLevel = 0.3;

  /// Projectile visual scale bonus for evolved.
  static const double projectileVisualScaleEvolved = 0.5;

  /// Projectile visual scale bonus for hybrid.
  static const double projectileVisualScaleHybrid = 0.3;

  /// Projectile trail base length.
  static const int projectileTrailBase = 5;

  /// Projectile trail length per level.
  static const int projectileTrailPerLevel = 1;

  /// Projectile trail length bonus for evolved.
  static const int projectileTrailEvolved = 2;

  /// Projectile trail min length.
  static const int projectileTrailMin = 4;

  /// Projectile trail max length.
  static const int projectileTrailMax = 10;

  /// Split shot speed multiplier.
  static const double splitShotSpeedMult = 0.7;

  /// Split shot damage multiplier.
  static const double splitShotDamageMult = 0.5;

  /// Splash damage falloff multiplier.
  static const double splashDamageFalloffMult = 0.5;

  // ══════════════════════════════════════
  // Elemental Effects
  // ══════════════════════════════════════

  /// Fire DoT: percent of damage per second.
  static const double elementalFireDotPercent = 0.30;

  /// Fire DoT duration (seconds).
  static const double elementalFireDuration = 3.0;

  /// Ice slow intensity.
  static const double elementalIceSlowPercent = 0.40;

  /// Ice slow duration (seconds).
  static const double elementalIceDuration = 2.0;

  /// Poison DoT: percent of damage per second.
  static const double elementalPoisonDotPercent = 0.15;

  /// Poison DoT duration (seconds).
  static const double elementalPoisonDuration = 5.0;

  // ══════════════════════════════════════
  // Enemy Behavior
  // ══════════════════════════════════════

  /// Distance at which enemy considers itself at the wall.
  static const double enemyWallProximity = 35.0;

  /// Hit flash duration (seconds).
  static const double enemyHitFlashDuration = 0.1;

  /// Death animation duration (seconds).
  static const double enemyDeathAnimDuration = 0.3;

  /// Healer: heal radius around healer enemy.
  static const double healerRadius = 50.0;

  /// Healer: heal percent of ally max HP per tick.
  static const double healerHealPercent = 0.10;

  /// Healer: heal interval (seconds).
  static const double healerInterval = 3.0;

  /// DoT tick interval (seconds).
  static const double dotTickInterval = 0.5;

  /// Ice wall skill: enemy speed multiplier.
  static const double iceWallSpeedMult = 0.3;

  /// Shielded enemy: frontal damage reduction.
  static const double shieldedDamageReduction = 0.5;

  /// Knockback distance on hit.
  static const double enemyKnockbackDistance = 3.0;

  /// Boss size multiplier.
  static const double bossSizeMultiplier = 1.5;

  /// Big hit threshold (% of max HP).
  static const double bigHitThreshold = 0.15;

  // ══════════════════════════════════════
  // Field Drop Physics
  // ══════════════════════════════════════

  /// Gravity for field drops.
  static const double fieldDropGravity = 120.0;

  /// Ground delay before homing starts (seconds).
  static const double fieldDropGroundDelay = 0.8;

  /// Homing acceleration.
  static const double fieldDropHomeAccel = 800.0;

  /// Homing max speed.
  static const double fieldDropHomeMaxSpeed = 500.0;

  /// Max active field drops.
  static const int fieldDropMaxDrops = 60;

  /// Pickup/absorb radius.
  static const double fieldDropPickupRadius = 10.0;

  // ══════════════════════════════════════
  // Damage Number Visual
  // ══════════════════════════════════════

  /// Damage number lifetime (seconds).
  static const double damageNumberLifetime = 1.2;

  /// Damage number float speed (px/s).
  static const double damageNumberFloatSpeed = 50.0;

  /// Damage number pop animation duration (seconds).
  static const double damageNumberPopDuration = 0.15;

  // ══════════════════════════════════════
  // Upgrade Scaling
  // ══════════════════════════════════════

  /// Upgrade cost exponential scale per level.
  static const double upgradeCostScale = 1.12;

  /// Wall HP upgrade: +% per level.
  static const double upgradeWallHpPerLevel = 0.05;

  /// Wall regen upgrade: HP/s per level.
  static const double upgradeWallRegenPerLevel = 0.5;

  /// Wall defense upgrade: -% damage per level.
  static const double upgradeWallDefensePerLevel = 0.02;

  /// Wall defense minimum multiplier (always takes at least this % damage).
  static const double upgradeWallDefenseMin = 0.4;

  /// Unit ATK upgrade: +% per level.
  static const double upgradeUnitAtkPerLevel = 0.03;

  /// Unit ATK speed upgrade: +% per level.
  static const double upgradeUnitAtkSpeedPerLevel = 0.02;

  /// Gold gain upgrade: +% per level.
  static const double upgradeGoldGainPerLevel = 0.05;

  /// Unit discount upgrade: -% cost per level.
  static const double upgradeUnitDiscountPerLevel = 0.02;

  /// Unit discount minimum multiplier.
  static const double upgradeUnitDiscountMin = 0.4;

  /// Star bonus upgrade: +% per level.
  static const double upgradeStarBonusPerLevel = 0.05;

  /// Base unit slots before expansion.
  static const int upgradeBaseSlots = 8;

  /// Relic chance upgrade: +% per level.
  static const double upgradeRelicChancePerLevel = 0.05;

  /// Start gold upgrade: gold per level.
  static const int upgradeStartGoldPerLevel = 20;

  /// Relic quality upgrade: +% higher tier per level.
  static const double upgradeRelicQualityPerLevel = 0.03;

  /// Combo duration upgrade: +seconds per level.
  static const double upgradeComboDurationPerLevel = 0.3;

  /// Hybrid bonus upgrade: +% ATK per level.
  static const double upgradeHybridBonusPerLevel = 0.05;

  /// Crit chance upgrade: +% per level.
  static const double upgradeCritChancePerLevel = 0.02;

  // ══════════════════════════════════════
  // Wall Visual
  // ══════════════════════════════════════

  /// Wall damage flash duration (seconds).
  static const double wallDamageFlashDuration = 0.15;

  /// Phoenix relic: revive HP percent.
  static const double wallPhoenixRevivePercent = 0.5;

  // ══════════════════════════════════════
  // Unit Behavior
  // ══════════════════════════════════════

  /// Target search throttle interval (seconds).
  static const double unitTargetSearchInterval = 0.15;

  /// Evolved unit ATK speed bonus multiplier.
  static const double unitEvolvedAtkSpeedMult = 1.2;

  /// Evolved unit range bonus multiplier.
  static const double unitEvolvedRangeMult = 1.2;

  /// War cry skill: ATK multiplier while active.
  static const double unitWarCryAtkMult = 1.5;

  /// Attack recoil animation duration (seconds).
  static const double unitRecoilDuration = 0.15;

  /// Attack beam visibility duration (seconds).
  static const double unitBeamDuration = 0.25;

  // ══════════════════════════════════════
  // Hybrid Unit Special Stats
  // ══════════════════════════════════════

  /// Hybrid flame hunter crit chance.
  static const double hybridFlameHunterCrit = 0.20;

  /// Hybrid shadow sage crit chance.
  static const double hybridShadowSageCrit = 0.30;

  /// Hybrid wolf blade crit chance.
  static const double hybridWolfBladeCrit = 0.25;

  /// Hybrid wise bear slow intensity.
  static const double hybridWiseBearSlowIntensity = 0.40;

  /// Hybrid mystic sage heal fraction.
  static const double hybridMysticSageHealFraction = 0.03;

  // ══════════════════════════════════════
  // Game Feel Timing
  // ══════════════════════════════════════

  /// Auto-merge check interval (seconds).
  static const double autoMergeInterval = 1.5;

  /// Auto-place check interval (seconds).
  static const double autoPlaceInterval = 3.0;

  /// Enemy kill: hit stop duration.
  static const double feelEnemyKillHitStop = 0.015;

  /// Enemy kill: combo threshold for screen flash.
  static const int feelEnemyKillComboThreshold = 3;

  /// Enemy kill: flash color at high combo.
  static const int feelEnemyKillFlashColor = 0x44FFFFFF;

  /// Enemy kill: flash duration at high combo.
  static const double feelEnemyKillFlashDuration = 0.08;

  /// Boss hit: hit stop duration.
  static const double feelBossHitHitStop = 0.04;

  /// Boss kill: hit stop duration.
  static const double feelBossKillHitStop = 0.25;

  /// Boss kill: slow motion scale.
  static const double feelBossKillSlowScale = 0.2;

  /// Boss kill: slow motion duration.
  static const double feelBossKillSlowDuration = 1.0;

  /// Boss kill: zoom punch target.
  static const double feelBossKillZoom = 1.08;

  /// Boss kill: zoom punch duration.
  static const double feelBossKillZoomDuration = 0.5;

  /// Boss kill: flash color.
  static const int feelBossKillFlashColor = 0xFFFFAA00;

  /// Boss kill: flash duration.
  static const double feelBossKillFlashDuration = 0.3;

  /// Wall hit (heavy): flash color.
  static const int feelWallHitFlashColor = 0xFFFF4444;

  /// Wall hit (heavy): flash duration.
  static const double feelWallHitFlashDuration = 0.2;

  /// Wall critical: flash color.
  static const int feelWallCriticalFlashColor = 0xFFFF0000;

  /// Wall critical: flash duration.
  static const double feelWallCriticalFlashDuration = 0.4;

  /// Merge: zoom punch base.
  static const double feelMergeZoomBase = 1.02;

  /// Merge: zoom punch per level.
  static const double feelMergeZoomPerLevel = 0.01;

  /// Merge: zoom punch duration.
  static const double feelMergeZoomDuration = 0.2;

  /// Evolve: hit stop duration.
  static const double feelEvolveHitStop = 0.15;

  /// Evolve: slow motion scale.
  static const double feelEvolveSlowScale = 0.3;

  /// Evolve: slow motion duration.
  static const double feelEvolveSlowDuration = 0.8;

  /// Evolve: zoom punch target.
  static const double feelEvolveZoom = 1.06;

  /// Evolve: zoom punch duration.
  static const double feelEvolveZoomDuration = 0.4;

  /// Evolve: flash color.
  static const int feelEvolveFlashColor = 0xFFFFD700;

  /// Evolve: flash duration.
  static const double feelEvolveFlashDuration = 0.3;

  /// Hybrid merge: hit stop duration.
  static const double feelHybridHitStop = 0.1;

  /// Hybrid merge: slow motion scale.
  static const double feelHybridSlowScale = 0.4;

  /// Hybrid merge: slow motion duration.
  static const double feelHybridSlowDuration = 0.6;

  /// Hybrid merge: zoom punch target.
  static const double feelHybridZoom = 1.05;

  /// Hybrid merge: zoom punch duration.
  static const double feelHybridZoomDuration = 0.3;

  /// Hybrid merge: flash color.
  static const int feelHybridFlashColor = 0xFFE040FB;

  /// Hybrid merge: flash duration.
  static const double feelHybridFlashDuration = 0.25;

  /// Ascension: slow motion scale.
  static const double feelAscensionSlowScale = 0.2;

  /// Ascension: slow motion duration.
  static const double feelAscensionSlowDuration = 1.5;

  /// Ascension: flash color.
  static const int feelAscensionFlashColor = 0xFFFFFFFF;

  /// Ascension: flash duration.
  static const double feelAscensionFlashDuration = 0.5;

  /// Perfect wave: zoom punch target.
  static const double feelPerfectWaveZoom = 1.03;

  /// Perfect wave: zoom punch duration.
  static const double feelPerfectWaveZoomDuration = 0.3;

  /// Perfect wave: flash color.
  static const int feelPerfectWaveFlashColor = 0xFF4CAF50;

  /// Perfect wave: flash duration.
  static const double feelPerfectWaveFlashDuration = 0.2;

  /// Skill activation: hit stop duration.
  static const double feelSkillHitStop = 0.08;

  /// Skill activation: slow motion scale.
  static const double feelSkillSlowScale = 0.3;

  /// Skill activation: slow motion duration.
  static const double feelSkillSlowDuration = 0.5;

  /// Skill activation: zoom punch target.
  static const double feelSkillZoom = 1.04;

  /// Skill activation: zoom punch duration.
  static const double feelSkillZoomDuration = 0.3;

  /// Combo tier change: hit stop duration.
  static const double feelComboTierHitStop = 0.06;

  /// Combo tier change: flash duration.
  static const double feelComboTierFlashDuration = 0.3;

  /// Relic acquired: zoom punch target.
  static const double feelRelicZoom = 1.03;

  /// Relic acquired: zoom punch duration.
  static const double feelRelicZoomDuration = 0.2;

  /// Relic acquired: flash color.
  static const int feelRelicFlashColor = 0xFFE040FB;

  /// Relic acquired: flash duration.
  static const double feelRelicFlashDuration = 0.2;
}
