import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Color;

import '../game/defense_game.dart';

/// Type of damage number for visual differentiation.
enum DamageNumberType {
  normal,     // white
  critical,   // red/orange with "!" and bigger size
  heal,       // green with "+" prefix
  dot,        // smaller, orange/purple ticks
  gold,       // gold colored
  shield,     // grey (reduced damage)
}

/// Floating damage/gold number popup that rises and fades out.
/// Uses dart:ui ParagraphBuilder for text rendering (Flame component).
class DamageNumber extends PositionComponent
    with HasGameReference<DefenseGame> {
  final String text;
  final Color color;
  final double fontSize;
  final bool isCritical;
  final DamageNumberType type;

  double _alpha = 1.0;
  double _elapsed = 0.0;
  double _scale = 1.0;

  static const double _lifetime = 0.8;
  static const double _floatSpeed = 40.0;

  static final Random _rng = Random();

  // Cached ParagraphStyle to avoid per-frame allocation
  static final ui.ParagraphStyle _paragraphStyle = ui.ParagraphStyle(
    textAlign: ui.TextAlign.center,
    maxLines: 1,
  );
  static const ui.ParagraphConstraints _constraints =
      ui.ParagraphConstraints(width: 100);

  DamageNumber({
    required Vector2 position,
    required this.text,
    required this.color,
    this.fontSize = 8,
    this.isCritical = false,
    this.type = DamageNumberType.normal,
  }) : super(position: position.clone()) {
    // Slight random X offset for visual variety
    this.position.x += _rng.nextDouble() * 10 - 5;
    // Scale and speed vary by type
    switch (type) {
      case DamageNumberType.critical:
        _scale = 2.0;
        break;
      case DamageNumberType.heal:
        _scale = 1.4;
        this.position.y -= 5; // start slightly higher
        break;
      case DamageNumberType.dot:
        _scale = 0.9;
        break;
      case DamageNumberType.gold:
        _scale = 1.3;
        break;
      case DamageNumberType.shield:
        _scale = 1.0;
        break;
      default:
        _scale = isCritical ? 1.8 : 1.3;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    // Float upward — crits float faster
    final speed = isCritical ? _floatSpeed * 1.3 : _floatSpeed;
    position.y -= speed * dt;

    // Scale pop: quickly shrink to 1.0 in the first 0.15s
    if (_elapsed < 0.15) {
      final t = _elapsed / 0.15;
      _scale = 1.0 + (isCritical ? 0.8 : 0.3) * (1.0 - t);
    } else {
      _scale = 1.0;
    }

    // Fade out over lifetime
    _alpha = (1.0 - _elapsed / _lifetime).clamp(0.0, 1.0);

    if (_alpha <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(ui.Canvas canvas) {
    canvas.save();
    canvas.scale(_scale, _scale);

    final actualFontSize = isCritical ? fontSize * 1.3 : fontSize;

    // Shadow/outline based on type
    final shadows = <ui.Shadow>[];
    if (type == DamageNumberType.critical || isCritical) {
      shadows.add(ui.Shadow(
        color: const Color(0xFF000000).withValues(alpha: _alpha * 0.9),
        offset: const ui.Offset(1, 1),
        blurRadius: 0,
      ));
      shadows.add(ui.Shadow(
        color: const Color(0xFFFF0000).withValues(alpha: _alpha * 0.4),
        offset: const ui.Offset(0, 0),
        blurRadius: 4,
      ));
    } else if (type == DamageNumberType.heal) {
      shadows.add(ui.Shadow(
        color: const Color(0xFF004D00).withValues(alpha: _alpha * 0.6),
        offset: const ui.Offset(1, 1),
        blurRadius: 0,
      ));
    } else if (type == DamageNumberType.gold) {
      shadows.add(ui.Shadow(
        color: const Color(0xFF5D4037).withValues(alpha: _alpha * 0.6),
        offset: const ui.Offset(1, 1),
        blurRadius: 0,
      ));
    } else {
      shadows.add(ui.Shadow(
        color: const Color(0xFF000000).withValues(alpha: _alpha * 0.6),
        offset: const ui.Offset(1, 1),
        blurRadius: 0,
      ));
    }

    final textStyle = ui.TextStyle(
      color: color.withValues(alpha: _alpha),
      fontSize: actualFontSize,
      fontWeight: ui.FontWeight.w900,
      shadows: shadows,
    );

    // Format display text based on type
    String displayText;
    switch (type) {
      case DamageNumberType.critical:
        displayText = '$text!';
        break;
      case DamageNumberType.heal:
        displayText = '+$text';
        break;
      case DamageNumberType.gold:
        displayText = '+$text';
        break;
      case DamageNumberType.shield:
        displayText = text;
        break;
      default:
        displayText = isCritical ? '$text!' : text;
    }

    final builder = ui.ParagraphBuilder(_paragraphStyle)
      ..pushStyle(textStyle)
      ..addText(displayText);

    final paragraph = builder.build();
    paragraph.layout(_constraints);

    // Center the text horizontally
    canvas.drawParagraph(
      paragraph,
      ui.Offset(-50, -actualFontSize / 2),
    );

    canvas.restore();
  }
}
