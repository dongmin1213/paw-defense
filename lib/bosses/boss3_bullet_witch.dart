import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'boss_base.dart';
import '../components/enemy_bullet.dart';
import '../game/boss_rush_game.dart';
import '../utils/constants.dart';

class Boss3BulletWitch extends BossBase {
  double _attackTimer = 0;
  double _moveTimer = 0;
  double _floatY;
  final Random _rng = Random();
  int _patternIndex = 0;

  Boss3BulletWitch(BossRushGame game)
      : _floatY = 250,
        super(
          bossName: 'Bullet Witch',
          maxHp: 70,
          totalPhases: 3,
          size: Vector2(50, 70),
          position: Vector2(GameConstants.worldWidth - 120, 250),
        );

  @override
  void updateBehavior(double dt) {
    _attackTimer += dt;
    _moveTimer += dt;

    // Float movement
    position.y = _floatY + sin(_moveTimer * 2) * 30;
    position.x = GameConstants.worldWidth - 120 + sin(_moveTimer * 1.5) * 40;

    switch (currentPhase) {
      case 1:
        if (_attackTimer >= 1.8) {
          _attackTimer = 0;
          _circularBurst(8);
        }
        break;
      case 2:
        if (_attackTimer >= 1.2) {
          _attackTimer = 0;
          _patternIndex++;
          if (_patternIndex % 2 == 0) {
            _spiralAttack(12);
          } else {
            _circularBurst(10);
            _fireAimed();
          }
        }
        break;
      case 3:
        if (_attackTimer >= 0.8) {
          _attackTimer = 0;
          _patternIndex++;
          switch (_patternIndex % 3) {
            case 0:
              _spiralAttack(16);
              break;
            case 1:
              _circularBurst(14);
              _fireAimed();
              break;
            case 2:
              _laserWarning();
              break;
          }
        }
        break;
    }
  }

  void _circularBurst(int count) {
    final center = position + size / 2;
    for (int i = 0; i < count; i++) {
      final angle = (i / count) * 2 * pi;
      game.world.add(EnemyBullet(
        startPosition: center.clone(),
        velocity: Vector2(cos(angle) * 120, sin(angle) * 120),
        pattern: EnemyBulletPattern.straight,
        radius: 4,
      ));
    }
  }

  void _spiralAttack(int count) {
    final center = position + size / 2;
    for (int i = 0; i < count; i++) {
      Future.delayed(Duration(milliseconds: i * 80), () {
        if (!isMounted || isDefeated) return;
        final angle = (i / count) * 4 * pi + _moveTimer;
        game.world.add(EnemyBullet(
          startPosition: center.clone(),
          velocity: Vector2(cos(angle) * 100, sin(angle) * 100),
          pattern: EnemyBulletPattern.straight,
          radius: 5,
        ));
      });
    }
  }

  void _fireAimed() {
    final playerPos = game.player.position + game.player.size / 2;
    final myCenter = position + size / 2;
    final dir = (playerPos - myCenter).normalized();
    game.world.add(EnemyBullet(
      startPosition: myCenter.clone(),
      velocity: dir * 200,
      pattern: EnemyBulletPattern.aimed,
      radius: 6,
    ));
  }

  void _laserWarning() {
    // Vertical rain of bullets
    for (int i = 0; i < 8; i++) {
      final x = _rng.nextDouble() * GameConstants.worldWidth;
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (!isMounted || isDefeated) return;
        game.world.add(EnemyBullet(
          startPosition: Vector2(x, -10),
          velocity: Vector2(0, 250),
          pattern: EnemyBulletPattern.falling,
          radius: 5,
        ));
      });
    }
  }

  @override
  void onPhaseChange(int newPhase) {
    _attackTimer = 0;
    _floatY = newPhase == 3 ? 200 : 250;
  }

  @override
  void onDefeat() {}

  @override
  void render(Canvas canvas) {
    final paint = basePaint;

    // Witch body / robe
    final robePaint = Paint()..color = isFlashing ? Colors.white : Colors.deepPurple;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(10, 20, 30, 40),
        const Radius.circular(4),
      ),
      robePaint,
    );

    // Robe bottom flare
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(6, 48, 38, 22),
        const Radius.circular(6),
      ),
      robePaint,
    );

    // Head
    canvas.drawCircle(Offset(size.x / 2, 15), 12, paint);

    // Witch hat
    final hatPaint = Paint()..color = isFlashing ? Colors.white : Colors.deepPurple.shade900;
    final hatPath = Path()
      ..moveTo(8, 10)
      ..lineTo(size.x / 2, -15)
      ..lineTo(42, 10)
      ..close();
    canvas.drawPath(hatPath, hatPaint);
    canvas.drawRect(Rect.fromLTWH(4, 6, 42, 6), hatPaint);

    // Eyes - magic glow
    final eyeColor = currentPhase >= 3 ? Colors.pinkAccent : Colors.cyan;
    canvas.drawCircle(Offset(size.x / 2 - 4, 13), 2.5, Paint()..color = eyeColor);
    canvas.drawCircle(Offset(size.x / 2 + 4, 13), 2.5, Paint()..color = eyeColor);

    // Magic aura
    final auraPaint = Paint()
      ..color = (currentPhase >= 2 ? Colors.purple : Colors.deepPurple).withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 35, auraPaint);

    // Staff
    final staffPaint = Paint()..color = Colors.brown.shade600;
    canvas.drawRect(Rect.fromLTWH(42, 10, 3, 50), staffPaint);
    // Staff orb
    canvas.drawCircle(const Offset(43.5, 8), 5, Paint()..color = Colors.cyan);
  }
}
