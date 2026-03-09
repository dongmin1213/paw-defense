/// Enemy data for castle defense mode.
/// 7 regular types + 1 boss type.

enum EnemyCategory { normal, fast, tank, flying, shielded, bomber, healer, boss }

class DefenseEnemyData {
  final String id;
  final String name;
  final EnemyCategory category;
  final double baseHp;
  final double speed;
  final double damage; // damage to wall per hit
  final double attackSpeed; // hits per second on wall (0 = explodes on contact)
  final bool isFlying;
  final int goldDrop;
  final String description;

  const DefenseEnemyData({
    required this.id,
    required this.name,
    required this.category,
    required this.baseHp,
    required this.speed,
    required this.damage,
    required this.attackSpeed,
    this.isFlying = false,
    required this.goldDrop,
    required this.description,
  });
}

class DefenseEnemyDatabase {
  static const List<DefenseEnemyData> all = [
    DefenseEnemyData(
      id: 'slime',
      name: 'Slime',
      category: EnemyCategory.normal,
      baseHp: 10,
      speed: 30,
      damage: 5,
      attackSpeed: 1.0,
      goldDrop: 1,
      description: 'Basic slow-moving blob. Easy to deal with.',
    ),
    DefenseEnemyData(
      id: 'goblin',
      name: 'Goblin',
      category: EnemyCategory.fast,
      baseHp: 8,
      speed: 60,
      damage: 3,
      attackSpeed: 1.5,
      goldDrop: 2,
      description: 'Fast and nimble. Reaches the wall quickly.',
    ),
    DefenseEnemyData(
      id: 'orc',
      name: 'Orc',
      category: EnemyCategory.tank,
      baseHp: 40,
      speed: 20,
      damage: 10,
      attackSpeed: 0.5,
      goldDrop: 3,
      description: 'Tough brute with heavy armor. Slow but durable.',
    ),
    DefenseEnemyData(
      id: 'bat',
      name: 'Bat',
      category: EnemyCategory.flying,
      baseHp: 12,
      speed: 45,
      damage: 4,
      attackSpeed: 1.2,
      isFlying: true,
      goldDrop: 2,
      description: 'Flying enemy. Only anti-air units can target it.',
    ),
    DefenseEnemyData(
      id: 'shieldBearer',
      name: 'Shield Bearer',
      category: EnemyCategory.shielded,
      baseHp: 25,
      speed: 25,
      damage: 7,
      attackSpeed: 0.8,
      goldDrop: 3,
      description: 'Carries a shield that blocks some damage.',
    ),
    DefenseEnemyData(
      id: 'bomber',
      name: 'Bomber',
      category: EnemyCategory.bomber,
      baseHp: 15,
      speed: 35,
      damage: 30,
      attackSpeed: 0,
      goldDrop: 3,
      description: 'Explodes on contact dealing massive wall damage.',
    ),
    DefenseEnemyData(
      id: 'healer',
      name: 'Healer',
      category: EnemyCategory.healer,
      baseHp: 20,
      speed: 25,
      damage: 2,
      attackSpeed: 0.5,
      goldDrop: 4,
      description: 'Heals nearby enemies. Prioritize killing first.',
    ),
    DefenseEnemyData(
      id: 'boss_golem',
      name: 'Stone Golem',
      category: EnemyCategory.boss,
      baseHp: 200,
      speed: 15,
      damage: 15,
      attackSpeed: 0.3,
      goldDrop: 40,
      description: 'Massive boss with enormous HP. Appears every 10 waves.',
    ),
  ];

  static DefenseEnemyData get(String id) =>
      all.firstWhere((e) => e.id == id);

  static List<DefenseEnemyData> getByCategory(EnemyCategory cat) =>
      all.where((e) => e.category == cat).toList();
}
