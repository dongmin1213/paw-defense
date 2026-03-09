import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../game/runner_game.dart';
import '../utils/constants.dart';
import '../utils/pixel_art.dart';
import 'coin.dart';

/// 필드 보물상자 — 접촉 시 코인 폭발 + 랜덤 보너스
class TreasureBox extends PositionComponent
    with HasGameReference<RunnerGame>, CollisionCallbacks {
  bool _opened = false;
  double _openTimer = 0;
  double _animTimer = 0;
  double _hoverOffset = 0;
  final double _coinMultiplier;

  // 보물상자 등급
  final TreasureRarity rarity;

  TreasureBox({
    required Vector2 spawnPosition,
    this.rarity = TreasureRarity.common,
  })  : _coinMultiplier = rarity.multiplier,
        super(
          position: spawnPosition,
          size: Vector2(22, 22),
          priority: 4,
        );

  static const _closedSprite = [
    '......GGGGGG......',
    '....GGGGGGGGGG....',
    '...GBBBBBBBBBBBG..',
    '..GBBBBBBBBBBBBBG.',
    '..GBBBBBYBBBBBBG..',
    '..GBBBBBYBBBBBBG..',
    '.GGGGGGGGGGGGGGGG.',
    '.GDDDDDDDDDDDDDG.',
    '.GBBBBBBYBBBBBBG..',
    '.GBBBBBBYBBBBBBG..',
    '.GBBBBBBBBBBBBG...',
    '..GGGGGGGGGGGG....',
  ];

  static const _palette = {
    'G': Color(0xFF5D4E37),  // 테두리
    'B': Color(0xFF8B6914),  // 나무 본체
    'D': Color(0xFFA0801A),  // 밝은 나무
    'Y': Color(0xFFFFD700),  // 금 장식
  };

  static const _paletteRare = {
    'G': Color(0xFF2E5090),
    'B': Color(0xFF3A6BC5),
    'D': Color(0xFF5A8BE5),
    'Y': Color(0xFFFFD700),
  };

  static const _paletteEpic = {
    'G': Color(0xFF6A2D8E),
    'B': Color(0xFF9B4DCA),
    'D': Color(0xFFBB6DEA),
    'Y': Color(0xFFFFD700),
  };

  Map<String, Color> get _activePalette {
    switch (rarity) {
      case TreasureRarity.common:
        return _palette;
      case TreasureRarity.rare:
        return _paletteRare;
      case TreasureRarity.epic:
        return _paletteEpic;
    }
  }

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    _animTimer += dt;
    _hoverOffset = sin(_animTimer * 3) * 2;

    if (_opened) {
      _openTimer += dt;
      if (_openTimer > 0.8) {
        removeFromParent();
      }
      return;
    }

    final cameraX = game.camera.viewfinder.position.x;
    if (position.x < cameraX - GameConstants.despawnBehindDistance) {
      removeFromParent();
    }
  }

  void collect() {
    if (_opened) return;
    _opened = true;

    // 업적 추적
    game.achievementManager.onBoxOpened();
    game.soundManager.playTreasureOpen();

    // 코인 폭발
    final rng = Random();
    final coinCount = 5 + rng.nextInt(5) + rarity.index * 3;
    final baseValue = (5.0 + rng.nextDouble() * 10) * _coinMultiplier;

    for (var i = 0; i < coinCount; i++) {
      final coinX = position.x + rng.nextDouble() * 50 - 25;
      final coinY = position.y - 10 - rng.nextDouble() * 40;
      game.world.add(Coin(
        spawnPosition: Vector2(coinX, coinY),
        value: baseValue / coinCount,
      ));
    }

    // 파티클
    game.particleEffect.spawnBossExplosion(
      position.x + size.x / 2,
      position.y + size.y / 2,
    );
    game.gameFeel.shake(intensity: 3, duration: 0.15);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other == game.player) {
      collect();
    }
  }

  @override
  void render(Canvas canvas) {
    if (_opened) {
      // 열림 이펙트
      final alpha = (1.0 - _openTimer / 0.8).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = Color.fromARGB((alpha * 200).toInt(), 255, 215, 0);
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2 + _hoverOffset),
        10 + _openTimer * 20,
        paint,
      );
      return;
    }

    canvas.save();
    canvas.translate(0, _hoverOffset);

    PixelArt.drawCentered(
      canvas,
      _closedSprite,
      _activePalette,
      Size(size.x, size.y),
      pixelSize: size.x / _closedSprite[0].length,
    );

    // 글로우 이펙트 (레어 이상)
    if (rarity != TreasureRarity.common) {
      final glowPaint = Paint()
        ..color = (rarity == TreasureRarity.epic
                ? const Color(0xFFBB6DEA)
                : const Color(0xFF5A8BE5))
            .withAlpha((40 + sin(_animTimer * 4) * 20).toInt());
      canvas.drawCircle(Offset(size.x / 2, size.y / 2), 14, glowPaint);
    }

    canvas.restore();
  }
}

enum TreasureRarity {
  common,   // 70%
  rare,     // 25%
  epic,     // 5%
}

extension on TreasureRarity {
  double get multiplier {
    switch (this) {
      case TreasureRarity.common:
        return 1.0;
      case TreasureRarity.rare:
        return 3.0;
      case TreasureRarity.epic:
        return 10.0;
    }
  }
}
