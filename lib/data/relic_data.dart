/// Relic data — one relic per unit evolution.
/// Relics are found via boss drops or star shop purchases.

import 'unit_data.dart';

class RelicData {
  final String id;
  final String name;
  final String description;
  final UnitType? evolutionTarget; // null if general relic

  const RelicData({
    required this.id,
    required this.name,
    required this.description,
    this.evolutionTarget,
  });
}

class RelicDatabase {
  static const List<RelicData> all = [
    RelicData(
      id: 'arrowRain',
      name: 'Arrow Rain',
      description: 'Enchanted quiver that summons a rain of arrows.',
      evolutionTarget: UnitType.catArcher,
    ),
    RelicData(
      id: 'flameArmor',
      name: 'Flame Armor',
      description: 'Armor forged in dragon fire. Burns all who approach.',
      evolutionTarget: UnitType.dogWarrior,
    ),
    RelicData(
      id: 'manaCrystal',
      name: 'Mana Crystal',
      description: 'Ancient crystal pulsing with raw magical energy.',
      evolutionTarget: UnitType.rabbitMage,
    ),
    RelicData(
      id: 'steelShield',
      name: 'Steel Shield',
      description: 'Unbreakable shield that radiates a slowing aura.',
      evolutionTarget: UnitType.bearTanker,
    ),
    RelicData(
      id: 'poisonDagger',
      name: 'Poison Dagger',
      description: 'Blade coated in deadly shadow venom.',
      evolutionTarget: UnitType.foxAssassin,
    ),
    RelicData(
      id: 'windFeather',
      name: 'Wind Feather',
      description: 'Feather of the storm hawk. Commands gale-force winds.',
      evolutionTarget: UnitType.birdScout,
    ),
  ];

  static RelicData get(String id) =>
      all.firstWhere((r) => r.id == id);
}
