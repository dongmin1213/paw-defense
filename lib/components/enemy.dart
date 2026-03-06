import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/boss_rush_game.dart';
import '../utils/constants.dart';
import 'player.dart';

enum EnemyType { slime, bat, skeleton }

class Enemy extends PositionComponent
    with HasGameReference<BossRushGame>, CollisionCallbacks {
  final EnemyType type;
  final Vector2 startPosition;
  final double patrolRange;

  double hp = 3;
  double _moveTimer = 0;
  double _attackTimer = 0;
  int _direction = 1;
  double _hitFlash = 0;


  Enemy({
    required this.type,
    required this.startPosition,
    this.patrolRange = 80,
  }) : super(position: startPosition.clone());

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    switch (type) {
      case EnemyType.slime:
        size = Vector2(30, 24);
        hp = 3;
        break;
      case EnemyType.bat:
        size = Vector2(28, 20);
        hp = 2;
        break;
      case EnemyType.skeleton:
        size = Vector2(30, 40);
        hp = 5;
        break;
    }
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    _moveTimer += dt;
    _attackTimer += dt;
    if (_hitFlash > 0) _hitFlash -= dt;

    switch (type) {
      case EnemyType.slime:
        _updateSlime(dt);
        break;
      case EnemyType.bat:
        _updateBat(dt);
        break;
      case EnemyType.skeleton:
        _updateSkeleton(dt);
        break;
    }
  }

  void _updateSlime(double dt) {
    // Patrol back and forth
    position.x += _direction * 40 * dt;
    if ((position.x - startPosition.x).abs() > patrolRange) {
      _direction *= -1;
    }
    // Hop animation
    position.y = startPosition.y + sin(_moveTimer * 4) * 3;
  }

  void _updateBat(double dt) {
    // Sine wave flight
    position.x += _direction * 50 * dt;
    position.y = startPosition.y + sin(_moveTimer * 3) * 20;
    if ((position.x - startPosition.x).abs() > patrolRange) {
      _direction *= -1;
    }
  }

  void _updateSkeleton(double dt) {
    // Patrol and occasionally throw bone
    position.x += _direction * 30 * dt;
    if ((position.x - startPosition.x).abs() > patrolRange) {
      _direction *= -1;
    }

    if (_attackTimer >= 2.5) {
      _attackTimer = 0;
      _throwBone();
    }
  }

  void _throwBone() {
    if (!isMounted) return;
    final playerPos = game.player.position;
    final dir = (playerPos.x > position.x) ? 1 : -1;
    game.world.add(_Bone(
      startPosition: Vector2(position.x + size.x / 2, position.y),
      direction: dir,
    ));
  }

  void takeDamage(double damage) {
    hp -= damage;
    _hitFlash = 0.1;

    if (hp <= 0) {
      game.onEnemyDefeated(this);
      removeFromParent();
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
    final isFlash = _hitFlash > 0;

    switch (type) {
      case EnemyType.slime:
        _renderSlime(canvas, isFlash);
        break;
      case EnemyType.bat:
        _renderBat(canvas, isFlash);
        break;
      case EnemyType.skeleton:
        _renderSkeleton(canvas, isFlash);
        break;
    }
  }

  void _renderSlime(Canvas canvas, bool flash) {
    final color = flash ? Colors.white : Colors.green;
    final paint = Paint()..color = color;

    // Body blob
    final path = Path()
      ..moveTo(0, size.y)
      ..quadraticBezierTo(0, 0, size.x / 2, 2)
      ..quadraticBezierTo(size.x, 0, size.x, size.y)
      ..close();
    canvas.drawPath(path, paint);

    // Eyes
    if (!flash) {
      final eye = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(size.x * 0.35, size.y * 0.4), 3, eye);
      canvas.drawCircle(Offset(size.x * 0.65, size.y * 0.4), 3, eye);
      final pupil = Paint()..color = Colors.black;
      canvas.drawCircle(Offset(size.x * 0.35 + _direction * 1, size.y * 0.4), 1.5, pupil);
      canvas.drawCircle(Offset(size.x * 0.65 + _direction * 1, size.y * 0.4), 1.5, pupil);
    }
  }

  void _renderBat(Canvas canvas, bool flash) {
    final color = flash ? Colors.white : Colors.purple.shade800;
    final paint = Paint()..color = color;

    // Body
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 6, paint);

    // Wings
    final wingPhase = sin(_moveTimer * 8) * 0.3;
    final wing = Paint()..color = color;
    // Left wing
    final leftWing = Path()
      ..moveTo(size.x / 2 - 4, size.y / 2)
      ..quadraticBezierTo(-2, size.y * (0.2 + wingPhase), 0, size.y / 2)
      ..lineTo(size.x / 2 - 4, size.y / 2 + 3)
      ..close();
    canvas.drawPath(leftWing, wing);
    // Right wing
    final rightWing = Path()
      ..moveTo(size.x / 2 + 4, size.y / 2)
      ..quadraticBezierTo(size.x + 2, size.y * (0.2 + wingPhase), size.x, size.y / 2)
      ..lineTo(size.x / 2 + 4, size.y / 2 + 3)
      ..close();
    canvas.drawPath(rightWing, wing);

    // Eyes
    if (!flash) {
      final eye = Paint()..color = Colors.red;
      canvas.drawCircle(Offset(size.x / 2 - 2, size.y / 2 - 1), 1.5, eye);
      canvas.drawCircle(Offset(size.x / 2 + 2, size.y / 2 - 1), 1.5, eye);
    }
  }

  void _renderSkeleton(Canvas canvas, bool flash) {
    final color = flash ? Colors.white : Colors.grey.shade300;
    final paint = Paint()..color = color;

    // Head (skull)
    canvas.drawCircle(Offset(size.x / 2, 8), 8, paint);
    // Eye sockets
    if (!flash) {
      final dark = Paint()..color = Colors.black;
      canvas.drawCircle(Offset(size.x / 2 - 3, 7), 2, dark);
      canvas.drawCircle(Offset(size.x / 2 + 3, 7), 2, dark);
      // Mouth
      canvas.drawRect(Rect.fromLTWH(size.x / 2 - 3, 12, 6, 2), dark);
    }

    // Ribcage
    final bonePaint = Paint()..color = color;
    canvas.drawRect(Rect.fromLTWH(size.x / 2 - 1, 16, 2, 16), bonePaint);
    for (int i = 0; i < 3; i++) {
      final y = 18.0 + i * 5;
      canvas.drawRect(Rect.fromLTWH(size.x / 2 - 6, y, 12, 2), bonePaint);
    }

    // Arms
    canvas.drawRect(Rect.fromLTWH(size.x / 2 - 10, 18, 4, 2), bonePaint);
    canvas.drawRect(Rect.fromLTWH(size.x / 2 + 6, 18, 4, 2), bonePaint);

    // Legs
    canvas.drawRect(Rect.fromLTWH(size.x / 2 - 5, 32, 2, 8), bonePaint);
    canvas.drawRect(Rect.fromLTWH(size.x / 2 + 3, 32, 2, 8), bonePaint);
  }
}

/// Bone projectile thrown by Skeleton
class _Bone extends PositionComponent
    with HasGameReference<BossRushGame>, CollisionCallbacks {
  final int direction;
  double _rotation = 0;

  _Bone({
    required Vector2 startPosition,
    required this.direction,
  }) : super(position: startPosition, size: Vector2(12, 6));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x += direction * 150 * dt;
    _rotation += dt * 10;

    if (position.x < -20 || position.x > GameConstants.worldWidth + 20) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Player) {
      game.onPlayerHit();
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(_rotation);

    final paint = Paint()..color = Colors.grey.shade200;
    canvas.drawRect(Rect.fromLTWH(-size.x / 2, -1, size.x, 2), paint);
    canvas.drawCircle(Offset(-size.x / 2, 0), 3, paint);
    canvas.drawCircle(Offset(size.x / 2, 0), 3, paint);

    canvas.restore();
  }
}
