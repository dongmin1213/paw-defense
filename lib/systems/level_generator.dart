import 'dart:math';
import 'package:flame/components.dart';

import '../game/runner_game.dart';
import '../components/enemy.dart';
import '../components/coin.dart';
import '../components/obstacle.dart';
import '../data/enemy_data.dart';
import '../data/balance_config.dart';
import '../utils/constants.dart';

class LevelGenerator extends Component with HasGameReference<RunnerGame> {
  double _generationCursorX = GameConstants.worldWidth;
  final Random _rng = Random();
  double _lastEnemyX = 0;
  double _lastObstacleX = 0;

  @override
  void update(double dt) {
    super.update(dt);

    final cameraX = game.camera.viewfinder.position.x;
    final targetX = cameraX + GameConstants.worldWidth + GameConstants.spawnAheadDistance;

    while (_generationCursorX < targetX) {
      _generateSegment();
      _generationCursorX += GameConstants.segmentWidth;
    }
  }

  void _generateSegment() {
    final segmentStartX = _generationCursorX;

    // Spawn enemies
    _spawnEnemiesInSegment(segmentStartX);

    // Spawn coins (independent of enemies)
    _spawnCoinsInSegment(segmentStartX);

    // Spawn obstacles (only in active mode)
    if (game.isActiveMode) {
      _spawnObstaclesInSegment(segmentStartX);
    }
  }

  void _spawnEnemiesInSegment(double startX) {
    final enemies = EnemyDatabase.getEnemiesForRegion(game.currentRegionId);
    if (enemies.isEmpty) return;

    final enemyCount = 1 + _rng.nextInt(3); // 1-3 enemies per segment
    final spacing = GameConstants.segmentWidth / (enemyCount + 1);

    for (var i = 0; i < enemyCount; i++) {
      final x = startX + spacing * (i + 1) + (_rng.nextDouble() * 30 - 15);

      // Decide ground or air
      final isAir = game.isActiveMode && _rng.nextDouble() < BalanceConfig.airEnemyChance;

      final pool = isAir
          ? EnemyDatabase.getAirEnemies(game.currentRegionId)
          : EnemyDatabase.getGroundEnemies(game.currentRegionId);
      if (pool.isEmpty) continue;

      final data = _weightedRandom(pool);

      final y = isAir
          ? GameConstants.groundY - 80 - _rng.nextDouble() * 60 // air: 80-140px above ground
          : GameConstants.groundY - data.height; // ground: sitting on ground

      game.world.add(Enemy(
        data: data,
        spawnPosition: Vector2(x, y),
      ));
    }
  }

  void _spawnCoinsInSegment(double startX) {
    // 60% chance to spawn a coin pattern
    if (_rng.nextDouble() > 0.6) return;

    final pattern = _rng.nextInt(3); // 0: single, 1: line, 2: arc
    final baseX = startX + _rng.nextDouble() * GameConstants.segmentWidth * 0.5 + 50;

    switch (pattern) {
      case 0: // Single coin
        game.world.add(Coin(
          spawnPosition: Vector2(baseX, GameConstants.groundY - 30 - _rng.nextDouble() * 40),
          value: 1,
        ));
        break;
      case 1: // Line of 3-5 coins
        final count = 3 + _rng.nextInt(3);
        final isAir = _rng.nextBool();
        final y = isAir
            ? GameConstants.groundY - 100 - _rng.nextDouble() * 30
            : GameConstants.groundY - 30;
        for (var i = 0; i < count; i++) {
          game.world.add(Coin(
            spawnPosition: Vector2(baseX + i * 22, y),
            value: 1,
          ));
        }
        break;
      case 2: // Arc of coins
        final count = 5;
        for (var i = 0; i < count; i++) {
          final t = i / (count - 1);
          final arcX = baseX + t * 100;
          final arcY = GameConstants.groundY - 40 - sin(t * 3.1416) * 60;
          game.world.add(Coin(
            spawnPosition: Vector2(arcX, arcY),
            value: 1,
          ));
        }
        break;
    }
  }

  void _spawnObstaclesInSegment(double startX) {
    if (_rng.nextDouble() > BalanceConfig.obstacleSpawnChance) return;

    // Don't spawn too close to last obstacle
    final x = startX + _rng.nextDouble() * GameConstants.segmentWidth * 0.6 + 60;
    if (x - _lastObstacleX < 200) return;

    game.world.add(Obstacle(
      spawnPosition: Vector2(x, GameConstants.groundY - 28),
    ));
    _lastObstacleX = x;
  }

  EnemyData _weightedRandom(List<EnemyData> pool) {
    final totalWeight = pool.fold<int>(0, (sum, e) => sum + e.spawnWeight);
    var roll = _rng.nextInt(totalWeight);
    for (final enemy in pool) {
      roll -= enemy.spawnWeight;
      if (roll < 0) return enemy;
    }
    return pool.last;
  }
}
