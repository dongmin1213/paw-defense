import '../data/balance_config.dart';
import '../data/soul_upgrade_data.dart';

class AscensionManager {
  int souls = 0;
  int ascensionCount = 0;
  final Map<SoulUpgradeId, int> _soulLevels = {};

  AscensionManager() {
    for (final id in SoulUpgradeId.values) {
      _soulLevels[id] = 0;
    }
  }

  // === Ascension ===

  bool canAscend(double totalCoinsEarned) {
    return totalCoinsEarned >= BalanceConfig.ascensionCoinThreshold(ascensionCount);
  }

  double ascensionThreshold() {
    return BalanceConfig.ascensionCoinThreshold(ascensionCount);
  }

  int calculateSoulReward(double totalCoinsEarned) {
    return BalanceConfig.soulReward(totalCoinsEarned);
  }

  /// Perform ascension. Returns souls earned.
  int performAscension(double totalCoinsEarned) {
    final reward = calculateSoulReward(totalCoinsEarned);
    souls += reward;
    ascensionCount++;
    return reward;
  }

  // === Soul Upgrades ===

  int getSoulLevel(SoulUpgradeId id) => _soulLevels[id] ?? 0;

  bool isSoulMaxed(SoulUpgradeId id) {
    final data = SoulUpgradeDatabase.get(id);
    return getSoulLevel(id) >= data.maxLevel;
  }

  int getSoulCost(SoulUpgradeId id) {
    final data = SoulUpgradeDatabase.get(id);
    return data.costAt(getSoulLevel(id));
  }

  bool canAffordSoul(SoulUpgradeId id) {
    if (isSoulMaxed(id)) return false;
    return souls >= getSoulCost(id);
  }

  /// Buy a soul upgrade. Returns cost spent, or 0 if can't buy.
  int buySoulUpgrade(SoulUpgradeId id) {
    if (!canAffordSoul(id)) return 0;
    final cost = getSoulCost(id);
    souls -= cost;
    _soulLevels[id] = (_soulLevels[id] ?? 0) + 1;
    return cost;
  }

  // === Multiplier Getters ===

  /// Permanent coin multiplier: 1.0 + level * 0.25
  double get soulCoinMultiplier {
    final lv = getSoulLevel(SoulUpgradeId.coinMultiplier);
    return 1.0 + lv * 0.25;
  }

  /// Start speed bonus: level * 0.10
  double get startSpeedBonus {
    final lv = getSoulLevel(SoulUpgradeId.startSpeed);
    return lv * 0.10;
  }

  /// Offline efficiency bonus: level * 0.15
  double get offlineEfficiencyBonus {
    final lv = getSoulLevel(SoulUpgradeId.offlineEfficiency);
    return lv * 0.15;
  }

  /// Extra combo multiplier per stack from soul upgrade
  double get extraComboMultiplier {
    final lv = getSoulLevel(SoulUpgradeId.comboBooster);
    return lv * 0.02;
  }

  // === Region Unlocks ===

  bool isRegionUnlocked(String regionId) {
    switch (regionId) {
      case 'meadow':
        return true;
      case 'forest':
        return getSoulLevel(SoulUpgradeId.regionForest) >= 1;
      case 'desert':
        return getSoulLevel(SoulUpgradeId.regionDesert) >= 1;
      case 'snowfield':
        return getSoulLevel(SoulUpgradeId.regionSnowfield) >= 1;
      case 'volcano':
        return getSoulLevel(SoulUpgradeId.regionVolcano) >= 1;
      default:
        return false;
    }
  }

  List<String> get unlockedRegionIds {
    return ['meadow', 'forest', 'desert', 'snowfield', 'volcano']
        .where((r) => isRegionUnlocked(r))
        .toList();
  }

  // === Equipment Unlocks ===

  bool get hasBow => getSoulLevel(SoulUpgradeId.equipBow) >= 1;
  bool get hasGauntlet => getSoulLevel(SoulUpgradeId.equipGauntlet) >= 1;
  bool get hasCloak => getSoulLevel(SoulUpgradeId.equipCloak) >= 1;
  bool get hasAutoAirKill => getSoulLevel(SoulUpgradeId.autoAirKill) >= 1;
  bool get hasAutoUpgrade => getSoulLevel(SoulUpgradeId.autoUpgrade) >= 1;

  // === Save/Load ===

  Map<String, int> toMap() {
    return _soulLevels.map((k, v) => MapEntry(k.name, v));
  }

  void loadFromMap(Map<String, int> map) {
    for (final entry in map.entries) {
      try {
        final id = SoulUpgradeId.values.firstWhere((e) => e.name == entry.key);
        _soulLevels[id] = entry.value;
      } catch (_) {}
    }
  }
}
