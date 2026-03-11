import 'dart:math';

import '../data/relic_data.dart';
import '../data/balance_config.dart';

/// Manages relics obtained from boss kills during a run.
/// Relics provide passive bonuses, mechanic changes, and rule overrides.
/// Reset on run end.
class RelicManager {
  final List<String> _ownedRelics = [];

  /// Base max relics per run (can be increased by relic_infinity).
  int get maxRelics => BalanceConfig.maxRelics + (hasRelic('relic_infinity') ? 2 : 0);

  // ── State flags ──
  bool _lastStandUsed = false;
  bool _phoenixUsed = false;

  /// Read-only view of owned relics.
  List<String> get ownedRelics => List.unmodifiable(_ownedRelics);

  /// Number of relics currently held.
  int get relicCount => _ownedRelics.length;

  /// Whether the relic inventory is full.
  bool get isFull => _ownedRelics.length >= maxRelics;

  /// Add a relic. Returns false if inventory is full or already owned.
  bool addRelic(String relicId) {
    if (isFull) return false;
    if (_ownedRelics.contains(relicId)) return false;
    _ownedRelics.add(relicId);
    return true;
  }

  /// Check if a specific relic is owned.
  bool hasRelic(String relicId) => _ownedRelics.contains(relicId);

  /// Remove a specific relic. Returns true if it was present.
  bool removeRelic(String relicId) => _ownedRelics.remove(relicId);

  /// Clear all relics (on run end / new run).
  void reset() {
    _ownedRelics.clear();
    _lastStandUsed = false;
    _phoenixUsed = false;
  }

  // ══════════════════════════════════════
  // Weighted Relic Selection
  // ══════════════════════════════════════

  /// Generate relic choices for a boss drop using weighted rarity.
  /// Higher rarity = lower drop chance.
  /// [qualityBonus] increases the chance of higher rarity relics (0.0 = none).
  List<String> generateRelicChoices(Random rng,
      {int choiceCount = 3, double qualityBonus = 0.0}) {
    final available = RelicDatabase.allIds
        .where((id) => !_ownedRelics.contains(id))
        .toList();

    if (available.isEmpty) return [];
    if (available.length <= choiceCount) return List.from(available);

    // Weighted selection by rarity
    final choices = <String>[];
    final pool = List<String>.from(available);

    for (int i = 0; i < choiceCount && pool.isNotEmpty; i++) {
      final selected =
          _weightedPick(pool, rng, qualityBonus: qualityBonus);
      choices.add(selected);
      pool.remove(selected);
    }
    return choices;
  }

  /// Pick one relic from pool using rarity weights.
  /// [qualityBonus] boosts higher-rarity relic weights.
  String _weightedPick(List<String> pool, Random rng,
      {double qualityBonus = 0.0}) {
    double totalWeight = 0;
    final weights = <double>[];
    for (final id in pool) {
      final def = RelicDatabase.get(id);
      final baseWeight = (def?.rarity.weight ?? 10).toDouble();
      // Quality bonus: boost rare+ weights, reduce common weights
      double w = baseWeight;
      if (def != null && qualityBonus > 0) {
        if (def.rarity == RelicRarity.common) {
          w *= (1.0 - qualityBonus).clamp(0.3, 1.0);
        } else {
          // Higher rarity gets more boost: rare 1.5x, epic 2x, legendary 3x, mythic 4x
          final rarityMultiplier = def.rarity.index.toDouble();
          w *= (1.0 + qualityBonus * rarityMultiplier);
        }
      }
      weights.add(w);
      totalWeight += w;
    }

    double roll = rng.nextDouble() * totalWeight;
    for (int i = 0; i < pool.length; i++) {
      roll -= weights[i];
      if (roll < 0) return pool[i];
    }
    return pool.last;
  }

  // ══════════════════════════════════════
  // Stat Multiplier Queries
  // ══════════════════════════════════════

  /// ATK multiplier from relics. Base 1.0.
  double get atkMultiplier {
    double m = 1.0;
    if (hasRelic('relic_atk_boost')) m += BalanceConfig.relicAtkBonus;
    if (hasRelic('relic_ghost_unit')) m += 0.20; // Ghost unit: ATK +20%
    if (hasRelic('relic_rapid_fire')) m -= 0.15; // ATK -15%
    if (hasRelic('relic_war_god')) m *= 3.0;
    if (hasRelic('relic_midas')) m = 0.0; // Midas: no damage
    return m;
  }

  /// ATK speed multiplier from relics. Base 1.0.
  double get atkSpeedMultiplier {
    double m = 1.0;
    if (hasRelic('relic_speed_boost')) m += BalanceConfig.relicAtkSpeedBonus;
    if (hasRelic('relic_rapid_fire')) m += 0.30;
    if (hasRelic('relic_tiny')) m += 0.40;
    return m;
  }

  /// Range multiplier from relics. Base 1.0.
  double get rangeMultiplier {
    double m = 1.0;
    if (hasRelic('relic_range_boost')) m += 0.20;
    if (hasRelic('relic_giant')) m += 0.30;
    return m;
  }

  /// Projectile speed multiplier from relics. Base 1.0.
  double get projectileSpeedMultiplier {
    double m = 1.0;
    if (hasRelic('relic_proj_speed')) m += 0.30;
    return m;
  }

  /// Gold gain multiplier from relics. Base 1.0.
  double get goldMultiplier {
    double m = 1.0;
    if (hasRelic('relic_gold_boost')) m += BalanceConfig.relicGoldBonus;
    return m;
  }

  /// Boss gold multiplier.
  double get bossGoldMultiplier {
    double m = 1.0;
    if (hasRelic('relic_boss_gold')) m += 0.50;
    if (hasRelic('relic_treasure_hunter')) m *= 3.0;
    return m;
  }

  /// Wall damage reduction from relics. 0.0 = no reduction.
  double get wallDamageReduction {
    double r = 0.0;
    if (hasRelic('relic_wall_shield')) r += BalanceConfig.relicWallDefenseBonus;
    return r.clamp(0.0, 0.8);
  }

  /// Crit chance bonus from relics. 0.0 = no bonus.
  double get critChanceBonus {
    double c = 0.0;
    if (hasRelic('relic_crit_chance')) c += BalanceConfig.relicCritBonus;
    return c;
  }

  /// Crit damage multiplier from relics. Base 2.0 (default crit = 2x).
  double get critDamageMultiplier {
    double m = 2.0;
    if (hasRelic('relic_crit_dmg')) m += 0.50;
    return m;
  }

  /// Sell refund rate override.
  double get sellRefundRate {
    if (hasRelic('relic_recycle')) return 0.80;
    return BalanceConfig.sellRefundRate;
  }

  /// Star gain bonus multiplier.
  double get starMultiplier {
    double m = 1.0;
    if (hasRelic('relic_star_magnet')) m += BalanceConfig.relicStarBonus;
    return m;
  }

  /// Lifesteal percentage (fraction of damage dealt heals wall).
  double get lifestealPercent {
    double l = 0.0;
    if (hasRelic('relic_lifesteal')) l += BalanceConfig.relicLifestealPercent;
    if (hasRelic('relic_lifesteal_up')) l += 0.05; // upgraded
    return l;
  }

  /// Unit size scale multiplier.
  double get unitSizeMultiplier {
    double m = 1.0;
    if (hasRelic('relic_giant')) m += 0.50;
    if (hasRelic('relic_tiny')) m -= 0.30;
    return m.clamp(0.5, 2.0);
  }

  // ══════════════════════════════════════
  // Boolean Effect Queries
  // ══════════════════════════════════════

  /// Whether splash damage is enabled for all ranged units.
  bool get hasSplash => hasRelic('relic_splash');

  /// Whether slow aura is active near wall.
  bool get hasSlowAura => hasRelic('relic_slow_aura');

  /// Whether merge requires only 2 units instead of 3.
  bool get hasDoubleMerge => hasRelic('relic_double_merge');

  /// Whether all ranged units have piercing projectiles.
  bool get hasPierceAll => hasRelic('relic_pierce_all');

  /// Whether projectiles split on hit.
  bool get hasSplitShot => hasRelic('relic_split_shot');

  /// Whether chain lightning triggers on kill.
  bool get hasChainLightning => hasRelic('relic_chain_lightning');

  /// Whether the living wall attacks enemies.
  bool get hasLivingWall => hasRelic('relic_living_wall');

  /// Whether the wall has a turret.
  bool get hasWallTurret => hasRelic('relic_wall_turret');

  /// Whether ghost unit mode is active (units can't be targeted).
  bool get hasGhostUnit => hasRelic('relic_ghost_unit');

  /// Whether Midas mode is active (damage→gold, ATK=0).
  bool get hasMidas => hasRelic('relic_midas');

  /// Whether auto-evolve is active.
  bool get hasAutoEvolve => hasRelic('relic_auto_evolve');

  /// Whether elemental effects are active.
  bool get hasElemental => hasRelic('relic_elemental');

  /// Whether doppelganger is active (buy = most common type).
  bool get hasDoppelganger => hasRelic('relic_doppelganger');

  /// Max unit level (default 5, +2 with infinite merge).
  int get maxUnitLevel =>
      BalanceConfig.maxUnitLevel + (hasRelic('relic_infinite_merge') ? 2 : 0);

  // ══════════════════════════════════════
  // Event-Driven Effects
  // ══════════════════════════════════════

  /// Called when an enemy is killed. Returns bonus gold.
  int onEnemyKilled(Random rng) {
    int bonusGold = 0;
    // Midas: convert damage concept to gold
    if (hasMidas) bonusGold += 5;
    return bonusGold;
  }

  /// Called when wall takes fatal damage.
  /// Returns true if death is prevented (last stand / phoenix).
  bool onWallFatalDamage() {
    if (hasRelic('relic_last_stand') && !_lastStandUsed) {
      _lastStandUsed = true;
      return true; // Survive with 1 HP
    }
    if (hasRelic('relic_phoenix') && !_phoenixUsed) {
      _phoenixUsed = true;
      return true; // Revive with 50% HP + 5s invincible
    }
    return false;
  }

  /// Whether phoenix just activated (for invincibility).
  bool get phoenixJustUsed => hasRelic('relic_phoenix') && _phoenixUsed;

  /// Whether last stand just activated.
  bool get lastStandJustUsed => hasRelic('relic_last_stand') && _lastStandUsed;

  /// Called on wave start. Returns bonus gold.
  int onWaveStart(int waveNumber, Random rng) {
    int gold = 0;
    if (hasRelic('relic_wave_gold')) gold += 10;
    return gold;
  }

  /// Heal amount on wave start (blessing rain).
  double onWaveStartHeal(int waveNumber) {
    if (hasRelic('relic_blessing_rain') && waveNumber % 3 == 0) {
      return 0.15; // 15% of max HP
    }
    return 0.0;
  }

  /// Whether time warp triggers on this wave.
  bool shouldTimeWarp(int waveNumber) {
    return hasRelic('relic_time_warp') && waveNumber % 5 == 0;
  }

  /// Whether rift spawns a free unit on wave start.
  bool get hasRift => hasRelic('relic_rift');

  /// Whether berserker mode is active (check HP threshold externally).
  bool get hasBerserker => hasRelic('relic_berserker');

  /// Berserker ATK multiplier (applied when wall HP < 30%).
  double berserkerMultiplier(double wallHpPercent) {
    if (hasBerserker && wallHpPercent < 0.30) return 2.0;
    return 1.0;
  }

  /// Reverse law ATK multiplier (lower HP = higher ATK).
  double reverseMultiplier(double wallHpPercent) {
    if (hasRelic('relic_reverse')) {
      // At 100% HP → x1, at 1% HP → x5
      return 1.0 + 4.0 * (1.0 - wallHpPercent);
    }
    return 1.0;
  }

  /// Gambler: returns cost multiplier (0.0 = free, 2.0 = double).
  double gamblerCostMultiplier(Random rng) {
    if (hasRelic('relic_gambler')) {
      return rng.nextBool() ? 0.0 : 2.0;
    }
    return 1.0;
  }

  /// Twin: returns true if an extra unit should spawn.
  bool twinProc(Random rng) {
    if (hasRelic('relic_twin')) {
      return rng.nextDouble() < 0.30;
    }
    return false;
  }

  /// Merge bomb damage when merge occurs.
  double get mergeBombDamage {
    if (hasRelic('relic_merge_bomb')) return 30.0;
    return 0.0;
  }

  /// Convert chance on enemy kill.
  double get convertChance {
    if (hasRelic('relic_convert')) return 0.05;
    return 0.0;
  }

  /// Thorns damage on wall hit.
  double get thornsDamage {
    if (hasRelic('relic_thorns')) return 10.0;
    return 0.0;
  }

  /// Kill heal amount.
  double get killHealAmount {
    if (hasRelic('relic_kill_heal')) return 1.0;
    return 0.0;
  }

  /// Wave duration override (time sand).
  double get waveDurationOverride {
    if (hasRelic('relic_time_sand')) return 10.0;
    return BalanceConfig.waveDuration;
  }

  /// Enemy speed multiplier (time sand).
  double get enemySpeedMultiplier {
    double m = 1.0;
    if (hasRelic('relic_time_sand')) m *= 0.70;
    return m;
  }

  /// Living wall DPS.
  double get livingWallDps {
    if (hasLivingWall) return 15.0;
    return 0.0;
  }

  /// Wall turret DPS.
  double get wallTurretDps {
    if (hasWallTurret) return 20.0;
    return 0.0;
  }

  // ══════════════════════════════════════
  // Save/Load (for mid-run save)
  // ══════════════════════════════════════

  List<String> toList() => List<String>.from(_ownedRelics);

  void loadFromList(List<String> list) {
    _ownedRelics.clear();
    for (final id in list) {
      if (RelicDatabase.get(id) != null && _ownedRelics.length < maxRelics) {
        _ownedRelics.add(id);
      }
    }
  }
}
