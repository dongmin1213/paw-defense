import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'boss_base.dart';
import '../components/enemy_bullet.dart';
import '../game/boss_rush_game.dart';
import '../utils/constants.dart';

class Boss5MirrorTrickster extends BossBase {
  double _attackTimer = 0;

  bool _isShuffling = false;
  double _shuffleProgress = 0;
  final List<_MirrorClone> _clones = [];
  final Random _rng = Random();

  Boss5MirrorTrickster(BossRushGame game)
      : super(
          bossName: 'Mirror Trickster',
          maxHp: 65,
          totalPhases: 3,
          size: Vector2(50, 70),
          position: Vector2(GameConstants.worldWidth - 130, GameConstants.groundY - 70),
        );

  @override
  void updateBehavior(double dt) {
    _attackTimer += dt;

    if (_isShuffling) {
      _handleShuffle(dt);
      return;
    }

    // Bob movement
    position.y = GameConstants.groundY - 70 + sin(_attackTimer * 2) * 8;

    switch (currentPhase) {
      case 1:
        if (_attackTimer >= 2.0) {
          _attackTimer = 0;
          _mirrorShot();
        }
        break;
      case 2:
        if (_attackTimer >= 1.5) {
          _attackTimer = 0;
          if (_rng.nextBool()) {
            _mirrorShot();
          } else {
            _startShuffle();
          }
        }
        break;
      case 3:
        if (_attackTimer >= 1.0) {
          _attackTimer = 0;
          final roll = _rng.nextInt(3);
          if (roll == 0) _mirrorShot();
          else if (roll == 1) _startShuffle();
          else _reflectAttack();
        }
        break;
    }
  }

  void _mirrorShot() {
    // Fire from self and all clones
    _fireFromPosition(position + size / 2);
    for (final clone in _clones) {
      _fireFromPosition(clone.position + clone.size / 2);
    }
  }

  void _fireFromPosition(Vector2 pos) {
    final playerPos = game.player.position + game.player.size / 2;
    final dir = (playerPos - pos).normalized();
    game.world.add(EnemyBullet(
      startPosition: pos.clone(),
      velocity: dir * 160,
      pattern: EnemyBulletPattern.aimed,
      radius: 5,
    ));
  }

  void _startShuffle() {
    _isShuffling = true;
    _shuffleProgress = 0;
  }

  void _handleShuffle(double dt) {
    _shuffleProgress += dt;

    if (_shuffleProgress >= 0.5) {
      _isShuffling = false;
      // Randomize positions
      final positions = [
        Vector2(GameConstants.worldWidth - 130, GameConstants.groundY - 70),
        Vector2(GameConstants.worldWidth - 250, GameConstants.groundY - 70),
        Vector2(GameConstants.worldWidth - 190, GameConstants.groundY - 130),
      ];
      positions.shuffle(_rng);
      position = positions[0];

      // Update/create clones
      _updateClones(positions.sublist(1));
    }
  }

  void _updateClones(List<Vector2> positions) {
    // Remove old clones
    for (final c in _clones) {
      if (c.isMounted) c.removeFromParent();
    }
    _clones.clear();

    final cloneCount = currentPhase >= 2 ? (currentPhase >= 3 ? 2 : 1) : 0;
    for (int i = 0; i < cloneCount && i < positions.length; i++) {
      final clone = _MirrorClone(position: positions[i]);
      _clones.add(clone);
      game.world.add(clone);
    }
  }

  void _reflectAttack() {
    // Circular burst that bounces
    final center = position + size / 2;
    for (int i = 0; i < 6; i++) {
      final angle = (i / 6) * 2 * pi;
      game.world.add(EnemyBullet(
        startPosition: center.clone(),
        velocity: Vector2(cos(angle) * 130, sin(angle) * 130),
        pattern: EnemyBulletPattern.sine,
        radius: 5,
      ));
    }
  }

  @override
  void onPhaseChange(int newPhase) {
    _attackTimer = 0;
    _startShuffle();
  }

  @override
  void onDefeat() {
    for (final c in _clones) {
      if (c.isMounted) c.removeFromParent();
    }
    _clones.clear();
  }

  @override
  void render(Canvas canvas) {
    final paint = basePaint;

    // Jester body
    final bodyColor = isFlashing ? Colors.white : Colors.teal;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(10, 20, 30, 40),
        const Radius.circular(4),
      ),
      Paint()..color = bodyColor,
    );

    // Head
    canvas.drawCircle(Offset(size.x / 2, 14), 12, paint);

    // Jester hat
    final hatPaint = Paint()..color = isFlashing ? Colors.white : Colors.teal.shade800;
    canvas.drawPath(
      Path()
        ..moveTo(8, 8)
        ..quadraticBezierTo(0, -10, 12, -5)
        ..lineTo(size.x / 2, 4)
        ..close(),
      hatPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(42, 8)
        ..quadraticBezierTo(50, -10, 38, -5)
        ..lineTo(size.x / 2, 4)
        ..close(),
      hatPaint,
    );

    // Eyes - mischievous
    final eyePaint = Paint()..color = Colors.yellowAccent;
    canvas.drawCircle(Offset(size.x / 2 - 4, 12), 3, eyePaint);
    canvas.drawCircle(Offset(size.x / 2 + 4, 12), 3, eyePaint);

    // Smile
    final smilePaint = Paint()
      ..color = Colors.yellowAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawArc(
      Rect.fromLTWH(size.x / 2 - 5, 14, 10, 6),
      0, pi, false, smilePaint,
    );

    // Mirror effect
    if (_isShuffling) {
      final shimmer = Paint()
        ..color = Colors.white.withValues(alpha: 0.5 * (1 - _shuffleProgress * 2))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawRect(Rect.fromLTWH(-5, -5, size.x + 10, size.y + 10), shimmer);
    }
  }
}

class _MirrorClone extends PositionComponent with CollisionCallbacks {
  _MirrorClone({required Vector2 position})
      : super(position: position, size: Vector2(50, 70));

  @override
  void render(Canvas canvas) {
    // Semi-transparent clone
    final bodyColor = Colors.teal.withValues(alpha: 0.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(10, 20, 30, 40),
        const Radius.circular(4),
      ),
      Paint()..color = bodyColor,
    );
    canvas.drawCircle(
      Offset(size.x / 2, 14),
      12,
      Paint()..color = Colors.red.withValues(alpha: 0.5),
    );
    // Shimmer
    final shimmer = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), shimmer);
  }
}
