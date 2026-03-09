import 'dart:math';
import 'package:flame/components.dart';

import '../game/runner_game.dart';
import '../components/enemy.dart';
import '../components/coin.dart';
import '../components/obstacle.dart';
import '../components/companion_pickup.dart';
import '../components/boss.dart';
import '../components/treasure_box.dart';
import '../data/enemy_data.dart';
import '../data/companion_data.dart';
import '../data/balance_config.dart';
import '../ui/ui_effects.dart';
import '../utils/constants.dart';
import 'dart:ui' show Color;

/// 구간 유형 — 위험/평화/일반 리듬
enum ZoneType { normal, danger, peace }

class LevelGenerator extends Component with HasGameReference<RunnerGame> {
  double _generationCursorX = GameConstants.worldWidth;
  final Random _rng = Random();
  double _lastObstacleX = 0;

  // Companion spawn timer (average 2 min interval)
  double _companionTimer = 0;
  double _nextCompanionTime = 60; // First companion after ~1 min

  // Boss tracking
  int _nextBossDistance = 500; // First boss at 500m
  bool _bossActive = false;

  // === 위험/평화 구간 리듬 ===
  ZoneType _currentZone = ZoneType.normal;
  double _zoneSegmentsLeft = 0; // 남은 세그먼트 수
  double _normalSegmentCount = 0; // 일반 구간 경과 세그먼트
  static const double _dangerZoneChance = 0.12; // 세그먼트당 위험 구간 돌입 확률
  static const double _dangerZoneLength = 6; // 위험 구간 세그먼트 수
  static const double _peaceZoneLength = 4; // 평화 구간 세그먼트 수
  static const double _minNormalBetweenZones = 5; // 최소 일반 세그먼트

  /// 현재 구간 타입
  ZoneType get currentZone => _currentZone;
  bool get isDangerZone => _currentZone == ZoneType.danger;
  bool get isPeaceZone => _currentZone == ZoneType.peace;
  /// 위험 구간 코인 배율
  double get zoneCoinMultiplier => _currentZone == ZoneType.danger ? 3.0 : 1.0;

  @override
  void update(double dt) {
    super.update(dt);

    final cameraX = game.camera.viewfinder.position.x;
    final targetX = cameraX + GameConstants.worldWidth + GameConstants.spawnAheadDistance;

    while (_generationCursorX < targetX) {
      _generateSegment();
      _generationCursorX += GameConstants.segmentWidth;
    }

    // Companion spawn (only in active mode, affected by rally event)
    if (game.isActiveMode) {
      _companionTimer += dt * game.companionSpawnMultiplier;
      if (_companionTimer >= _nextCompanionTime) {
        _companionTimer = 0;
        _nextCompanionTime = 90 + _rng.nextDouble() * 60; // 90-150s
        _spawnCompanion();
      }
    }

    // Boss spawn check
    final distanceM = game.distanceInMeters;
    if (!_bossActive && distanceM >= _nextBossDistance) {
      _spawnBoss();
    }
  }

  void _generateSegment() {
    final segmentStartX = _generationCursorX;

    // === 구간 리듬 업데이트 ===
    _updateZone();

    // Don't spawn enemies during boss fight
    if (!_bossActive) {
      if (!isPeaceZone) {
        _spawnEnemiesInSegment(segmentStartX);
      }
    }

    _spawnCoinsInSegment(segmentStartX);
    _spawnTreasureBoxInSegment(segmentStartX);

    if (game.isActiveMode && !_bossActive && !isPeaceZone) {
      _spawnObstaclesInSegment(segmentStartX);
    }
  }

  void _updateZone() {
    if (_zoneSegmentsLeft > 0) {
      _zoneSegmentsLeft -= 1;
      if (_zoneSegmentsLeft <= 0) {
        // 위험 구간이 끝나면 → 평화 구간 전환
        if (_currentZone == ZoneType.danger) {
          _currentZone = ZoneType.peace;
          _zoneSegmentsLeft = _peaceZoneLength;
          UIEffectManager.instance.spawnImpactText(
            text: 'PEACE ZONE',
            color: const Color(0xFF66BB6A),
            fontSize: 16,
            duration: 1.2,
          );
        } else {
          // 평화 구간 종료 → 일반
          _currentZone = ZoneType.normal;
          _normalSegmentCount = 0;
        }
      }
      return;
    }

    // 일반 구간에서 위험 구간 돌입 확률 체크
    _normalSegmentCount += 1;
    if (_normalSegmentCount >= _minNormalBetweenZones && !_bossActive) {
      if (_rng.nextDouble() < _dangerZoneChance) {
        _currentZone = ZoneType.danger;
        _zoneSegmentsLeft = _dangerZoneLength;
        UIEffectManager.instance.spawnImpactText(
          text: 'DANGER ZONE!',
          color: const Color(0xFFEF5350),
          fontSize: 18,
          duration: 1.5,
        );
        UIEffectManager.instance.screenFlash(
          color: const Color(0xFFEF5350),
          duration: 0.3,
          maxAlpha: 0.3,
        );
      }
    }
  }

  void _spawnEnemiesInSegment(double startX) {
    final enemies = EnemyDatabase.getEnemiesForRegion(game.currentRegionId);
    if (enemies.isEmpty) return;

    final baseCount = isDangerZone ? 3 + _rng.nextInt(3) : 1 + _rng.nextInt(3);
    final enemyCount = baseCount;
    final spacing = GameConstants.segmentWidth / (enemyCount + 1);

    for (var i = 0; i < enemyCount; i++) {
      final x = startX + spacing * (i + 1) + (_rng.nextDouble() * 30 - 15);

      final isAir = game.isActiveMode && _rng.nextDouble() < BalanceConfig.airEnemyChance;

      final pool = isAir
          ? EnemyDatabase.getAirEnemies(game.currentRegionId)
          : EnemyDatabase.getGroundEnemies(game.currentRegionId);
      if (pool.isEmpty) continue;

      final data = _weightedRandom(pool);

      final y = isAir
          ? GameConstants.groundY - 60 - _rng.nextDouble() * 30
          : GameConstants.groundY - data.height;

      // Golden enemy chance (2%, or 100% during golden hour)
      final isGolden = game.isGoldenHour || _rng.nextDouble() < BalanceConfig.goldenEnemyChance;

      game.world.add(Enemy(
        data: data,
        spawnPosition: Vector2(x, y),
        isGolden: isGolden,
      ));
    }
  }

  void _spawnCoinsInSegment(double startX) {
    // 평화 구간: 코인 100% 스폰, 일반: 60%
    final coinChance = isPeaceZone ? 1.0 : 0.6;
    if (_rng.nextDouble() > coinChance) return;

    // 평화 구간에서는 코인 가치 증가
    final coinValue = isPeaceZone ? 2 : 1;
    final pattern = _rng.nextInt(3);
    final baseX = startX + _rng.nextDouble() * GameConstants.segmentWidth * 0.5 + 50;

    switch (pattern) {
      case 0:
        game.world.add(Coin(
          spawnPosition: Vector2(baseX, GameConstants.groundY - 30 - _rng.nextDouble() * 40),
          value: coinValue,
        ));
        break;
      case 1:
        // 평화 구간에서는 더 긴 코인 줄
        final count = isPeaceZone ? 5 + _rng.nextInt(4) : 3 + _rng.nextInt(3);
        final isAir = _rng.nextBool();
        final y = isAir
            ? GameConstants.groundY - 100 - _rng.nextDouble() * 30
            : GameConstants.groundY - 30;
        for (var i = 0; i < count; i++) {
          game.world.add(Coin(
            spawnPosition: Vector2(baseX + i * 22, y),
            value: coinValue,
          ));
        }
        break;
      case 2:
        final count = isPeaceZone ? 8 : 5;
        for (var i = 0; i < count; i++) {
          final t = i / (count - 1);
          final arcX = baseX + t * 100;
          final arcY = GameConstants.groundY - 40 - sin(t * 3.1416) * 60;
          game.world.add(Coin(
            spawnPosition: Vector2(arcX, arcY),
            value: coinValue,
          ));
        }
        break;
    }
  }

  void _spawnObstaclesInSegment(double startX) {
    final stormMult = game.weatherManager.obstacleMultiplier;
    // 위험 구간: 장애물 2배 확률
    final dangerMult = isDangerZone ? 2.0 : 1.0;
    if (_rng.nextDouble() > BalanceConfig.obstacleSpawnChance * stormMult * dangerMult) return;

    final x = startX + _rng.nextDouble() * GameConstants.segmentWidth * 0.6 + 60;
    if (x - _lastObstacleX < 200) return;

    game.world.add(Obstacle(
      spawnPosition: Vector2(x, GameConstants.groundY - 28),
    ));
    _lastObstacleX = x;
  }

  void _spawnCompanion() {
    final companionId = game.companionManager.rollCompanionSpawn(_rng);
    if (companionId == null) return;

    final data = CompanionDatabase.get(companionId);
    final playerX = game.player.position.x;
    final x = playerX + GameConstants.worldWidth * 0.8;
    final y = GameConstants.groundY - 40 - _rng.nextDouble() * 60;

    game.world.add(CompanionPickup(
      data: data,
      spawnPosition: Vector2(x, y),
    ));
  }

  void _spawnBoss() {
    _bossActive = true;
    final bossIndex = (_nextBossDistance ~/ 500);
    final playerX = game.player.position.x;

    final boss = Boss(
      regionId: game.currentRegionId,
      bossIndex: bossIndex,
      spawnPosition: Vector2(playerX + GameConstants.worldWidth + 50, GameConstants.groundY - 80),
    );

    game.world.add(boss);
    game.activeBoss = boss;

    // Schedule next boss and track boss completion
    _nextBossDistance += 500;
  }

  /// Called by runner_game when boss is defeated or escapes
  void onBossComplete() {
    _bossActive = false;
    game.activeBoss = null;
  }

  void _spawnTreasureBoxInSegment(double startX) {
    // 5% chance per segment
    if (_rng.nextDouble() > 0.05) return;

    final x = startX + _rng.nextDouble() * GameConstants.segmentWidth * 0.7 + 40;
    final y = GameConstants.groundY - 30 - _rng.nextDouble() * 50;

    // Rarity roll
    final rarityRoll = _rng.nextDouble();
    TreasureRarity rarity;
    if (rarityRoll < 0.05) {
      rarity = TreasureRarity.epic;
    } else if (rarityRoll < 0.30) {
      rarity = TreasureRarity.rare;
    } else {
      rarity = TreasureRarity.common;
    }

    game.world.add(TreasureBox(
      spawnPosition: Vector2(x, y),
      rarity: rarity,
    ));
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
