import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/boss_rush_game.dart';
import '../utils/constants.dart';

class Ground extends RectangleComponent {
  final int stageIndex;
  ui.Picture? _cachedPicture;

  Ground({this.stageIndex = 0})
      : super(
          position: Vector2(0, GameConstants.groundY),
          size: Vector2(GameConstants.worldWidth, GameConstants.worldHeight - GameConstants.groundY),
          paint: Paint()..color = StageThemes.getGroundColor(stageIndex),
        );

  void _buildCache() {
    final recorder = ui.PictureRecorder();
    final c = Canvas(recorder);

    // Base fill
    c.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);

    final baseColor = StageThemes.getGroundColor(stageIndex);
    final lighter = Color.lerp(baseColor, Colors.white, 0.15)!;
    final darker = Color.lerp(baseColor, Colors.black, 0.1)!;

    final linePaint = Paint()
      ..color = lighter
      ..strokeWidth = 2;
    c.drawLine(Offset.zero, Offset(size.x, 0), linePaint);

    final texturePaint = Paint()
      ..color = darker
      ..strokeWidth = 1;
    for (double x = 0; x < size.x; x += 30) {
      c.drawLine(Offset(x, 5), Offset(x + 15, 5), texturePaint);
    }
    for (double x = 15; x < size.x; x += 40) {
      c.drawLine(Offset(x, 12), Offset(x + 10, 12), texturePaint);
    }

    _cachedPicture = recorder.endRecording();
  }

  @override
  void render(Canvas canvas) {
    if (_cachedPicture == null) _buildCache();
    canvas.drawPicture(_cachedPicture!);
  }
}
