import '../data/upgrade_data.dart';

class UpgradeManager {
  final Map<UpgradeId, int> _levels = {};

  UpgradeManager() {
    for (final id in UpgradeId.values) {
      _levels[id] = 0;
    }
  }

  int getLevel(UpgradeId id) => _levels[id] ?? 0;

  bool isMaxed(UpgradeId id) {
    final data = UpgradeDatabase.get(id);
    return getLevel(id) >= data.maxLevel;
  }

  double getCost(UpgradeId id) {
    final data = UpgradeDatabase.get(id);
    return data.costAt(getLevel(id));
  }

  bool canAfford(UpgradeId id, double coins) {
    if (isMaxed(id)) return false;
    return coins >= getCost(id);
  }

  /// Returns the cost spent, or 0 if can't buy
  double buy(UpgradeId id, double coins) {
    if (!canAfford(id, coins)) return 0;
    final cost = getCost(id);
    _levels[id] = (_levels[id] ?? 0) + 1;
    return cost;
  }

  // === Multiplier getters ===

  double get speedMultiplier {
    final lv = getLevel(UpgradeId.moveSpeed);
    return 1.0 + lv * UpgradeDatabase.get(UpgradeId.moveSpeed).effectPerLevel;
  }

  double get coinMultiplier {
    final lv = getLevel(UpgradeId.coinGain);
    return 1.0 + lv * UpgradeDatabase.get(UpgradeId.coinGain).effectPerLevel;
  }

  double get attackMultiplier {
    final lv = getLevel(UpgradeId.attackPower);
    return 1.0 + lv * UpgradeDatabase.get(UpgradeId.attackPower).effectPerLevel;
  }

  double get jumpMultiplier {
    final lv = getLevel(UpgradeId.jumpPower);
    return 1.0 + lv * UpgradeDatabase.get(UpgradeId.jumpPower).effectPerLevel;
  }

  bool get hasDoubleJump => getLevel(UpgradeId.doubleJump) >= 1;

  double get coinMagnetRadius {
    final lv = getLevel(UpgradeId.coinMagnet);
    return lv * UpgradeDatabase.get(UpgradeId.coinMagnet).effectPerLevel;
  }

  /// Combo retain: at level N, combo drops by (100 - N*10)% instead of resetting
  /// Level 0 = full reset, level 5 = only lose 50%
  int comboAfterTimeout(int currentCombo) {
    final lv = getLevel(UpgradeId.comboRetain);
    if (lv == 0) return 0;
    final retainRate = lv * UpgradeDatabase.get(UpgradeId.comboRetain).effectPerLevel;
    return (currentCombo * retainRate).floor();
  }

  // === Save/Load ===

  Map<String, int> toMap() {
    return _levels.map((k, v) => MapEntry(k.name, v));
  }

  void loadFromMap(Map<String, int> map) {
    for (final entry in map.entries) {
      try {
        final id = UpgradeId.values.firstWhere((e) => e.name == entry.key);
        _levels[id] = entry.value;
      } catch (_) {
        // Skip unknown upgrade IDs (forward compatibility)
      }
    }
  }

  /// 이름 문자열로 UpgradeId 조회 (자동 업그레이드 시스템용)
  UpgradeId? upgradeIdFromName(String name) {
    try {
      return UpgradeId.values.firstWhere((e) => e.name == name);
    } catch (_) {
      return null;
    }
  }

  void resetAll() {
    for (final id in UpgradeId.values) {
      _levels[id] = 0;
    }
  }
}
