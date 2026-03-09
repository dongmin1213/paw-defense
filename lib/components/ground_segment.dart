import 'dart:ui' as ui;
import 'dart:math';
import 'package:flame/components.dart';

import '../game/runner_game.dart';
import '../data/region_data.dart';
import '../utils/constants.dart';

class GroundSegment extends PositionComponent with HasGameReference<RunnerGame> {
  final RegionData region;

  GroundSegment({
    required double startX,
    required this.region,
  }) : super(
          position: Vector2(startX, GameConstants.groundY),
          size: Vector2(GameConstants.groundSegmentWidth, GameConstants.groundHeight),
        );

  @override
  void update(double dt) {
    super.update(dt);

    final cameraX = game.camera.viewfinder.position.x;
    if (position.x + size.x < cameraX - GameConstants.despawnBehindDistance) {
      final aheadX = cameraX + GameConstants.worldWidth + GameConstants.spawnAheadDistance;
      position.x = aheadX;
    }
  }

  @override
  void render(ui.Canvas canvas) {
    final paint = ui.Paint()..isAntiAlias = false;
    final px = 4.0;

    // === Top grass strip (16px) ===
    final grassH = 16.0;

    // Grass base
    paint.color = region.groundColor;
    canvas.drawRect(ui.Rect.fromLTWH(0, 0, size.x, grassH), paint);

    // Top highlight line
    final grassBright = ui.Color.fromARGB(255,
      min(255, region.groundColor.red + 35),
      min(255, region.groundColor.green + 45),
      min(255, region.groundColor.blue + 20),
    );
    paint.color = grassBright;
    canvas.drawRect(ui.Rect.fromLTWH(0, 0, size.x, 2), paint);

    // Grass blades extending upward from top
    final grassLight = ui.Color.fromARGB(255,
      min(255, region.groundColor.red + 25),
      min(255, region.groundColor.green + 35),
      min(255, region.groundColor.blue + 15),
    );
    final grassDark = ui.Color.fromARGB(255,
      (region.groundColor.red * 0.8).round().clamp(0, 255),
      (region.groundColor.green * 0.85).round().clamp(0, 255),
      (region.groundColor.blue * 0.8).round().clamp(0, 255),
    );

    final numBlades = (size.x / px).ceil();
    final segSeed = (position.x * 0.1).floor();
    for (var i = 0; i < numBlades; i++) {
      final seed = ((segSeed + i) * 17 + 53) % 100;
      final bladeH = 6.0 + (seed % 5) * 2;

      if (seed % 5 == 0) {
        paint.color = grassLight;
      } else if (seed % 3 == 0) {
        paint.color = grassDark;
      } else {
        paint.color = region.groundColor;
      }
      canvas.drawRect(ui.Rect.fromLTWH(i * px, -bladeH, px, bladeH + 4), paint);
    }

    // Occasional flowers/decorations on grass
    for (var i = 0; i < numBlades; i++) {
      final seed = ((segSeed + i) * 31 + 71) % 200;
      if (seed % 17 == 0) {
        // Small flower
        final flowerColors = [
          const ui.Color(0xFFFF6B6B),
          const ui.Color(0xFFFFD93D),
          const ui.Color(0xFFFF9FF3),
          const ui.Color(0xFF54A0FF),
        ];
        paint.color = flowerColors[seed % flowerColors.length];
        canvas.drawRect(ui.Rect.fromLTWH(i * px, -4, px, px), paint);
        // Stem
        paint.color = grassDark;
        canvas.drawRect(ui.Rect.fromLTWH(i * px, 0, px, 4), paint);
      }
    }

    // Mid grass stripe for depth
    paint.color = grassDark;
    canvas.drawRect(ui.Rect.fromLTWH(0, grassH * 0.5, size.x, 2), paint);

    // === Dirt/earth section below grass ===
    final dirtY = grassH;
    final dirtH = 8.0;
    final dirtColor = ui.Color.fromARGB(255,
      (region.groundColor.red * 0.7 + region.groundAccentColor.red * 0.3).round().clamp(0, 255),
      (region.groundColor.green * 0.6 + region.groundAccentColor.green * 0.4).round().clamp(0, 255),
      (region.groundColor.blue * 0.7 + region.groundAccentColor.blue * 0.3).round().clamp(0, 255),
    );
    paint.color = dirtColor;
    canvas.drawRect(ui.Rect.fromLTWH(0, dirtY, size.x, dirtH), paint);

    // Dirt texture dots
    final dirtDark = ui.Color.fromARGB(255,
      (dirtColor.red * 0.8).round().clamp(0, 255),
      (dirtColor.green * 0.8).round().clamp(0, 255),
      (dirtColor.blue * 0.8).round().clamp(0, 255),
    );
    for (var i = 0; i < numBlades; i++) {
      final seed = ((segSeed + i) * 23 + 91) % 100;
      if (seed % 4 == 0) {
        paint.color = dirtDark;
        canvas.drawRect(ui.Rect.fromLTWH(i * px, dirtY + (seed % 2) * px, px, px), paint);
      }
    }

    // === Stone wall section ===
    final stoneY = dirtY + dirtH;
    final stoneH = size.y - stoneY;

    // Base stone color
    paint.color = region.groundAccentColor;
    canvas.drawRect(ui.Rect.fromLTWH(0, stoneY, size.x, stoneH), paint);

    // Brick pattern
    final brickW = 20.0;
    final brickH = 10.0;
    final cols = (size.x / brickW).ceil() + 1;
    final rows = (stoneH / brickH).ceil();

    final stoneLight = ui.Color.fromARGB(255,
      min(255, region.groundAccentColor.red + 20),
      min(255, region.groundAccentColor.green + 20),
      min(255, region.groundAccentColor.blue + 20),
    );
    final stoneDark = ui.Color.fromARGB(255,
      (region.groundAccentColor.red * 0.75).round().clamp(0, 255),
      (region.groundAccentColor.green * 0.75).round().clamp(0, 255),
      (region.groundAccentColor.blue * 0.75).round().clamp(0, 255),
    );
    final stoneMortar = ui.Color.fromARGB(255,
      (region.groundAccentColor.red * 0.55).round().clamp(0, 255),
      (region.groundAccentColor.green * 0.55).round().clamp(0, 255),
      (region.groundAccentColor.blue * 0.55).round().clamp(0, 255),
    );

    for (var r = 0; r < rows; r++) {
      final rowOffset = (r % 2 == 0) ? 0.0 : brickW * 0.5;
      for (var c = -1; c < cols; c++) {
        final bx = c * brickW + rowOffset;
        final by = stoneY + r * brickH;

        // Mortar
        paint.color = stoneMortar;
        canvas.drawRect(ui.Rect.fromLTWH(bx, by, brickW, brickH), paint);

        // Brick face
        final brickSeed = ((segSeed + r * 13 + c * 7) % 100);
        if (brickSeed % 3 == 0) {
          paint.color = stoneLight;
        } else if (brickSeed % 5 == 0) {
          paint.color = stoneDark;
        } else {
          paint.color = region.groundAccentColor;
        }
        canvas.drawRect(
          ui.Rect.fromLTWH(bx + 1, by + 1, brickW - 2, brickH - 2),
          paint,
        );

        // Highlight on top
        paint.color = stoneLight.withAlpha(80);
        canvas.drawRect(ui.Rect.fromLTWH(bx + 1, by + 1, brickW - 2, 2), paint);

        // Shadow on bottom
        paint.color = stoneDark.withAlpha(80);
        canvas.drawRect(ui.Rect.fromLTWH(bx + 1, by + brickH - 3, brickW - 2, 2), paint);
      }
    }
  }
}
