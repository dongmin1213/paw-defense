import 'dart:ui';
import 'dart:math';
import '../utils/pixel_art.dart';

/// Pixel art renderer for the castle wall / fortress.
/// All static methods, no instances.
class WallRenderer {
  // Cached Paint objects to avoid per-frame allocation
  static final Paint _flagPaint = Paint()
    ..color = const Color(0xFFFF0000)
    ..isAntiAlias = false;
  static final Paint _hpBgPaint = Paint()
    ..color = const Color(0xFF424242)
    ..isAntiAlias = false;
  static final Paint _hpFillPaint = Paint()..isAntiAlias = false;
  static final Paint _hpBorderPaint = Paint()
    ..color = const Color(0xFF212121)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0
    ..isAntiAlias = false;

  /// Render the castle wall.
  /// [hpPercent] 0.0-1.0 controls color (green>yellow>red) and crack overlays.
  /// [level] adds visual flourishes (flags, bigger towers).
  static void render(Canvas canvas, Size size, {
    required double hpPercent,
    required double animTimer,
    int level = 1,
    bool isDamageFlash = false,
  }) {
    final hp = hpPercent.clamp(0.0, 1.0);

    // Choose sprite based on level
    final sprite = level >= 4
        ? _castleLv4
        : level >= 3
            ? _castleLv3
            : level >= 2
                ? _castleLv2
                : _castleLv1;

    // Build palette based on HP
    final palette = _buildPalette(hp);

    final spriteW = sprite[0].length;
    final spriteH = sprite.length;
    final px = min(size.width / spriteW, size.height / spriteH);

    PixelArt.drawCentered(canvas, sprite, palette, size, pixelSize: px);

    // Overlay cracks at low HP
    if (hp < 0.6) {
      final crackSprite = hp < 0.3 ? _cracksHeavy : _cracksLight;
      final crackPalette = <String, Color>{
        'x': const Color(0xFF3E2723),
        'X': const Color(0xFF212121),
      };
      PixelArt.drawCentered(canvas, crackSprite, crackPalette, size, pixelSize: px);
    }

    // Flag animation for level 3+
    if (level >= 3) {
      _drawFlag(canvas, size, animTimer, px, spriteW, spriteH);
    }

    // HP bar below the castle
    _drawHpBar(canvas, size, hp);
  }

  static Map<String, Color> _buildPalette(double hp) {
    // Stone wall color shifts from healthy gray to damaged red
    Color stoneMain;
    Color stoneDark;
    Color stoneLight;

    if (hp > 0.6) {
      // Healthy — gray stone
      stoneMain  = const Color(0xFF9E9E9E);
      stoneDark  = const Color(0xFF757575);
      stoneLight = const Color(0xFFBDBDBD);
    } else if (hp > 0.3) {
      // Damaged — yellowish
      stoneMain  = const Color(0xFFBCAAA4);
      stoneDark  = const Color(0xFF8D6E63);
      stoneLight = const Color(0xFFD7CCC8);
    } else {
      // Critical — reddish
      stoneMain  = const Color(0xFFBF7B6B);
      stoneDark  = const Color(0xFF8B4513);
      stoneLight = const Color(0xFFD4A08A);
    }

    return {
      'S': stoneMain,    // Stone
      'D': stoneDark,    // Dark stone / mortar
      'L': stoneLight,   // Light stone / highlight
      'W': const Color(0xFF5D4037),  // Wood (gate/door)
      'M': const Color(0xFF424242),  // Metal (portcullis)
      'F': const Color(0xFFFF0000),  // Flag red
      'f': const Color(0xFFFFEB3B),  // Flag gold
      'B': const Color(0xFF3E2723),  // Base / foundation
      'T': const Color(0xFF757575),  // Tower top
    };
  }

  // Level 1: Simple wall with gate
  static const _castleLv1 = [
    '.....SSSS.........SSSS.....',
    '....SSSSSS.......SSSSSS....',
    '....SSSSSS.......SSSSSS....',
    '....SSSSSS.......SSSSSS....',
    '.SSSDSSDSSDSSSSSDSSDSSDSS..',
    '.SSSSSSSSSSSSSSSSSSSSSSSSS.',
    '.SSSSSSSSSSSSSSSSSSSSSSSSS.',
    '.SSSDSSDSSSSSSSSSSDSSDSSS..',
    '.SSSSSSSSSSSSSSSSSSSSSSSSS.',
    '.SSSSSSSSSSSSSSSSSSSSSSSSS.',
    '.SSSSSSSSSSSSSSSSSSSSSSSSS.',
    '.SSSSSSSSSLWWWLSSSSSSSSSSS.',
    '.SSSSSSSSSWWWWWSSSSSSSSSS..',
    '.SSSSSSSSSWWWWWSSSSSSSSSS..',
    '.SSSSSSSSSWWWWWSSSSSSSSSS..',
    '.SSSSSSSSSMMMMMSSSSSSSSSSS.',
    'BBBBBBBBBBBBBBBBBBBBBBBBBBB',
    'BBBBBBBBBBBBBBBBBBBBBBBBBBB',
    'BBBBBBBBBBBBBBBBBBBBBBBBBBB',
    'BBBBBBBBBBBBBBBBBBBBBBBBBBB',
  ];

  // Level 2: Taller towers, thicker walls
  static const _castleLv2 = [
    '....LSSSSL.......LSSSSL....',
    '....SSSSSS.......SSSSSS....',
    '....SSSSSS.......SSSSSS....',
    '....SSSSSS.......SSSSSS....',
    '....SSSSSS.......SSSSSS....',
    '.SSSDSSDSSDSSSSSDSSDSSDSS..',
    '.SSSSSSSSSSSSSSSSSSSSSSSSS.',
    '.SSSSSSSSSSSSSSSSSSSSSSSSS.',
    '.SSSDSSDSSSSSSSSSSDSSDSSS..',
    '.SSSSSSSSSSSSSSSSSSSSSSSSS.',
    '.SSSSSSSSSSSSSSSSSSSSSSSSS.',
    '.SSSSSSSSSSSSSSSSSSSSSSSSS.',
    '.SSSSSSSSSLWWWLSSSSSSSSSSS.',
    '.SSSSSSSSSWWWWWSSSSSSSSSS..',
    '.SSSSSSSSSWWWWWSSSSSSSSSS..',
    '.SSSSSSSSSWWWWWSSSSSSSSSS..',
    '.SSSSSSSSSMMMMMSSSSSSSSSSS.',
    'BBBBBBBBBBBBBBBBBBBBBBBBBBB',
    'BBBBBBBBBBBBBBBBBBBBBBBBBBB',
    'BBBBBBBBBBBBBBBBBBBBBBBBBBB',
  ];

  // Level 3: Flags on towers, decorative battlements
  static const _castleLv3 = [
    '....F.............F........',
    '...FF............FF........',
    '....LSSSSL.......LSSSSL....',
    '....SSSSSS.......SSSSSS....',
    '....SSSSSS.......SSSSSS....',
    '....SSSSSS.......SSSSSS....',
    '.SSSDSSDSSDSSSSSDSSDSSDSS..',
    '.SSSSSSSSSSSSSSSSSSSSSSSSS.',
    '.SSLSSSSSSSSSSSSSSSSSLSSSS.',
    '.SSSDSSDSSSSSSSSSSDSSDSSS..',
    '.SSSSSSSSSSSSSSSSSSSSSSSSS.',
    '.SSSSSSSSSSSSSSSSSSSSSSSSS.',
    '.SSSSSSSSSLWWWLSSSSSSSSSSS.',
    '.SSSSSSSSSWWWWWSSSSSSSSSS..',
    '.SSSSSSSSSWWWWWSSSSSSSSSS..',
    '.SSSSSSSSSWWWWWSSSSSSSSSS..',
    '.SSSSSSSSSMMMMMSSSSSSSSSSS.',
    'BBBBBBBBBBBBBBBBBBBBBBBBBBB',
    'BBBBBBBBBBBBBBBBBBBBBBBBBBB',
    'BBBBBBBBBBBBBBBBBBBBBBBBBBB',
  ];

  // Level 4+: Grand castle with gold accents and center tower
  static const _castleLv4 = [
    '.............f.............',
    '............ff.............',
    '....F......LSSL......F.....',
    '...FF......SSSS.....FF.....',
    '....LSSSSL.SSSS.LSSSSL.....',
    '....SSSSSS.SSSS.SSSSSS.....',
    '....SSSSSS.SSSS.SSSSSS.....',
    '....SSSSSS.SSSS.SSSSSS.....',
    '.SSSDSSDSSDSSSSSDSSDSSDSS..',
    '.SSSSSSSSSSSSSSSSSSSSSSSSS.',
    '.SSLSSSSSSSSSSSSSSSSSLSSSS.',
    '.SSSDSSDSSSSSSSSSSDSSDSSS..',
    '.SSSSSSSSSSSSSSSSSSSSSSSSS.',
    '.SSSSSSSSSLWWWLSSSSSSSSSSS.',
    '.SSSSSSSSSWWWWWSSSSSSSSSS..',
    '.SSSSSSSSSWWWWWSSSSSSSSSS..',
    '.SSSSSSSSSMMMMMSSSSSSSSSSS.',
    'BBBBBBBBBBBBBBBBBBBBBBBBBBB',
    'BBBBBBBBBBBBBBBBBBBBBBBBBBB',
    'BBBBBBBBBBBBBBBBBBBBBBBBBBB',
  ];

  // Light cracks overlay (HP 30%-60%)
  static const _cracksLight = [
    '...........................',
    '...........................',
    '...........................',
    '...........................',
    '...........................',
    '...........................',
    '...........................',
    '...........................',
    '..........x................',
    '.........x.................',
    '........x...........x.....',
    '...........................',
    '...........................',
    '...........................',
    '...................x.......',
    '...........................',
    '...........................',
    '...........................',
    '...........................',
    '...........................',
  ];

  // Heavy cracks overlay (HP < 30%)
  static const _cracksHeavy = [
    '...........................',
    '...........................',
    '...........................',
    '...........................',
    '......x.........x.........',
    '.....x..........x.........',
    '....x............x........',
    '...........................',
    '..........x................',
    '.........xx..........x....',
    '........x..x........xx....',
    '.......x............x.....',
    '...........................',
    '....x.................x....',
    '...xx...........x...xx....',
    '..x..............x........',
    '...........................',
    '...X.............X.........',
    '...X.............X.........',
    '...........................',
  ];

  /// Draw a waving flag above tower positions.
  static void _drawFlag(Canvas canvas, Size size, double t, double px, int spriteW, int spriteH) {
    final offsetX = (size.width - spriteW * px) / 2;
    final offsetY = (size.height - spriteH * px) / 2;

    // Wave offset
    final wave = sin(t * 5) * px * 0.5;

    // Left tower flag position (col ~5, row ~0)
    final fx1 = offsetX + 5 * px;
    final fy1 = offsetY - 1 * px + wave;
    canvas.drawRect(Rect.fromLTWH(fx1, fy1, px * 3, px), _flagPaint);
    canvas.drawRect(Rect.fromLTWH(fx1, fy1 + px, px * 2, px), _flagPaint);
  }

  /// Draw a horizontal HP bar below the castle.
  static void _drawHpBar(Canvas canvas, Size size, double hp) {
    final barWidth = size.width * 0.8;
    final barHeight = 4.0;
    final barX = (size.width - barWidth) / 2;
    final barY = size.height - barHeight - 2;

    // Background
    canvas.drawRect(Rect.fromLTWH(barX, barY, barWidth, barHeight), _hpBgPaint);

    // Fill
    Color fillColor;
    if (hp > 0.6) {
      fillColor = const Color(0xFF4CAF50);
    } else if (hp > 0.3) {
      fillColor = const Color(0xFFFFEB3B);
    } else {
      fillColor = const Color(0xFFFF1744);
    }
    _hpFillPaint.color = fillColor;
    canvas.drawRect(Rect.fromLTWH(barX, barY, barWidth * hp, barHeight), _hpFillPaint);

    // Border
    canvas.drawRect(Rect.fromLTWH(barX, barY, barWidth, barHeight), _hpBorderPaint);
  }
}
