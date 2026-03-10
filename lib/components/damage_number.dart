import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Color, Colors;

import '../game/defense_game.dart';

/// Floating damage/gold number popup that rises and fades out.
/// Uses dart:ui ParagraphBuilder for text rendering (Flame component).
class DamageNumber extends PositionComponent
    with HasGameReference<DefenseGame> {
  final String text;
  final Color color;
  final double fontSize;

  double _alpha = 1.0;
  double _elapsed = 0.0;

  static const double _lifetime = 0.8;
  static const double _floatSpeed = 40.0;

  static final Random _rng = Random();

  DamageNumber({
    required Vector2 position,
    required this.text,
    required this.color,
    this.fontSize = 8,
  }) : super(position: position.clone()) {
    // Slight random X offset for visual variety
    this.position.x += _rng.nextDouble() * 10 - 5;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    // Float upward
    position.y -= _floatSpeed * dt;

    // Fade out over lifetime
    _alpha = (1.0 - _elapsed / _lifetime).clamp(0.0, 1.0);

    if (_alpha <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(ui.Canvas canvas) {
    final paragraphStyle = ui.ParagraphStyle(
      textAlign: ui.TextAlign.center,
      maxLines: 1,
    );

    final textStyle = ui.TextStyle(
      color: color.withValues(alpha: _alpha),
      fontSize: fontSize,
      fontWeight: ui.FontWeight.w700,
    );

    final builder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(textStyle)
      ..addText(text);

    final paragraph = builder.build();
    paragraph.layout(const ui.ParagraphConstraints(width: 100));

    // Center the text horizontally
    canvas.drawParagraph(
      paragraph,
      ui.Offset(-50, -fontSize / 2),
    );
  }
}
