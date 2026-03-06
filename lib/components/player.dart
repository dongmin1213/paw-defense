import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/boss_rush_game.dart';
import '../utils/constants.dart';
import 'bullet.dart';

class Player extends RectangleComponent with HasGameReference<BossRushGame>, CollisionCallbacks {
  double velocityY = 0;
  bool isOnGround = false;
  bool isDashing = false;
  bool isInvincible = false;
  int facingDirection = 1; // 1 = right, -1 = left

  double _dashTimer = 0;
  double _dashCooldownTimer = 0;
  double _invincibleTimer = 0;
  double _fireTimer = 0;
  double _blinkTimer = 0;

  // Input state (controlled by UI overlay)
  double moveDirection = 0; // -1 left, 0 none, 1 right
  bool wantsJump = false;
  bool wantsDash = false;
  bool wantsShoot = false;
  bool wantsSpecial = false;

  Player()
      : super(
          size: Vector2(GameConstants.playerWidth, GameConstants.playerHeight),
          paint: Paint()..color = GameConstants.playerColor,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    _updateTimers(dt);
    _handleMovement(dt);
    _handleDash(dt);
    _handleJumpAndGravity(dt);
    _handleShooting(dt);
    _handleSpecial();
    _handleInvincibility(dt);
    _clampPosition();
  }

  void _updateTimers(double dt) {
    if (_dashCooldownTimer > 0) _dashCooldownTimer -= dt;
    if (_fireTimer > 0) _fireTimer -= dt;
  }

  void _handleMovement(double dt) {
    if (isDashing) return;

    if (moveDirection != 0) {
      position.x += moveDirection * GameConstants.playerSpeed * dt;
      facingDirection = moveDirection > 0 ? 1 : -1;
    }
  }

  void _handleDash(double dt) {
    if (wantsDash && !isDashing && _dashCooldownTimer <= 0) {
      isDashing = true;
      isInvincible = true;
      _dashTimer = GameConstants.playerDashDuration;
      _dashCooldownTimer = GameConstants.playerDashCooldown;
      wantsDash = false;
    }

    if (isDashing) {
      position.x += facingDirection * GameConstants.playerDashSpeed * dt;
      _dashTimer -= dt;

      if (_dashTimer <= 0) {
        isDashing = false;
        if (_invincibleTimer <= 0) {
          isInvincible = false;
        }
      }
    }
  }

  void _handleJumpAndGravity(double dt) {
    if (wantsJump && isOnGround) {
      velocityY = GameConstants.playerJumpForce;
      isOnGround = false;
      wantsJump = false;
    }

    if (!isOnGround) {
      velocityY += GameConstants.gravity * dt;
      position.y += velocityY * dt;
    }

    // Ground check
    final groundLevel = GameConstants.groundY - size.y;
    if (position.y >= groundLevel) {
      position.y = groundLevel;
      velocityY = 0;
      isOnGround = true;
    }

    wantsJump = false;
  }

  void _handleShooting(double dt) {
    if (wantsShoot && _fireTimer <= 0) {
      _fireBullet();
      _fireTimer = GameConstants.fireRate;
    }
  }

  void _fireBullet() {
    final bullet = Bullet(
      direction: facingDirection,
      startPosition: Vector2(
        position.x + (facingDirection > 0 ? size.x : 0),
        position.y + size.y / 2 - 3,
      ),
    );
    game.world.add(bullet);
  }

  void _handleSpecial() {
    if (wantsSpecial) {
      if (game.useSpecialAttack()) {
        _fireSpecialAttack();
      }
      wantsSpecial = false;
    }
  }

  void _fireSpecialAttack() {
    // Fire a large, powerful projectile
    final bullet = Bullet(
      direction: facingDirection,
      startPosition: Vector2(
        position.x + (facingDirection > 0 ? size.x : 0),
        position.y + size.y / 2 - 10,
      ),
      isSpecial: true,
    );
    game.world.add(bullet);
  }

  void startInvincibility() {
    isInvincible = true;
    _invincibleTimer = GameConstants.playerInvincibleDuration;
  }

  void _handleInvincibility(double dt) {
    if (_invincibleTimer > 0) {
      _invincibleTimer -= dt;
      _blinkTimer += dt;

      // Blink effect
      paint.color = (_blinkTimer * 10).toInt() % 2 == 0
          ? GameConstants.playerColor.withValues(alpha: 0.3)
          : GameConstants.playerColor;

      if (_invincibleTimer <= 0 && !isDashing) {
        isInvincible = false;
        paint.color = GameConstants.playerColor;
        _blinkTimer = 0;
      }
    }
  }

  void _clampPosition() {
    position.x = position.x.clamp(0, GameConstants.worldWidth - size.x);
  }

  // Visual rendering - draw a simple character shape
  @override
  void render(Canvas canvas) {
    // Body
    canvas.drawRect(
      Rect.fromLTWH(8, 10, 24, 30),
      paint,
    );

    // Head
    canvas.drawCircle(
      Offset(size.x / 2, 10),
      10,
      paint,
    );

    // Eye (direction indicator)
    final eyeX = size.x / 2 + (facingDirection * 4);
    canvas.drawCircle(
      Offset(eyeX, 8),
      2,
      Paint()..color = Colors.white,
    );

    // Dash trail effect
    if (isDashing) {
      final trailPaint = Paint()..color = GameConstants.dashTrailColor;
      canvas.drawRect(
        Rect.fromLTWH(-facingDirection * 15.0, 10, 15, 30),
        trailPaint,
      );
    }
  }
}
