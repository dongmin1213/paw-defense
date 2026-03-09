/// Wave composition data — defines which enemies spawn per wave range.
/// Composition weights shift as waves progress, introducing harder enemies.

class WaveEnemyEntry {
  final String enemyId;
  final int weight; // spawn weight within this wave bracket

  const WaveEnemyEntry({
    required this.enemyId,
    required this.weight,
  });
}

class WaveBracket {
  final int startWave;
  final int endWave; // inclusive, -1 = infinity
  final List<WaveEnemyEntry> enemies;
  final int baseCount; // base number of enemies per wave in this bracket
  final bool hasBoss; // boss spawns every 10 waves within bracket

  const WaveBracket({
    required this.startWave,
    required this.endWave,
    required this.enemies,
    required this.baseCount,
    this.hasBoss = false,
  });
}

class WaveDatabase {
  static const List<WaveBracket> brackets = [
    // Waves 1–5: slimes only
    WaveBracket(
      startWave: 1,
      endWave: 5,
      enemies: [
        WaveEnemyEntry(enemyId: 'slime', weight: 100),
      ],
      baseCount: 3,
    ),
    // Waves 6–10: slimes + goblins, first boss at 10
    WaveBracket(
      startWave: 6,
      endWave: 10,
      enemies: [
        WaveEnemyEntry(enemyId: 'slime', weight: 60),
        WaveEnemyEntry(enemyId: 'goblin', weight: 40),
      ],
      baseCount: 5,
      hasBoss: true,
    ),
    // Waves 11–20: add bats and orcs
    WaveBracket(
      startWave: 11,
      endWave: 20,
      enemies: [
        WaveEnemyEntry(enemyId: 'slime', weight: 30),
        WaveEnemyEntry(enemyId: 'goblin', weight: 25),
        WaveEnemyEntry(enemyId: 'orc', weight: 20),
        WaveEnemyEntry(enemyId: 'bat', weight: 25),
      ],
      baseCount: 7,
      hasBoss: true,
    ),
    // Waves 21–30: add shield bearers and bombers
    WaveBracket(
      startWave: 21,
      endWave: 30,
      enemies: [
        WaveEnemyEntry(enemyId: 'slime', weight: 15),
        WaveEnemyEntry(enemyId: 'goblin', weight: 20),
        WaveEnemyEntry(enemyId: 'orc', weight: 20),
        WaveEnemyEntry(enemyId: 'bat', weight: 15),
        WaveEnemyEntry(enemyId: 'shieldBearer', weight: 15),
        WaveEnemyEntry(enemyId: 'bomber', weight: 15),
      ],
      baseCount: 9,
      hasBoss: true,
    ),
    // Waves 31+: all enemy types including healers
    WaveBracket(
      startWave: 31,
      endWave: -1,
      enemies: [
        WaveEnemyEntry(enemyId: 'slime', weight: 10),
        WaveEnemyEntry(enemyId: 'goblin', weight: 15),
        WaveEnemyEntry(enemyId: 'orc', weight: 15),
        WaveEnemyEntry(enemyId: 'bat', weight: 15),
        WaveEnemyEntry(enemyId: 'shieldBearer', weight: 15),
        WaveEnemyEntry(enemyId: 'bomber', weight: 15),
        WaveEnemyEntry(enemyId: 'healer', weight: 15),
      ],
      baseCount: 11,
      hasBoss: true,
    ),
  ];

  /// Returns the bracket for a given wave number.
  static WaveBracket getBracket(int wave) {
    for (final bracket in brackets) {
      if (wave >= bracket.startWave &&
          (bracket.endWave == -1 || wave <= bracket.endWave)) {
        return bracket;
      }
    }
    return brackets.last;
  }

  /// Whether a boss spawns on this wave (every 10 waves, if bracket allows).
  static bool isBossWave(int wave) {
    final bracket = getBracket(wave);
    return bracket.hasBoss && wave % 10 == 0;
  }
}
