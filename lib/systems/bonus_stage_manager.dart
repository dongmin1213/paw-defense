import 'dart:math';

import 'package:flame/components.dart';

import '../game/runner_game.dart';
import '../components/coin.dart';
import '../utils/constants.dart';

/// 보너스 스테이지 — 일정 거리마다 코인 러시 구간
class BonusStageManager extends Component with HasGameReference<RunnerGame> {
  bool isActive = false;
  double _timer = 0;
  double _spawnTimer = 0;
  double _nextTriggerDistance = 800; // 첫 보너스 800m
  final Random _rng = Random();

  static const double stageDuration = 8.0; // 8초 동안
  static const double coinSpawnInterval = 0.12; // 코인 빈도

  @override
  void update(double dt) {
    if (!game.isPlaying) return;

    if (isActive) {
      _updateActiveStage(dt);
    } else {
      _checkTrigger();
    }
  }

  void _checkTrigger() {
    final distM = game.distanceInMeters;
    if (distM >= _nextTriggerDistance) {
      _startBonusStage();
    }
  }

  void _startBonusStage() {
    isActive = true;
    _timer = 0;
    _spawnTimer = 0;
    _nextTriggerDistance += 500 + _rng.nextInt(300).toDouble(); // 500~800m 간격

    game.achievementManager.onBonusStage();
    game.gameFeel.shake(intensity: 4, duration: 0.2);
  }

  void _updateActiveStage(double dt) {
    _timer += dt;
    _spawnTimer += dt;

    if (_timer >= stageDuration) {
      isActive = false;
      return;
    }

    // 대량 코인 스폰
    if (_spawnTimer >= coinSpawnInterval) {
      _spawnTimer = 0;
      _spawnBonusCoin();
    }
  }

  void _spawnBonusCoin() {
    final playerX = game.player.position.x;
    final x = playerX + 300 + _rng.nextDouble() * 400;

    // 패턴: 상단에 코인 줄, 아치 형태
    final pattern = _rng.nextInt(3);
    switch (pattern) {
      case 0: // 직선
        final y = GameConstants.groundY - 40 - _rng.nextDouble() * 80;
        for (var i = 0; i < 3; i++) {
          game.world.add(Coin(
            spawnPosition: Vector2(x + i * 20, y),
            value: 3,
          ));
        }
        break;
      case 1: // 아치
        for (var i = 0; i < 5; i++) {
          final t = i / 4.0;
          final arcX = x + t * 80;
          final arcY = GameConstants.groundY - 50 - sin(t * 3.1416) * 60;
          game.world.add(Coin(
            spawnPosition: Vector2(arcX, arcY),
            value: 2,
          ));
        }
        break;
      case 2: // 세로 줄
        for (var i = 0; i < 4; i++) {
          game.world.add(Coin(
            spawnPosition: Vector2(x, GameConstants.groundY - 30 - i * 25),
            value: 2,
          ));
        }
        break;
    }
  }

  double get progress => isActive ? (_timer / stageDuration).clamp(0.0, 1.0) : 0;
  double get timeLeft => isActive ? (stageDuration - _timer).clamp(0.0, stageDuration) : 0;
}
