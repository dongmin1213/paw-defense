/// Centralized enemy type definitions for castle defense.
/// All enemy stats are defined here — no hardcoded values in other files.
class DefenseEnemyData {
  final String id;
  final String name;
  final double baseHp;
  final double baseSpeed;
  final double baseDamage;
  final double baseAtkSpeed;
  final int goldDrop;
  final bool isFlying;

  /// Wave at which this enemy type first appears.
  final int unlockWave;

  const DefenseEnemyData({
    required this.id,
    required this.name,
    required this.baseHp,
    required this.baseSpeed,
    required this.baseDamage,
    required this.baseAtkSpeed,
    required this.goldDrop,
    this.isFlying = false,
    this.unlockWave = 1,
  });
}

/// Database of all enemy types. Add new enemies here only.
class DefenseEnemyDatabase {
  static const List<DefenseEnemyData> all = [
    DefenseEnemyData(
      id: 'slime',
      name: '슬라임',
      baseHp: 20,
      baseSpeed: 40,
      baseDamage: 3,
      baseAtkSpeed: 1.0,
      goldDrop: 2,
      unlockWave: 1,
    ),
    DefenseEnemyData(
      id: 'goblin',
      name: '고블린',
      baseHp: 35,
      baseSpeed: 60,
      baseDamage: 5,
      baseAtkSpeed: 1.2,
      goldDrop: 4,
      unlockWave: 4,
    ),
    DefenseEnemyData(
      id: 'bat',
      name: '박쥐',
      baseHp: 15,
      baseSpeed: 70,
      baseDamage: 3,
      baseAtkSpeed: 1.5,
      goldDrop: 3,
      isFlying: true,
      unlockWave: 7,
    ),
    DefenseEnemyData(
      id: 'orc',
      name: '오크',
      baseHp: 80,
      baseSpeed: 30,
      baseDamage: 10,
      baseAtkSpeed: 0.6,
      goldDrop: 8,
      unlockWave: 10,
    ),
    DefenseEnemyData(
      id: 'shielded',
      name: '방패병',
      baseHp: 120,
      baseSpeed: 25,
      baseDamage: 7,
      baseAtkSpeed: 0.8,
      goldDrop: 10,
      unlockWave: 15,
    ),
    DefenseEnemyData(
      id: 'bomber',
      name: '폭탄병',
      baseHp: 40,
      baseSpeed: 50,
      baseDamage: 15,
      baseAtkSpeed: 0.5,
      goldDrop: 12,
      unlockWave: 18,
    ),
    DefenseEnemyData(
      id: 'healer',
      name: '힐러',
      baseHp: 50,
      baseSpeed: 35,
      baseDamage: 4,
      baseAtkSpeed: 1.0,
      goldDrop: 6,
      unlockWave: 20,
    ),
  ];

  /// Lookup enemy data by ID. Returns null if not found.
  static DefenseEnemyData? get(String id) {
    for (final e in all) {
      if (e.id == id) return e;
    }
    return null;
  }

  /// Get all enemy types available at the given wave.
  static List<DefenseEnemyData> availableAt(int wave) {
    return all.where((e) => e.unlockWave <= wave).toList();
  }
}
