import 'dart:ui';
import 'dart:math';
import '../utils/pixel_art.dart';
import '../data/hybrid_unit_data.dart';

/// Pixel art renderer for 6 animal defender units + hybrid units.
/// Each unit has base sprite, 2-frame idle animation, level visual scaling,
/// and an evolved form with glow effects.
/// Hybrid units render with parent A base sprite + parent B color overlay.
class UnitRenderer {
  /// Render a unit by type string and level.
  static void render(Canvas canvas, Size size, {
    required String unitTypeId,
    required int level,
    required double animTimer,
    bool isEvolved = false,
    bool hasTarget = false,
  }) {
    // Check if this is a hybrid unit
    if (HybridDatabase.isHybrid(unitTypeId)) {
      _renderHybrid(canvas, size,
          hybridId: unitTypeId, level: level, animTimer: animTimer);
      return;
    }

    final frame = (animTimer * 3).toInt() % 2;
    final data = _getSpriteData(unitTypeId, frame, isEvolved: isEvolved);
    if (data.frames.isEmpty) return;

    // Level affects pixel size (slightly larger at higher levels)
    final spriteW = data.frames[0].length;
    final spriteH = data.frames.length;
    final basePx = min(size.width / spriteW, size.height / spriteH);
    final px = basePx * (1.0 + (level - 1) * 0.04);

    // Evolved glow
    if (isEvolved) {
      final glowColor = _evolvedGlowColor(unitTypeId);
      final pulse = 0.4 + sin(animTimer * 4) * 0.15;
      PixelArt.drawGlow(
        canvas,
        size,
        glowColor.withAlpha((pulse * 255).toInt()),
        size.width * 0.45,
      );
    }

    // Level 3+ highlight pixels: brighten palette slightly
    final palette = level >= 3
        ? _brightenPalette(data.palette, (level - 2) * 12)
        : data.palette;

    PixelArt.drawCentered(canvas, data.frames, palette, size, pixelSize: px);

    // Level 5 sparkle effect
    if (level >= 5) {
      _drawSparkles(canvas, size, animTimer);
    }
  }

  static Color _evolvedGlowColor(String id) {
    switch (id) {
      case 'cat_archer':    return const Color(0xFFFFAB00);
      case 'dog_warrior':   return const Color(0xFFFF6D00);
      case 'rabbit_mage':   return const Color(0xFFAA00FF);
      case 'bear_tanker':   return const Color(0xFF795548);
      case 'fox_assassin':  return const Color(0xFFFF3D00);
      case 'bird_scout':    return const Color(0xFF2979FF);
      case 'turtle_healer': return const Color(0xFF00C853);
      case 'owl_wizard':    return const Color(0xFF651FFF);
      default:              return const Color(0xFFFFFFFF);
    }
  }

  static Map<String, Color> _brightenPalette(Map<String, Color> p, int amount) {
    return p.map((k, v) => MapEntry(k, Color.fromARGB(
      v.alpha,
      min(255, v.red + amount),
      min(255, v.green + amount),
      min(255, v.blue + amount),
    )));
  }

  static void _drawSparkles(Canvas canvas, Size size, double t) {
    final paint = Paint()
      ..color = const Color(0xCCFFFFFF)
      ..isAntiAlias = false;
    final rng = Random((t * 10).toInt());
    for (var i = 0; i < 3; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.5;
      canvas.drawRect(Rect.fromLTWH(x, y, 2, 2), paint);
    }
  }

  static _SpriteData _getSpriteData(String id, int frame, {bool isEvolved = false}) {
    if (isEvolved) {
      switch (id) {
        case 'cat_archer':    return _catArcherEvolved(frame);
        case 'dog_warrior':   return _dogWarriorEvolved(frame);
        case 'rabbit_mage':   return _rabbitMageEvolved(frame);
        case 'bear_tanker':   return _bearTankerEvolved(frame);
        case 'fox_assassin':  return _foxAssassinEvolved(frame);
        case 'bird_scout':    return _birdScoutEvolved(frame);
        case 'turtle_healer': return _turtleHealerEvolved(frame);
        case 'owl_wizard':    return _owlWizardEvolved(frame);
        default:              return _catArcher(frame);
      }
    }
    switch (id) {
      case 'cat_archer':    return _catArcher(frame);
      case 'dog_warrior':   return _dogWarrior(frame);
      case 'rabbit_mage':   return _rabbitMage(frame);
      case 'bear_tanker':   return _bearTanker(frame);
      case 'fox_assassin':  return _foxAssassin(frame);
      case 'bird_scout':    return _birdScout(frame);
      case 'turtle_healer': return _turtleHealer(frame);
      case 'owl_wizard':    return _owlWizard(frame);
      default:              return _catArcher(frame);
    }
  }

  // ========== CAT ARCHER ==========

  static _SpriteData _catArcher(int frame) {
    final sprites = frame == 0 ? [
      '....OOOO....',
      '...OOOOOO...',
      '..OO.EE.OO..',
      '..OOOOOOOO..',
      '..O.ONNO.O..',
      '....OOOO....',
      '...OOOOOO...',
      '..OObOO.OO..',
      '..ObOOO..O..',
      '.b..OO......',
      '....O..O....',
      '...O....O...',
    ] : [
      '....OOOO....',
      '...OOOOOO...',
      '..OO.EE.OO..',
      '..OOOOOOOO..',
      '..O.ONNO.O..',
      '....OOOO....',
      '...OOOOOO...',
      '..OObOO.OO..',
      '..ObOOO..O..',
      '.b..OO......',
      '...O....O...',
      '....O..O....',
    ];
    return _SpriteData(sprites, {
      'O': const Color(0xFFFF8C00),
      'E': const Color(0xFF1A1A1A),
      'N': const Color(0xFFFF6F00),
      'b': const Color(0xFF8D6E63),
    });
  }

  static _SpriteData _catArcherEvolved(int frame) {
    final sprites = frame == 0 ? [
      '..g.OOOO.g..',
      '...OOOOOO...',
      '..OO.EE.OO..',
      '..OOOOOOOO..',
      '..O.ONNO.O..',
      '..g.OOOO.g..',
      '...OOOOOO...',
      '..OObOO.OO..',
      '..ObOOO..O..',
      '.bA.OO...A..',
      '....O..O....',
      '...O....O...',
    ] : [
      '..g.OOOO.g..',
      '...OOOOOO...',
      '..OO.EE.OO..',
      '..OOOOOOOO..',
      '..O.ONNO.O..',
      '..g.OOOO.g..',
      '...OOOOOO...',
      '..OObOO.OO..',
      '..ObOOO..O..',
      '.bA.OO...A..',
      '...O....O...',
      '....O..O....',
    ];
    return _SpriteData(sprites, {
      'O': const Color(0xFFFFAB00),
      'E': const Color(0xFF1A1A1A),
      'N': const Color(0xFFFF8F00),
      'b': const Color(0xFFFFD54F),
      'g': const Color(0xFFFFE082),
      'A': const Color(0xFFFFD600),
    });
  }

  // ========== DOG WARRIOR ==========

  static _SpriteData _dogWarrior(int frame) {
    final sprites = frame == 0 ? [
      '...DDDDDD...',
      '..DDDDDDDD..',
      '..DD.EE.DD..',
      '..DDDDDDDD..',
      '..DD.DD.DD..',
      '...DDDDDD...',
      'SS.DDDDDD...',
      'SSS.DDDD....',
      'SS.DDDDDD...',
      '...DD..DD...',
      '...DD..DD...',
      '...DD..DD...',
    ] : [
      '...DDDDDD...',
      '..DDDDDDDD..',
      '..DD.EE.DD..',
      '..DDDDDDDD..',
      '..DD.DD.DD..',
      '...DDDDDD...',
      'SS.DDDDDD...',
      'SSS.DDDD....',
      'SS.DDDDDD...',
      '..DD....DD..',
      '..DD....DD..',
      '..DD....DD..',
    ];
    return _SpriteData(sprites, {
      'D': const Color(0xFF8B4513),
      'E': const Color(0xFF1A1A1A),
      'S': const Color(0xFF808080),
    });
  }

  static _SpriteData _dogWarriorEvolved(int frame) {
    final sprites = frame == 0 ? [
      '..hDDDDDDh..',
      '..DDDDDDDD..',
      '..DD.EE.DD..',
      '..DDDDDDDD..',
      '..DD.DD.DD..',
      '...DDDDDD...',
      'GG.DDDDDD...',
      'GGG.DDDD....',
      'GG.DDDDDD...',
      '...DD..DD...',
      '...DD..DD...',
      '...DD..DD...',
    ] : [
      '..hDDDDDDh..',
      '..DDDDDDDD..',
      '..DD.EE.DD..',
      '..DDDDDDDD..',
      '..DD.DD.DD..',
      '...DDDDDD...',
      'GG.DDDDDD...',
      'GGG.DDDD....',
      'GG.DDDDDD...',
      '..DD....DD..',
      '..DD....DD..',
      '..DD....DD..',
    ];
    return _SpriteData(sprites, {
      'D': const Color(0xFFA0522D),
      'E': const Color(0xFF1A1A1A),
      'G': const Color(0xFFFFD700),
      'h': const Color(0xFFCD853F),
    });
  }

  // ========== RABBIT MAGE ==========

  static _SpriteData _rabbitMage(int frame) {
    final sprites = frame == 0 ? [
      '..WW....WW..',
      '..WW....WW..',
      '..WW....WW..',
      '...WWWWWW...',
      '..WW.EE.WW..',
      '..WWWWWWWW..',
      '...WWWWWW...',
      '..WWWWWWWP..',
      '..WWWWWWWP..',
      '...WWWWWP...',
      '...WW.WWP...',
      '...WW.WW....',
    ] : [
      '..WW....WW..',
      '..WW....WW..',
      '..WW....WW..',
      '...WWWWWW...',
      '..WW.EE.WW..',
      '..WWWWWWWW..',
      '...WWWWWW...',
      '..WWWWWWWP..',
      '..WWWWWWWP..',
      '...WWWWWPP..',
      '..WW...WWP..',
      '..WW...WW...',
    ];
    return _SpriteData(sprites, {
      'W': const Color(0xFFFFFFFF),
      'E': const Color(0xFFFF1744),
      'P': const Color(0xFF9C27B0),
    });
  }

  static _SpriteData _rabbitMageEvolved(int frame) {
    final sprites = frame == 0 ? [
      '..WW..m.WW..',
      '..WW.m..WW..',
      '..WW....WW..',
      '...WWWWWW...',
      '..WW.EE.WW..',
      '..WWWWWWWW..',
      '...WWWWWW...',
      '..WWWWWWWP..',
      '.mWWWWWWWPm.',
      '...WWWWWP...',
      '...WW.WWP...',
      '...WW.WW....',
    ] : [
      '..WW.m..WW..',
      '..WW..m.WW..',
      '..WW....WW..',
      '...WWWWWW...',
      '..WW.EE.WW..',
      '..WWWWWWWW..',
      '...WWWWWW...',
      '..WWWWWWWP..',
      '.mWWWWWWWPm.',
      '...WWWWWPP..',
      '..WW...WWP..',
      '..WW...WW...',
    ];
    return _SpriteData(sprites, {
      'W': const Color(0xFFF3E5F5),
      'E': const Color(0xFFFF1744),
      'P': const Color(0xFF7B1FA2),
      'm': const Color(0xFFCE93D8),
    });
  }

  // ========== BEAR TANKER ==========

  static _SpriteData _bearTanker(int frame) {
    final sprites = frame == 0 ? [
      '..BB....BB..',
      '..BBBBBBBB..',
      '.BBBBBBBBBB.',
      '.BB.EE.EBBB.',
      '.BBBBBBBBBB.',
      '.BBBBnBBBBB.',
      '..BBBBBBBB..',
      '.BBBBBBBBBB.',
      'BBBBBBBBBBBB',
      'BBBBBBBBBBBB',
      '.BBB....BBB.',
      '.BBB....BBB.',
    ] : [
      '..BB....BB..',
      '..BBBBBBBB..',
      '.BBBBBBBBBB.',
      '.BB.EE.EBBB.',
      '.BBBBBBBBBB.',
      '.BBBBnBBBBB.',
      '..BBBBBBBB..',
      '.BBBBBBBBBB.',
      'BBBBBBBBBBBB',
      'BBBBBBBBBBBB',
      '..BB....BB..',
      '..BBB..BBB..',
    ];
    return _SpriteData(sprites, {
      'B': const Color(0xFF5D4037),
      'E': const Color(0xFF1A1A1A),
      'n': const Color(0xFF3E2723),
    });
  }

  static _SpriteData _bearTankerEvolved(int frame) {
    final sprites = frame == 0 ? [
      'a.BB....BB.a',
      '..BBBBBBBB..',
      '.BBBBBBBBBB.',
      '.BB.EE.EBBB.',
      '.BBBBBBBBBB.',
      '.BBBBnBBBBB.',
      '..BBBBBBBB..',
      '.BBBBBBBBBB.',
      'BBBBBBBBBBBB',
      'BBBBaaBBBBBB',
      '.BBB....BBB.',
      '.BBB....BBB.',
    ] : [
      'a.BB....BB.a',
      '..BBBBBBBB..',
      '.BBBBBBBBBB.',
      '.BB.EE.EBBB.',
      '.BBBBBBBBBB.',
      '.BBBBnBBBBB.',
      '..BBBBBBBB..',
      '.BBBBBBBBBB.',
      'BBBBBBBBBBBB',
      'BBBBaaBBBBBB',
      '..BB....BB..',
      '..BBB..BBB..',
    ];
    return _SpriteData(sprites, {
      'B': const Color(0xFF6D4C41),
      'E': const Color(0xFF1A1A1A),
      'n': const Color(0xFF3E2723),
      'a': const Color(0xFFFFD54F),
    });
  }

  // ========== FOX ASSASSIN ==========

  static _SpriteData _foxAssassin(int frame) {
    final sprites = frame == 0 ? [
      '..FF....FF..',
      '..FFFFFFFF..',
      '.FF.EE.EFF..',
      '.FFFFFFFFFF.',
      '.FFF.FF.FFF.',
      '..FFFFFFFF..',
      '...FFFFFF...',
      '..FFFFFFFF..',
      '..FFFFFFFFW.',
      '...FFFFFFFWW',
      '...FF..FF...',
      '...FF..FF...',
    ] : [
      '..FF....FF..',
      '..FFFFFFFF..',
      '.FF.EE.EFF..',
      '.FFFFFFFFFF.',
      '.FFF.FF.FFF.',
      '..FFFFFFFF..',
      '...FFFFFF...',
      '..FFFFFFFF..',
      '..FFFFFFFFW.',
      '...FFFFFFFWW',
      '..FF....FF..',
      '..FF....FF..',
    ];
    return _SpriteData(sprites, {
      'F': const Color(0xFFFF5722),
      'W': const Color(0xFFFFFFFF),
      'E': const Color(0xFF1A1A1A),
    });
  }

  static _SpriteData _foxAssassinEvolved(int frame) {
    final sprites = frame == 0 ? [
      's.FF....FF.s',
      '..FFFFFFFF..',
      '.FF.EE.EFF..',
      '.FFFFFFFFFFg',
      '.FFF.FF.FFFg',
      '..FFFFFFFF..',
      '...FFFFFF...',
      '..FFFFFFFF..',
      '..FFFFFFFFWg',
      '...FFFFFFFWW',
      '...FF..FF...',
      '...FF..FF...',
    ] : [
      's.FF....FF.s',
      '..FFFFFFFF..',
      '.FF.EE.EFF..',
      '.FFFFFFFFFFg',
      '.FFF.FF.FFFg',
      '..FFFFFFFF..',
      '...FFFFFF...',
      '..FFFFFFFF..',
      '..FFFFFFFFWg',
      '...FFFFFFFWW',
      '..FF....FF..',
      '..FF....FF..',
    ];
    return _SpriteData(sprites, {
      'F': const Color(0xFFFF6E40),
      'W': const Color(0xFFFFFFFF),
      'E': const Color(0xFF1A1A1A),
      's': const Color(0xFFB0BEC5),
      'g': const Color(0xFFFFD600),
    });
  }

  // ========== BIRD SCOUT ==========

  static _SpriteData _birdScout(int frame) {
    final sprites = frame == 0 ? [
      '....LLLL....',
      '...LLLLLL...',
      '..LL.EE.LL..',
      '..LLLLLLLL..',
      '..LLYYLLLLo.',
      '..LLLLLLLL..',
      '.LL.LLLL.LL.',
      'LL..LLLL..LL',
      '....LLLL....',
      '....L..L....',
      '...YY..YY...',
    ] : [
      '....LLLL....',
      '...LLLLLL...',
      '..LL.EE.LL..',
      '..LLLLLLLL..',
      '..LLYYLLLLo.',
      '..LLLLLLLL..',
      '....LLLL....',
      '..LL.LL.LL..',
      '.LL..LL..LL.',
      '....L..L....',
      '...YY..YY...',
    ];
    return _SpriteData(sprites, {
      'L': const Color(0xFF2196F3),
      'Y': const Color(0xFFFFEB3B),
      'E': const Color(0xFF1A1A1A),
      'o': const Color(0xFFFFEB3B),
    });
  }

  static _SpriteData _birdScoutEvolved(int frame) {
    final sprites = frame == 0 ? [
      '..c.LLLL.c..',
      '...LLLLLL...',
      '..LL.EE.LL..',
      '..LLLLLLLL..',
      '..LLYYLLLLo.',
      '..LLLLLLLL..',
      '.LL.LLLL.LL.',
      'LL..LLLL..LL',
      '..c.LLLL.c..',
      '....L..L....',
      '...YY..YY...',
    ] : [
      '..c.LLLL.c..',
      '...LLLLLL...',
      '..LL.EE.LL..',
      '..LLLLLLLL..',
      '..LLYYLLLLo.',
      '..LLLLLLLL..',
      '....LLLL....',
      '..LL.LL.LL..',
      '.LLc.LL.cLL.',
      '....L..L....',
      '...YY..YY...',
    ];
    return _SpriteData(sprites, {
      'L': const Color(0xFF42A5F5),
      'Y': const Color(0xFFFFEB3B),
      'E': const Color(0xFF1A1A1A),
      'o': const Color(0xFFFFEB3B),
      'c': const Color(0xFF90CAF9),
    });
  }
  // ========== TURTLE HEALER ==========

  static _SpriteData _turtleHealer(int frame) {
    final sprites = frame == 0 ? [
      '...TTTTTT...',
      '..TTTTTTTT..',
      '.TTSSSSSSTT.',
      '.TSSSSSSST..',
      '.TSSSSSSST..',
      '.TTSSSSSSTT.',
      '..TTTTTTTT..',
      '..TT.TT.TT..',
      '..TT....TT..',
      '..TT....TT..',
    ] : [
      '...TTTTTT...',
      '..TTTTTTTT..',
      '.TTSSSSSSTT.',
      '.TSSSSSSST..',
      '.TSSSSSSST..',
      '.TTSSSSSSTT.',
      '..TTTTTTTT..',
      '.TT..TT..TT.',
      '.TT......TT.',
      '.TT......TT.',
    ];
    return _SpriteData(sprites, {
      'T': const Color(0xFF2E7D32),
      'S': const Color(0xFF4CAF50),
    });
  }

  static _SpriteData _turtleHealerEvolved(int frame) {
    final sprites = frame == 0 ? [
      'g..TTTTTT..g',
      '..TTTTTTTT..',
      '.TTSSSSSSTT.',
      '.TSgSSSSgST.',
      '.TSSSSSSST..',
      '.TTSSSSSSTT.',
      '..TTTTTTTT..',
      '..TT.TT.TT..',
      '..TT....TT..',
      '..TT....TT..',
    ] : [
      'g..TTTTTT..g',
      '..TTTTTTTT..',
      '.TTSSSSSSTT.',
      '.TSgSSSSgST.',
      '.TSSSSSSST..',
      '.TTSSSSSSTT.',
      '..TTTTTTTT..',
      '.TT..TT..TT.',
      '.TT......TT.',
      '.TT......TT.',
    ];
    return _SpriteData(sprites, {
      'T': const Color(0xFF388E3C),
      'S': const Color(0xFF66BB6A),
      'g': const Color(0xFF00E676),
    });
  }

  // ========== OWL WIZARD ==========

  static _SpriteData _owlWizard(int frame) {
    final sprites = frame == 0 ? [
      '..OO....OO..',
      '..OOOOOOOO..',
      '.OO.YY.YOO..',
      '.OOOOOOOOOO.',
      '.OOO.bb.OOO.',
      '..OOOOOOOO..',
      '..OOOOOOOO..',
      '.OO.OOOO.OO.',
      'OO..OOOO..OO',
      '....OOOO....',
      '....OO.O....',
      '...YY..YY...',
    ] : [
      '..OO....OO..',
      '..OOOOOOOO..',
      '.OO.YY.YOO..',
      '.OOOOOOOOOO.',
      '.OOO.bb.OOO.',
      '..OOOOOOOO..',
      '..OOOOOOOO..',
      '....OOOO....',
      '..OO.OO.OO..',
      '.OO..OO..OO.',
      '....OO.O....',
      '...YY..YY...',
    ];
    return _SpriteData(sprites, {
      'O': const Color(0xFF795548),
      'Y': const Color(0xFFFFEB3B),
      'b': const Color(0xFFFF8F00),
    });
  }

  static _SpriteData _owlWizardEvolved(int frame) {
    final sprites = frame == 0 ? [
      'p.OO....OO.p',
      '..OOOOOOOO..',
      '.OO.YY.YOO..',
      '.OOOOOOOOOO.',
      '.OOO.bb.OOO.',
      '..OOOOOOOO..',
      '..OOOOOOOOp.',
      '.OO.OOOO.OO.',
      'OO..OOOO..OO',
      '....OOOO....',
      '....OO.O....',
      '...YY..YY...',
    ] : [
      'p.OO....OO.p',
      '..OOOOOOOO..',
      '.OO.YY.YOO..',
      '.OOOOOOOOOO.',
      '.OOO.bb.OOO.',
      '..OOOOOOOO..',
      '..OOOOOOOOp.',
      '....OOOO....',
      '..OO.OO.OO..',
      '.OO..OO..OO.',
      '....OO.O....',
      '...YY..YY...',
    ];
    return _SpriteData(sprites, {
      'O': const Color(0xFF6D4C41),
      'Y': const Color(0xFFFFEB3B),
      'b': const Color(0xFFFF8F00),
      'p': const Color(0xFFCE93D8),
    });
  }

  // ========== HYBRID UNIT RENDERING ==========

  /// Color map for hybrid types (glow + tint).
  static const Map<String, Color> _hybridColors = {
    'hybrid_flame_hunter': Color(0xFFFF6D00),
    'hybrid_iron_warrior': Color(0xFF607D8B),
    'hybrid_archmage': Color(0xFF7B1FA2),
    'hybrid_mountain_guard': Color(0xFF4CAF50),
    'hybrid_storm_archer': Color(0xFF42A5F5),
    'hybrid_wind_thief': Color(0xFF80CBC4),
    'hybrid_holy_knight': Color(0xFFFFD54F),
    'hybrid_mystic_sage': Color(0xFFCE93D8),
    'hybrid_wise_bear': Color(0xFF795548),
    'hybrid_shadow_sage': Color(0xFF311B92),
    'hybrid_wolf_blade': Color(0xFFBDBDBD),
    'hybrid_spell_sniper': Color(0xFFE040FB),
  };

  /// Render a hybrid unit using parent A sprite with color tint overlay.
  static void _renderHybrid(Canvas canvas, Size size, {
    required String hybridId,
    required int level,
    required double animTimer,
  }) {
    final hybridData = HybridDatabase.get(hybridId);
    if (hybridData == null) return;

    // Use parent A as base sprite
    final frame = (animTimer * 3).toInt() % 2;
    final baseData = _getSpriteData(hybridData.parentA, frame);
    if (baseData.frames.isEmpty) return;

    final spriteW = baseData.frames[0].length;
    final spriteH = baseData.frames.length;
    final basePx = min(size.width / spriteW, size.height / spriteH);
    final px = basePx * (1.0 + (level - 1) * 0.04);

    // Hybrid glow effect (dual color pulse)
    final glowColor = _hybridColors[hybridId] ?? const Color(0xFFFFFFFF);
    final pulse = 0.5 + sin(animTimer * 3) * 0.2;
    PixelArt.drawGlow(
      canvas, size,
      glowColor.withAlpha((pulse * 180).toInt()),
      size.width * 0.4,
    );

    // Tint palette toward hybrid color
    final tintedPalette = _tintPalette(baseData.palette, glowColor, 0.3);
    final palette = level >= 3
        ? _brightenPalette(tintedPalette, (level - 2) * 15)
        : tintedPalette;

    PixelArt.drawCentered(canvas, baseData.frames, palette, size, pixelSize: px);

    // Draw hybrid badge (small emoji indicator)
    _drawHybridBadge(canvas, size, hybridData.emoji, animTimer);

    // Level 3+ sparkle effect
    if (level >= 3) {
      _drawSparkles(canvas, size, animTimer);
    }
  }

  /// Tint a palette toward a target color by [amount] (0.0~1.0).
  static Map<String, Color> _tintPalette(
      Map<String, Color> p, Color target, double amount) {
    return p.map((k, v) => MapEntry(k, Color.fromARGB(
      v.alpha,
      (v.red + (target.red - v.red) * amount).toInt().clamp(0, 255),
      (v.green + (target.green - v.green) * amount).toInt().clamp(0, 255),
      (v.blue + (target.blue - v.blue) * amount).toInt().clamp(0, 255),
    )));
  }

  /// Draw a small badge indicator for hybrid units.
  static void _drawHybridBadge(Canvas canvas, Size size, String emoji, double t) {
    // Pulsing indicator dot in corner
    final dotPaint = Paint()
      ..color = const Color(0xCCFFFFFF)
      ..isAntiAlias = false;
    final dotSize = 3.0 + sin(t * 5) * 0.5;
    canvas.drawRect(
      Rect.fromLTWH(size.width - dotSize - 1, 1, dotSize, dotSize),
      dotPaint,
    );
  }
}

class _SpriteData {
  final List<String> frames;
  final Map<String, Color> palette;
  _SpriteData(this.frames, this.palette);
}
