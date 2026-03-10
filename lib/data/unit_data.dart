/// Unit types for the castle defense game.
/// 8 base units + 8 evolved forms.

enum UnitType {
  catArcher,
  dogWarrior,
  rabbitMage,
  bearTanker,
  foxAssassin,
  birdScout,
  turtleHealer,
  owlWizard,
}

class UnitData {
  final UnitType type;
  final String id;
  final String name;
  final String emoji;
  final double baseAtk;
  final double baseAtkSpeed; // attacks per second
  final double range;
  final bool isMelee;
  final bool canHitAir;
  final bool isSplash;
  final bool isPiercing;
  final String description;

  const UnitData({
    required this.type,
    required this.id,
    required this.name,
    required this.emoji,
    required this.baseAtk,
    required this.baseAtkSpeed,
    required this.range,
    required this.isMelee,
    this.canHitAir = false,
    this.isSplash = false,
    this.isPiercing = false,
    required this.description,
  });
}

class EvolvedUnitData {
  final UnitType baseType;
  final String id;
  final String name;
  final String requiredRelicId;
  final double atkMultiplier;
  final String specialEffect;

  const EvolvedUnitData({
    required this.baseType,
    required this.id,
    required this.name,
    required this.requiredRelicId,
    required this.atkMultiplier,
    required this.specialEffect,
  });
}

class UnitDatabase {
  static const List<UnitData> all = [
    UnitData(
      type: UnitType.catArcher,
      id: 'catArcher',
      name: 'Cat Archer',
      emoji: '🐱',
      baseAtk: 10,
      baseAtkSpeed: 1.5,
      range: 120,
      isMelee: false,
      canHitAir: true,
      description: 'Fast-firing ranged archer. Single target specialist.',
    ),
    UnitData(
      type: UnitType.dogWarrior,
      id: 'dogWarrior',
      name: 'Dog Warrior',
      emoji: '🐶',
      baseAtk: 15,
      baseAtkSpeed: 0.8,
      range: 40,
      isMelee: true,
      isSplash: true,
      description: 'Melee brawler with splash damage. Hits all nearby enemies.',
    ),
    UnitData(
      type: UnitType.rabbitMage,
      id: 'rabbitMage',
      name: 'Rabbit Mage',
      emoji: '🐰',
      baseAtk: 20,
      baseAtkSpeed: 0.5,
      range: 100,
      isMelee: false,
      isSplash: true,
      description: 'Slow but devastating AoE magic attacks.',
    ),
    UnitData(
      type: UnitType.bearTanker,
      id: 'bearTanker',
      name: 'Bear Tanker',
      emoji: '🐻',
      baseAtk: 8,
      baseAtkSpeed: 0.6,
      range: 35,
      isMelee: true,
      description: 'Sturdy melee defender that slows enemies on hit.',
    ),
    UnitData(
      type: UnitType.foxAssassin,
      id: 'foxAssassin',
      name: 'Fox Assassin',
      emoji: '🦊',
      baseAtk: 25,
      baseAtkSpeed: 0.7,
      range: 90,
      isMelee: false,
      description: 'High damage ranged attacker with critical hit chance.',
    ),
    UnitData(
      type: UnitType.birdScout,
      id: 'birdScout',
      name: 'Bird Scout',
      emoji: '🐦',
      baseAtk: 12,
      baseAtkSpeed: 1.0,
      range: 110,
      isMelee: false,
      canHitAir: true,
      isPiercing: true,
      description: 'Piercing shots that pass through enemies. Can hit air.',
    ),
    UnitData(
      type: UnitType.turtleHealer,
      id: 'turtleHealer',
      name: 'Turtle Healer',
      emoji: '🐢',
      baseAtk: 5,
      baseAtkSpeed: 0.4,
      range: 60,
      isMelee: true,
      description: 'Slowly attacks but heals the wall with each hit.',
    ),
    UnitData(
      type: UnitType.owlWizard,
      id: 'owlWizard',
      name: 'Owl Wizard',
      emoji: '🦉',
      baseAtk: 18,
      baseAtkSpeed: 0.6,
      range: 130,
      isMelee: false,
      isSplash: true,
      canHitAir: true,
      description: 'Long-range AoE mage that can target air units.',
    ),
  ];

  static UnitData get(UnitType type) =>
      all.firstWhere((u) => u.type == type);

  static const List<EvolvedUnitData> evolutions = [
    EvolvedUnitData(
      baseType: UnitType.catArcher,
      id: 'stormArcher',
      name: 'Storm Archer',
      requiredRelicId: 'arrowRain',
      atkMultiplier: 3.0,
      specialEffect: 'Arrows rain down on a wide area',
    ),
    EvolvedUnitData(
      baseType: UnitType.dogWarrior,
      id: 'flameKnight',
      name: 'Flame Knight',
      requiredRelicId: 'flameArmor',
      atkMultiplier: 2.5,
      specialEffect: 'Burns enemies in melee range over time',
    ),
    EvolvedUnitData(
      baseType: UnitType.rabbitMage,
      id: 'archmage',
      name: 'Archmage',
      requiredRelicId: 'manaCrystal',
      atkMultiplier: 3.0,
      specialEffect: 'Magic blasts cover a massive area',
    ),
    EvolvedUnitData(
      baseType: UnitType.bearTanker,
      id: 'ironGuardian',
      name: 'Iron Guardian',
      requiredRelicId: 'steelShield',
      atkMultiplier: 2.5,
      specialEffect: 'Greatly slows and weakens nearby enemies',
    ),
    EvolvedUnitData(
      baseType: UnitType.foxAssassin,
      id: 'shadowFox',
      name: 'Shadow Fox',
      requiredRelicId: 'poisonDagger',
      atkMultiplier: 3.0,
      specialEffect: 'Poison attacks deal damage over time',
    ),
    EvolvedUnitData(
      baseType: UnitType.birdScout,
      id: 'stormHawk',
      name: 'Storm Hawk',
      requiredRelicId: 'windFeather',
      atkMultiplier: 2.5,
      specialEffect: 'Wind gusts push enemies back and pierce all',
    ),
    EvolvedUnitData(
      baseType: UnitType.turtleHealer,
      id: 'ancientTurtle',
      name: 'Ancient Turtle',
      requiredRelicId: 'lifeShell',
      atkMultiplier: 2.5,
      specialEffect: 'AoE heal pulse that repairs wall and buffs nearby units',
    ),
    EvolvedUnitData(
      baseType: UnitType.owlWizard,
      id: 'cosmicOwl',
      name: 'Cosmic Owl',
      requiredRelicId: 'moonstone',
      atkMultiplier: 3.0,
      specialEffect: 'Meteor shower attack covering massive area',
    ),
  ];

  static EvolvedUnitData? getEvolution(UnitType type) {
    for (final evo in evolutions) {
      if (evo.baseType == type) return evo;
    }
    return null;
  }
}
