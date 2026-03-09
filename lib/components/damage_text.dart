import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Floating damage number that rises and fades out
class DamageText extends PositionComponent {
  final double damage;
  final bool isCritical;
  double _lifetime = 0;
  static const double _duration = 0.6;

  DamageText({
    required Vector2 position,
    required this.damage,
    this.isCritical = false,
  }) : super(position: position);

  @override
  void update(double dt) {
    super.update(dt);
    _lifetime += dt;
    position.y -= 60 * dt; // Float upward

    if (_lifetime >= _duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final t = (_lifetime / _duration).clamp(0.0, 1.0);
    final alpha = (1.0 - t).clamp(0.0, 1.0);
    final scale = isCritical ? 1.0 + (1.0 - t) * 0.3 : 1.0;

    final text = damage >= 1 ? damage.toInt().toString() : damage.toStringAsFixed(1);

    final textPainter = TextPainter(
      text: TextSpan(
        text: isCritical ? '$text!' : text,
        style: TextStyle(
          color: (isCritical ? Colors.amber : Colors.white).withValues(alpha: alpha),
          fontSize: (isCritical ? 16.0 : 12.0) * scale,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: alpha * 0.8),
              offset: const Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
  }
}
