import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/boss_rush_game.dart';
import '../utils/constants.dart';

class Ground extends RectangleComponent {
  final int stageIndex;

  Ground({this.stageIndex = 0})
      : super(
          position: Vector2(0, GameConstants.groundY),
          size: Vector2(GameConstants.worldWidth, GameConstants.worldHeight - GameConstants.groundY),
          paint: Paint()..color = StageThemes.getGroundColor(stageIndex),
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final baseColor = StageThemes.getGroundColor(stageIndex);
    final lighter = Color.lerp(baseColor, Colors.white, 0.15)!;
    final darker = Color.lerp(baseColor, Colors.black, 0.1)!;

    // Ground line
    final linePaint = Paint()
      ..color = lighter
      ..strokeWidth = 2;
    canvas.drawLine(Offset.zero, Offset(size.x, 0), linePaint);

    // Texture lines
    final texturePaint = Paint()
      ..color = darker
      ..strokeWidth = 1;
    for (double x = 0; x < size.x; x += 30) {
      canvas.drawLine(Offset(x, 5), Offset(x + 15, 5), texturePaint);
    }
    for (double x = 15; x < size.x; x += 40) {
      canvas.drawLine(Offset(x, 12), Offset(x + 10, 12), texturePaint);
    }
  }
}
