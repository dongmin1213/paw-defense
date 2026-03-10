import 'dart:math';

/// Permanent upgrade IDs for castle defense (bought with stars between runs).
enum DefenseUpgradeId {
  wallHp,
  wallRegen,
  wallDefense,
  unitAtk,
  unitAtkSpeed,
  startUnits,
  goldGain,
  unitDiscount,
  starBonus,
  slotExpansion,
  relicChance,
  // Phase 4: New upgrades
  startGold,
  relicQuality,
  comboDuration,
  hybridBonus,
  critChance,
}

/// Static data definition for a defense upgrade.
class DefenseUpgradeData {
  final DefenseUpgradeId id;
  final String name;
  final String description;
  final int baseCost;
  final int maxLevel;

  const DefenseUpgradeData({
    required this.id,
    required this.name,
    required this.description,
    required this.baseCost,
    required this.maxLevel,
  });

  /// Cost at a given level: baseCost * pow(1.12, level), rounded up.
  int costAt(int level) {
    if (level >= maxLevel) return 0;
    return (baseCost * pow(1.12, level)).ceil();
  }
}

/// Database of all defense upgrade definitions.
class DefenseUpgradeDatabase {
  static const List<DefenseUpgradeData> _all = [
    DefenseUpgradeData(
      id: DefenseUpgradeId.wallHp,
      name: '성벽 강화',
      description: '성벽 최대 HP +5% / 레벨',
      baseCost: 10,
      maxLevel: 30,
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.wallRegen,
      name: '성벽 재생',
      description: '초당 HP 재생 +0.5 / 레벨',
      baseCost: 15,
      maxLevel: 20,
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.wallDefense,
      name: '성벽 방어',
      description: '받는 피해 -2% / 레벨',
      baseCost: 20,
      maxLevel: 20,
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.unitAtk,
      name: '유닛 공격력',
      description: '모든 유닛 공격력 +3% / 레벨',
      baseCost: 12,
      maxLevel: 30,
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.unitAtkSpeed,
      name: '유닛 공속',
      description: '모든 유닛 공격속도 +2% / 레벨',
      baseCost: 15,
      maxLevel: 25,
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.startUnits,
      name: '초기 유닛',
      description: '런 시작 시 무료 유닛 +1 / 레벨',
      baseCost: 50,
      maxLevel: 5,
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.goldGain,
      name: '골드 획득',
      description: '골드 획득량 +5% / 레벨',
      baseCost: 10,
      maxLevel: 30,
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.unitDiscount,
      name: '유닛 할인',
      description: '유닛 구매 비용 -2% / 레벨',
      baseCost: 18,
      maxLevel: 20,
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.starBonus,
      name: '스타 보너스',
      description: '런 종료 시 스타 +5% / 레벨',
      baseCost: 25,
      maxLevel: 20,
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.slotExpansion,
      name: '배치 확장',
      description: '유닛 배치 슬롯 +1 / 레벨 (기본 8)',
      baseCost: 60,
      maxLevel: 8,
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.relicChance,
      name: '유물 행운',
      description: '유물 추가 선택지 확률 +5% / 레벨',
      baseCost: 30,
      maxLevel: 10,
    ),
    // Phase 4: New upgrades
    DefenseUpgradeData(
      id: DefenseUpgradeId.startGold,
      name: '초기 자금',
      description: '런 시작 시 골드 +20 / 레벨',
      baseCost: 15,
      maxLevel: 10,
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.relicQuality,
      name: '유물 품질',
      description: '높은 등급 유물 확률 +3% / 레벨',
      baseCost: 40,
      maxLevel: 10,
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.comboDuration,
      name: '콤보 지속',
      description: '콤보 유지 시간 +0.3초 / 레벨',
      baseCost: 20,
      maxLevel: 10,
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.hybridBonus,
      name: '하이브리드 강화',
      description: '하이브리드 유닛 공격력 +5% / 레벨',
      baseCost: 35,
      maxLevel: 10,
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.critChance,
      name: '기본 크리티컬',
      description: '기본 크리 확률 +2% / 레벨',
      baseCost: 25,
      maxLevel: 10,
    ),
  ];

  static DefenseUpgradeData get(DefenseUpgradeId id) {
    return _all.firstWhere((d) => d.id == id);
  }

  static List<DefenseUpgradeData> get all => _all;
}

/// Manages permanent upgrade levels for castle defense.
/// Upgrades persist between runs and are purchased with stars.
class DefenseUpgradeManager {
  final Map<DefenseUpgradeId, int> _levels = {};

  DefenseUpgradeManager() {
    for (final id in DefenseUpgradeId.values) {
      _levels[id] = 0;
    }
  }

  /// Get current level of an upgrade.
  int getLevel(DefenseUpgradeId id) => _levels[id] ?? 0;

  /// Whether the upgrade is at max level.
  bool isMaxed(DefenseUpgradeId id) =>
      getLevel(id) >= DefenseUpgradeDatabase.get(id).maxLevel;

  /// Cost to buy the next level.
  int getCost(DefenseUpgradeId id) {
    final data = DefenseUpgradeDatabase.get(id);
    return data.costAt(getLevel(id));
  }

  /// Whether the player can afford the next level.
  bool canAfford(DefenseUpgradeId id, int stars) {
    if (isMaxed(id)) return false;
    return stars >= getCost(id);
  }

  /// Attempt to buy the next level. Returns cost spent, or 0 if not possible.
  int buy(DefenseUpgradeId id, int stars) {
    if (!canAfford(id, stars)) return 0;
    final cost = getCost(id);
    _levels[id] = (_levels[id] ?? 0) + 1;
    return cost;
  }

  // === Multiplier getters ===

  /// Wall max HP multiplier. +5% per level.
  double get wallHpMultiplier => 1.0 + getLevel(DefenseUpgradeId.wallHp) * 0.05;

  /// Wall HP regeneration per second.
  double get wallRegenPerSec => getLevel(DefenseUpgradeId.wallRegen) * 0.5;

  /// Wall damage reduction multiplier (lower = less damage taken).
  /// Clamped so wall always takes at least 40% damage.
  double get wallDefenseMultiplier =>
      (1.0 - getLevel(DefenseUpgradeId.wallDefense) * 0.02).clamp(0.4, 1.0);

  /// Unit ATK multiplier. +3% per level.
  double get unitAtkMultiplier =>
      1.0 + getLevel(DefenseUpgradeId.unitAtk) * 0.03;

  /// Unit attack speed multiplier. +2% per level.
  double get unitAtkSpeedMultiplier =>
      1.0 + getLevel(DefenseUpgradeId.unitAtkSpeed) * 0.02;

  /// Number of free units at run start.
  int get startUnitCount => getLevel(DefenseUpgradeId.startUnits);

  /// Gold gain multiplier. +5% per level.
  double get goldGainMultiplier =>
      1.0 + getLevel(DefenseUpgradeId.goldGain) * 0.05;

  /// Unit purchase cost discount multiplier (lower = cheaper).
  /// Clamped so units always cost at least 40% of base price.
  double get unitCostDiscount =>
      (1.0 - getLevel(DefenseUpgradeId.unitDiscount) * 0.02).clamp(0.4, 1.0);

  /// Star gain multiplier at run end. +5% per level.
  double get starBonusMultiplier =>
      1.0 + getLevel(DefenseUpgradeId.starBonus) * 0.05;

  /// Total available unit slots. Base 8 + expansion levels.
  int get totalSlots => 8 + getLevel(DefenseUpgradeId.slotExpansion);

  /// Bonus relic choice chance. +5% per level.
  double get relicChanceBonus =>
      getLevel(DefenseUpgradeId.relicChance) * 0.05;

  // === Phase 4: New upgrade getters ===

  /// Bonus start gold. +20 per level.
  int get startGoldBonus => getLevel(DefenseUpgradeId.startGold) * 20;

  /// Relic quality bonus. +3% higher tier chance per level.
  double get relicQualityBonus =>
      getLevel(DefenseUpgradeId.relicQuality) * 0.03;

  /// Combo duration bonus in seconds. +0.3s per level.
  double get comboDurationBonus =>
      getLevel(DefenseUpgradeId.comboDuration) * 0.3;

  /// Hybrid unit ATK multiplier. +5% per level.
  double get hybridAtkMultiplier =>
      1.0 + getLevel(DefenseUpgradeId.hybridBonus) * 0.05;

  /// Base crit chance bonus. +2% per level.
  double get baseCritChance =>
      getLevel(DefenseUpgradeId.critChance) * 0.02;

  /// Reset all upgrades to level 0.
  void resetAll() {
    for (final id in DefenseUpgradeId.values) {
      _levels[id] = 0;
    }
  }

  // === Save/Load ===

  Map<String, int> toMap() {
    return _levels.map((k, v) => MapEntry(k.name, v));
  }

  void loadFromMap(Map<String, int> map) {
    for (final entry in map.entries) {
      try {
        final id = DefenseUpgradeId.values.firstWhere((e) => e.name == entry.key);
        _levels[id] = entry.value;
      } catch (_) {
        // Skip unknown upgrade IDs (forward compatibility)
      }
    }
  }
}
