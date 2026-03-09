import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../game/runner_game.dart';
import '../utils/constants.dart';
import '../utils/sprite_loader.dart';

class Obstacle extends PositionComponent
    with HasGameReference<RunnerGame>, CollisionCallbacks {
  Sprite? _sprite;

  Obstacle({
    required Vector2 spawnPosition,
  }) : super(
          position: spawnPosition,
          size: Vector2(24, 28),
        );

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());

    _sprite = await SpriteLoader.loadSprite(
      'obstacle.png',
      frameWidth: 24, frameHeight: 24,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    final cameraX = game.camera.viewfinder.position.x;
    if (position.x < cameraX - GameConstants.despawnBehindDistance) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (_sprite != null) {
      _sprite!.render(canvas, size: size);
    }
  }
}
