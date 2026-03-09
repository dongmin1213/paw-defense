import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../game/runner_game.dart';
import '../data/companion_data.dart';
import '../renderers/companion_renderer.dart';

class CompanionPickup extends PositionComponent
    with HasGameReference<RunnerGame>, CollisionCallbacks {
  final CompanionData data;
  final Vector2 spawnPosition;
  double _animTimer = 0;
  bool _collected = false;
  double _collectAnim = 0;

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
  }

  @override
  void update(double dt) {
    super.update(dt);
    _animTimer += dt;

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
    game.soundManager.playCompanionGet();

    game.world.add(_CompanionPopup(
      companionData: data,
      isNew: isNew,
      position: position.clone(),
    ));
  }

  @override
  void render(Canvas canvas) {
    if (_collected) return;

    // Rarity glow
    final rarityColor = CompanionDatabase.rarityColor(data.rarity);
    final glowAlpha = (sin(_animTimer * 4) * 0.2 + 0.3).clamp(0.0, 1.0);
    final glowPaint = Paint()
      ..color = rarityColor.withValues(alpha: glowAlpha)
      ..isAntiAlias = false;
    canvas.drawRect(
      Rect.fromCenter(center: Offset(size.x / 2, size.y / 2), width: 30, height: 30),
      glowPaint,
    );

    // Render companion pixel art
    CompanionRenderer.render(canvas, data.id, Size(size.x, size.y), _animTimer);

    // Rarity border (pixel style - square)
    final borderPaint = Paint()
      ..color = rarityColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..isAntiAlias = false;
    canvas.drawRect(
      Rect.fromLTWH(1, 1, size.x - 2, size.y - 2),
      borderPaint,
    );
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

    final bgPaint = Paint()
      ..color = Color.fromRGBO(0, 0, 0, 0.7 * alpha)
      ..isAntiAlias = false;
    canvas.drawRect(Rect.fromLTWH(-20, 0, 80, 24), bgPaint);

    final borderPaint = Paint()
      ..color = rarityColor.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..isAntiAlias = false;
    canvas.drawRect(Rect.fromLTWH(-20, 0, 80, 24), borderPaint);

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
