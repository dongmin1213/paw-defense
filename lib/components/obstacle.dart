import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../game/runner_game.dart';
import '../utils/constants.dart';
import '../utils/pixel_art.dart';

class Obstacle extends PositionComponent
    with HasGameReference<RunnerGame>, CollisionCallbacks {

  static const _rockSprite = [
    '......dddd......',
    '....ddDDDDdd....',
    '...dDDDDDDDDd...',
    '..dDDhDDDDDDDd..',
    '.dDDhhDDDDDDDDd.',
    '.dDDhDDDDDDDDDd.',
    'dDDDDDDDDDDDDDDd',
    'dDDDDDDDDDssDDDd',
    'dDDDDDDDDDssDDDd',
    'dDDsDDDDDDDDDDDd',
    '.dDDDDDDDDDDDDd.',
    '.dDDDDDDDDDDDDd.',
    '..ddDDDDDDDDdd..',
    '....dddddddd....',
  ];

  static const _palette = {
    'D': Color(0xFF8B7355), // Rock body
    'd': Color(0xFF6B5545), // Rock dark outline
    'h': Color(0xFFA89070), // Highlight
    's': Color(0xFF5A4535), // Shadow crack
  };

  Obstacle({
    required Vector2 spawnPosition,
  }) : super(
          position: spawnPosition,
          size: Vector2(24, 28),
        );

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
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
    PixelArt.drawCentered(
      canvas, _rockSprite, _palette, Size(size.x, size.y),
      pixelSize: size.x / _rockSprite[0].length,
    );
  }
}
