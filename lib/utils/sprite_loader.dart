import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/flame.dart';

/// Loads sprite sheets and creates sprite animations.
class SpriteLoader {
  static final Map<String, ui.Image> _cache = {};

  /// Load an image and cache it.
  static Future<ui.Image> loadImage(String path) async {
    if (_cache.containsKey(path)) return _cache[path]!;
    final image = await Flame.images.load(path);
    _cache[path] = image;
    return image;
  }

  /// Create a SpriteAnimation from a horizontal sprite sheet.
  /// [path] - asset path (e.g. 'bichon.png')
  /// [frameWidth], [frameHeight] - size of each frame
  /// [frameCount] - total frames in the sheet
  /// [stepTime] - seconds per frame
  /// [startFrame] - first frame index (for sub-animations)
  /// [loop] - whether animation loops
  static Future<SpriteAnimation> loadAnimation(
    String path, {
    required double frameWidth,
    required double frameHeight,
    required int frameCount,
    double stepTime = 0.15,
    int startFrame = 0,
    bool loop = true,
  }) async {
    final image = await loadImage(path);
    final sprites = <Sprite>[];
    for (var i = startFrame; i < startFrame + frameCount; i++) {
      sprites.add(Sprite(
        image,
        srcPosition: Vector2(i * frameWidth, 0),
        srcSize: Vector2(frameWidth, frameHeight),
      ));
    }
    return SpriteAnimation.spriteList(sprites, stepTime: stepTime, loop: loop);
  }

  /// Create a single Sprite from a sheet at given frame index.
  static Future<Sprite> loadSprite(
    String path, {
    required double frameWidth,
    required double frameHeight,
    int frameIndex = 0,
  }) async {
    final image = await loadImage(path);
    return Sprite(
      image,
      srcPosition: Vector2(frameIndex * frameWidth, 0),
      srcSize: Vector2(frameWidth, frameHeight),
    );
  }
}
