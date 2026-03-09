import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../game/runner_game.dart';
import '../data/balance_config.dart';
import '../renderers/player_renderer.dart';
import '../utils/constants.dart';
import 'enemy.dart';
import 'obstacle.dart';
import 'coin.dart';
import 'companion_pickup.dart';

enum PlayerState { idle, run, jump, attack }

class RunnerPlayer extends PositionComponent
    with HasGameReference<RunnerGame>, CollisionCallbacks {
  double velocityY = 0;
  bool _isOnGround = true;
  bool _canDoubleJump = false;
  bool _hasDoubleJumped = false;
  bool _isAttacking = false;
  double _attackTimer = 0;
  double _animTimer = 0;

  // Slowdown from obstacle
  double _slowdownTimer = 0;
  double _slowdownFactor = 1.0;

  // Speed
  double get currentSpeed {
    final baseSpeed = GameConstants.basePlayerSpeed;
    final distanceMultiplier = BalanceConfig.speedMultiplier(game.distance);
    final upgradeMultiplier = game.upgradeManager.speedMultiplier;
    final companionMultiplier = game.companionManager.speedMultiplier;
    // 망토 장비 효과: 이동속도 +20%
    final cloakBonus = game.ascensionManager.hasCloak ? 1.2 : 1.0;
    return baseSpeed * distanceMultiplier * upgradeMultiplier * companionMultiplier * cloakBonus * _slowdownFactor;
  }

  RunnerPlayer()
      : super(
          position: Vector2(GameConstants.playerStartX, GameConstants.groundY - GameConstants.playerHeight),
          size: Vector2(GameConstants.playerWidth, GameConstants.playerHeight),
        );

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  PlayerState get _state {
    if (_isAttacking) return PlayerState.attack;
    if (!_isOnGround) return PlayerState.jump;
    return PlayerState.run;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _animTimer += dt;

    // Horizontal movement (auto-run)
    position.x += currentSpeed * dt;

    // Gravity
    velocityY += GameConstants.gravity * dt;
    position.y += velocityY * dt;

    // Ground collision
    final groundLevel = GameConstants.groundY - size.y;
    final wasAirborne = !_isOnGround;
    if (position.y >= groundLevel) {
      position.y = groundLevel;
      velocityY = 0;
      if (wasAirborne) {
        game.gameFeel.onLanding();
        game.particleEffect.spawnDustTrail(position.x, position.y + size.y);
        game.particleEffect.spawnDustTrail(position.x + 5, position.y + size.y);
      }
      _isOnGround = true;
      _hasDoubleJumped = false;
    } else {
      _isOnGround = false;
    }

    // Attack animation timer
    if (_isAttacking) {
      _attackTimer -= dt;
      if (_attackTimer <= 0) {
        _isAttacking = false;
      }
    }

    // Slowdown recovery
    if (_slowdownTimer > 0) {
      _slowdownTimer -= dt;
      if (_slowdownTimer <= 0) {
        _slowdownFactor = 1.0;
      }
    }
  }

  void jump() {
    final jumpForce = GameConstants.baseJumpForce * game.upgradeManager.jumpMultiplier;
    if (_isOnGround) {
      velocityY = jumpForce;
      _isOnGround = false;
    } else if (_canDoubleJump && !_hasDoubleJumped) {
      velocityY = jumpForce * 0.85;
      _hasDoubleJumped = true;
    }
  }

  void triggerAttack() {
    _isAttacking = true;
    _attackTimer = 0.3;
  }

  void applySlowdown() {
    _slowdownFactor = BalanceConfig.obstacleSlowdownFactor;
    _slowdownTimer = BalanceConfig.obstacleSlowdownDuration;
  }

  void enableDoubleJump() {
    _canDoubleJump = true;
  }

  bool get isJumping => !_isOnGround;

  @override
  void render(Canvas canvas) {
    PlayerRenderer.render(
      canvas,
      Size(size.x, size.y),
      isRunning: _state == PlayerState.run,
      animTimer: _animTimer,
      isJumping: !_isOnGround,
      isAttacking: _isAttacking,
    );
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Enemy) {
      other.onHit(this);
    } else if (other is Obstacle) {
      if (game.companionManager.obstacleIgnoreChance > 0) {
        final hash = (position.x * 1000).toInt() % 100;
        if (hash < game.companionManager.obstacleIgnoreChance * 100) return;
      }
      applySlowdown();
      game.gameFeel.onObstacleHit();
      game.soundManager.playObstacleHit();
    } else if (other is Coin) {
      other.collect();
    } else if (other is CompanionPickup) {
      other.collect();
    }
  }
}
