import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/boss_rush_game.dart';
import '../utils/constants.dart';
import 'player.dart';

/// Collectible coin that drops from enemies
class Coin extends CircleComponent
    with HasGameReference<BossRushGame>, CollisionCallbacks {
  final int value;
  double _lifetime = 0;
  double _velocityY;
  double _velocityX;
  bool _onGround = false;
  bool _magnetized = false;
  static const double _magnetRange = 80;
  static const double _magnetSpeed = 350;

  Coin({
    required Vector2 startPosition,
    this.value = 1,
  })  : _velocityY = -(150 + Random().nextDouble() * 100),
        _velocityX = (Random().nextDouble() - 0.5) * 120,
        super(
          position: startPosition,
          radius: 5,
          paint: Paint()..color = Colors.amber,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox(isSolid: true));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _lifetime += dt;

    if (_magnetized) {
      // Fly toward player
      final playerCenter = game.player.position + game.player.size / 2;
      final dir = playerCenter - position;
      final dist = dir.length;
      if (dist < 15) {
        _collect();
        return;
      }
      dir.normalize();
      position += dir * _magnetSpeed * dt;
      return;
    }

    // Physics
    if (!_onGround) {
      _velocityY += GameConstants.gravity * dt;
      position.y += _velocityY * dt;
      position.x += _velocityX * dt;

      if (position.y >= GameConstants.groundY - 5) {
        position.y = GameConstants.groundY - 5;
        _onGround = true;
      }
    }

    // Check magnet range to player
    final playerCenter = game.player.position + game.player.size / 2;
    if ((playerCenter - position).length < _magnetRange) {
      _magnetized = true;
    }

    // Despawn after 8 seconds
    if (_lifetime > 8) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Player) {
      _collect();
    }
  }

  void _collect() {
    game.addCoins(value);
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    // Coin body
    final shimmer = (sin(_lifetime * 6) * 0.15 + 0.85).clamp(0.0, 1.0);
    final coinPaint = Paint()
      ..color = Color.lerp(Colors.amber, Colors.yellow, shimmer)!;
    canvas.drawCircle(Offset.zero, radius, coinPaint);

    // Inner circle
    final inner = Paint()
      ..color = Colors.amber.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(Offset.zero, radius * 0.6, inner);
  }
}
