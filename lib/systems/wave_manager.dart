import 'dart:math';
import 'package:flame/components.dart';
import '../game/defense_game.dart';
import '../data/enemy_data.dart';
import '../data/balance_config.dart';

/// Enemy wave spawning system for castle defense.
/// Manages wave progression, enemy spawn timing, difficulty scaling,
/// boss waves, reward waves, and perfect wave tracking.
class WaveManager extends Component with HasGameReference<DefenseGame> {
  int currentWave = 0;
  int enemiesRemaining = 0;
  int enemiesSpawned = 0;
  int totalEnemiesInWave = 0;
  double waveTimer = 0;
  double spawnTimer = 0;
  bool waveActive = false;
  bool betweenWaves = false;
  double betweenWaveTimer = 0;
  int bossesKilled = 0;

  // Perfect wave tracking (wall took no damage during wave)
  bool wallTookDamage = false;
  int consecutivePerfects = 0;

  // Wave duration & spawn interval (from BalanceConfig or relic override)
  double get waveDuration => game.relicManager.waveDurationOverride;
  double get betweenWavePause => BalanceConfig.betweenWavePause;

  // Spawn boundaries (just outside the 400x420 field area)
  static const double fieldWidth = 400.0;
  static const double fieldHeight = 420.0;
  static const double spawnMargin = 30.0;

  final Random _rng = Random();

  /// Whether the current wave is a boss wave.
  bool get isBossWave =>
      currentWave > 0 && currentWave % BalanceConfig.bossInterval == 0;

  /// Whether the current wave triggers a reward card selection.
  bool get isRewardWave =>
      currentWave > 0 && currentWave % BalanceConfig.rewardInterval == 0;

  /// Start the next wave. Called from game or automatically after between-wave pause.
  void startNextWave() {
    currentWave++;
    wallTookDamage = false;

    final unitCount = game.unitSlots.where((s) => s.isOccupied).length;
    final baseCount = _baseEnemyCount;
    totalEnemiesInWave = ((baseCount +
                (currentWave * BalanceConfig.enemyCountWaveScale).floor()) *
            (1 + unitCount * BalanceConfig.enemyCountUnitScale))
        .round()
        .clamp(1, BalanceConfig.maxEnemiesPerWave);

    enemiesRemaining = totalEnemiesInWave;
    enemiesSpawned = 0;
    spawnTimer = 0;
    waveTimer = 0;
    waveActive = true;
    betweenWaves = false;

    // Notify game of wave start (relic hooks: gold, heal, rift, time warp)
    game.onWaveStart(currentWave);
  }

  /// Base enemy count per wave tier with late-game scaling.
  int get _baseEnemyCount {
    // Late-game scaling: massive enemy counts for spectacle
    if (currentWave > 30) return 60;
    if (currentWave > 24) return 40;
    if (currentWave > 20) return 30;
    if (currentWave > 15) return 20;

    for (final tier in BalanceConfig.baseEnemyCountTiers) {
      if (currentWave <= tier[0]) return tier[1];
    }
    return BalanceConfig.baseEnemyCountDefault;
  }

  /// Spawn interval: spread enemies evenly across wave duration.
  double get _spawnInterval {
    if (totalEnemiesInWave <= 0) return 1.0;
    return (waveDuration / totalEnemiesInWave)
        .clamp(BalanceConfig.minSpawnInterval, BalanceConfig.maxSpawnInterval);
  }

  @override
  void update(double dt) {
    if (betweenWaves) {
      _updateBetweenWaves(dt);
      return;
    }
    if (!waveActive) return;
    _updateWave(dt);
  }

  void _updateBetweenWaves(double dt) {
    betweenWaveTimer -= dt;
    if (betweenWaveTimer <= 0) {
      betweenWaves = false;
      startNextWave();
    }
  }

  void _updateWave(double dt) {
    waveTimer += dt;
    spawnTimer += dt;

    // Spawn enemies at intervals until all are spawned
    if (enemiesSpawned < totalEnemiesInWave && spawnTimer >= _spawnInterval) {
      spawnTimer -= _spawnInterval;
      spawnEnemy();
    }

    // Wave ends when all enemies are killed (not just spawned)
    if (enemiesSpawned >= totalEnemiesInWave && enemiesRemaining <= 0) {
      onWaveComplete();
    }
  }

  /// Spawn a single enemy at a random screen edge.
  void spawnEnemy() {
    if (enemiesSpawned >= totalEnemiesInWave) return;

    final unitCount = game.unitSlots.where((s) => s.isOccupied).length;
    final typeId = _pickEnemyType();
    final hp = _scaledHp(typeId, unitCount);
    final speed = _scaledSpeed(typeId, unitCount);
    final spawnPos = _randomSpawnPosition();

    game.spawnEnemy(
      typeId: typeId,
      position: spawnPos,
      hp: hp,
      speed: speed,
    );
    enemiesSpawned++;

    // Boss wave: spawn a boss at wave midpoint
    if (isBossWave && enemiesSpawned == (totalEnemiesInWave ~/ 2)) {
      final bossPos = _randomSpawnPosition();
      game.spawnBoss(
        wave: currentWave,
        position: bossPos,
        hpMultiplier:
            pow(BalanceConfig.enemyHpWaveScale, currentWave).toDouble() *
                (1 + unitCount * BalanceConfig.enemyHpUnitScale),
      );
    }
  }

  /// Pick enemy type based on current wave (data-driven unlock).
  String _pickEnemyType() {
    final available = DefenseEnemyDatabase.availableAt(currentWave);
    return available[_rng.nextInt(available.length)].id;
  }

  /// Scale HP by wave and unit count.
  double _scaledHp(String typeId, int unitCount) {
    final data = DefenseEnemyDatabase.get(typeId);
    final baseHp = data?.baseHp ?? 20;
    return baseHp *
        pow(BalanceConfig.enemyHpWaveScale, currentWave).toDouble() *
        (1 + unitCount * BalanceConfig.enemyHpUnitScale);
  }

  /// Scale speed by wave and unit count.
  double _scaledSpeed(String typeId, int unitCount) {
    final data = DefenseEnemyDatabase.get(typeId);
    final baseSpeed = data?.baseSpeed ?? 40;
    return baseSpeed *
        (1 + unitCount * BalanceConfig.enemySpeedUnitScale) *
        (1 +
            max(0, currentWave - BalanceConfig.enemySpeedLateWaveStart) *
                BalanceConfig.enemySpeedLateWaveScale);
  }

  /// Generate a spawn position just outside one of the 4 screen edges.
  Vector2 _randomSpawnPosition() {
    final direction = _rng.nextInt(4); // 0=top, 1=bottom, 2=left, 3=right
    switch (direction) {
      case 0: // top
        return Vector2(
          _rng.nextDouble() * fieldWidth,
          -spawnMargin,
        );
      case 1: // bottom
        return Vector2(
          _rng.nextDouble() * fieldWidth,
          fieldHeight + spawnMargin,
        );
      case 2: // left
        return Vector2(
          -spawnMargin,
          _rng.nextDouble() * fieldHeight,
        );
      case 3: // right
        return Vector2(
          fieldWidth + spawnMargin,
          _rng.nextDouble() * fieldHeight,
        );
      default:
        return Vector2(
          _rng.nextDouble() * fieldWidth,
          -spawnMargin,
        );
    }
  }

  /// Called when an enemy is killed.
  void onEnemyKilled() {
    enemiesRemaining--;
    if (enemiesRemaining < 0) enemiesRemaining = 0;
  }

  /// Called when a boss is killed.
  void onBossKilled() {
    bossesKilled++;
  }

  /// Called when the wall takes damage during this wave.
  void onWallDamaged() {
    wallTookDamage = true;
  }

  /// Called when all enemies in the wave are killed.
  void onWaveComplete() {
    waveActive = false;

    // Perfect wave tracking
    if (!wallTookDamage) {
      consecutivePerfects++;
      game.onPerfectWave(consecutivePerfects);
    } else {
      consecutivePerfects = 0;
    }

    // Wave clear announcement
    game.onWaveClear(currentWave);

    // Update highest wave record
    if (currentWave > game.highestWave) {
      game.highestWave = currentWave;
    }

    // Reward wave: trigger card selection overlay
    if (isRewardWave) {
      game.showRewardSelection();
    }

    // Start between-wave pause
    betweenWaves = true;
    betweenWaveTimer = betweenWavePause;
  }

  /// Begin the first wave (called at game start).
  void startFirstWave() {
    currentWave = 0;
    bossesKilled = 0;
    consecutivePerfects = 0;
    wallTookDamage = false;
    waveActive = false;
    betweenWaves = true;
    betweenWaveTimer = betweenWavePause;
  }

  /// Reset all wave state (for new run).
  void reset() {
    currentWave = 0;
    enemiesRemaining = 0;
    enemiesSpawned = 0;
    totalEnemiesInWave = 0;
    waveTimer = 0;
    spawnTimer = 0;
    waveActive = false;
    betweenWaves = false;
    betweenWaveTimer = 0;
    bossesKilled = 0;
    wallTookDamage = false;
    consecutivePerfects = 0;
  }

  // === Save/Load (for mid-run resume) ===

  Map<String, dynamic> toMap() {
    return {
      'currentWave': currentWave,
      'enemiesRemaining': enemiesRemaining,
      'enemiesSpawned': enemiesSpawned,
      'totalEnemiesInWave': totalEnemiesInWave,
      'waveTimer': waveTimer,
      'spawnTimer': spawnTimer,
      'waveActive': waveActive,
      'betweenWaves': betweenWaves,
      'betweenWaveTimer': betweenWaveTimer,
      'bossesKilled': bossesKilled,
      'wallTookDamage': wallTookDamage,
      'consecutivePerfects': consecutivePerfects,
    };
  }

  void loadFromMap(Map<String, dynamic> map) {
    currentWave = (map['currentWave'] as num?)?.toInt() ?? 0;
    enemiesRemaining = (map['enemiesRemaining'] as num?)?.toInt() ?? 0;
    enemiesSpawned = (map['enemiesSpawned'] as num?)?.toInt() ?? 0;
    totalEnemiesInWave = (map['totalEnemiesInWave'] as num?)?.toInt() ?? 0;
    waveTimer = (map['waveTimer'] as num?)?.toDouble() ?? 0;
    spawnTimer = (map['spawnTimer'] as num?)?.toDouble() ?? 0;
    waveActive = (map['waveActive'] as bool?) ?? false;
    betweenWaves = (map['betweenWaves'] as bool?) ?? false;
    betweenWaveTimer = (map['betweenWaveTimer'] as num?)?.toDouble() ?? 0;
    bossesKilled = (map['bossesKilled'] as num?)?.toInt() ?? 0;
    wallTookDamage = (map['wallTookDamage'] as bool?) ?? false;
    consecutivePerfects = (map['consecutivePerfects'] as num?)?.toInt() ?? 0;
  }
}
