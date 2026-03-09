/// Permanent upgrades bought with stars between runs.
/// Persist across ascensions.

import 'defense_balance.dart';

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
  unitUnlock,
}

class DefenseUpgradeData {
  final DefenseUpgradeId id;
  final String name;
  final String description;
  final int maxLevel;
  final double baseCost;
  final double effectPerLevel;
  final String effectUnit;

  const DefenseUpgradeData({
    required this.id,
    required this.name,
    required this.description,
    required this.maxLevel,
    required this.baseCost,
    required this.effectPerLevel,
    required this.effectUnit,
  });

  double costAt(int level) {
    return DefenseBalance.upgradeCost(baseCost, level);
  }
}

class DefenseUpgradeDatabase {
  static const List<DefenseUpgradeData> all = [
    DefenseUpgradeData(
      id: DefenseUpgradeId.wallHp,
      name: 'Wall Fortification',
      description: 'Increases wall max HP.',
      maxLevel: 30,
      baseCost: 10,
      effectPerLevel: 20,
      effectUnit: 'HP',
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.wallRegen,
      name: 'Wall Regeneration',
      description: 'Wall recovers HP over time.',
      maxLevel: 20,
      baseCost: 15,
      effectPerLevel: 0.5,
      effectUnit: 'HP/s',
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.wallDefense,
      name: 'Wall Defense',
      description: 'Reduces damage taken by the wall.',
      maxLevel: 20,
      baseCost: 20,
      effectPerLevel: 2,
      effectUnit: '% reduction',
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.unitAtk,
      name: 'Unit Attack',
      description: 'All units deal more damage.',
      maxLevel: 30,
      baseCost: 12,
      effectPerLevel: 5,
      effectUnit: '% ATK',
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.unitAtkSpeed,
      name: 'Unit Attack Speed',
      description: 'All units attack faster.',
      maxLevel: 20,
      baseCost: 15,
      effectPerLevel: 3,
      effectUnit: '% speed',
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.startUnits,
      name: 'Starting Units',
      description: 'Begin each run with free units already placed.',
      maxLevel: 3,
      baseCost: 50,
      effectPerLevel: 1,
      effectUnit: 'units',
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.goldGain,
      name: 'Gold Gain',
      description: 'Earn more gold from defeated enemies.',
      maxLevel: 25,
      baseCost: 10,
      effectPerLevel: 5,
      effectUnit: '% gold',
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.unitDiscount,
      name: 'Unit Discount',
      description: 'Reduces the gold cost of placing units.',
      maxLevel: 15,
      baseCost: 12,
      effectPerLevel: 3,
      effectUnit: '% discount',
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.starBonus,
      name: 'Star Bonus',
      description: 'Earn more stars at the end of each run.',
      maxLevel: 20,
      baseCost: 20,
      effectPerLevel: 5,
      effectUnit: '% stars',
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.slotExpansion,
      name: 'Slot Expansion',
      description: 'Increases the max number of units on the field.',
      maxLevel: 6,
      baseCost: 40,
      effectPerLevel: 1,
      effectUnit: 'slots',
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.relicChance,
      name: 'Relic Finder',
      description: 'Increases chance of finding relics from bosses.',
      maxLevel: 10,
      baseCost: 25,
      effectPerLevel: 5,
      effectUnit: '% chance',
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.unitUnlock,
      name: 'Unit Unlock',
      description: 'Unlocks new unit types for recruitment.',
      maxLevel: 5,
      baseCost: 30,
      effectPerLevel: 1,
      effectUnit: 'type',
    ),
  ];

  static DefenseUpgradeData get(DefenseUpgradeId id) =>
      all.firstWhere((u) => u.id == id);
}
