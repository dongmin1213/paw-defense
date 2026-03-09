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
      // Hover animation — 콤보 높으면 빠르게 회전
      final comboSpeed = 1.0 + game.combo * 0.05;
      _hoverOffset = sin(_animTimer * 4 * comboSpeed) * 3;
      position.y += _hoverOffset * dt * 2;

      // 코인 자석 — 플레이어 근처면 끌어당기기
      final magnetRange = 80.0 + game.upgradeManager.coinMagnetRadius;
      final dx = game.player.position.x - position.x;
      final dy = game.player.position.y - position.y;
      final dist = dx * dx + dy * dy;
      if (dist < magnetRange * magnetRange && dist > 1) {
        final pullSpeed = 300.0;
        final d = sqrt(dist);
        position.x += (dx / d) * pullSpeed * dt;
        position.y += (dy / d) * pullSpeed * dt;
      }

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
    game.soundManager.playCoinCollect(isBig: value >= 10);

    // 코인 수집 미세 쉐이크 — 큰 코인은 더 강하게
    if (value >= 10) {
      game.gameFeel.shake(intensity: 1.5, duration: 0.06);
    }

    // Collect particles
    game.particleEffect.spawnCoinCollect(position.x, position.y);

    // Remove hitbox
    removeAll(children.whereType<CircleHitbox>());
  }

  @override
  void render(Canvas canvas) {
    if (!_collected) {
      CoinRenderer.render(canvas, Size(size.x, size.y), animTimer: _animTimer);
    } else {
      // Render popup text "+N" — 스케일 바운스 + 큰 폰트
      final popupScale = _popupTimer < 0.1
          ? 1.0 + (1.0 - _popupTimer / 0.1) * 0.4 // 처음 1.4x → 1.0x
          : 1.0;
      final baseFontSize = value >= 10 ? 20.0 : 16.0;
      final style = ParagraphStyle(textAlign: TextAlign.center);
      final textStyle = TextStyle(
        color: Color.fromRGBO(255, 215, 0, _popupAlpha),
        fontSize: baseFontSize * popupScale,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(color: Color.fromRGBO(0, 0, 0, _popupAlpha * 0.8), blurRadius: 3),
          Shadow(color: Color.fromRGBO(255, 200, 0, _popupAlpha * 0.4), blurRadius: 8),
        ],
      );
      final builder = ParagraphBuilder(style)
        ..pushStyle(textStyle)
        ..addText('+${value.toInt()}');
      final paragraph = builder.build()
        ..layout(const ParagraphConstraints(width: 80));
      canvas.drawParagraph(paragraph, Offset(-32, _popupY));
    }
  }
}
