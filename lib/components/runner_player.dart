import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../game/runner_game.dart';
import '../data/balance_config.dart';
import '../renderers/player_renderer.dart';
import '../utils/constants.dart';
import 'enemy.dart';
import 'obstacle.dart';
import 'coin.dart';

class RunnerPlayer extends PositionComponent
    with HasGameReference<RunnerGame>, CollisionCallbacks {
  double velocityY = 0;
  double _animTimer = 0;
  bool _isOnGround = true;
  bool _canDoubleJump = false; // upgradeable
  bool _hasDoubleJumped = false;
  bool _isAttacking = false;
  double _attackTimer = 0;

  // Slowdown from obstacle
  double _slowdownTimer = 0;
  double _slowdownFactor = 1.0;

  // Speed
  double get currentSpeed {
    final baseSpeed = GameConstants.basePlayerSpeed;
    final distanceMultiplier = BalanceConfig.speedMultiplier(game.distance);
    return baseSpeed * distanceMultiplier * _slowdownFactor;
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
  }

  void jump() {
    if (_isOnGround) {
      velocityY = GameConstants.baseJumpForce;
      _isOnGround = false;
    } else if (_canDoubleJump && !_hasDoubleJumped) {
      velocityY = GameConstants.baseJumpForce * 0.85;
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
      size.toSize(),
      isRunning: true,
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
      applySlowdown();
    } else if (other is Coin) {
      other.collect();
    }
  }
}
