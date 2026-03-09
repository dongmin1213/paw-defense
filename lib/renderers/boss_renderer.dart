import 'dart:math';
import 'dart:ui';

import '../utils/pixel_art.dart';

class BossRenderer {
  static void render(Canvas canvas, String regionId, Size size, double animTimer) {
    final frame = (animTimer * 3).toInt() % 2;
    final data = _getSpriteData(regionId, frame);
    if (data.frames.isEmpty) return;

    final spriteW = data.frames[0].length;
    final spriteH = data.frames.length;
    final px = min(size.width / spriteW, size.height / spriteH);

    PixelArt.drawCentered(canvas, data.frames, data.palette, size, pixelSize: px);
  }

  static _SpriteData _getSpriteData(String regionId, int frame) {
    switch (regionId) {
      case 'meadow': return _kingSlime(frame);
      case 'forest': return _trent(frame);
      case 'desert': return _sphinx(frame);
      case 'snowfield': return _iceSerp(frame);
      case 'volcano': return _fireDragon(frame);
      default: return _kingSlime(frame);
    }
  }

  // King Slime — big bouncy slime with crown
  static _SpriteData _kingSlime(int frame) {
    return _SpriteData(frame == 0 ? [
      '..........CC.CC.CC..........',
      '..........CCCCCCCC..........',
      '..........CCCCCCCC..........',
      '.......GGGGGGGGGGGGGG.......',
      '......GGGGGGGGGGGGGGG.......',
      '.....GGGGGgGGGGGGGGGGG.....',
      '.....GGGGgGGGGGGGGGGGG.....',
      '....GGGGGGGGGGGGGGGGGGG....',
      '....GGGGwwEGGGwwEGGGGGG....',
      '....GGGGwwEGGGwwEGGGGGG....',
      '....GGGGGGGGMMGGGGGGGGG....',
      '.....GGGGGGGGGGGGGGGGG.....',
      '......GGGGGGGGGGGGGGG......',
      '.......GGGGGGGGGGGGG.......',
      '........GGGGGGGGGGG........',
      '..........GGGGGGG..........',
    ] : [
      '..........CC.CC.CC..........',
      '..........CCCCCCCC..........',
      '..........CCCCCCCC..........',
      '.......GGGGGGGGGGGGGG.......',
      '.....GGGGGGGGGGGGGGGGG.....',
      '....GGGGGgGGGGGGGGGGGGG....',
      '....GGGGgGGGGGGGGGGGGGG....',
      '...GGGGGGGGGGGGGGGGGGGGG....',
      '...GGGGwwEGGGwwEGGGGGGGG...',
      '...GGGGwwEGGGwwEGGGGGGGG...',
      '...GGGGGGGGGMMGGGGGGGGGG....',
      '....GGGGGGGGGGGGGGGGGGG.....',
      '.....GGGGGGGGGGGGGGGGG.....',
      '.......GGGGGGGGGGGGG.......',
      '..........GGGGGGG..........',
      '..........GGGGGGG..........',
    ], {
      'G': const Color(0xFF66BB6A),
      'g': const Color(0xFFA5D6A7),
      'C': const Color(0xFFFFD600),
      'E': const Color(0xFF1B5E20),
      'w': const Color(0xFFFFFFFF),
      'M': const Color(0xFF2E7D32),
    });
  }

  // Trent — tree monster
  static _SpriteData _trent(int frame) {
    return _SpriteData(frame == 0 ? [
      '........LLLLLL........',
      '......LLLLLLLLLL......',
      '.....LLLLLLLLLLLL.....',
      '....LLLLLLLLLLLLLL....',
      '......LLLLLLLLLL......',
      '.....LLLLLLLLLLLL.....',
      '......TTTTTTTT........',
      '......TTTTTTTT........',
      '......TTEEGTTT........',
      '......TTEEGTTT........',
      '......TTTTMTTT........',
      '......TTTTTTTT........',
      '.....TTTTTTTTTT.......',
      'rr..TTTTTTTTTTTT..rr..',
      '.rrTTTTTTTTTTTTrr....',
      '..rrrr......rrrr.....',
    ] : [
      '.......LLLLLL.........',
      '.....LLLLLLLLLL.......',
      '....LLLLLLLLLLLL......',
      '....LLLLLLLLLLLLLL....',
      '.....LLLLLLLLLLLL.....',
      '......LLLLLLLLLL......',
      '......TTTTTTTT........',
      '......TTTTTTTT........',
      '......TTEEGTTT........',
      '......TTEEGTTT........',
      '......TTTTMTTT........',
      '......TTTTTTTT........',
      '.....TTTTTTTTTT.......',
      '.rr.TTTTTTTTTTTT.rr...',
      '..rrTTTTTTTTTTTTrr....',
      '...rrrr......rrrr.....',
    ], {
      'L': const Color(0xFF388E3C),
      'T': const Color(0xFF6D4C41),
      'E': const Color(0xFFFFD600),
      'G': const Color(0xFF333333),
      'M': const Color(0xFF3E2723),
      'r': const Color(0xFF5D4037),
    });
  }

  // Sphinx
  static _SpriteData _sphinx(int frame) {
    return _SpriteData([
      '.......CCCCCC.........',
      '......CsCCCCsC........',
      '.....CCCCCCCCCC.......',
      '.....CCbbCCbbCC.......',
      '.....CCCCCCCCCC.......',
      '......CCCCCCCC........',
      '....BBBBBBBBBBBB......',
      '...BBBBBBBBBBBBBB.....',
      '..BBBBBBBBBBBBBBBB....',
      '..BBBBBBBBBBBBBBBB....',
      '..BBBBBBbbBBBBBBBB....',
      '..BBBBBBBBBBBBBBBB....',
      '.ppBBBBBBBBBBBBBBpp...',
      '.ppBBBBBBBBBBBBBBpp...',
    ], {
      'B': const Color(0xFFD4A574),
      'C': const Color(0xFFFFD600),
      's': const Color(0xFF1565C0),
      'b': const Color(0xFF00BCD4),
      'p': const Color(0xFFD4A574),
    });
  }

  // Ice Serpent
  static _SpriteData _iceSerp(int frame) {
    return _SpriteData(frame == 0 ? [
      '...hh....hh.........',
      '..IIIIIIIIII........',
      '.IIIIIIIwIIII.......',
      '.IIbIIIIIIIII.......',
      '.IIIIIIIIIIIII......',
      '..IIIIIIIIIII.......',
      '...IIIIIIIII........',
      '....IIIIIII.........',
      '.....IIIII..........',
      '......III...........',
      '.......I............',
    ] : [
      '....hh....hh........',
      '...IIIIIIIIII.......',
      '..IIIIIIIwIIII......',
      '..IIbIIIIIIIII.....',
      '..IIIIIIIIIIIII.....',
      '...IIIIIIIIIII......',
      '....IIIIIIIII.......',
      '.....IIIIIII........',
      '......IIIII.........',
      '.......III..........',
      '........I...........',
    ], {
      'I': const Color(0xFFB3E5FC),
      'h': const Color(0xFF81D4FA),
      'b': const Color(0xFF0288D1),
      'w': const Color(0xFFFFFFFF),
    });
  }

  // Fire Dragon
  static _SpriteData _fireDragon(int frame) {
    return _SpriteData(frame == 0 ? [
      '.....hh......hh.........',
      '.....DDDDDDDDDDD........',
      '....DDDDDDDDDDDDD.......',
      '....DDDyDDDDyDDDDD.......',
      '....DDDDDDDDDDDDDDD.....',
      'wwwwDDDDDbbbbDDDDDDD.....',
      '.wwwDDDDDDDDDDDDDDDDDD...',
      '....DDDDDDDDDDDDDDDDDDff.',
      '.....DDDDDDDDDDDDDDDFF..',
      '......DDDDDDDDDDDDDDDf...',
      '.......DDDDDDDDDDDDD....',
      '........DDD....DDDD.....',
      '........DDD....DDDD.....',
    ] : [
      '.....hh......hh............',
      '.....DDDDDDDDDDD...........',
      '....DDDDDDDDDDDDD..........',
      '....DDDyDDDDyDDDDD..........',
      '....DDDDDDDDDDDDDDD........',
      '.wwwDDDDDbbbbDDDDDDD........',
      'wwwwDDDDDDDDDDDDDDDDDD..fff.',
      '....DDDDDDDDDDDDDDDDDDffff..',
      '.....DDDDDDDDDDDDDDDDDff....',
      '......DDDDDDDDDDDDDDD......',
      '.......DDDDDDDDDDDDD.......',
      '........DDD.....DDDD.......',
      '........DDD.....DDDD.......',
    ], {
      'D': const Color(0xFFD32F2F),
      'h': const Color(0xFF4E342E),
      'y': const Color(0xFFFFD600),
      'b': const Color(0xFFFF8A65),
      'w': const Color(0xFFBF360C),
      'f': const Color(0xFFFF9800),
    });
  }
}

class _SpriteData {
  final List<String> frames;
  final Map<String, Color> palette;
  _SpriteData(this.frames, this.palette);
}
