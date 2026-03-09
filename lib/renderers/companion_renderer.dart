import 'dart:math';
import 'dart:ui';

import '../utils/pixel_art.dart';

class CompanionRenderer {
  static void render(Canvas canvas, String id, Size size, double animTimer) {
    final frame = (animTimer * 4).toInt() % 2;
    final data = _getSpriteData(id, frame);
    if (data.frames.isEmpty) return;

    final spriteW = data.frames[0].length;
    final spriteH = data.frames.length;
    final px = min(size.width / spriteW, size.height / spriteH);

    PixelArt.drawCentered(canvas, data.frames, data.palette, size, pixelSize: px);
  }

  static _SpriteData _getSpriteData(String id, int frame) {
    switch (id) {
      case 'cat': return _catSprite(frame);
      case 'hamster': return _hamsterSprite(frame);
      case 'rabbit': return _rabbitSprite(frame);
      case 'owl': return _owlSprite();
      case 'fox': return _foxSprite(frame);
      case 'penguin': return _penguinSprite(frame);
      case 'wolf_c': return _wolfSprite(frame);
      case 'unicorn': return _unicornSprite(frame);
      case 'dragon_c': return _dragonSprite(frame);
      case 'phoenix_c': return _phoenixSprite(frame);
      default: return _catSprite(frame);
    }
  }

  static _SpriteData _catSprite(int frame) {
    return _SpriteData(frame == 0 ? [
      '.ee...ee.',
      '.eOOOOOe.',
      '.OOOOOOO.',
      '.OOEEOEO.',
      '.OOONOOOO',
      '.OOOOOOO.',
      'OOOOOOOOO',
      'OOOOOOOO.',
      '.OO..OO..',
      '.OO..OO..',
    ] : [
      '.ee...ee.',
      '.eOOOOOe.',
      '.OOOOOOO.',
      '.OOEEOEO.',
      '.OOONOOOO',
      '.OOOOOOO.',
      'OOOOOOOOO',
      'OOOOOOOO.',
      'OO....OO.',
      'OO....OO.',
    ], {
      'O': const Color(0xFFFF9800),
      'e': const Color(0xFFFFE0B2),
      'E': const Color(0xFF333333),
      'N': const Color(0xFFFF8A65),
    });
  }

  static _SpriteData _hamsterSprite(int frame) {
    return _SpriteData([
      '..ee..ee..',
      '..eHHHHe..',
      '.HHHHHHHH.',
      '.HcHEEHcH.',
      '.HHHHNHHH.',
      '.HcHHHHcH.',
      '..HHHHHH..',
      '...HHHH...',
    ], {
      'H': const Color(0xFFFFCC80),
      'e': const Color(0xFFFFAB91),
      'c': const Color(0xFFFFE0B2),
      'E': const Color(0xFF333333),
      'N': const Color(0xFFFF8A65),
    });
  }

  static _SpriteData _rabbitSprite(int frame) {
    return _SpriteData(frame == 0 ? [
      '..ii.ii..',
      '..iR.Ri..',
      '..RRRRR..',
      '.RRRRRR..',
      '.RREERR..',
      '.RRNRRR..',
      '.RRRRRRR.',
      'RRRRRRR..',
      '.RR..RR..',
      '.RR..RR..',
    ] : [
      '..ii.ii..',
      '..iR.Ri..',
      '..RRRRR..',
      '.RRRRRR..',
      '.RREERR..',
      '.RRNRRR..',
      '.RRRRRRR.',
      'RRRRRRR..',
      'RR....RR.',
      'RR....RR.',
    ], {
      'R': const Color(0xFFF5F5F5),
      'i': const Color(0xFFFFCDD2),
      'E': const Color(0xFFE53935),
      'N': const Color(0xFFFFCDD2),
    });
  }

  static _SpriteData _owlSprite() {
    return _SpriteData([
      '..e.....e..',
      '..eBBBBBe..',
      '..BBBBBBB..',
      '.BBYYBBYY..',
      '.BBEPPEPPB.',
      '.BBBBOBBBB.',
      '..BbbbbbB..',
      '..BBBBBBB..',
      '...BBBBB...',
      '...ff.ff...',
    ], {
      'B': const Color(0xFF8D6E63),
      'e': const Color(0xFF8D6E63),
      'Y': const Color(0xFFFFD600),
      'P': const Color(0xFF1A1A1A),
      'E': const Color(0xFFFFD600),
      'b': const Color(0xFFD7CCC8),
      'O': const Color(0xFFFFB300),
      'f': const Color(0xFFFFCC80),
    });
  }

  static _SpriteData _foxSprite(int frame) {
    return _SpriteData(frame == 0 ? [
      '.ee...ee....',
      '.eFFFFFe....',
      '.FFFFFFFW...',
      '.FFEEFFFFF..',
      '.FFnFFFFFF..',
      '.FFwwFFFFFF.',
      'FFFFFFFFFFFF',
      'FFFFFFFFFFF.',
      '.FF.....FF..',
      '.FF.....FF..',
    ] : [
      '.ee...ee....',
      '.eFFFFFe....',
      '.FFFFFFFW...',
      '.FFEEFFFFF..',
      '.FFnFFFFFF..',
      '.FFwwFFFFFF.',
      'FFFFFFFFFFFF',
      'FFFFFFFFFFF.',
      'FF.......FF.',
      'FF.......FF.',
    ], {
      'F': const Color(0xFFFF5722),
      'e': const Color(0xFFFF5722),
      'E': const Color(0xFF333333),
      'n': const Color(0xFF333333),
      'w': const Color(0xFFFFCCBC),
      'W': const Color(0xFFFFFFFF),
    });
  }

  static _SpriteData _penguinSprite(int frame) {
    return _SpriteData(frame == 0 ? [
      '...BBBB...',
      '..BBBBBB..',
      '..BBEEBB..',
      '..BBBBBB..',
      '..BBooBB..',
      '.BBwwwwBB.',
      '.BBwwwwBB.',
      '..BwwwwB..',
      '..BBBBBB..',
      '...ff.ff..',
    ] : [
      '...BBBB...',
      '..BBBBBB..',
      '..BBEEBB..',
      '..BBBBBB..',
      '..BBooBB..',
      '.BBwwwwBB.',
      '.BBwwwwBB.',
      '..BwwwwB..',
      '..BBBBBB..',
      '..ff..ff..',
    ], {
      'B': const Color(0xFF263238),
      'E': const Color(0xFFFFFFFF),
      'w': const Color(0xFFECEFF1),
      'o': const Color(0xFFFF9800),
      'f': const Color(0xFFFF9800),
    });
  }

  static _SpriteData _wolfSprite(int frame) {
    return _SpriteData(frame == 0 ? [
      '..ee..ee.......',
      '..WWWWWWW......',
      '.WWWWWWWWW.....',
      '.WWEYWWWWW.....',
      '.WWWWWWWWWWW...',
      '.WWWWWWWmmWWW..',
      'WWWWWWWWWWWWWW.',
      'WWWWWWWWWWWWW..',
      '.WW.......WW...',
      '.WW.......WW...',
    ] : [
      '..ee..ee.......',
      '..WWWWWWW......',
      '.WWWWWWWWW.....',
      '.WWEYWWWWW.....',
      '.WWWWWWWWWWW...',
      '.WWWWWWWmmWWW..',
      'WWWWWWWWWWWWWW.',
      'WWWWWWWWWWWWW..',
      'WW.........WW..',
      'WW.........WW..',
    ], {
      'W': const Color(0xFF546E7A),
      'e': const Color(0xFF546E7A),
      'E': const Color(0xFFFFEB3B),
      'Y': const Color(0xFFFFEB3B),
      'm': const Color(0xFFB0BEC5),
    });
  }

  static _SpriteData _unicornSprite(int frame) {
    return _SpriteData(frame == 0 ? [
      '....R........',
      '...RR........',
      '..RRUUUUU....',
      '..UUUpUUU....',
      '..UUEUUUUU...',
      '.UUUUUUmUUU..',
      '.UUmUUUUUUU..',
      'UUUUUUUUUUUU.',
      'UUUUUUUUUUU..',
      '.UU......UU...',
      '.UU......UU...',
    ] : [
      '....R........',
      '...RR........',
      '..RRUUUUU....',
      '..UUUpUUU....',
      '..UUEUUUUU...',
      '.UUUUUUmUUU..',
      '.UUmUUUUUUU..',
      'UUUUUUUUUUUU.',
      'UUUUUUUUUUU..',
      'UU........UU..',
      'UU........UU..',
    ], {
      'U': const Color(0xFFF3E5F5),
      'R': const Color(0xFFE040FB),
      'p': const Color(0xFFCE93D8),
      'E': const Color(0xFF7B1FA2),
      'm': const Color(0xFFCE93D8),
    });
  }

  static _SpriteData _dragonSprite(int frame) {
    return _SpriteData(frame == 0 ? [
      '..hh..hh........',
      '..DDDDDDD.......',
      '.DDDDDDDDD......',
      '.DDDyDDDDDD.....',
      '.wwDDDDDDDDDDD..',
      '.wwDDDbbbDDDDD..',
      '..DDDDDDDDDDDDD.',
      '..DDDDDDDDDDDDD.',
      '...DDDDDDDDDDDD.',
      '..DD.......DD....',
      '..DD.......DD....',
    ] : [
      '..hh..hh........',
      '..DDDDDDD.......',
      '.DDDDDDDDD......',
      '.DDDyDDDDDD.....',
      '..wDDDDDDDDDDD..',
      '..wDDDbbbDDDDD..',
      'wwDDDDDDDDDDDDD.',
      '..DDDDDDDDDDDDD.',
      '...DDDDDDDDDDDD.',
      '.DD.........DD...',
      '.DD.........DD...',
    ], {
      'D': const Color(0xFFD32F2F),
      'h': const Color(0xFFFFCDD2),
      'y': const Color(0xFFFFD600),
      'b': const Color(0xFFFF8A65),
      'w': const Color(0xFFEF5350),
    });
  }

  static _SpriteData _phoenixSprite(int frame) {
    return _SpriteData(frame == 0 ? [
      '....cc........',
      '...cFFFFc.....',
      '..wFFFFFFw....',
      '.wwFFEFFFww...',
      '.wFFFFFFFFFw..',
      '..FFFFFFFFFFF.',
      '...FFFfFFF....',
      '....FfFfF.....',
      '.....fFf......',
      '......f.......',
    ] : [
      '...............',
      '..wFFFFFFw.....',
      '.wwFFFFFww.....',
      '.wFFFEFFFFw....',
      '..FFFFFFFFFF...',
      '...FFFFFFFFFFF.',
      '....FFFfFFF....',
      '.....FfFfF.....',
      'ww....fFf....ww',
      '......f........',
    ], {
      'F': const Color(0xFFFF6F00),
      'c': const Color(0xFFFFD600),
      'w': const Color(0xFFFF8F00),
      'E': const Color(0xFFFFFFFF),
      'f': const Color(0xFFFFD600),
    });
  }
}

class _SpriteData {
  final List<String> frames;
  final Map<String, Color> palette;
  _SpriteData(this.frames, this.palette);
}
