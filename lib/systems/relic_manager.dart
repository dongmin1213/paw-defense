import 'dart:math';

import '../data/balance_config.dart';

/// Manages relics obtained from boss kills during a run.
/// Relics provide passive bonuses and enable unit evolution.
/// Maximum 3 relics per run; reset on run end.
class RelicManager {
  final List<String> _ownedRelics = [];

  /// Maximum number of relics that can be held at once.
  static const int maxRelics = 3;

  /// All available relic IDs in the game.
  static const List<String> allRelicIds = [
    // Unit evolution relics (one per unit type, format: evolve_<unitTypeId>)
    'evolve_cat_archer',
    'evolve_dog_warrior',
    'evolve_rabbit_mage',
    'evolve_bear_tanker',
    'evolve_fox_assassin',
    'evolve_bird_scout',
    'evolve_turtle_healer',
    'evolve_owl_wizard',
    // Passive bonus relics
    'relic_atk_boost', // All units +15% ATK
    'relic_speed_boost', // All units +15% ATK speed
    'relic_gold_boost', // +30% gold gain
    'relic_wall_shield', // Wall takes 20% less damage
    'relic_crit_chance', // Units gain 10% crit chance
    'relic_splash', // Ranged units gain splash damage
    'relic_slow_aura', // Enemies near wall slowed 20%
    'relic_lifesteal', // Units heal wall for 2% of damage dealt
    'relic_double_merge', // Merge requires 2 units instead of 3
    'relic_star_magnet', // +20% star gain on run end
  ];

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
  void reset() => _ownedRelics.clear();

  /// Generate relic choices for a boss drop.
  /// Returns [choiceCount] relics from the available pool,
  /// excluding already-owned relics.
  List<String> generateRelicChoices(Random rng, {int choiceCount = 2}) {
    final available = allRelicIds
        .where((id) => !_ownedRelics.contains(id))
        .toList();

    if (available.isEmpty) return [];
    if (available.length <= choiceCount) return List.from(available);

    // Fisher-Yates partial shuffle for unbiased selection
    final choices = <String>[];
    final pool = List<String>.from(available);
    for (int i = 0; i < choiceCount && pool.isNotEmpty; i++) {
      final idx = rng.nextInt(pool.length);
      choices.add(pool[idx]);
      pool[idx] = pool.last;
      pool.removeLast();
    }
    return choices;
  }

  // === Relic effect queries ===

  /// ATK multiplier from relics. Base 1.0.
  double get atkMultiplier =>
      hasRelic('relic_atk_boost') ? 1.0 + BalanceConfig.relicAtkBonus : 1.0;

  /// ATK speed multiplier from relics. Base 1.0.
  double get atkSpeedMultiplier =>
      hasRelic('relic_speed_boost')
          ? 1.0 + BalanceConfig.relicAtkSpeedBonus
          : 1.0;

  /// Gold gain multiplier from relics. Base 1.0.
  double get goldMultiplier =>
      hasRelic('relic_gold_boost') ? 1.0 + BalanceConfig.relicGoldBonus : 1.0;

  /// Wall damage reduction from relics. 0.0 = no reduction.
  double get wallDamageReduction =>
      hasRelic('relic_wall_shield') ? BalanceConfig.relicWallDefenseBonus : 0.0;

  /// Crit chance bonus from relics. 0.0 = no bonus.
  double get critChanceBonus =>
      hasRelic('relic_crit_chance') ? BalanceConfig.relicCritBonus : 0.0;

  /// Whether splash damage is enabled.
  bool get hasSplash => hasRelic('relic_splash');

  /// Whether slow aura is active near wall.
  bool get hasSlowAura => hasRelic('relic_slow_aura');

  /// Lifesteal percentage (fraction of damage dealt heals wall).
  double get lifestealPercent =>
      hasRelic('relic_lifesteal') ? BalanceConfig.relicLifestealPercent : 0.0;

  /// Whether merge requires only 2 units instead of 3.
  bool get hasDoubleMerge => hasRelic('relic_double_merge');

  /// Star gain bonus multiplier.
  double get starMultiplier =>
      hasRelic('relic_star_magnet') ? 1.0 + BalanceConfig.relicStarBonus : 1.0;

  // === Save/Load (for mid-run save) ===

  List<String> toList() => List<String>.from(_ownedRelics);

  void loadFromList(List<String> list) {
    _ownedRelics.clear();
    for (final id in list) {
      if (allRelicIds.contains(id) && _ownedRelics.length < maxRelics) {
        _ownedRelics.add(id);
      }
    }
  }
}
