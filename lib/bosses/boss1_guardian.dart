import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'boss_base.dart';
import '../components/enemy_bullet.dart';
import '../game/boss_rush_game.dart';
import '../utils/constants.dart';

/// Boss 1: Stone Guardian - Tutorial boss
/// Teaches basic mechanics: dodge, jump, dash
/// Phase 1: Simple horizontal shots
/// Phase 2: Adds ground slam with shockwave
/// Phase 3: Faster attacks + aimed shots
class Boss1Guardian extends BossBase {
  double _attackTimer = 0;
  double _moveTimer = 0;
  double _slamTimer = 0;
  bool _isSlamming = false;
  double _slamProgress = 0;
  final double _originalY;
  final Random _rng = Random();

  Boss1Guardian(BossRushGame game)
      : _originalY = GameConstants.groundY - 120,
        super(
          bossName: 'Stone Guardian',
          maxHp: 80,
          totalPhases: 3,
          size: Vector2(80, 120),
          position: Vector2(GameConstants.worldWidth - 160, GameConstants.groundY - 120),
        );

  @override
  void updateBehavior(double dt) {
    _attackTimer += dt;
    _moveTimer += dt;

    switch (currentPhase) {
      case 1:
        _phase1Behavior(dt);
        break;
      case 2:
        _phase2Behavior(dt);
        break;
      case 3:
        _phase3Behavior(dt);
        break;
    }

    _handleSlam(dt);
  }

  void _phase1Behavior(double dt) {
    // Simple horizontal shots every 1.5 seconds
    if (_attackTimer >= 1.5) {
      _attackTimer = 0;
      _fireHorizontalShots(1);
    }

    // Gentle bobbing
    position.y = _originalY + sin(_moveTimer * 2) * 10;
  }

  void _phase2Behavior(double dt) {
    // Faster horizontal shots
    if (_attackTimer >= 1.2) {
      _attackTimer = 0;
      _fireHorizontalShots(2);
    }

    // Ground slam every 5 seconds
    _slamTimer += dt;
    if (_slamTimer >= 5.0 && !_isSlamming) {
      _startSlam();
      _slamTimer = 0;
    }

    if (!_isSlamming) {
      position.y = _originalY + sin(_moveTimer * 2) * 10;
    }
  }

  void _phase3Behavior(double dt) {
    // Rapid fire + aimed shots
    if (_attackTimer >= 0.8) {
      _attackTimer = 0;
      if (_rng.nextBool()) {
        _fireHorizontalShots(3);
      } else {
        _fireAimedShot();
      }
    }

    // More frequent slams
    _slamTimer += dt;
    if (_slamTimer >= 3.5 && !_isSlamming) {
      _startSlam();
      _slamTimer = 0;
    }

    if (!_isSlamming) {
      position.y = _originalY + sin(_moveTimer * 3) * 15;
    }
  }

  void _fireHorizontalShots(int count) {
    for (int i = 0; i < count; i++) {
      final yOffset = (i - (count - 1) / 2) * 25;
      game.world.add(EnemyBullet(
        startPosition: Vector2(position.x, position.y + size.y / 2 + yOffset),
        velocity: Vector2(-200, 0),
        pattern: EnemyBulletPattern.straight,
      ));
    }
  }

  void _fireAimedShot() {
    final playerPos = game.player.position + game.player.size / 2;
    final myCenter = position + size / 2;
    final direction = (playerPos - myCenter).normalized();

    game.world.add(EnemyBullet(
      startPosition: Vector2(position.x, position.y + size.y / 2),
      velocity: direction * 180,
      pattern: EnemyBulletPattern.aimed,
      radius: 7,
    ));
  }

  void _startSlam() {
    _isSlamming = true;
    _slamProgress = 0;
  }

  void _handleSlam(double dt) {
    if (!_isSlamming) return;

    _slamProgress += dt;

    if (_slamProgress < 0.3) {
      // Rise up
      position.y = _originalY - (_slamProgress / 0.3) * 80;
    } else if (_slamProgress < 0.5) {
      // Slam down
      final t = (_slamProgress - 0.3) / 0.2;
      position.y = _originalY - 80 + t * (80 + (_originalY - (GameConstants.groundY - size.y)));
      if (position.y >= GameConstants.groundY - size.y) {
        position.y = GameConstants.groundY - size.y;
        _createShockwave();
      }
    } else if (_slamProgress < 1.2) {
      position.y = GameConstants.groundY - size.y;
    } else {
      // Return to original position
      final t = ((_slamProgress - 1.2) / 0.5).clamp(0.0, 1.0);
      position.y = GameConstants.groundY - size.y + t * (_originalY - (GameConstants.groundY - size.y));
      if (t >= 1.0) {
        _isSlamming = false;
        position.y = _originalY;
      }
    }
  }

  void _createShockwave() {
    // Ground shockwave - multiple bullets traveling along the ground
    for (int i = 0; i < 4; i++) {
      game.world.add(EnemyBullet(
        startPosition: Vector2(
          position.x + size.x / 2 - (i + 1) * 40,
          GameConstants.groundY - 15,
        ),
        velocity: Vector2(-150 - i * 30, 0),
        pattern: EnemyBulletPattern.straight,
        radius: 8,
      ));
    }
  }

  @override
  void onPhaseChange(int newPhase) {
    _attackTimer = 0;
    _slamTimer = 0;
  }

  @override
  void onDefeat() {
    // Death animation could go here
  }

  @override
  void render(Canvas canvas) {
    final paint = basePaint;

    // Main body - stone-like rectangle
    final bodyRect = Rect.fromLTWH(10, 20, 60, 80);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(8)),
      paint,
    );

    // Head
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(15, 0, 50, 35),
        const Radius.circular(6),
      ),
      paint,
    );

    // Eyes - glow based on phase
    final eyeColor = currentPhase == 3
        ? Colors.red
        : currentPhase == 2
            ? Colors.orange
            : Colors.yellow;
    final eyePaint = Paint()..color = eyeColor;
    canvas.drawCircle(const Offset(28, 14), 5, eyePaint);
    canvas.drawCircle(const Offset(52, 14), 5, eyePaint);

    // Fists
    canvas.drawRect(Rect.fromLTWH(0, 50, 15, 25), paint);
    canvas.drawRect(Rect.fromLTWH(65, 50, 15, 25), paint);

    // Phase indicator cracks
    if (currentPhase >= 2) {
      final crackPaint = Paint()
        ..color = Colors.black54
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(const Offset(30, 30), const Offset(25, 60), crackPaint);
    }
    if (currentPhase >= 3) {
      final crackPaint = Paint()
        ..color = Colors.black54
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(const Offset(50, 25), const Offset(55, 55), crackPaint);
      canvas.drawLine(const Offset(35, 70), const Offset(45, 90), crackPaint);
    }

    // Slam warning
    if (_isSlamming && _slamProgress < 0.3) {
      final warningPaint = Paint()
        ..color = Colors.red.withValues(alpha: 0.5 * (1 - _slamProgress / 0.3));
      canvas.drawRect(Rect.fromLTWH(-10, -10, size.x + 20, size.y + 20), warningPaint);
    }
  }
}
