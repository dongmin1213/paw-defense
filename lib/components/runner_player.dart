import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

import '../game/runner_game.dart';
import '../data/balance_config.dart';
import '../utils/constants.dart';
import '../utils/sprite_loader.dart';
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

  // Slowdown from obstacle
  double _slowdownTimer = 0;
  double _slowdownFactor = 1.0;

  // Sprite animation tickers
  SpriteAnimationTicker? _idleTicker;
  SpriteAnimationTicker? _runTicker;
  SpriteAnimationTicker? _jumpTicker;
  SpriteAnimationTicker? _attackTicker;
  SpriteAnimationTicker? _currentTicker;
  PlayerState _prevState = PlayerState.run;

  // Speed
  double get currentSpeed {
    final baseSpeed = GameConstants.basePlayerSpeed;
    final distanceMultiplier = BalanceConfig.speedMultiplier(game.distance);
    final upgradeMultiplier = game.upgradeManager.speedMultiplier;
    final companionMultiplier = game.companionManager.speedMultiplier;
    return baseSpeed * distanceMultiplier * upgradeMultiplier * companionMultiplier * _slowdownFactor;
  }

  RunnerPlayer()
      : super(
          position: Vector2(GameConstants.playerStartX, GameConstants.groundY - GameConstants.playerHeight),
          size: Vector2(GameConstants.playerWidth, GameConstants.playerHeight),
        );

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());

    const fw = 36.0;
    const fh = 40.0;

    final idleAnim = await SpriteLoader.loadAnimation(
      'bichon.png', frameWidth: fw, frameHeight: fh,
      frameCount: 4, startFrame: 0, stepTime: 0.25,
    );
    final runAnim = await SpriteLoader.loadAnimation(
      'bichon.png', frameWidth: fw, frameHeight: fh,
      frameCount: 6, startFrame: 4, stepTime: 0.1,
    );
    final jumpAnim = await SpriteLoader.loadAnimation(
      'bichon.png', frameWidth: fw, frameHeight: fh,
      frameCount: 3, startFrame: 10, stepTime: 0.15, loop: false,
    );
    final attackAnim = await SpriteLoader.loadAnimation(
      'bichon.png', frameWidth: fw, frameHeight: fh,
      frameCount: 3, startFrame: 13, stepTime: 0.1, loop: false,
    );

    _idleTicker = idleAnim.createTicker();
    _runTicker = runAnim.createTicker();
    _jumpTicker = jumpAnim.createTicker();
    _attackTicker = attackAnim.createTicker();
    _currentTicker = _runTicker;
  }

  PlayerState get _state {
    if (_isAttacking) return PlayerState.attack;
    if (!_isOnGround) return PlayerState.jump;
    return PlayerState.run;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Horizontal movement (auto-run)
    position.x += currentSpeed * dt;

    // Gravity
    velocityY += GameConstants.gravity * dt;
    position.y += velocityY * dt;

    // Ground collision
    final groundLevel = GameConstants.groundY - size.y;
    if (position.y >= groundLevel) {
      position.y = groundLevel;
      velocityY = 0;
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

    // Update sprite animation
    _updateAnimation(dt);
  }

  void _updateAnimation(double dt) {
    final state = _state;
    if (state != _prevState) {
      _prevState = state;
      switch (state) {
        case PlayerState.attack:
          _currentTicker = _attackTicker;
          break;
        case PlayerState.jump:
          _currentTicker = _jumpTicker;
          break;
        case PlayerState.run:
          _currentTicker = _runTicker;
          break;
        case PlayerState.idle:
          _currentTicker = _idleTicker;
          break;
      }
      _currentTicker?.reset();
    }
    _currentTicker?.update(dt);
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
    final sprite = _currentTicker?.getSprite();
    if (sprite != null) {
      sprite.render(canvas, size: size);
    }
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
    } else if (other is Coin) {
      other.collect();
    } else if (other is CompanionPickup) {
      other.collect();
    }
  }
}
