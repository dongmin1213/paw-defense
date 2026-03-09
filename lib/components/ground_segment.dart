import 'dart:ui' as ui;
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
      // Tile the 32x16 image across the segment
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
      // Fallback solid color
      canvas.drawRect(
        ui.Rect.fromLTWH(0, 0, size.x, size.y),
        ui.Paint()..color = region.groundColor,
      );
    }
  }
}
