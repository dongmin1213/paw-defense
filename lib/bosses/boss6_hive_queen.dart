import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'boss_base.dart';
import '../components/enemy_bullet.dart';
import '../components/player.dart';
import '../game/boss_rush_game.dart';
import '../utils/constants.dart';

class Boss6HiveQueen extends BossBase {
  double _attackTimer = 0;
  double _spawnTimer = 0;
  final List<_BeeMinion> _minions = [];
  final Random _rng = Random();
  int _maxMinions = 3;

  Boss6HiveQueen(BossRushGame game)
      : super(
          bossName: 'Hive Queen',
          maxHp: 90,
          totalPhases: 3,
          size: Vector2(70, 90),
          position: Vector2(GameConstants.worldWidth - 150, GameConstants.groundY - 90),
        );

  @override
  void updateBehavior(double dt) {
    _attackTimer += dt;
    _spawnTimer += dt;

    // Bob
    position.y = GameConstants.groundY - 90 + sin(_attackTimer * 1.5) * 10;

    // Manage minions
    _minions.removeWhere((m) => !m.isMounted);

    if (_spawnTimer >= 3.0 && _minions.length < _maxMinions) {
      _spawnTimer = 0;
      _spawnMinion();
    }

    switch (currentPhase) {
      case 1:
        if (_attackTimer >= 2.0) {
          _attackTimer = 0;
          _stingerShot(2);
        }
        break;
      case 2:
        _maxMinions = 5;
        if (_attackTimer >= 1.5) {
          _attackTimer = 0;
          if (_rng.nextBool()) {
            _stingerShot(3);
          } else {
            _poisonCloud();
          }
        }
        break;
      case 3:
        _maxMinions = 7;
        if (_attackTimer >= 1.0) {
          _attackTimer = 0;
          final roll = _rng.nextInt(3);
          if (roll == 0) _stingerShot(4);
          else if (roll == 1) _poisonCloud();
          else _swarmRush();
        }
        break;
    }
  }

  void _spawnMinion() {
    final minion = _BeeMinion(
      startPosition: Vector2(
        position.x + _rng.nextDouble() * 40,
        position.y - 20,
      ),
      game: game,
    );
    _minions.add(minion);
    game.world.add(minion);
  }

  void _stingerShot(int count) {
    final center = position + size / 2;
    for (int i = 0; i < count; i++) {
      final spread = (i - (count - 1) / 2) * 15;
      game.world.add(EnemyBullet(
        startPosition: center.clone(),
        velocity: Vector2(-200, spread),
        pattern: EnemyBulletPattern.straight,
        radius: 4,
      ));
    }
  }

  void _poisonCloud() {
    // Slow-moving poison orbs
    for (int i = 0; i < 3; i++) {
      game.world.add(EnemyBullet(
        startPosition: Vector2(
          position.x - 20 - i * 60,
          GameConstants.groundY - 30 - _rng.nextDouble() * 40,
        ),
        velocity: Vector2(-40, 0),
        pattern: EnemyBulletPattern.sine,
        radius: 12,
      ));
    }
  }

  void _swarmRush() {
    // Command all minions to charge player
    for (final m in _minions) {
      m.startCharge();
    }
  }

  @override
  void onPhaseChange(int newPhase) {
    _attackTimer = 0;
  }

  @override
  void onDefeat() {
    for (final m in _minions) {
      if (m.isMounted) m.removeFromParent();
    }
    _minions.clear();
  }

  @override
  void render(Canvas canvas) {
    final paint = basePaint;

    // Abdomen
    final abdomenColor = isFlashing ? Colors.white : Colors.amber.shade700;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(15, 40, 40, 45),
        const Radius.circular(15),
      ),
      Paint()..color = abdomenColor,
    );
    // Stripes
    if (!isFlashing) {
      final stripePaint = Paint()..color = Colors.brown.shade800;
      for (int i = 0; i < 3; i++) {
        canvas.drawRect(Rect.fromLTWH(15, 48.0 + i * 12, 40, 4), stripePaint);
      }
    }

    // Thorax
    canvas.drawCircle(Offset(size.x / 2, 35), 16, paint);

    // Head
    canvas.drawCircle(Offset(size.x / 2, 16), 14, paint);

    // Crown
    final crownPaint = Paint()..color = Colors.amber;
    canvas.drawRect(Rect.fromLTWH(20, -2, 30, 6), crownPaint);
    for (int i = 0; i < 3; i++) {
      canvas.drawRect(Rect.fromLTWH(24.0 + i * 10, -8, 4, 8), crownPaint);
    }

    // Eyes
    final eyeColor = currentPhase >= 3 ? Colors.red : Colors.black;
    canvas.drawCircle(Offset(size.x / 2 - 5, 14), 3, Paint()..color = eyeColor);
    canvas.drawCircle(Offset(size.x / 2 + 5, 14), 3, Paint()..color = eyeColor);

    // Wings
    final wingPaint = Paint()..color = Colors.white.withValues(alpha: 0.3);
    canvas.drawOval(Rect.fromLTWH(-10, 15, 25, 35), wingPaint);
    canvas.drawOval(Rect.fromLTWH(size.x - 15, 15, 25, 35), wingPaint);

    // Stinger
    final stingerPaint = Paint()..color = Colors.black;
    canvas.drawPath(
      Path()
        ..moveTo(size.x / 2 - 3, size.y - 5)
        ..lineTo(size.x / 2, size.y + 5)
        ..lineTo(size.x / 2 + 3, size.y - 5)
        ..close(),
      stingerPaint,
    );
  }
}

class _BeeMinion extends PositionComponent
    with HasGameReference<BossRushGame>, CollisionCallbacks {
  double hp = 2;
  double _moveTimer = 0;
  final Vector2 startPosition;
  bool _isCharging = false;


  _BeeMinion({required this.startPosition, required BossRushGame game})
      : super(position: startPosition.clone(), size: Vector2(20, 14));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  void startCharge() {
    _isCharging = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _moveTimer += dt;

    if (_isCharging) {
      final playerPos = game.player.position + game.player.size / 2;
      final dir = (playerPos - (position + size / 2)).normalized();
      position += dir * 200 * dt;

      if (_moveTimer > 3) {
        _isCharging = false;
        _moveTimer = 0;
      }
    } else {
      // Hover around
      position.x = startPosition.x + sin(_moveTimer * 3) * 30;
      position.y = startPosition.y + sin(_moveTimer * 4) * 15;
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Player) {
      game.onPlayerHit();
    }
  }

  @override
  void render(Canvas canvas) {
    final bodyPaint = Paint()..color = Colors.amber.shade600;
    canvas.drawOval(Rect.fromLTWH(2, 2, 16, 10), bodyPaint);
    // Stripe
    canvas.drawRect(Rect.fromLTWH(6, 2, 3, 10), Paint()..color = Colors.brown.shade800);
    // Wings
    final wingPaint = Paint()..color = Colors.white.withValues(alpha: 0.5);
    canvas.drawOval(Rect.fromLTWH(4, -4, 6, 8), wingPaint);
    canvas.drawOval(Rect.fromLTWH(10, -4, 6, 8), wingPaint);
  }
}
