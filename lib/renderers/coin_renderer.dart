import 'dart:ui';
import 'dart:math';
import '../utils/pixel_art.dart';

class CoinRenderer {
  // Big detailed coin sprite (12x12 pixels)
  static const _coin1 = [
    '....OOOO....',
    '..OOyyyyOO..',
    '.OyyyYYyyyO.',
    'OyyYYYYYYyyO',
    'OyYYYsYYYYyO',
    'OyYYYYYYYYyO',
    'OyYYYYYYYYyO',
    'OyYYYYsYYYyO',
    'OyyYYYYYYyyO',
    '.OyyyYYyyyO.',
    '..OOyyyyOO..',
    '....OOOO....',
  ];

  // Alternate frame for rotation effect
  static const _coin2 = [
    '....OOOO....',
    '..OOyyyyOO..',
    '.OyyyYYyyyO.',
    'OyyYYYYYYyyO',
    'OyYYYYYsYYyO',
    'OyYYYYYYYYyO',
    'OyYYYYYYYYyO',
    'OyYYsYYYYYyO',
    'OyyYYYYYYyyO',
    '.OyyyYYyyyO.',
    '..OOyyyyOO..',
    '....OOOO....',
  ];

  static const _palette = {
    'O': Color(0xFF8B6914), // Dark outline
    'y': Color(0xFFDAA520), // Mid gold
    'Y': Color(0xFFFFD700), // Bright gold
    's': Color(0xFFFFECB3), // Shine highlight
  };

  static const _goldenPalette = {
    'O': Color(0xFF6B4E00), // Darker outline
    'y': Color(0xFFFFB300), // Mid gold brighter
    'Y': Color(0xFFFFD740), // Even brighter
    's': Color(0xFFFFFFFF), // White shine
  };

  static void render(Canvas canvas, Size size, {required double animTimer, bool isGolden = false}) {
    final frame = (animTimer * 3).toInt() % 2;
    final sprite = frame == 0 ? _coin1 : _coin2;
    final palette = isGolden ? _goldenPalette : _palette;

    final spriteW = sprite[0].length;
    final spriteH = sprite.length;
    final px = min(size.width / spriteW, size.height / spriteH);

    // Glow for golden
    if (isGolden) {
      PixelArt.drawGlow(canvas, size, const Color(0x40FFD700), size.width * 0.5);
    }

    PixelArt.drawCentered(canvas, sprite, palette, size, pixelSize: px);
  }
}
