import 'dart:ui';

enum EnemyType { ground, air }

class EnemyData {
  final String id;
  final String name;
  final EnemyType type;
  final int hp;
  final double coinDrop;
  final double soulDrop;
  final double width;
  final double height;
  final Color color;
  final Color accentColor;
  final int spawnWeight;

  const EnemyData({
    required this.id,
    required this.name,
    required this.type,
    required this.hp,
    required this.coinDrop,
    this.soulDrop = 0,
    required this.width,
    required this.height,
    required this.color,
    required this.accentColor,
    required this.spawnWeight,
  });
}

class EnemyDatabase {
  static const List<EnemyData> meadowEnemies = [
    // Ground
    EnemyData(
      id: 'slime',
      name: '슬라임',
      type: EnemyType.ground,
      hp: 1,
      coinDrop: 1,
      width: 28,
      height: 22,
      color: Color(0xFF4CAF50),
      accentColor: Color(0xFF81C784),
      spawnWeight: 40,
    ),
    EnemyData(
      id: 'mushroom',
      name: '버섯',
      type: EnemyType.ground,
      hp: 2,
      coinDrop: 2,
      width: 24,
      height: 28,
      color: Color(0xFFE57373),
      accentColor: Color(0xFFFFCDD2),
      spawnWeight: 25,
    ),
    // Air
    EnemyData(
      id: 'bird',
      name: '새',
      type: EnemyType.air,
      hp: 1,
      coinDrop: 3,
      width: 26,
      height: 18,
      color: Color(0xFF42A5F5),
      accentColor: Color(0xFF90CAF9),
      spawnWeight: 25,
    ),
    EnemyData(
      id: 'butterfly',
      name: '나비',
      type: EnemyType.air,
      hp: 1,
      coinDrop: 2,
      width: 22,
      height: 16,
      color: Color(0xFFCE93D8),
      accentColor: Color(0xFFF3E5F5),
      spawnWeight: 10,
    ),
  ];

  static List<EnemyData> getEnemiesForRegion(String regionId) {
    switch (regionId) {
      case 'meadow':
        return meadowEnemies;
      default:
        return meadowEnemies;
    }
  }

  static List<EnemyData> getGroundEnemies(String regionId) {
    return getEnemiesForRegion(regionId)
        .where((e) => e.type == EnemyType.ground)
        .toList();
  }

  static List<EnemyData> getAirEnemies(String regionId) {
    return getEnemiesForRegion(regionId)
        .where((e) => e.type == EnemyType.air)
        .toList();
  }
}
