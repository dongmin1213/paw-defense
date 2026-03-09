import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../game/runner_game.dart';
import '../data/enemy_data.dart';
import '../data/balance_config.dart';
import '../renderers/enemy_renderer.dart';
import '../ui/ui_effects.dart';
import '../utils/constants.dart';
import 'runner_player.dart';
import 'coin.dart';

class Enemy extends PositionComponent
    with HasGameReference<RunnerGame>, CollisionCallbacks {
  final EnemyData data;
  final bool isGolden;
  int currentHp;
  double _animTimer = 0;
  bool _isHit = false;
  double _hitFlashTimer = 0;
  double _hoverOffset = 0;
  final double _hoverBaseY;

  static const double goldenMultiplier = 10.0;

  Enemy({
    required this.data,
    required Vector2 spawnPosition,
    this.isGolden = false,
  })  : currentHp = data.hp,
        _hoverBaseY = spawnPosition.y,
        super(
          position: spawnPosition,
          size: Vector2(data.width, data.height),
        );

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    _animTimer += dt;

    // Air enemies hover
    if (data.type == EnemyType.air) {
      _hoverOffset = _sin(_animTimer * 3) * 8;
      position.y = _hoverBaseY + _hoverOffset;
    }

    // Hit flash
    if (_isHit) {
      _hitFlashTimer -= dt;
      if (_hitFlashTimer <= 0) {
        _isHit = false;
      }
    }

    // Cleanup if behind camera
    final cameraX = game.camera.viewfinder.position.x;
    if (position.x < cameraX - GameConstants.despawnBehindDistance) {
      removeFromParent();
    }
  }

  void onHit(RunnerPlayer player) {
    final damage = game.upgradeManager.attackMultiplier.ceil();
    currentHp -= damage;
    _isHit = true;
    _hitFlashTimer = 0.15;

    player.triggerAttack();

    if (currentHp <= 0) {
      _die();
    }
  }

  void _die() {
    double coinAmount = data.type == EnemyType.air
        ? data.coinDrop * BalanceConfig.airEnemyCoinMultiplier
        : data.coinDrop;

    if (isGolden) {
      coinAmount *= goldenMultiplier;
    }

    game.world.add(Coin(
      spawnPosition: position.clone(),
      value: coinAmount,
    ));

    final comboAmount = data.type == EnemyType.air
        ? BalanceConfig.jumpKillComboBonus
        : BalanceConfig.groundKillComboBonus;
    game.addCombo(comboAmount);

    // 게임필 — 스크린 쉐이크 + 히트스탑
    game.gameFeel.onEnemyKill(
      isGolden: isGolden,
      isAir: data.type == EnemyType.air,
    );

    // 사운드
    game.soundManager.playEnemyKill(isGolden: isGolden);

    // UI 이펙트 — 황금 적 처치 시 스크린 플래시 + 임팩트 텍스트
    if (isGolden) {
      UIEffectManager.instance.screenFlash(
        color: const Color(0xFFFFD54F),
        duration: 0.2,
        maxAlpha: 0.4,
      );
    }

    // 업적 추적
    game.achievementManager.onEnemyKill(
      isGolden: isGolden,
      isAir: data.type == EnemyType.air,
    );

    game.particleEffect.spawnEnemyDeath(
      position.x + size.x / 2,
      position.y + size.y / 2,
      isGolden: isGolden,
    );

    removeFromParent();
  }

  double _sin(double x) {
    x = x % 6.2832;
    if (x < 0) x += 6.2832;
    if (x > 3.1416) {
      x -= 3.1416;
      return -(x * (4 - x * 1.2732) * 0.405 + x * (4 - x * 1.2732) * 0.595);
    }
    return x * (4 - x * 1.2732) * 0.405 + x * (4 - x * 1.2732) * 0.595;
  }

  @override
  void render(Canvas canvas) {
    EnemyRenderer.render(
      canvas,
      Size(size.x, size.y),
      data,
      animTimer: _animTimer,
      isHit: _isHit,
      isGolden: isGolden,
    );
  }
}
