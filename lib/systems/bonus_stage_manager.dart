import 'dart:math';

import 'package:flame/components.dart';

import 'dart:ui' show Color;
import '../game/runner_game.dart';
import '../components/coin.dart';
import '../ui/ui_effects.dart';
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
    game.gameFeel.shake(intensity: 6, duration: 0.3);
    game.gameFeel.slowMotion(scale: 0.6, duration: 0.5); // 드라마틱 진입
    game.gameFeel.zoomPunch(targetZoom: 1.04, duration: 0.3);
    game.soundManager.playBonusStageStart();
    UIEffectManager.instance.spawnImpactText(
      text: 'BONUS STAGE!',
      color: const Color(0xFFFFD54F),
      fontSize: 26,
      duration: 1.8,
    );
    UIEffectManager.instance.screenFlash(
      color: const Color(0xFFFFD54F),
      duration: 0.3,
      maxAlpha: 0.4,
    );
  }

  void _updateActiveStage(double dt) {
    _timer += dt;
    _spawnTimer += dt;

    if (_timer >= stageDuration) {
      isActive = false;
      // 종료 축하 연출
      game.gameFeel.shake(intensity: 8, duration: 0.3);
      UIEffectManager.instance.spawnImpactText(
        text: 'BONUS COMPLETE!',
        color: const Color(0xFF66BB6A),
        fontSize: 20,
        duration: 1.5,
      );
      UIEffectManager.instance.screenFlash(
        color: const Color(0xFFFFFFFF),
        duration: 0.2,
        maxAlpha: 0.3,
      );
      return;
    }

    // 스폰 가속 — 시간이 갈수록 코인이 빠르게 등장
    final accelInterval = coinSpawnInterval - (_timer / stageDuration) * 0.06;
    if (_spawnTimer >= accelInterval) {
      _spawnTimer = 0;
      _spawnBonusCoin();
    }
  }

  void _spawnBonusCoin() {
    final playerX = game.player.position.x;
    final x = playerX + 300 + _rng.nextDouble() * 400;

    // 다양한 코인 패턴
    final pattern = _rng.nextInt(6);
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
      case 3: // 다이아몬드
        final cy = GameConstants.groundY - 80;
        final offsets = [
          Vector2(0, -20), Vector2(-15, 0), Vector2(15, 0),
          Vector2(0, 20), Vector2(0, 0),
        ];
        for (final o in offsets) {
          game.world.add(Coin(
            spawnPosition: Vector2(x + o.x, cy + o.y),
            value: 3,
          ));
        }
        break;
      case 4: // 물결
        for (var i = 0; i < 6; i++) {
          final waveY = GameConstants.groundY - 50 - sin(i * 1.0) * 40;
          game.world.add(Coin(
            spawnPosition: Vector2(x + i * 18, waveY),
            value: 2,
          ));
        }
        break;
      case 5: // 코인 비 (상단에서 랜덤)
        for (var i = 0; i < 4; i++) {
          game.world.add(Coin(
            spawnPosition: Vector2(
              x + _rng.nextDouble() * 100,
              GameConstants.groundY - 100 - _rng.nextDouble() * 80,
            ),
            value: 3,
          ));
        }
        break;
    }
  }

  double get progress => isActive ? (_timer / stageDuration).clamp(0.0, 1.0) : 0;
  double get timeLeft => isActive ? (stageDuration - _timer).clamp(0.0, stageDuration) : 0;
}
