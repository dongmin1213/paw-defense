import 'dart:ui';
import 'dart:math';
import '../utils/pixel_art.dart';

/// Pixel art renderer for 8 castle defense enemy types.
/// All static methods, no instances.
class DefenseEnemyRenderer {
  /// Render an enemy by id.
  /// [isHit] flashes the sprite white.
  /// [isBoss] renders the sprite larger.
  static void render(Canvas canvas, Size size, {
    required String enemyId,
    required double animTimer,
    bool isHit = false,
    bool isBoss = false,
    bool isFlying = false,
    double hpPercent = 1.0,
  }) {
    final frame = (animTimer * 4).toInt() % 2;
    final data = _getSpriteData(enemyId, frame);
    if (data.frames.isEmpty) return;

    final palette = isHit ? _whitePalette(data.palette) : data.palette;

    final spriteW = data.frames[0].length;
    final spriteH = data.frames.length;
    final basePx = min(size.width / spriteW, size.height / spriteH);
    final px = isBoss ? basePx * 1.3 : basePx;

    if (isBoss && !isHit) {
      PixelArt.drawGlow(canvas, size, const Color(0x30FF0000), size.width * 0.5);
    }

    PixelArt.drawCentered(canvas, data.frames, palette, size, pixelSize: px);
  }

  // Cache white palettes by identity to avoid re-creating every hit frame
  static final Map<int, Map<String, Color>> _whitePaletteCache = {};

  static Map<String, Color> _whitePalette(Map<String, Color> original) {
    final key = identityHashCode(original);
    final cached = _whitePaletteCache[key];
    if (cached != null) return cached;
    final result = original.map((k, v) => MapEntry(k, const Color(0xFFFFFFFF)));
    if (_whitePaletteCache.length > 32) _whitePaletteCache.clear();
    _whitePaletteCache[key] = result;
    return result;
  }

  static _SpriteData _getSpriteData(String id, int frame) {
    switch (id) {
      case 'slime':         return _slime(frame);
      case 'goblin':        return _goblin(frame);
      case 'orc':           return _orc(frame);
      case 'bat':           return _bat(frame);
      case 'shield_bearer': return _shieldBearer(frame);
      case 'bomber':        return _bomber(frame);
      case 'healer':        return _healer(frame);
      case 'boss_golem':    return _bossGolem(frame);
      case 'boss':          return _bossGolem(frame);
      case 'shielded':      return _shieldBearer(frame);
      case 'skeleton':      return _skeleton(frame);
      case 'mushroom':      return _mushroom(frame);
      case 'golem':         return _golem(frame);
      default:              return _slime(frame);
    }
  }

  // ========== SLIME ==========

  static _SpriteData _slime(int frame) {
    final sprites = frame == 0 ? [
      '...GGGG...',
      '..GGGGGG..',
      '.GGgGGgGG.',
      '.GGEEGEEG.',
      '.GGGGGGGG.',
      '.GGGdddGG.',
      '..GGGGGG..',
      '..GGGGGG..',
      '...GGGG...',
      '..GGGGGG..',
    ] : [
      '...........',
      '...GGGG....',
      '..GGGGGG...',
      '.GGgGGgGG..',
      '.GGEEGEEG..',
      '.GGGGGGGG..',
      '.GGGdddGG..',
      '..GGGGGG...',
      '.GGGGGGGG..',
      '.GGGGGGGG..',
    ];
    return _SpriteData(sprites, {
      'G': const Color(0xFF4CAF50),
      'g': const Color(0xFF81C784),
      'D': const Color(0xFF388E3C),
      'd': const Color(0xFF388E3C),
      'E': const Color(0xFFFFFFFF),
    });
  }

  // ========== GOBLIN ==========

  static _SpriteData _goblin(int frame) {
    final sprites = frame == 0 ? [
      '..e.....e..',
      '.eee...eee.',
      '..GGGGGGG..',
      '.GGGGGGGGG.',
      '.GG.EE.EGG.',
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
      '.GG.EE.EGG.',
      '.GGGMMGGGG.',
      '..GGGGGGG..',
      '..GGGGGGG..',
      '.GG.....GG.',
      '.GG.....GG.',
    ];
    return _SpriteData(sprites, {
      'G': const Color(0xFF8BC34A),
      'e': const Color(0xFFA5D6A7),
      'E': const Color(0xFFFF0000),
      'M': const Color(0xFF558B2F),
    });
  }

  // ========== ORC ==========

  static _SpriteData _orc(int frame) {
    final sprites = frame == 0 ? [
      '...OOOOOO...',
      '..OOOOOOOO..',
      '.OOOOOOOOOO.',
      '.OO.EE.EOO..',
      '.OOTOOOOTOO.',
      '.OOOOOOOOOO.',
      '..OOOOOOOO..',
      '.OOOOOOOOOO.',
      'OOOOOOOOOOOO',
      '.OOO....OOO.',
      '.OOO....OOO.',
    ] : [
      '...OOOOOO...',
      '..OOOOOOOO..',
      '.OOOOOOOOOO.',
      '.OO.EE.EOO..',
      '.OOTOOOOTOO.',
      '.OOOOOOOOOO.',
      '..OOOOOOOO..',
      '.OOOOOOOOOO.',
      'OOOOOOOOOOOO',
      '..OO....OO..',
      '..OOO..OOO..',
    ];
    return _SpriteData(sprites, {
      'O': const Color(0xFF2E7D32),
      'E': const Color(0xFFFF0000),
      'T': const Color(0xFF795548),
    });
  }

  // ========== BAT ==========

  static _SpriteData _bat(int frame) {
    final sprites = frame == 0 ? [
      'PP........PP',
      '.PPPPPPPPPP.',
      '..PPPPPPPP..',
      '..PPP.EPPP..',
      '..PPPEEPPP..',
      '...PPPPPP...',
      '....PPPP....',
    ] : [
      '............',
      '..PPPPPPPP..',
      '.PPPPPPPPPP.',
      '.PPP.EPPPPp.',
      '.PPPEEPPPP..',
      '..PPPPPPPP..',
      '....PPPP....',
      'PP........PP',
    ];
    return _SpriteData(sprites, {
      'P': const Color(0xFF7B1FA2),
      'p': const Color(0xFF9C27B0),
      'E': const Color(0xFFFF0000),
    });
  }

  // ========== SHIELD BEARER ==========

  static _SpriteData _shieldBearer(int frame) {
    final sprites = frame == 0 ? [
      '...SSSSSS...',
      '..SSSSSSSS..',
      '..SS.AA.SS..',
      '..SSSSSSSS..',
      '..SS.SS.SS..',
      '..ASSSSSSA..',
      '.AAASSSSAAA.',
      '.AAASSSSAAA.',
      '.AAASSSSAAA.',
      '..AASSSSAA..',
      '...SS..SS...',
      '...SS..SS...',
    ] : [
      '...SSSSSS...',
      '..SSSSSSSS..',
      '..SS.AA.SS..',
      '..SSSSSSSS..',
      '..SS.SS.SS..',
      '..ASSSSSSA..',
      '.AAASSSSAAA.',
      '.AAASSSSAAA.',
      '.AAASSSSAAA.',
      '..AASSSSAA..',
      '..SS....SS..',
      '..SS....SS..',
    ];
    return _SpriteData(sprites, {
      'S': const Color(0xFF9E9E9E),
      'A': const Color(0xFF616161),
    });
  }

  // ========== BOMBER ==========

  static _SpriteData _bomber(int frame) {
    final sprites = frame == 0 ? [
      '........fF..',
      '.........F..',
      '...RRRR.BB..',
      '..RRRRRR....',
      '.RR.EE.RR...',
      '.RRRMMRRR...',
      '..RRRRRR....',
      '..RRRRRRR...',
      '..RR...RR...',
      '..RR...RR...',
    ] : [
      '.........fF.',
      '..........F.',
      '...RRRR.BB..',
      '..RRRRRR....',
      '.RR.EE.RR...',
      '.RRRMMRRR...',
      '..RRRRRR....',
      '..RRRRRRR...',
      '.RR.....RR..',
      '.RR.....RR..',
    ];
    return _SpriteData(sprites, {
      'R': const Color(0xFFFF0000),
      'E': const Color(0xFFFFFFFF),
      'M': const Color(0xFFB71C1C),
      'B': const Color(0xFF1A1A1A),
      'F': const Color(0xFF424242),
      'f': const Color(0xFFFF9800),
    });
  }

  // ========== HEALER ==========

  static _SpriteData _healer(int frame) {
    final sprites = frame == 0 ? [
      '...WWWWWW...',
      '..WWWWWWWW..',
      '..WW.WW.WW..',
      '..WWWWWWWW..',
      '..WWWWWWWW..',
      '...WWWWWW...',
      '..WWWWWWWW..',
      '..WW.GG.WW..',
      '..WWGGGGWW..',
      '..WW.GG.WW..',
      '..WWWWWWWW..',
      '...WWWWWW...',
    ] : [
      '...WWWWWW...',
      '..WWWWWWWW..',
      '..WW.WW.WW..',
      '..WWWWWWWW..',
      '..WWWWWWWW..',
      '...WWWWWW...',
      '..WWWWWWWW..',
      '..WW.GG.WW..',
      '..WWGGGGWW..',
      '..WW.GG.WW..',
      '.WWWWWWWWWW.',
      '...WWWWWW...',
    ];
    return _SpriteData(sprites, {
      'W': const Color(0xFFFFFFFF),
      'G': const Color(0xFF4CAF50),
    });
  }

  // ========== BOSS GOLEM (16x16) ==========

  static _SpriteData _bossGolem(int frame) {
    final sprites = frame == 0 ? [
      '......SSSSSS........',
      '....SSSSSSSSSS......',
      '...SSSSSSSSSSSS.....',
      '..SSSSSSSSSSSSSS....',
      '..SSS.EESS.EESSSS..',
      '..SSSSSSSSSSSSSSSS..',
      '..SSSSSSggSSSSSSSS..',
      '...SSSSSSSSSSSSSS...',
      '....SSGGGGGGSS......',
      '...GGGGGGGGGGGG.....',
      '..GGGGGGGGGGGGGG....',
      '..GGGGGGGGGGGGGG....',
      '.GGGGGGGGGGGGGGGG...',
      '.GGGG........GGGG...',
      '.GGGG........GGGG...',
      '.GGGG........GGGG...',
    ] : [
      '......SSSSSS........',
      '....SSSSSSSSSS......',
      '...SSSSSSSSSSSS.....',
      '..SSSSSSSSSSSSSS....',
      '..SSS.EESS.EESSSS..',
      '..SSSSSSSSSSSSSSSS..',
      '..SSSSSSggSSSSSSSS..',
      '...SSSSSSSSSSSSSS...',
      '....SSGGGGGGSS......',
      '...GGGGGGGGGGGG.....',
      '..GGGGGGGGGGGGGG....',
      '..GGGGGGGGGGGGGG....',
      '.GGGGGGGGGGGGGGGG...',
      '..GGG........GGG....',
      '..GGGG......GGGG....',
      '..GGGG......GGGG....',
    ];
    return _SpriteData(sprites, {
      'S': const Color(0xFF795548),
      'G': const Color(0xFF9E9E9E),
      'E': const Color(0xFFFF5722),
      'g': const Color(0xFF5D4037),
    });
  }

  // ========== SKELETON ==========

  static _SpriteData _skeleton(int frame) {
    final sprites = frame == 0 ? [
      '...WWWWWW...',
      '..WWWWWWWW..',
      '..WW.BB.WW..',
      '..WWWWWWWW..',
      '..WW.WW.WW..',
      '...WWWWWW...',
      '..WWWWWWWW..',
      '..WW.WW.WW..',
      '..WWWWWWWW..',
      '...WW..WW...',
      '...WW..WW...',
    ] : [
      '...WWWWWW...',
      '..WWWWWWWW..',
      '..WW.BB.WW..',
      '..WWWWWWWW..',
      '..WW.WW.WW..',
      '...WWWWWW...',
      '..WWWWWWWW..',
      '..WW.WW.WW..',
      '..WWWWWWWW..',
      '..WW....WW..',
      '..WW....WW..',
    ];
    return _SpriteData(sprites, {
      'W': const Color(0xFFEEEEEE),
      'B': const Color(0xFF1A1A1A),
    });
  }

  // ========== MUSHROOM ==========

  static _SpriteData _mushroom(int frame) {
    final sprites = frame == 0 ? [
      '...RRRRRR...',
      '..RRRRRRRR..',
      '.RRRWRRWRRR.',
      '.RRRRRRRRRR.',
      '..RRRRRRRR..',
      '....SSSS....',
      '...SSSSSS...',
      '...SSSSSS...',
      '....SSSS....',
      '...SSSSSS...',
    ] : [
      '..RRRRRRRR..',
      '.RRRRRRRRRR.',
      '.RRRWRRWRRR.',
      '.RRRRRRRRRR.',
      '..RRRRRRRR..',
      '...RRRRRR...',
      '....SSSS....',
      '...SSSSSS...',
      '...SSSSSS...',
      '..SSSSSSSS..',
    ];
    return _SpriteData(sprites, {
      'R': const Color(0xFFE91E63),
      'W': const Color(0xFFFFFFFF),
      'S': const Color(0xFFBCAAA4),
    });
  }

  // ========== GOLEM ==========

  static _SpriteData _golem(int frame) {
    final sprites = frame == 0 ? [
      '....GGGGGG....',
      '...GGGGGGGG...',
      '..GGGGGGGGGG..',
      '..GG.EE.EGGG..',
      '..GGGGGGGGGG..',
      '..GGGGggGGGG..',
      '...GGGGGGGG...',
      '..GGGGGGGGGG..',
      '.GGGGGGGGGGGG.',
      '.GGGGGGGGGGGG.',
      '..GGG....GGG..',
      '..GGG....GGG..',
    ] : [
      '....GGGGGG....',
      '...GGGGGGGG...',
      '..GGGGGGGGGG..',
      '..GG.EE.EGGG..',
      '..GGGGGGGGGG..',
      '..GGGGggGGGG..',
      '...GGGGGGGG...',
      '..GGGGGGGGGG..',
      '.GGGGGGGGGGGG.',
      '.GGGGGGGGGGGG.',
      '.GGG......GGG.',
      '.GGG......GGG.',
    ];
    return _SpriteData(sprites, {
      'G': const Color(0xFF78909C),
      'E': const Color(0xFFFF5722),
      'g': const Color(0xFF546E7A),
    });
  }
}

class _SpriteData {
  final List<String> frames;
  final Map<String, Color> palette;
  _SpriteData(this.frames, this.palette);
}
