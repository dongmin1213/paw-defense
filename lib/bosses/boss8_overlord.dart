import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'boss_base.dart';
import '../components/enemy_bullet.dart';
import '../game/boss_rush_game.dart';
import '../utils/constants.dart';

class Boss8Overlord extends BossBase {
  double _attackTimer = 0;
  double _moveTimer = 0;
  final Random _rng = Random();
  int _attackPattern = 0;

  Boss8Overlord(BossRushGame game)
      : super(
          bossName: 'The Overlord',
          maxHp: 120,
          totalPhases: 4,
          size: Vector2(90, 130),
          position: Vector2(GameConstants.worldWidth - 180, GameConstants.groundY - 130),
        );

  @override
  void updateBehavior(double dt) {
    _attackTimer += dt;
    _moveTimer += dt;

    // Menacing hover
    position.y = GameConstants.groundY - 130 + sin(_moveTimer * 1.5) * 15;

    switch (currentPhase) {
      case 1:
        // Guardian patterns
        if (_attackTimer >= 2.0) {
          _attackTimer = 0;
          _guardianPattern();
        }
        break;
      case 2:
        // Dasher + Witch patterns
        if (_attackTimer >= 1.5) {
          _attackTimer = 0;
          _attackPattern++;
          if (_attackPattern % 2 == 0) {
            _dasherPattern();
          } else {
            _witchPattern();
          }
        }
        break;
      case 3:
        // Colossus + Elemental patterns
        if (_attackTimer >= 1.2) {
          _attackTimer = 0;
          _attackPattern++;
          if (_attackPattern % 2 == 0) {
            _colossusPattern();
          } else {
            _elementalPattern();
          }
        }
        break;
      case 4:
        // All combined + unique ultimate
        if (_attackTimer >= 0.8) {
          _attackTimer = 0;
          _attackPattern++;
          switch (_attackPattern % 5) {
            case 0:
              _guardianPattern();
              _witchPattern();
              break;
            case 1:
              _dasherPattern();
              break;
            case 2:
              _ultimateBarrage();
              break;
            case 3:
              _colossusPattern();
              break;
            case 4:
              _elementalPattern();
              _guardianPattern();
              break;
          }
        }
        break;
    }
  }

  void _guardianPattern() {
    // Horizontal shots
    for (int i = 0; i < 3; i++) {
      final yOffset = (i - 1) * 25.0;
      game.world.add(EnemyBullet(
        startPosition: Vector2(position.x, position.y + size.y / 2 + yOffset),
        velocity: Vector2(-200, 0),
        pattern: EnemyBulletPattern.straight,
      ));
    }
  }

  void _dasherPattern() {
    // Blade wave
    final center = position + size / 2;
    for (int i = 0; i < 5; i++) {
      final angle = -pi / 2 + (i - 2) * 0.3;
      game.world.add(EnemyBullet(
        startPosition: center.clone(),
        velocity: Vector2(cos(angle) * 200, sin(angle) * 200),
        pattern: EnemyBulletPattern.straight,
        radius: 5,
      ));
    }
  }

  void _witchPattern() {
    // Circular burst
    final center = position + size / 2;
    for (int i = 0; i < 10; i++) {
      final angle = (i / 10) * 2 * pi + _moveTimer;
      game.world.add(EnemyBullet(
        startPosition: center.clone(),
        velocity: Vector2(cos(angle) * 120, sin(angle) * 120),
        pattern: EnemyBulletPattern.straight,
        radius: 4,
      ));
    }
  }

  void _colossusPattern() {
    // Ground shockwave
    for (int i = 0; i < 5; i++) {
      game.world.add(EnemyBullet(
        startPosition: Vector2(position.x - (i + 1) * 50, GameConstants.groundY - 15),
        velocity: Vector2(-120 - i * 20, 0),
        pattern: EnemyBulletPattern.straight,
        radius: 9,
      ));
    }
  }

  void _elementalPattern() {
    // Lightning strikes
    for (int i = 0; i < 3; i++) {
      final x = _rng.nextDouble() * (GameConstants.worldWidth - 100) + 50;
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (!isMounted || isDefeated) return;
        game.world.add(EnemyBullet(
          startPosition: Vector2(x, -10),
          velocity: Vector2(0, 350),
          pattern: EnemyBulletPattern.straight,
          radius: 6,
        ));
      });
    }
  }

  void _ultimateBarrage() {
    final center = position + size / 2;
    // Multi-wave spiral
    for (int wave = 0; wave < 3; wave++) {
      Future.delayed(Duration(milliseconds: wave * 200), () {
        if (!isMounted || isDefeated) return;
        for (int i = 0; i < 8; i++) {
          final angle = (i / 8) * 2 * pi + wave * 0.4;
          game.world.add(EnemyBullet(
            startPosition: center.clone(),
            velocity: Vector2(cos(angle) * (100 + wave * 30), sin(angle) * (100 + wave * 30)),
            pattern: EnemyBulletPattern.straight,
            radius: 5,
          ));
        }
      });
    }
  }

  @override
  void onPhaseChange(int newPhase) {
    _attackTimer = 0;
    _attackPattern = 0;
  }

  @override
  void onDefeat() {}

  @override
  void render(Canvas canvas) {
    final paint = basePaint;

    // Dark throne-like body
    final bodyColor = isFlashing ? Colors.white : Colors.grey.shade900;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(15, 30, 60, 80),
        const Radius.circular(6),
      ),
      Paint()..color = bodyColor,
    );

    // Shoulder armor
    final armorPaint = Paint()
      ..color = isFlashing ? Colors.white : Colors.red.shade900;
    canvas.drawRect(Rect.fromLTWH(0, 25, 20, 30), armorPaint);
    canvas.drawRect(Rect.fromLTWH(70, 25, 20, 30), armorPaint);

    // Head - crown/helmet
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(20, 0, 50, 35),
        const Radius.circular(6),
      ),
      paint,
    );

    // Crown spikes
    final crownPaint = Paint()..color = isFlashing ? Colors.white : Colors.amber;
    for (int i = 0; i < 5; i++) {
      final x = 24.0 + i * 10;
      canvas.drawPath(
        Path()
          ..moveTo(x, 2)
          ..lineTo(x + 5, -12)
          ..lineTo(x + 10, 2)
          ..close(),
        crownPaint,
      );
    }

    // Eyes - intense glow
    final eyeColor = currentPhase == 4
        ? Colors.white
        : currentPhase >= 3
            ? Colors.red
            : Colors.orange;
    canvas.drawCircle(Offset(size.x / 2 - 8, 15), 5, Paint()..color = eyeColor);
    canvas.drawCircle(Offset(size.x / 2 + 8, 15), 5, Paint()..color = eyeColor);

    // Eye glow
    final eyeGlow = Paint()
      ..color = eyeColor.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(size.x / 2 - 8, 15), 8, eyeGlow);
    canvas.drawCircle(Offset(size.x / 2 + 8, 15), 8, eyeGlow);

    // Cape
    final capePaint = Paint()..color = isFlashing ? Colors.white : Colors.red.shade800;
    canvas.drawPath(
      Path()
        ..moveTo(15, 40)
        ..lineTo(5, size.y + 10)
        ..lineTo(size.x - 5, size.y + 10)
        ..lineTo(size.x - 15, 40)
        ..close(),
      capePaint,
    );

    // Weapon - dark scepter
    final scepterPaint = Paint()..color = Colors.grey.shade600;
    canvas.drawRect(Rect.fromLTWH(-8, 15, 4, 80), scepterPaint);
    // Scepter orb
    final orbColor = currentPhase >= 3 ? Colors.red : Colors.purple;
    canvas.drawCircle(const Offset(-6, 12), 7, Paint()..color = orbColor);
    canvas.drawCircle(
      const Offset(-6, 12),
      9,
      Paint()
        ..color = orbColor.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Dark aura
    final auraPaint = Paint()
      ..color = (currentPhase >= 3 ? Colors.red : Colors.purple).withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 60, auraPaint);

    // Phase 4 - ultimate form indicator
    if (currentPhase >= 4) {
      final ultimatePaint = Paint()
        ..color = Colors.red.withValues(alpha: 0.1 + sin(_moveTimer * 5) * 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
      canvas.drawCircle(Offset(size.x / 2, size.y / 2), 70, ultimatePaint);
    }
  }
}
