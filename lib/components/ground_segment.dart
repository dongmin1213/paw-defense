import 'dart:ui' as ui;
import 'dart:math';
import 'package:flame/components.dart';

import '../game/runner_game.dart';
import '../data/region_data.dart';
import '../utils/constants.dart';
import '../utils/sprite_loader.dart';

class GroundSegment extends PositionComponent with HasGameReference<RunnerGame> {
  final RegionData region;
  ui.Image? _tileImage;

  GroundSegment({
    required double startX,
    required this.region,
  }) : super(
          position: Vector2(startX, GameConstants.groundY),
          size: Vector2(GameConstants.groundSegmentWidth, GameConstants.groundHeight),
        );

  @override
  Future<void> onLoad() async {
    _tileImage = await SpriteLoader.loadImage('ground_${region.id}.png');
  }

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
    if (_tileImage != null) {
      // Tile the image across the segment
      final tileW = _tileImage!.width.toDouble();
      final tileH = _tileImage!.height.toDouble();
      final cols = (size.x / tileW).ceil();
      final rows = (size.y / tileH).ceil();

      for (var r = 0; r < rows; r++) {
        for (var c = 0; c < cols; c++) {
          canvas.drawImage(
            _tileImage!,
            ui.Offset(c * tileW, r * tileH),
            ui.Paint(),
          );
        }
      }
    } else {
      // Pixel art fallback: stone wall + grass top
      _renderPixelGround(canvas);
    }
  }

  void _renderPixelGround(ui.Canvas canvas) {
    final paint = ui.Paint()..isAntiAlias = false;
    final px = 4.0;

    // Top grass strip (first 12px)
    final grassH = 12.0;

    // Grass base color
    paint.color = region.groundColor;
    canvas.drawRect(ui.Rect.fromLTWH(0, 0, size.x, grassH), paint);

    // Grass blade variation on top
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
      final bladeH = 4.0 + (seed % 4) * 2;

      if (seed % 5 == 0) {
        paint.color = grassLight;
      } else if (seed % 3 == 0) {
        paint.color = grassDark;
      } else {
        paint.color = region.groundColor;
      }

      canvas.drawRect(ui.Rect.fromLTWH(i * px, -bladeH, px, bladeH + 4), paint);
    }

    // Grass highlight line
    paint.color = grassLight;
    canvas.drawRect(ui.Rect.fromLTWH(0, 0, size.x, px), paint);

    // Stone wall section (below grass)
    final stoneY = grassH;
    final stoneH = size.y - grassH;

    // Base stone color
    paint.color = region.groundAccentColor;
    canvas.drawRect(ui.Rect.fromLTWH(0, stoneY, size.x, stoneH), paint);

    // Draw stone brick pattern
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
      (region.groundAccentColor.red * 0.8).round().clamp(0, 255),
      (region.groundAccentColor.green * 0.8).round().clamp(0, 255),
      (region.groundAccentColor.blue * 0.8).round().clamp(0, 255),
    );
    final stoneMortar = ui.Color.fromARGB(255,
      (region.groundAccentColor.red * 0.6).round().clamp(0, 255),
      (region.groundAccentColor.green * 0.6).round().clamp(0, 255),
      (region.groundAccentColor.blue * 0.6).round().clamp(0, 255),
    );

    for (var r = 0; r < rows; r++) {
      final rowOffset = (r % 2 == 0) ? 0.0 : brickW * 0.5; // offset alternate rows
      for (var c = -1; c < cols; c++) {
        final bx = c * brickW + rowOffset;
        final by = stoneY + r * brickH;

        // Mortar (gap between bricks)
        paint.color = stoneMortar;
        canvas.drawRect(ui.Rect.fromLTWH(bx, by, brickW, brickH), paint);

        // Brick face (inset by 1px for mortar lines)
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

        // Highlight on top-left of each brick
        paint.color = stoneLight.withAlpha(80);
        canvas.drawRect(ui.Rect.fromLTWH(bx + 1, by + 1, brickW - 2, 2), paint);

        // Shadow on bottom of each brick
        paint.color = stoneDark.withAlpha(60);
        canvas.drawRect(ui.Rect.fromLTWH(bx + 1, by + brickH - 3, brickW - 2, 2), paint);
      }
    }
  }
}
