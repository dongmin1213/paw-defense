import 'dart:math';
import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../game/runner_game.dart';
import '../renderers/coin_renderer.dart';
import '../utils/constants.dart';

class Coin extends PositionComponent
    with HasGameReference<RunnerGame>, CollisionCallbacks {
  final double value;
  double _animTimer = 0;
  double _hoverOffset = 0;
  bool _collected = false;

  // Popup text
  double _popupTimer = 0;
  double _popupY = 0;
  double _popupAlpha = 0;

  Coin({
    required Vector2 spawnPosition,
    this.value = 1,
  }) : super(
          position: spawnPosition,
          size: Vector2(16, 16),
        );

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    _animTimer += dt;

    if (!_collected) {
      // Hover animation
      _hoverOffset = sin(_animTimer * 4) * 3;
      position.y += _hoverOffset * dt * 2;

      // Cleanup if behind camera
      final cameraX = game.camera.viewfinder.position.x;
      if (position.x < cameraX - GameConstants.despawnBehindDistance) {
        removeFromParent();
      }
    } else {
      // Popup animation
      _popupTimer += dt;
      _popupY -= 40 * dt;
      _popupAlpha = max(0, 1.0 - _popupTimer / 0.8);
      if (_popupTimer > 0.8) {
        removeFromParent();
      }
    }
  }

  void collect() {
    if (_collected) return;
    _collected = true;
    _popupTimer = 0;
    _popupY = -10;
    _popupAlpha = 1.0;

    game.addCoins(value);

    // Collect particles
    game.particleEffect.spawnCoinCollect(position.x, position.y);

    // Remove hitbox
    removeAll(children.whereType<CircleHitbox>());
  }

  @override
  void render(Canvas canvas) {
    if (!_collected) {
      CoinRenderer.render(canvas, size.toSize(), animTimer: _animTimer);
    } else {
      // Render popup text "+N"
      final style = ParagraphStyle(textAlign: TextAlign.center);
      final textStyle = TextStyle(
        color: Color.fromRGBO(255, 215, 0, _popupAlpha),
        fontSize: 14,
        fontWeight: FontWeight.bold,
      );
      final builder = ParagraphBuilder(style)
        ..pushStyle(textStyle)
        ..addText('+${value.toInt()}');
      final paragraph = builder.build()
        ..layout(const ParagraphConstraints(width: 60));
      canvas.drawParagraph(paragraph, Offset(-22, _popupY));
    }
  }
}
