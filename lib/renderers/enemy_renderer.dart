import 'dart:ui';
import 'dart:math';
import '../data/enemy_data.dart';
import '../utils/pixel_art.dart';

class EnemyRenderer {
  static void render(Canvas canvas, Size size, EnemyData data, {required double animTimer, bool isHit = false, bool isGolden = false}) {
    if (isGolden && !isHit) {
      PixelArt.drawGlow(canvas, size, const Color(0x40FFD600), size.width * 0.5);
    }

    // Get sprite and palette for this enemy
    final spriteData = _getSpriteData(data.id, animTimer);
    final palette = isHit
        ? _whitePalette(spriteData.palette)
        : (isGolden ? _goldenPalette(spriteData.palette) : spriteData.palette);

    final sprite = spriteData.frames;
    if (sprite.isEmpty) return;

    final spriteW = sprite[0].length;
    final spriteH = sprite.length;
    final px = min(size.width / spriteW, size.height / spriteH);

    PixelArt.drawCentered(canvas, sprite, palette, size, pixelSize: px);
  }

  static Map<String, Color> _whitePalette(Map<String, Color> original) {
    return original.map((k, v) => MapEntry(k, const Color(0xFFFFFFFF)));
  }

  static Map<String, Color> _goldenPalette(Map<String, Color> original) {
    return original.map((k, v) {
      final brightness = (v.red * 0.299 + v.green * 0.587 + v.blue * 0.114) / 255;
      if (brightness < 0.3) return MapEntry(k, const Color(0xFFB8860B)); // dark gold
      if (brightness < 0.6) return MapEntry(k, const Color(0xFFDAA520)); // gold
      return MapEntry(k, const Color(0xFFFFD700)); // bright gold
    });
  }

  static _SpriteData _getSpriteData(String id, double t) {
    final frame = (t * 4).toInt() % 2;
    switch (id) {
      case 'slime': return _slimeSprite(frame);
      case 'mushroom': return _mushroomSprite();
      case 'bird': return _birdSprite(frame);
      case 'butterfly': return _butterflySprite(frame);
      case 'goblin': return _goblinSprite(frame);
      case 'spider': return _spiderSprite(frame);
      case 'bat': return _batSprite(frame);
      case 'fairy': return _fairySprite(frame);
      case 'scorpion': return _scorpionSprite(frame);
      case 'mummy': return _mummySprite(frame);
      case 'eagle': return _eagleSprite(frame);
      case 'sand_spirit': return _spiritSprite(const Color(0xFFFFC107), frame);
      case 'snow_golem': return _golemSprite();
      case 'wolf': return _wolfSprite(frame);
      case 'snow_owl': return _owlSprite();
      case 'ice_spirit': return _spiritSprite(const Color(0xFF81D4FA), frame);
      case 'fire_imp': return _impSprite(frame);
      case 'dragonkin': return _dragonkinSprite(frame);
      case 'fire_bat': return _fireBatSprite(frame);
      case 'phoenix': return _phoenixSprite(frame);
      default: return _slimeSprite(frame);
    }
  }

  // ========== MEADOW ==========

  static _SpriteData _slimeSprite(int frame) {
    final sprites = frame == 0 ? [
      '....GGGG....',
      '..GGGGGGGG..',
      '.GGGgGGGGGG.',
      '.GGgGGGGGGG.',
      'GGGGEEGEEGGG',
      'GGGGGGGGGGG.',
      '.GGGGMMGGGG.',
      '..GGGGGGGG..',
      '...GGGGGG...',
      '....GGGG....',
    ] : [
      '....GGGG....',
      '..GGGGGGGG..',
      '.GGGgGGGGGG.',
      '.GGgGGGGGGG.',
      'GGGGEEGEEGGG',
      'GGGGGGGGGGG.',
      '.GGGGMMGGGG.',
      '..GGGGGGGG..',
      '..GGGGGGGG..',
      '.GGGGGGGGGG.',
    ];
    return _SpriteData(sprites, {
      'G': const Color(0xFF4CAF50),
      'g': const Color(0xFF81C784),
      'E': const Color(0xFF1A1A1A),
      'M': const Color(0xFF2E7D32),
    });
  }

  static _SpriteData _mushroomSprite() {
    return _SpriteData([
      '....RRRRRR....',
      '..RRRrRRrRRR..',
      '.RRRRrRRRrRRR.',
      'RRRRRRRRRRRRRR',
      '......SSSS....',
      '......SSSS....',
      '.....EESEESS..',
      '......SSSS....',
      '......SSSS....',
      '......SSSS....',
      '.....SSSSSS...',
    ], {
      'R': const Color(0xFFE57373),
      'r': const Color(0xFFFFCDD2),
      'S': const Color(0xFFF5E6D0),
      'E': const Color(0xFF1A1A1A),
    });
  }

  static _SpriteData _birdSprite(int frame) {
    final sprites = frame == 0 ? [
      '..........BB..',
      '.....BBBBBBB..',
      '...BBBBBBBBBo.',
      '..wBBBEBBBBBo.',
      '.wwBBBBBBBBB..',
      '..wBBBBBBBBB..',
      '...BBBBBBBBB..',
      '....BBBBB.....',
    ] : [
      '..ww..........',
      '..wwBBBBBBBB..',
      '...BBBBBBBBBo.',
      '....BBEBBBBBo.',
      '....BBBBBBBB..',
      '...BBBBBBBBB..',
      '....BBBBB.....',
      '...............',
    ];
    return _SpriteData(sprites, {
      'B': const Color(0xFF42A5F5),
      'w': const Color(0xFF90CAF9),
      'E': const Color(0xFF1A1A1A),
      'o': const Color(0xFFFF9800),
    });
  }

  static _SpriteData _butterflySprite(int frame) {
    final sprites = frame == 0 ? [
      '.PP...PP.',
      'PPPP.PPPP',
      'PPpP.PpPP',
      'PPPP.PPPP',
      '.PP.B.PP.',
      '....B....',
      '...BBB...',
      'a..B.B..a',
    ] : [
      '....B....',
      '.PP.B.PP.',
      'PPpP.PpPP',
      'PPPP.PPPP',
      '.PP.B.PP.',
      '....B....',
      '...BBB...',
      'a..B.B..a',
    ];
    return _SpriteData(sprites, {
      'P': const Color(0xFFCE93D8),
      'p': const Color(0xFFF3E5F5),
      'B': const Color(0xFF4A4A4A),
      'a': const Color(0xFFCE93D8),
    });
  }

  // ========== FOREST ==========

  static _SpriteData _goblinSprite(int frame) {
    final sprites = frame == 0 ? [
      '..e.....e..',
      '.eee...eee.',
      '..GGGGGGG..',
      '.GGGGGGGGG.',
      '.GGREEREGGG',
      '.GGGGGGGGG.',
      '.GGGMMGGGG.',
      '..GGGGGGG..',
      '..GGGGGGG..',
      '..GG...GG..',
      '..GG...GG..',
    ] : [
      '..e.....e..',
      '.eee...eee.',
      '..GGGGGGG..',
      '.GGGGGGGGG.',
      '.GGREEREGGG',
      '.GGGGGGGGG.',
      '.GGGMMGGGG.',
      '..GGGGGGG..',
      '..GGGGGGG..',
      '.GG.....GG.',
      '.GG.....GG.',
    ];
    return _SpriteData(sprites, {
      'G': const Color(0xFF558B2F),
      'e': const Color(0xFF8BC34A),
      'E': const Color(0xFFFF0000),
      'R': const Color(0xFFFF0000),
      'M': const Color(0xFF33691E),
    });
  }

  static _SpriteData _spiderSprite(int frame) {
    final f = frame == 0;
    return _SpriteData([
      f ? 'l...BBBB...l' : '.l..BBBB..l.',
      f ? '.l.BBBBBB.l.' : 'l..BBBBBB..l',
      f ? '..lBrBBrBl..' : '..lBrBBrBl..',
      f ? 'l.BBBBBBBB.l' : '.lBBBBBBBB.l',
      f ? '.l.BBBBBB.l.' : 'l..BBBBBB..l',
      f ? '..l.BBBB.l..' : '..l.BBBB.l..',
    ], {
      'B': const Color(0xFF4E342E),
      'r': const Color(0xFFFF0000),
      'l': const Color(0xFF795548),
    });
  }

  static _SpriteData _batSprite(int frame) {
    final sprites = frame == 0 ? [
      'ww......ww',
      '.wwBBBBww.',
      '..wBBBBw..',
      '..BBEEBB..',
      '..BBBBBB..',
      '...BBBB...',
    ] : [
      '...........',
      '..wBBBBw...',
      '.wwBBBBww..',
      '.wBBEEBBw..',
      '..BBBBBB...',
      '...BBBB....',
      'ww......ww.',
    ];
    return _SpriteData(sprites, {
      'B': const Color(0xFF37474F),
      'w': const Color(0xFF78909C),
      'E': const Color(0xFFFF5252),
    });
  }

  static _SpriteData _fairySprite(int frame) {
    return _SpriteData([
      '...*..*..',
      '.www.www.',
      '.wwwYwww.',
      '..wYYYw..',
      '..YYEYY..',
      '..wYYYw..',
      '.wwwYwww.',
      '.www.www.',
      '...*..*..',
    ], {
      'Y': const Color(0xFFFFEB3B),
      'w': const Color(0xFFFFF9C4),
      'E': const Color(0xFF7B1FA2),
      '*': const Color(0xFFFFFFFF),
    });
  }

  // ========== DESERT ==========

  static _SpriteData _scorpionSprite(int frame) {
    final sprites = frame == 0 ? [
      '..r.............',
      '..BB............',
      '...BB...........',
      '....BB..........',
      '....BBBBBBBBB...',
      '...BBBBEBBbBBcc.',
      '...BBBBBBBBB.cc.',
      '....BBBBBBB.....',
    ] : [
      '.r..............',
      '..BB............',
      '...BB...........',
      '....BB..........',
      '....BBBBBBBBB...',
      '...BBBBEBBbBBcc.',
      '...BBBBBBBBB.cc.',
      '....BBBBBBB.....',
    ];
    return _SpriteData(sprites, {
      'B': const Color(0xFFBF360C),
      'b': const Color(0xFFFF8A65),
      'E': const Color(0xFF1A1A1A),
      'r': const Color(0xFFFF0000),
      'c': const Color(0xFFBF360C),
    });
  }

  static _SpriteData _mummySprite(int frame) {
    final sprites = frame == 0 ? [
      '...MMMM...',
      '..MMMMMM..',
      '..MGEMGM..',
      '..MMMMMM..',
      '..bMMMMb..',
      '..MMMMMM..',
      '..bMMMMb..',
      '..MMMMMM..',
      '..bMMMMb..',
      '..MMMMMM..',
      '..MM..MM..',
      '..MM..MM..',
    ] : [
      '...MMMM...',
      '..MMMMMM..',
      '..MGEMGM..',
      '..MMMMMM..',
      '..bMMMMb..',
      '..MMMMMM..',
      '..bMMMMb..',
      '..MMMMMM..',
      '..bMMMMb..',
      '..MMMMMM..',
      '.MM....MM.',
      '.MM....MM.',
    ];
    return _SpriteData(sprites, {
      'M': const Color(0xFFD7CCC8),
      'b': const Color(0xFF8D6E63),
      'G': const Color(0xFF00E676),
      'E': const Color(0xFF00E676),
    });
  }

  static _SpriteData _eagleSprite(int frame) {
    final sprites = frame == 0 ? [
      'ww..........ww',
      '.wwBBBBBBBBww.',
      '..wBBBBBBBBw..',
      '...BBBEBBBBB.o',
      '...BBBBBBBBBo.',
      '....BBBBBBB...',
      '.....BBBBB....',
    ] : [
      '...............',
      '..wBBBBBBBBw...',
      '.wwBBBBBBBBww..',
      '.wBBBEBBBBBBwo.',
      '..BBBBBBBBBBo..',
      '....BBBBBBB....',
      'ww..BBBBB..ww..',
    ];
    return _SpriteData(sprites, {
      'B': const Color(0xFF5D4037),
      'w': const Color(0xFFA1887F),
      'E': const Color(0xFF1A1A1A),
      'o': const Color(0xFFFF9800),
    });
  }

  static _SpriteData _spiritSprite(Color baseColor, int frame) {
    final light = Color.fromARGB(255,
      min(255, baseColor.red + 60),
      min(255, baseColor.green + 60),
      min(255, baseColor.blue + 60),
    );
    final dark = Color.fromARGB(255,
      (baseColor.red * 0.7).round(),
      (baseColor.green * 0.7).round(),
      (baseColor.blue * 0.7).round(),
    );
    return _SpriteData(frame == 0 ? [
      '*...CC...*',
      '..CCCCCC..',
      '.CCCcCCCC.',
      '.CCEECCCC.',
      '.CCCcCCCC.',
      '..CCCCCC..',
      '...CCCC...',
      '*........*',
    ] : [
      '...CC.....',
      '..CCCCCC..',
      '.CCCcCCCC.',
      '.CCEECCCC.',
      '.CCCcCCCC.',
      '..CCCCCC..',
      '...CCCC...',
      '.....*....',
    ], {
      'C': baseColor,
      'c': light,
      'E': const Color(0xFF1A1A1A),
      '*': light.withValues(alpha: 0.5),
    });
  }

  // ========== SNOWFIELD ==========

  static _SpriteData _golemSprite() {
    return _SpriteData([
      '....iiii....',
      '...GGGGGG...',
      '..GGGGGGGG..',
      '..GGEEGGGG..',
      '..GGGGGGGG..',
      '..GGGGGGGG..',
      '.GGGGGGGGGG.',
      '.GGGGGGGGGG.',
      'GGGGGGGGGGGG',
      'GGGGGGGGGGGG',
      'GGGGGGGGGGGG',
      '.GGG....GGG.',
      '.GGG....GGG.',
    ], {
      'G': const Color(0xFFE0E0E0),
      'i': const Color(0xFF90CAF9),
      'E': const Color(0xFF42A5F5),
    });
  }

  static _SpriteData _wolfSprite(int frame) {
    final sprites = frame == 0 ? [
      '....ee..ee.....',
      '....WWWWWW.....',
      '...WWWWWWWW....',
      '...WWEYWWWW....',
      '..WWWWWWWWWW...',
      '..WWWWWWWWmm...',
      '.WWWWWWWWWWWW..',
      '.WWWWWWWWWWWW..',
      '..WW......WW...',
      '..WW......WW...',
    ] : [
      '....ee..ee.....',
      '....WWWWWW.....',
      '...WWWWWWWW....',
      '...WWEYWWWW....',
      '..WWWWWWWWWW...',
      '..WWWWWWWWmm...',
      '.WWWWWWWWWWWW..',
      '.WWWWWWWWWWWW..',
      '.WW........WW..',
      '.WW........WW..',
    ];
    return _SpriteData(sprites, {
      'W': const Color(0xFF78909C),
      'e': const Color(0xFFB0BEC5),
      'E': const Color(0xFFFFEB3B),
      'Y': const Color(0xFFFFEB3B),
      'm': const Color(0xFFB0BEC5),
    });
  }

  static _SpriteData _owlSprite() {
    return _SpriteData([
      '..e.....e..',
      '..eWWWWWe..',
      '..WWWWWWW..',
      '.WWYYWWYYW.',
      '.WWEPPEPPW.',
      '.WWWWOWWWW.',
      '..WbbbbbW..',
      '..WWWWWWW..',
      '...WWWWW...',
      '...ff.ff...',
    ], {
      'W': const Color(0xFFF5F5F5),
      'e': const Color(0xFFBBDEFB),
      'Y': const Color(0xFFFFD600),
      'P': const Color(0xFF1A1A1A),
      'E': const Color(0xFFFFD600),
      'b': const Color(0xFFE0E0E0),
      'O': const Color(0xFFFF9800),
      'f': const Color(0xFFFFCC80),
    });
  }

  // ========== VOLCANO ==========

  static _SpriteData _impSprite(int frame) {
    final sprites = frame == 0 ? [
      '..h.....h..',
      '...hhhhh...',
      '..FFFFFFF..',
      '.FFFFFFFFF.',
      '.FFYYFFYYF.',
      '.FFFFFFFFF.',
      '.FFFMMFFFF.',
      '..FFFFFFF..',
      '..FFFFFFF..',
      '..FF...FF..',
      '..FF...FF..',
    ] : [
      '..h.....h..',
      '...hhhhh...',
      '..FFFFFFF..',
      '.FFFFFFFFF.',
      '.FFYYFFYYF.',
      '.FFFFFFFFF.',
      '.FFFMMFFFF.',
      '..FFFFFFF..',
      '..FFFFFFF..',
      '...FF.FF...',
      '..FF...FF..',
    ];
    return _SpriteData(sprites, {
      'F': const Color(0xFFFF5722),
      'h': const Color(0xFF4A0000),
      'Y': const Color(0xFFFFD600),
      'M': const Color(0xFFFF0000),
    });
  }

  static _SpriteData _dragonkinSprite(int frame) {
    return _SpriteData(frame == 0 ? [
      '..hh....hh.......',
      '..DDDDDDDDD......',
      '.DDDDDDDDDDD.....',
      '.DDDyDDDDDDD.....',
      '.DDDDDDDDDDDDD...',
      '..DDDbbbDDDDDDD..',
      '..DDDDDDDDDDDDDD.',
      '...DDDDDDDDDDDDD.',
      '....DDDDDDDDDDDD.',
      '...DD......DD.....',
      '...DD......DD.....',
    ] : [
      '..hh....hh........',
      '..DDDDDDDDD.......',
      '.DDDDDDDDDDD......',
      '.DDDyDDDDDDD......',
      '.DDDDDDDDDDDDD....',
      '..DDDbbbDDDDDDD...',
      '..DDDDDDDDDDDDDD..',
      '...DDDDDDDDDDDDD..',
      '....DDDDDDDDDDDD..',
      '..DD........DD.....',
      '..DD........DD.....',
    ], {
      'D': const Color(0xFFB71C1C),
      'h': const Color(0xFFEF5350),
      'y': const Color(0xFFFFD600),
      'b': const Color(0xFFFF8A65),
    });
  }

  static _SpriteData _fireBatSprite(int frame) {
    final sprites = frame == 0 ? [
      'ww........ww',
      '.wwFFFFFFww.',
      '..wFFFFFFw..',
      '..FFFEEFFF..',
      '..FFFFFFFF..',
      '...FFFFFF...',
    ] : [
      '.............',
      '..wFFFFFFw...',
      '.wwFFFFFFww..',
      '.wFFFEEFFFw..',
      '..FFFFFFFF...',
      '...FFFFFF....',
      'ww........ww.',
    ];
    return _SpriteData(sprites, {
      'F': const Color(0xFFFF6F00),
      'w': const Color(0xFFFFD54F),
      'E': const Color(0xFFFFFFFF),
    });
  }

  static _SpriteData _phoenixSprite(int frame) {
    final sprites = frame == 0 ? [
      '..cc............cc..',
      '..cFFFFFFFFFFFFFc...',
      '...FFFFFcFFFFFFF....',
      '....FFFFFFFFcFFF....',
      '....FFFFFEFFFFFF....',
      '....FFFFFFFcFFFF....',
      '.....FFFFFFFFFFF....',
      '......FFFfFFF.......',
      '.......FfFfF........',
      '........fFf.........',
      '.........f..........',
    ] : [
      '...............',
      '..cFFFFFFFFFc..',
      '.ccFFFFcFFFFcc.',
      '.cFFFFFFFFcFFc.',
      '..FFFFFEFFFF...',
      '..FFFFFFFcFFF..',
      '...FFFFFFFFFFF.',
      '....FFFfFFF....',
      '.....FfFfF.....',
      'cc....fFf....cc',
      '......f........',
    ];
    return _SpriteData(sprites, {
      'F': const Color(0xFFFF8F00),
      'c': const Color(0xFFFFECB3),
      'f': const Color(0xFFFFD600),
      'E': const Color(0xFF1A1A1A),
    });
  }
}

class _SpriteData {
  final List<String> frames;
  final Map<String, Color> palette;
  _SpriteData(this.frames, this.palette);
}
