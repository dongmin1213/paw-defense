import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../game/runner_game.dart';
import '../data/enemy_data.dart';
import '../data/balance_config.dart';
import '../renderers/enemy_renderer.dart';
import '../utils/constants.dart';
import 'runner_player.dart';
import 'coin.dart';

class Enemy extends PositionComponent
    with HasGameReference<RunnerGame>, CollisionCallbacks {
  final EnemyData data;
  int currentHp;
  double _animTimer = 0;
  bool _isHit = false;
  double _hitFlashTimer = 0;
  double _hoverOffset = 0;
  final double _hoverBaseY;

  Enemy({
    required this.data,
    required Vector2 spawnPosition,
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
    // Determine coin amount
    final coinAmount = data.type == EnemyType.air
        ? data.coinDrop * BalanceConfig.airEnemyCoinMultiplier
        : data.coinDrop;

    // Spawn coin at enemy position
    game.world.add(Coin(
      spawnPosition: position.clone(),
      value: coinAmount,
    ));

    // Add combo
    final comboAmount = data.type == EnemyType.air
        ? BalanceConfig.jumpKillComboBonus
        : BalanceConfig.groundKillComboBonus;
    game.addCombo(comboAmount);

    removeFromParent();
  }

  double _sin(double x) {
    // Simple sin approximation to avoid importing dart:math in hot path
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
      size.toSize(),
      data,
      animTimer: _animTimer,
      isHit: _isHit,
    );
  }
}
