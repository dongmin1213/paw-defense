import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'boss_base.dart';
import '../components/enemy_bullet.dart';
import '../game/boss_rush_game.dart';
import '../utils/constants.dart';

class Boss7StormElemental extends BossBase {
  double _attackTimer = 0;
  double _moveTimer = 0;
  double _windForce = 0; // pushes player left/right
  final Random _rng = Random();
  bool _isStorming = false;

  Boss7StormElemental(BossRushGame game)
      : super(
          bossName: 'Storm Elemental',
          maxHp: 80,
          totalPhases: 3,
          size: Vector2(70, 100),
          position: Vector2(GameConstants.worldWidth - 150, 200),
        );

  @override
  void updateBehavior(double dt) {
    _attackTimer += dt;
    _moveTimer += dt;

    // Float erratically
    position.x = GameConstants.worldWidth - 150 + sin(_moveTimer * 1.8) * 50;
    position.y = 200 + sin(_moveTimer * 2.3) * 40;

    // Apply wind to player
    if (_windForce != 0) {
      game.player.position.x += _windForce * dt;
    }

    switch (currentPhase) {
      case 1:
        if (_attackTimer >= 2.0) {
          _attackTimer = 0;
          _lightningStrike(2);
        }
        break;
      case 2:
        if (_attackTimer >= 1.5) {
          _attackTimer = 0;
          if (_rng.nextBool()) {
            _lightningStrike(3);
          } else {
            _windGust();
          }
        }
        break;
      case 3:
        if (_attackTimer >= 1.0) {
          _attackTimer = 0;
          final roll = _rng.nextInt(3);
          if (roll == 0) _lightningStrike(4);
          else if (roll == 1) _windGust();
          else _stormBarrage();
        }
        break;
    }
  }

  void _lightningStrike(int count) {
    for (int i = 0; i < count; i++) {
      final x = _rng.nextDouble() * (GameConstants.worldWidth - 100) + 50;
      // Warning flash then strike
      Future.delayed(Duration(milliseconds: 300 + i * 200), () {
        if (!isMounted || isDefeated) return;
        game.world.add(EnemyBullet(
          startPosition: Vector2(x, -10),
          velocity: Vector2(0, 400),
          pattern: EnemyBulletPattern.straight,
          radius: 6,
        ));
      });
    }
  }

  void _windGust() {
    _windForce = (_rng.nextBool() ? 1 : -1) * 80;
    Future.delayed(const Duration(seconds: 2), () {
      _windForce = 0;
    });

    // Wind debris
    for (int i = 0; i < 4; i++) {
      game.world.add(EnemyBullet(
        startPosition: Vector2(
          _windForce > 0 ? -10 : GameConstants.worldWidth + 10,
          200 + _rng.nextDouble() * 200,
        ),
        velocity: Vector2(_windForce * 2, _rng.nextDouble() * 40 - 20),
        pattern: EnemyBulletPattern.straight,
        radius: 5,
      ));
    }
  }

  void _stormBarrage() {
    _isStorming = true;
    // Rapid lightning + rain
    for (int i = 0; i < 8; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (!isMounted || isDefeated) return;
        final x = _rng.nextDouble() * GameConstants.worldWidth;
        game.world.add(EnemyBullet(
          startPosition: Vector2(x, -10),
          velocity: Vector2(_rng.nextDouble() * 40 - 20, 300),
          pattern: EnemyBulletPattern.falling,
          radius: 4,
        ));
      });
    }
    Future.delayed(const Duration(milliseconds: 1200), () {
      _isStorming = false;
    });
  }

  @override
  void onPhaseChange(int newPhase) {
    _attackTimer = 0;
  }

  @override
  void onDefeat() {
    _windForce = 0;
  }

  @override
  void render(Canvas canvas) {
    // Storm cloud body
    final cloudColor = isFlashing ? Colors.white : Colors.blueGrey.shade700;
    final cloudPaint = Paint()..color = cloudColor;

    // Main cloud mass
    canvas.drawCircle(Offset(size.x / 2, 30), 28, cloudPaint);
    canvas.drawCircle(Offset(size.x / 2 - 20, 35), 20, cloudPaint);
    canvas.drawCircle(Offset(size.x / 2 + 20, 35), 20, cloudPaint);
    canvas.drawCircle(Offset(size.x / 2, 50), 22, cloudPaint);

    // Eyes
    final eyeColor = currentPhase >= 3 ? Colors.white : Colors.lightBlueAccent;
    canvas.drawCircle(Offset(size.x / 2 - 10, 28), 5, Paint()..color = eyeColor);
    canvas.drawCircle(Offset(size.x / 2 + 10, 28), 5, Paint()..color = eyeColor);

    // Angry eyebrows for later phases
    if (currentPhase >= 2) {
      final browPaint = Paint()
        ..color = Colors.grey.shade900
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(size.x / 2 - 16, 22), Offset(size.x / 2 - 6, 24), browPaint);
      canvas.drawLine(Offset(size.x / 2 + 16, 22), Offset(size.x / 2 + 6, 24), browPaint);
    }

    // Lightning crackling below
    if (!isFlashing) {
      final boltPaint = Paint()
        ..color = Colors.yellowAccent.withValues(alpha: 0.7)
        ..strokeWidth = 2;
      canvas.drawLine(Offset(size.x / 2 - 5, 60), Offset(size.x / 2 - 10, 80), boltPaint);
      canvas.drawLine(Offset(size.x / 2 - 10, 80), Offset(size.x / 2, 75), boltPaint);
      canvas.drawLine(Offset(size.x / 2, 75), Offset(size.x / 2 - 5, size.y), boltPaint);

      if (currentPhase >= 2) {
        canvas.drawLine(Offset(size.x / 2 + 10, 62), Offset(size.x / 2 + 15, 78), boltPaint);
        canvas.drawLine(Offset(size.x / 2 + 15, 78), Offset(size.x / 2 + 8, size.y - 5), boltPaint);
      }
    }

    // Wind indicator
    if (_windForce != 0) {
      final windPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..strokeWidth = 1;
      for (int i = 0; i < 5; i++) {
        final y = 20.0 + i * 15;
        final dir = _windForce > 0 ? 1.0 : -1.0;
        canvas.drawLine(
          Offset(size.x / 2, y),
          Offset(size.x / 2 + dir * 30, y + 5),
          windPaint,
        );
      }
    }

    // Storm aura
    if (_isStorming) {
      final stormPaint = Paint()
        ..color = Colors.lightBlueAccent.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      canvas.drawCircle(Offset(size.x / 2, size.y / 2), 50, stormPaint);
    }
  }
}
