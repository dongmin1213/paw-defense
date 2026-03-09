import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/boss_rush_game.dart';
import '../classes/player_class.dart';
import '../data/game_data.dart';
import '../utils/constants.dart';
import 'class_attacks.dart';

class Player extends RectangleComponent with HasGameReference<BossRushGame>, CollisionCallbacks {
  final PlayerClassData classData;

  double velocityY = 0;
  bool isOnGround = false;
  bool isDashing = false;
  bool isInvincible = false;
  int facingDirection = 1;

  double _dashTimer = 0;
  double _dashCooldownTimer = 0;
  double _invincibleTimer = 0;
  double _fireTimer = 0;
  double _blinkTimer = 0;

  // Archer charge
  double _chargeTimer = 0;
  bool get isCharging => classData.type == PlayerClassType.archer && wantsShoot;
  bool get isFullyCharged => _chargeTimer >= 0.8;

  // Mage element
  bool isFire = true;

  // Input state
  double moveDirection = 0;
  bool wantsJump = false;
  bool wantsDash = false;
  bool wantsShoot = false;
  bool wantsSpecial = false;
  bool wantsSkill = false;

  Player({required this.classData})
      : super(
          size: Vector2(GameConstants.playerWidth, GameConstants.playerHeight),
          paint: Paint()..color = classData.color,
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
    _handleAttack(dt);
    _handleSkill();
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
      position.x += moveDirection * classData.effectiveSpeed * dt;
      facingDirection = moveDirection > 0 ? 1 : -1;
    }
  }

  void _handleDash(double dt) {
    if (wantsDash && !isDashing && _dashCooldownTimer <= 0) {
      isDashing = true;
      isInvincible = true;
      _dashTimer = GameConstants.playerDashDuration;
      _dashCooldownTimer = GameConstants.playerDashCooldown * GameData.instance.dashCdMultiplier;
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

    final groundLevel = GameConstants.groundY - size.y;
    if (position.y >= groundLevel) {
      position.y = groundLevel;
      velocityY = 0;
      isOnGround = true;
    }

    wantsJump = false;
  }

  void _handleAttack(double dt) {
    // Archer charge mechanic
    if (classData.type == PlayerClassType.archer) {
      if (wantsShoot) {
        _chargeTimer += dt;
      } else if (_chargeTimer > 0) {
        // Release charged shot
        _fireClassAttack(charged: isFullyCharged);
        _chargeTimer = 0;
        _fireTimer = classData.fireRate;
        return;
      }
      return; // Don't auto-fire for archer
    }

    if (wantsShoot && _fireTimer <= 0) {
      _fireClassAttack();
      _fireTimer = classData.fireRate;
    }
  }

  void _fireClassAttack({bool charged = false}) {
    final spawnX = position.x + (facingDirection > 0 ? size.x : 0);
    final spawnY = position.y + size.y / 2;
    final spawnPos = Vector2(spawnX, spawnY);

    switch (classData.type) {
      case PlayerClassType.knight:
        game.world.add(MeleeSlash(
          damage: classData.effectiveAttackDamage,
          direction: facingDirection,
          startPosition: Vector2(
            facingDirection > 0 ? position.x + size.x - 10 : position.x - 40,
            position.y,
          ),
        ));
        break;

      case PlayerClassType.assassin:
        game.world.add(DaggerStrike(
          damage: classData.effectiveAttackDamage,
          direction: facingDirection,
          startPosition: spawnPos - Vector2(0, 10),
        ));
        break;

      case PlayerClassType.archer:
        final dmg = charged ? classData.effectiveAttackDamage * 2.5 : classData.effectiveAttackDamage;
        game.world.add(Arrow(
          damage: dmg,
          direction: facingDirection,
          startPosition: spawnPos - Vector2(0, 2),
          isCharged: charged,
        ));
        break;

      case PlayerClassType.mage:
        game.world.add(MagicBolt(
          damage: classData.effectiveAttackDamage,
          direction: facingDirection,
          startPosition: spawnPos - Vector2(0, 8),
          isFire: isFire,
        ));
        break;

      case PlayerClassType.gunner:
        game.world.add(Cannonball(
          damage: classData.effectiveAttackDamage,
          direction: facingDirection,
          startPosition: spawnPos - Vector2(0, 7),
        ));
        break;
    }
  }

  void _handleSkill() {
    if (!wantsSkill) return;
    wantsSkill = false;

    switch (classData.type) {
      case PlayerClassType.knight:
        // Shield block - brief invincibility
        startInvincibility(duration: 0.8);
        break;

      case PlayerClassType.assassin:
        // Shadow teleport - blink forward
        position.x += facingDirection * 150;
        _clampPosition();
        startInvincibility(duration: 0.3);
        break;

      case PlayerClassType.archer:
        // Backstep + shoot
        position.x -= facingDirection * 80;
        _clampPosition();
        game.world.add(Arrow(
          damage: classData.effectiveAttackDamage * 1.5,
          direction: facingDirection,
          startPosition: Vector2(
            position.x + (facingDirection > 0 ? size.x : 0),
            position.y + size.y / 2,
          ),
          isCharged: true,
        ));
        break;

      case PlayerClassType.mage:
        // Toggle element
        isFire = !isFire;
        break;

      case PlayerClassType.gunner:
        // Knockback shot
        game.world.add(Cannonball(
          damage: classData.effectiveAttackDamage * 1.5,
          direction: facingDirection,
          startPosition: Vector2(
            position.x + (facingDirection > 0 ? size.x : 0),
            position.y + size.y / 2 - 7,
          ),
        ));
        // Self-knockback
        position.x -= facingDirection * 40;
        _clampPosition();
        break;
    }
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
    switch (classData.type) {
      case PlayerClassType.knight:
        // Ground smash - forward shockwave
        game.world.add(MeleeSlash(
          damage: classData.effectiveSpecialDamage,
          direction: facingDirection,
          startPosition: Vector2(
            facingDirection > 0 ? position.x + size.x : position.x - 80,
            position.y - 10,
          ),
        )..size = Vector2(80, 60));
        break;

      case PlayerClassType.assassin:
        // Multi-strike rush
        for (int i = 0; i < 8; i++) {
          final delay = i * 0.05;
          Future.delayed(Duration(milliseconds: (delay * 1000).toInt()), () {
            if (!isMounted) return;
            game.world.add(DaggerStrike(
              damage: classData.effectiveSpecialDamage / 8,
              direction: facingDirection,
              startPosition: Vector2(
                position.x + (facingDirection > 0 ? size.x : 0),
                position.y + size.y / 2 + (i - 4) * 5,
              ),
            ));
          });
        }
        break;

      case PlayerClassType.archer:
        // Arrow rain
        game.world.add(ArrowRain(damage: classData.effectiveSpecialDamage));
        break;

      case PlayerClassType.mage:
        // Meteor
        game.world.add(Meteor(
          damage: classData.effectiveSpecialDamage,
          center: Vector2(GameConstants.worldWidth / 2, GameConstants.worldHeight / 2),
        ));
        break;

      case PlayerClassType.gunner:
        // Barrage - big explosion
        game.world.add(Cannonball(
          damage: classData.effectiveSpecialDamage,
          direction: facingDirection,
          startPosition: Vector2(
            position.x + (facingDirection > 0 ? size.x : 0),
            position.y + size.y / 2 - 7,
          ),
        )..size = Vector2(24, 24));
        break;
    }
  }

  void startInvincibility({double? duration}) {
    isInvincible = true;
    _invincibleTimer = duration ?? GameConstants.playerInvincibleDuration;
  }

  void _handleInvincibility(double dt) {
    if (_invincibleTimer > 0) {
      _invincibleTimer -= dt;
      _blinkTimer += dt;

      paint.color = (_blinkTimer * 10).toInt() % 2 == 0
          ? classData.color.withValues(alpha: 0.3)
          : classData.color;

      if (_invincibleTimer <= 0 && !isDashing) {
        isInvincible = false;
        paint.color = classData.color;
        _blinkTimer = 0;
      }
    }
  }

  void _clampPosition() {
    position.x = position.x.clamp(0, GameConstants.worldWidth - size.x);
  }

  @override
  void render(Canvas canvas) {
    switch (classData.type) {
      case PlayerClassType.knight:
        _renderKnight(canvas);
        break;
      case PlayerClassType.assassin:
        _renderAssassin(canvas);
        break;
      case PlayerClassType.archer:
        _renderArcher(canvas);
        break;
      case PlayerClassType.mage:
        _renderMage(canvas);
        break;
      case PlayerClassType.gunner:
        _renderGunner(canvas);
        break;
    }

    if (isDashing) {
      final trailPaint = Paint()
        ..color = classData.accentColor.withValues(alpha: 0.4);
      canvas.drawRect(
        Rect.fromLTWH(-facingDirection * 15.0, 10, 15, 30),
        trailPaint,
      );
    }

    // Charge indicator for archer
    if (classData.type == PlayerClassType.archer && _chargeTimer > 0) {
      final chargePercent = (_chargeTimer / 0.8).clamp(0.0, 1.0);
      final chargePaint = Paint()
        ..color = isFullyCharged ? Colors.greenAccent : Colors.green.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        size.x * 0.6 * chargePercent,
        chargePaint,
      );
    }

    // Element indicator for mage
    if (classData.type == PlayerClassType.mage) {
      final elemPaint = Paint()
        ..color = isFire ? Colors.orange : Colors.cyan;
      canvas.drawCircle(Offset(size.x / 2, -6), 4, elemPaint);
    }
  }

  void _renderBichonHead(Canvas canvas, double cx, double cy) {
    // White fluffy head
    final white = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), 11, white);
    // Fluffy ears
    canvas.drawCircle(Offset(cx - 8, cy - 6), 5, white);
    canvas.drawCircle(Offset(cx + 8, cy - 6), 5, white);
    // Eyes
    final eye = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(cx - 3 + facingDirection * 2, cy - 1), 2, eye);
    canvas.drawCircle(Offset(cx + 3 + facingDirection * 2, cy - 1), 2, eye);
    // Nose
    canvas.drawCircle(Offset(cx + facingDirection * 1, cy + 3), 1.5, Paint()..color = Colors.black);
  }

  void _renderKnight(Canvas canvas) {
    final armor = Paint()..color = classData.color;
    // Armor body
    canvas.drawRect(Rect.fromLTWH(6, 14, 28, 28), armor);
    // Cape
    final cape = Paint()..color = classData.accentColor;
    canvas.drawRect(Rect.fromLTWH(
      facingDirection < 0 ? 30 : 2.0,
      16, 8, 26,
    ), cape);
    // Head
    _renderBichonHead(canvas, size.x / 2, 10);
    // Helmet top
    final helmet = Paint()..color = Colors.grey.shade600;
    canvas.drawRect(Rect.fromLTWH(12, -2, 16, 6), helmet);
    // Sword
    final sword = Paint()..color = Colors.white70;
    final swordX = facingDirection > 0 ? size.x - 2 : -8.0;
    canvas.drawRect(Rect.fromLTWH(swordX, 12, 4, 30), sword);
    // Guard
    canvas.drawRect(Rect.fromLTWH(swordX - 3, 16, 10, 3), Paint()..color = Colors.amber);
    // Legs
    canvas.drawRect(Rect.fromLTWH(10, 42, 8, 8), armor);
    canvas.drawRect(Rect.fromLTWH(22, 42, 8, 8), armor);
  }

  void _renderAssassin(Canvas canvas) {
    final body = Paint()..color = classData.color;
    // Dark cloak body
    canvas.drawRect(Rect.fromLTWH(8, 14, 24, 26), body);
    // Hood
    final hood = Paint()..color = const Color(0xFF333333);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(8, -2, 24, 18), const Radius.circular(6)),
      hood,
    );
    // Head (partially hidden by hood)
    _renderBichonHead(canvas, size.x / 2, 8);
    // Daggers
    final dagger = Paint()..color = Colors.white70;
    final dx1 = facingDirection > 0 ? size.x - 4 : -6.0;
    canvas.drawRect(Rect.fromLTWH(dx1, 20, 3, 16), dagger);
    final dx2 = facingDirection > 0 ? size.x + 0 : -10.0;
    canvas.drawRect(Rect.fromLTWH(dx2, 24, 3, 14), dagger);
    // Scarf tail
    final scarf = Paint()..color = classData.accentColor.withValues(alpha: 0.7);
    canvas.drawRect(Rect.fromLTWH(
      facingDirection < 0 ? 30 : 2.0,
      8, 6, 20,
    ), scarf);
    // Legs
    canvas.drawRect(Rect.fromLTWH(12, 40, 6, 10), body);
    canvas.drawRect(Rect.fromLTWH(22, 40, 6, 10), body);
  }

  void _renderArcher(Canvas canvas) {
    final body = Paint()..color = classData.color;
    // Tunic
    canvas.drawRect(Rect.fromLTWH(8, 14, 24, 26), body);
    // Head
    _renderBichonHead(canvas, size.x / 2, 10);
    // Hat
    final hat = Paint()..color = const Color(0xFF1B5E20);
    final hatPath = Path()
      ..moveTo(10, 6)
      ..lineTo(size.x / 2, -8)
      ..lineTo(30, 6)
      ..close();
    canvas.drawPath(hatPath, hat);
    // Feather
    canvas.drawRect(Rect.fromLTWH(22, -10, 3, 8), Paint()..color = Colors.tealAccent);
    // Bow
    final bow = Paint()
      ..color = Colors.brown
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final bowX = facingDirection > 0 ? size.x - 2 : 2.0;
    canvas.drawArc(
      Rect.fromLTWH(bowX - 4, 10, 8, 30),
      facingDirection > 0 ? -1.2 : 1.9,
      2.4,
      false,
      bow,
    );
    // Bowstring
    final string = Paint()
      ..color = Colors.white60
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(bowX, 10), Offset(bowX, 40), string);
    // Legs
    canvas.drawRect(Rect.fromLTWH(12, 40, 6, 10), Paint()..color = Colors.brown.shade700);
    canvas.drawRect(Rect.fromLTWH(22, 40, 6, 10), Paint()..color = Colors.brown.shade700);
  }

  void _renderMage(Canvas canvas) {
    final body = Paint()..color = classData.color;
    // Robe
    canvas.drawRect(Rect.fromLTWH(6, 14, 28, 30), body);
    // Robe bottom flare
    canvas.drawRect(Rect.fromLTWH(4, 38, 32, 12), body);
    // Head
    _renderBichonHead(canvas, size.x / 2, 10);
    // Wizard hat - not full, just top
    final hat = Paint()..color = classData.color;
    final hatPath = Path()
      ..moveTo(8, 8)
      ..lineTo(size.x / 2, -12)
      ..lineTo(32, 8)
      ..close();
    canvas.drawPath(hatPath, hat);
    // Hat brim
    canvas.drawRect(Rect.fromLTWH(4, 4, 32, 4), hat);
    // Staff
    final staff = Paint()..color = Colors.brown.shade400;
    final staffX = facingDirection > 0 ? size.x + 2 : -6.0;
    canvas.drawRect(Rect.fromLTWH(staffX, 4, 3, 46), staff);
    // Staff orb
    final orbColor = isFire ? Colors.orange : Colors.cyan;
    final orb = Paint()..color = orbColor;
    canvas.drawCircle(Offset(staffX + 1.5, 2), 5, orb);
    final glow = Paint()
      ..color = orbColor.withValues(alpha: 0.2);
    canvas.drawCircle(Offset(staffX + 1.5, 2), 7, glow);
  }

  void _renderGunner(Canvas canvas) {
    final body = Paint()..color = classData.color;
    // Pirate coat
    canvas.drawRect(Rect.fromLTWH(6, 14, 28, 28), body);
    // Head
    _renderBichonHead(canvas, size.x / 2, 10);
    // Bandana
    final bandana = Paint()..color = Colors.red.shade700;
    canvas.drawRect(Rect.fromLTWH(8, -1, 24, 6), bandana);
    // Bandana tail
    canvas.drawRect(Rect.fromLTWH(
      facingDirection < 0 ? 30 : 2.0,
      0, 6, 12,
    ), bandana);
    // Cannon
    final cannon = Paint()..color = Colors.grey.shade700;
    final cannonX = facingDirection > 0 ? size.x - 8 : -16.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cannonX, 18, 24, 12),
        const Radius.circular(3),
      ),
      cannon,
    );
    // Cannon mouth
    final mouth = Paint()..color = Colors.grey.shade900;
    final mouthX = facingDirection > 0 ? cannonX + 20 : cannonX;
    canvas.drawRect(Rect.fromLTWH(mouthX, 16, 4, 16), mouth);
    // Belt
    canvas.drawRect(Rect.fromLTWH(6, 36, 28, 4), Paint()..color = Colors.amber.shade800);
    // Legs
    canvas.drawRect(Rect.fromLTWH(10, 42, 8, 8), Paint()..color = Colors.brown.shade800);
    canvas.drawRect(Rect.fromLTWH(22, 42, 8, 8), Paint()..color = Colors.brown.shade800);
  }
}
