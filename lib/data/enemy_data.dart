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
  // === 초원 (Meadow) ===
  static const List<EnemyData> meadowEnemies = [
    EnemyData(id: 'slime', name: '슬라임', type: EnemyType.ground, hp: 1, coinDrop: 1, width: 28, height: 22, color: Color(0xFF4CAF50), accentColor: Color(0xFF81C784), spawnWeight: 40),
    EnemyData(id: 'mushroom', name: '버섯', type: EnemyType.ground, hp: 2, coinDrop: 2, width: 24, height: 28, color: Color(0xFFE57373), accentColor: Color(0xFFFFCDD2), spawnWeight: 25),
    EnemyData(id: 'bird', name: '새', type: EnemyType.air, hp: 1, coinDrop: 3, width: 26, height: 18, color: Color(0xFF42A5F5), accentColor: Color(0xFF90CAF9), spawnWeight: 25),
    EnemyData(id: 'butterfly', name: '나비', type: EnemyType.air, hp: 1, coinDrop: 2, width: 22, height: 16, color: Color(0xFFCE93D8), accentColor: Color(0xFFF3E5F5), spawnWeight: 10),
  ];

  // === 숲 (Forest) ===
  static const List<EnemyData> forestEnemies = [
    EnemyData(id: 'goblin', name: '고블린', type: EnemyType.ground, hp: 3, coinDrop: 5, width: 26, height: 28, color: Color(0xFF558B2F), accentColor: Color(0xFF8BC34A), spawnWeight: 35),
    EnemyData(id: 'spider', name: '거미', type: EnemyType.ground, hp: 4, coinDrop: 7, width: 30, height: 22, color: Color(0xFF4E342E), accentColor: Color(0xFF795548), spawnWeight: 25),
    EnemyData(id: 'bat', name: '박쥐', type: EnemyType.air, hp: 2, coinDrop: 8, width: 28, height: 16, color: Color(0xFF37474F), accentColor: Color(0xFF78909C), spawnWeight: 25),
    EnemyData(id: 'fairy', name: '요정', type: EnemyType.air, hp: 1, coinDrop: 10, width: 18, height: 18, color: Color(0xFFFFEB3B), accentColor: Color(0xFFFFF9C4), spawnWeight: 15),
  ];

  // === 사막 (Desert) ===
  static const List<EnemyData> desertEnemies = [
    EnemyData(id: 'scorpion', name: '전갈', type: EnemyType.ground, hp: 6, coinDrop: 15, width: 32, height: 20, color: Color(0xFFBF360C), accentColor: Color(0xFFFF8A65), spawnWeight: 35),
    EnemyData(id: 'mummy', name: '미라', type: EnemyType.ground, hp: 8, coinDrop: 20, width: 26, height: 34, color: Color(0xFFD7CCC8), accentColor: Color(0xFF8D6E63), spawnWeight: 25),
    EnemyData(id: 'eagle', name: '독수리', type: EnemyType.air, hp: 4, coinDrop: 25, width: 34, height: 20, color: Color(0xFF5D4037), accentColor: Color(0xFFA1887F), spawnWeight: 25),
    EnemyData(id: 'sand_spirit', name: '모래령', type: EnemyType.air, hp: 3, coinDrop: 30, width: 24, height: 24, color: Color(0xFFFFC107), accentColor: Color(0xFFFFE082), spawnWeight: 15),
  ];

  // === 설산 (Snowfield) ===
  static const List<EnemyData> snowfieldEnemies = [
    EnemyData(id: 'snow_golem', name: '눈골렘', type: EnemyType.ground, hp: 12, coinDrop: 40, width: 34, height: 36, color: Color(0xFFE0E0E0), accentColor: Color(0xFF90CAF9), spawnWeight: 30),
    EnemyData(id: 'wolf', name: '늑대', type: EnemyType.ground, hp: 8, coinDrop: 50, width: 32, height: 24, color: Color(0xFF78909C), accentColor: Color(0xFFB0BEC5), spawnWeight: 30),
    EnemyData(id: 'snow_owl', name: '눈올빼미', type: EnemyType.air, hp: 6, coinDrop: 60, width: 26, height: 22, color: Color(0xFFF5F5F5), accentColor: Color(0xFFBBDEFB), spawnWeight: 25),
    EnemyData(id: 'ice_spirit', name: '얼음정령', type: EnemyType.air, hp: 5, coinDrop: 80, width: 22, height: 22, color: Color(0xFF81D4FA), accentColor: Color(0xFFE1F5FE), spawnWeight: 15),
  ];

  // === 화산 (Volcano) ===
  static const List<EnemyData> volcanoEnemies = [
    EnemyData(id: 'fire_imp', name: '화염임프', type: EnemyType.ground, hp: 15, coinDrop: 120, width: 26, height: 28, color: Color(0xFFFF5722), accentColor: Color(0xFFFFAB91), spawnWeight: 35),
    EnemyData(id: 'dragonkin', name: '용인', type: EnemyType.ground, hp: 20, coinDrop: 180, width: 34, height: 32, color: Color(0xFFB71C1C), accentColor: Color(0xFFEF5350), spawnWeight: 25),
    EnemyData(id: 'fire_bat', name: '불박쥐', type: EnemyType.air, hp: 10, coinDrop: 200, width: 30, height: 18, color: Color(0xFFFF6F00), accentColor: Color(0xFFFFD54F), spawnWeight: 25),
    EnemyData(id: 'phoenix', name: '피닉스', type: EnemyType.air, hp: 8, coinDrop: 300, width: 32, height: 26, color: Color(0xFFFF8F00), accentColor: Color(0xFFFFECB3), spawnWeight: 15),
  ];

  static List<EnemyData> getEnemiesForRegion(String regionId) {
    switch (regionId) {
      case 'meadow': return meadowEnemies;
      case 'forest': return forestEnemies;
      case 'desert': return desertEnemies;
      case 'snowfield': return snowfieldEnemies;
      case 'volcano': return volcanoEnemies;
      default: return meadowEnemies;
    }
  }

  static List<EnemyData> getGroundEnemies(String regionId) {
    return getEnemiesForRegion(regionId).where((e) => e.type == EnemyType.ground).toList();
  }

  static List<EnemyData> getAirEnemies(String regionId) {
    return getEnemiesForRegion(regionId).where((e) => e.type == EnemyType.air).toList();
  }
}
