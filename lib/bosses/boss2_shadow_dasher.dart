import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'boss_base.dart';
import '../components/enemy_bullet.dart';
import '../game/boss_rush_game.dart';
import '../utils/constants.dart';

class Boss2ShadowDasher extends BossBase {
  double _attackTimer = 0;
  double _dashTimer = 0;
  bool _isDashing = false;
  double _dashTargetX = 0;

  final double _originalY;
  final Random _rng = Random();
  double _teleportCooldown = 0;

  Boss2ShadowDasher(BossRushGame game)
      :
        _originalY = GameConstants.groundY - 80,
        super(
          bossName: 'Shadow Dasher',
          maxHp: 60,
          totalPhases: 3,
          size: Vector2(50, 80),
          position: Vector2(GameConstants.worldWidth - 140, GameConstants.groundY - 80),
        );

  @override
  void updateBehavior(double dt) {
    _attackTimer += dt;
    if (_teleportCooldown > 0) _teleportCooldown -= dt;

    if (_isDashing) {
      _handleDash(dt);
      return;
    }

    switch (currentPhase) {
      case 1:
        _phase1(dt);
        break;
      case 2:
        _phase2(dt);
        break;
      case 3:
        _phase3(dt);
        break;
    }
  }

  void _phase1(double dt) {
    if (_attackTimer >= 2.0) {
      _attackTimer = 0;
      _startDash();
    }
  }

  void _phase2(double dt) {
    if (_attackTimer >= 1.5) {
      _attackTimer = 0;
      if (_rng.nextBool()) {
        _startDash();
      } else {
        _teleport();
        _throwKnives(3);
      }
    }
  }

  void _phase3(double dt) {
    if (_attackTimer >= 1.0) {
      _attackTimer = 0;
      final roll = _rng.nextInt(3);
      if (roll == 0) {
        _startDash();
      } else if (roll == 1) {
        _teleport();
        _throwKnives(5);
      } else {
        _startDash();
        // Queue a second dash
        Future.delayed(const Duration(milliseconds: 400), () {
          if (isMounted && !isDefeated) _startDash();
        });
      }
    }
  }

  void _startDash() {
    _isDashing = true;
    _dashTimer = 0;
    _dashTargetX = game.player.position.x;
  }

  void _handleDash(double dt) {
    _dashTimer += dt;
    final dir = (_dashTargetX - position.x).sign;
    position.x += dir * 600 * dt;

    if (_dashTimer > 0.5 || (position.x - _dashTargetX).abs() < 10) {
      _isDashing = false;
      // Fire blade wave at end of dash
      game.world.add(EnemyBullet(
        startPosition: position + size / 2,
        velocity: Vector2(dir * -200, 0),
        pattern: EnemyBulletPattern.straight,
        radius: 5,
      ));
    }
  }

  void _teleport() {
    if (_teleportCooldown > 0) return;
    _teleportCooldown = 1.0;

    // Teleport to random position
    final newX = _rng.nextDouble() * (GameConstants.worldWidth - 100) + 50;
    position.x = newX;
    position.y = _originalY;
  }

  void _throwKnives(int count) {
    final center = position + size / 2;
    for (int i = 0; i < count; i++) {
      final angle = (i / count) * 2 * pi;
      game.world.add(EnemyBullet(
        startPosition: center.clone(),
        velocity: Vector2(cos(angle) * 150, sin(angle) * 150),
        pattern: EnemyBulletPattern.straight,
        radius: 4,
      ));
    }
  }

  @override
  void onPhaseChange(int newPhase) {
    _attackTimer = 0;
    _teleport();
  }

  @override
  void onDefeat() {}

  @override
  void render(Canvas canvas) {
    final paint = basePaint;

    // Shadow body - sleek
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(10, 10, 30, 55),
        const Radius.circular(4),
      ),
      paint,
    );

    // Hood
    final hoodPaint = Paint()..color = isFlashing ? Colors.white : Colors.grey.shade900;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(8, 0, 34, 25),
        const Radius.circular(8),
      ),
      hoodPaint,
    );

    // Eyes - glowing
    final eyeColor = currentPhase >= 3 ? Colors.red : Colors.purpleAccent;
    canvas.drawCircle(const Offset(18, 12), 3, Paint()..color = eyeColor);
    canvas.drawCircle(const Offset(32, 12), 3, Paint()..color = eyeColor);

    // Blades
    final bladePaint = Paint()..color = Colors.white70;
    canvas.drawRect(Rect.fromLTWH(0, 25, 3, 20), bladePaint);
    canvas.drawRect(Rect.fromLTWH(47, 25, 3, 20), bladePaint);

    // Dash trail
    if (_isDashing) {
      final trail = Paint()..color = Colors.purple.withValues(alpha: 0.4);
      canvas.drawRect(Rect.fromLTWH(-20, 10, 20, 55), trail);
    }

    // Shadow effect
    if (currentPhase >= 2) {
      final shadowPaint = Paint()
        ..color = Colors.purple.withValues(alpha: 0.15);
      canvas.drawRect(Rect.fromLTWH(-5, -5, size.x + 10, size.y + 10), shadowPaint);
    }
  }
}
