import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class Ground extends RectangleComponent {
  Ground()
      : super(
          position: Vector2(0, GameConstants.groundY),
          size: Vector2(GameConstants.worldWidth, GameConstants.worldHeight - GameConstants.groundY),
          paint: Paint()..color = const Color(0xFF2D2D44),
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Ground line
    final linePaint = Paint()
      ..color = const Color(0xFF4A4A6A)
      ..strokeWidth = 2;
    canvas.drawLine(Offset.zero, Offset(size.x, 0), linePaint);

    // Simple ground texture lines
    final texturePaint = Paint()
      ..color = const Color(0xFF363650)
      ..strokeWidth = 1;
    for (double x = 0; x < size.x; x += 30) {
      canvas.drawLine(Offset(x, 5), Offset(x + 15, 5), texturePaint);
    }
  }
}
