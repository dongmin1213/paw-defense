import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../game/runner_game.dart';
import '../data/companion_data.dart';
import '../utils/sprite_loader.dart';

class CompanionPickup extends PositionComponent
    with HasGameReference<RunnerGame>, CollisionCallbacks {
  final CompanionData data;
  final Vector2 spawnPosition;
  double _animTimer = 0;
  bool _collected = false;
  double _collectAnim = 0;

  SpriteAnimation? _anim;

  CompanionPickup({
    required this.data,
    required this.spawnPosition,
  }) : super(
          position: spawnPosition.clone(),
          size: Vector2(28, 28),
        );

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(isSolid: true));

    _anim = await SpriteLoader.loadAnimation(
      'companion_${data.id}.png',
      frameWidth: 20, frameHeight: 20,
      frameCount: 4, stepTime: 0.2,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _animTimer += dt;
    _anim?.update(dt);

    // Float hover
    position.y = spawnPosition.y + sin(_animTimer * 3) * 4;

    // Despawn if too far behind camera
    final cameraX = game.camera.viewfinder.position.x;
    if (position.x < cameraX - 100) {
      removeFromParent();
      return;
    }

    // Collect animation
    if (_collected) {
      _collectAnim += dt;
      if (_collectAnim > 1.0) {
        removeFromParent();
      }
    }
  }

  void collect() {
    if (_collected) return;
    _collected = true;

    final isNew = game.companionManager.addCompanion(data.id);

    game.world.add(_CompanionPopup(
      companionData: data,
      isNew: isNew,
      position: position.clone(),
    ));
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void render(Canvas canvas) {
    if (_collected) return;

    // Rarity glow
    final rarityColor = CompanionDatabase.rarityColor(data.rarity);
    final glowPaint = Paint()
      ..color = rarityColor.withValues(alpha: (sin(_animTimer * 4) * 0.2 + 0.3).clamp(0, 1));
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 16, glowPaint);

    // Render companion sprite
    final sprite = _anim?.getSprite();
    if (sprite != null) {
      // Center the 20x20 sprite in the 28x28 component
      canvas.save();
      canvas.translate(4, 4);
      sprite.render(canvas, size: Vector2(20, 20));
      canvas.restore();
    }

    // Rarity border
    final borderPaint = Paint()
      ..color = rarityColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 14, borderPaint);

    // "!" indicator
    final exclamation = sin(_animTimer * 5) * 2;
    final textPaint = Paint()..color = const Color(0xFFFFD600);
    canvas.drawCircle(Offset(size.x / 2, -4 + exclamation), 3, textPaint);
  }
}

class _CompanionPopup extends PositionComponent with HasGameReference<RunnerGame> {
  final CompanionData companionData;
  final bool isNew;
  double _timer = 0;

  _CompanionPopup({
    required this.companionData,
    required this.isNew,
    required Vector2 position,
  }) : super(position: position, size: Vector2(80, 30), priority: 100);

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
    position.y -= 30 * dt;

    if (_timer > 2.0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final alpha = (1.0 - (_timer / 2.0)).clamp(0.0, 1.0);
    final rarityColor = CompanionDatabase.rarityColor(companionData.rarity);

    final bgPaint = Paint()..color = Color.fromRGBO(0, 0, 0, 0.7 * alpha);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(-20, 0, 80, 24), const Radius.circular(6)),
      bgPaint,
    );

    final borderPaint = Paint()
      ..color = rarityColor.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(-20, 0, 80, 24), const Radius.circular(6)),
      borderPaint,
    );

    final text = isNew ? '${companionData.name} GET!' : '${companionData.name} +1';
    final builder = ParagraphBuilder(ParagraphStyle(
      textAlign: TextAlign.center,
      fontSize: 9,
    ))
      ..pushStyle(TextStyle(color: rarityColor.withValues(alpha: alpha)))
      ..addText(text);
    final paragraph = builder.build()..layout(const ParagraphConstraints(width: 80));
    canvas.drawParagraph(paragraph, const Offset(-20, 5));
  }
}
