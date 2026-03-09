import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'boss_base.dart';
import '../components/enemy_bullet.dart';
import '../game/boss_rush_game.dart';
import '../utils/constants.dart';

class Boss4IronColossus extends BossBase {
  double _attackTimer = 0;
  double _slamProgress = -1;
  bool _isCharging = false;
  double _chargeSpeed = 0;
  final Random _rng = Random();

  Boss4IronColossus(BossRushGame game)
      : super(
          bossName: 'Iron Colossus',
          maxHp: 150,
          totalPhases: 3,
          size: Vector2(120, 160),
          position: Vector2(GameConstants.worldWidth - 200, GameConstants.groundY - 160),
        );

  @override
  void updateBehavior(double dt) {
    _attackTimer += dt;

    if (_slamProgress >= 0) {
      _handleSlam(dt);
      return;
    }

    if (_isCharging) {
      _handleCharge(dt);
      return;
    }

    switch (currentPhase) {
      case 1:
        if (_attackTimer >= 2.5) {
          _attackTimer = 0;
          _fistSlam();
        }
        break;
      case 2:
        if (_attackTimer >= 2.0) {
          _attackTimer = 0;
          if (_rng.nextBool()) {
            _fistSlam();
          } else if (_rng.nextBool()) {
            _fireMissiles(3);
          } else {
            _startCharge();
          }
        }
        break;
      case 3:
        if (_attackTimer >= 1.5) {
          _attackTimer = 0;
          final roll = _rng.nextInt(4);
          if (roll == 0) _fistSlam();
          else if (roll == 1) _fireMissiles(5);
          else if (roll == 2) _startCharge();
          else _fireLaser();
        }
        break;
    }
  }

  void _fistSlam() {
    _slamProgress = 0;
  }

  void _handleSlam(double dt) {
    _slamProgress += dt;
    if (_slamProgress < 0.4) {
      // Raise fist
      position.y -= 60 * dt;
    } else if (_slamProgress < 0.6) {
      // Slam down
      position.y += 200 * dt;
      if (position.y >= GameConstants.groundY - size.y) {
        position.y = GameConstants.groundY - size.y;
        // Shockwave
        for (int i = 0; i < 6; i++) {
          game.world.add(EnemyBullet(
            startPosition: Vector2(position.x - (i + 1) * 50, GameConstants.groundY - 15),
            velocity: Vector2(-100 - i * 20, 0),
            pattern: EnemyBulletPattern.straight,
            radius: 10,
          ));
        }
      }
    } else if (_slamProgress > 1.2) {
      _slamProgress = -1;
      position.y = GameConstants.groundY - size.y;
    }
  }

  void _startCharge() {
    _isCharging = true;
    _chargeSpeed = 0;
  }

  void _handleCharge(double dt) {
    _chargeSpeed += 400 * dt;
    position.x -= _chargeSpeed * dt;

    if (position.x <= 50) {
      _isCharging = false;
      // Bounce back
      position.x = GameConstants.worldWidth - 200;
      // Debris
      for (int i = 0; i < 4; i++) {
        game.world.add(EnemyBullet(
          startPosition: Vector2(60 + i * 30, GameConstants.groundY - 40),
          velocity: Vector2(_rng.nextDouble() * 100, -200),
          pattern: EnemyBulletPattern.falling,
          radius: 8,
        ));
      }
    }
  }

  void _fireMissiles(int count) {
    for (int i = 0; i < count; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (!isMounted || isDefeated) return;
        game.world.add(EnemyBullet(
          startPosition: Vector2(position.x, position.y + 20 + i * 15),
          velocity: Vector2(-180, -100 + _rng.nextDouble() * 50),
          pattern: EnemyBulletPattern.aimed,
          radius: 6,
        ));
      });
    }
  }

  void _fireLaser() {
    // Horizontal laser beam - stream of bullets
    for (int i = 0; i < 12; i++) {
      Future.delayed(Duration(milliseconds: i * 50), () {
        if (!isMounted || isDefeated) return;
        game.world.add(EnemyBullet(
          startPosition: Vector2(position.x, position.y + size.y / 2),
          velocity: Vector2(-350, 0),
          pattern: EnemyBulletPattern.straight,
          radius: 4,
        ));
      });
    }
  }

  @override
  void onPhaseChange(int newPhase) {
    _attackTimer = 0;
  }

  @override
  void onDefeat() {}

  @override
  void render(Canvas canvas) {

    final metalPaint = Paint()
      ..color = isFlashing ? Colors.white : Colors.grey.shade600;

    // Main body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(20, 30, 80, 100),
        const Radius.circular(6),
      ),
      metalPaint,
    );

    // Head
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(30, 0, 60, 40),
        const Radius.circular(8),
      ),
      metalPaint,
    );

    // Eyes - red glow
    final eyeColor = currentPhase >= 3 ? Colors.red : Colors.orange;
    canvas.drawRect(Rect.fromLTWH(40, 14, 12, 6), Paint()..color = eyeColor);
    canvas.drawRect(Rect.fromLTWH(68, 14, 12, 6), Paint()..color = eyeColor);

    // Shoulder plates
    canvas.drawRect(Rect.fromLTWH(0, 30, 25, 30), metalPaint);
    canvas.drawRect(Rect.fromLTWH(95, 30, 25, 30), metalPaint);

    // Fists
    final fistPaint = Paint()..color = isFlashing ? Colors.white : Colors.grey.shade700;
    canvas.drawRect(Rect.fromLTWH(0, 60, 20, 25), fistPaint);
    canvas.drawRect(Rect.fromLTWH(100, 60, 20, 25), fistPaint);

    // Legs
    canvas.drawRect(Rect.fromLTWH(30, 130, 20, 30), metalPaint);
    canvas.drawRect(Rect.fromLTWH(70, 130, 20, 30), metalPaint);

    // Damage cracks
    if (currentPhase >= 2) {
      final crack = Paint()
        ..color = Colors.orange.withValues(alpha: 0.6)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(const Offset(40, 40), const Offset(50, 80), crack);
    }
    if (currentPhase >= 3) {
      final crack = Paint()
        ..color = Colors.red.withValues(alpha: 0.6)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(const Offset(70, 35), const Offset(80, 70), crack);
      // Core exposed
      canvas.drawCircle(const Offset(60, 70), 10, Paint()..color = Colors.redAccent);
      canvas.drawCircle(
        const Offset(60, 70),
        12,
        Paint()
          ..color = Colors.red.withValues(alpha: 0.2),
      );
    }

    // Charge warning
    if (_isCharging) {
      final warn = Paint()..color = Colors.red.withValues(alpha: 0.3);
      canvas.drawRect(Rect.fromLTWH(-10, -10, size.x + 20, size.y + 20), warn);
    }
  }
}
