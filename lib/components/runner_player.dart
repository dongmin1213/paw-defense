import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

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
  double _animTimer = 0;
  bool _isOnGround = true;
  bool _canDoubleJump = false;
  bool _hasDoubleJumped = false;
  bool _isAttacking = false;
  double _attackTimer = 0;

  // Slowdown from obstacle
  double _slowdownTimer = 0;
  double _slowdownFactor = 1.0;

  // Sprite animations
  SpriteAnimation? _idleAnim;
  SpriteAnimation? _runAnim;
  SpriteAnimation? _jumpAnim;
  SpriteAnimation? _attackAnim;
  SpriteAnimation? _currentAnim;
  double _spriteTimer = 0;

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

    // Load sprite animations from bichon.png sprite sheet
    // Layout: idle(0-3), run(4-9), jump(10-12), attack(13-15) = 16 frames, each 36x40
    const fw = 36.0;
    const fh = 40.0;

    _idleAnim = await SpriteLoader.loadAnimation(
      'bichon.png', frameWidth: fw, frameHeight: fh,
      frameCount: 4, startFrame: 0, stepTime: 0.25,
    );
    _runAnim = await SpriteLoader.loadAnimation(
      'bichon.png', frameWidth: fw, frameHeight: fh,
      frameCount: 6, startFrame: 4, stepTime: 0.1,
    );
    _jumpAnim = await SpriteLoader.loadAnimation(
      'bichon.png', frameWidth: fw, frameHeight: fh,
      frameCount: 3, startFrame: 10, stepTime: 0.15, loop: false,
    );
    _attackAnim = await SpriteLoader.loadAnimation(
      'bichon.png', frameWidth: fw, frameHeight: fh,
      frameCount: 3, startFrame: 13, stepTime: 0.1, loop: false,
    );

    _currentAnim = _runAnim;
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
    _spriteTimer += dt;

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
    SpriteAnimation? targetAnim;
    switch (_state) {
      case PlayerState.attack:
        targetAnim = _attackAnim;
        break;
      case PlayerState.jump:
        targetAnim = _jumpAnim;
        break;
      case PlayerState.run:
        targetAnim = _runAnim;
        break;
      case PlayerState.idle:
        targetAnim = _idleAnim;
        break;
    }

    if (targetAnim != _currentAnim) {
      _currentAnim = targetAnim;
      _currentAnim?.reset();
    }

    _currentAnim?.update(dt);
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
    final sprite = _currentAnim?.getSprite();
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
