import 'dart:ui';
import 'dart:math';
import '../data/enemy_data.dart';

class EnemyRenderer {
  static void render(Canvas canvas, Size size, EnemyData data, {required double animTimer, bool isHit = false, bool isGolden = false}) {
    final color = isHit ? const Color(0xFFFFFFFF) : (isGolden ? const Color(0xFFFFD600) : data.color);
    final accent = isHit ? const Color(0xFFFFFFFF) : (isGolden ? const Color(0xFFFFE082) : data.accentColor);

    switch (data.id) {
      // Meadow
      case 'slime': _renderSlime(canvas, size, color, accent, animTimer); break;
      case 'mushroom': _renderMushroom(canvas, size, color, accent, animTimer); break;
      case 'bird': _renderBird(canvas, size, color, accent, animTimer); break;
      case 'butterfly': _renderButterfly(canvas, size, color, accent, animTimer); break;
      // Forest
      case 'goblin': _renderGoblin(canvas, size, color, accent, animTimer); break;
      case 'spider': _renderSpider(canvas, size, color, accent, animTimer); break;
      case 'bat': _renderBat(canvas, size, color, accent, animTimer); break;
      case 'fairy': _renderFairy(canvas, size, color, accent, animTimer); break;
      // Desert
      case 'scorpion': _renderScorpion(canvas, size, color, accent, animTimer); break;
      case 'mummy': _renderMummy(canvas, size, color, accent, animTimer); break;
      case 'eagle': _renderEagle(canvas, size, color, accent, animTimer); break;
      case 'sand_spirit': _renderSpirit(canvas, size, color, accent, animTimer); break;
      // Snowfield
      case 'snow_golem': _renderGolem(canvas, size, color, accent, animTimer); break;
      case 'wolf': _renderWolf(canvas, size, color, accent, animTimer); break;
      case 'snow_owl': _renderOwl(canvas, size, color, accent, animTimer); break;
      case 'ice_spirit': _renderSpirit(canvas, size, color, accent, animTimer); break;
      // Volcano
      case 'fire_imp': _renderImp(canvas, size, color, accent, animTimer); break;
      case 'dragonkin': _renderDragonkin(canvas, size, color, accent, animTimer); break;
      case 'fire_bat': _renderBat(canvas, size, color, accent, animTimer); break;
      case 'phoenix': _renderPhoenix(canvas, size, color, accent, animTimer); break;
      default: _renderGeneric(canvas, size, color, accent, animTimer, data.type);
    }
  }

  // ========== Meadow ==========

  static void _renderSlime(Canvas canvas, Size size, Color color, Color accent, double t) {
    final cx = size.width / 2, cy = size.height / 2;
    final bounce = sin(t * 4) * 2;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 2 + bounce), width: size.width * 0.85, height: size.height * 0.7 - bounce), Paint()..color = color);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 3, cy - 2 + bounce), width: size.width * 0.3, height: size.height * 0.25), Paint()..color = accent);
    final ep = Paint()..color = const Color(0xFF1A1A1A);
    canvas.drawCircle(Offset(cx - 4, cy - 1 + bounce), 2, ep);
    canvas.drawCircle(Offset(cx + 4, cy - 1 + bounce), 2, ep);
  }

  static void _renderMushroom(Canvas canvas, Size size, Color color, Color accent, double t) {
    final cx = size.width / 2;
    canvas.drawRect(Rect.fromLTWH(cx - 4, size.height * 0.4, 8, size.height * 0.6), Paint()..color = const Color(0xFFF5E6D0));
    canvas.drawArc(Rect.fromCenter(center: Offset(cx, size.height * 0.4), width: size.width * 0.9, height: size.height * 0.7), pi, pi, true, Paint()..color = color);
    final sp = Paint()..color = accent;
    canvas.drawCircle(Offset(cx - 4, size.height * 0.25), 3, sp);
    canvas.drawCircle(Offset(cx + 5, size.height * 0.2), 2, sp);
    final ep = Paint()..color = const Color(0xFF1A1A1A);
    canvas.drawCircle(Offset(cx - 3, size.height * 0.5), 1.5, ep);
    canvas.drawCircle(Offset(cx + 3, size.height * 0.5), 1.5, ep);
  }

  static void _renderBird(Canvas canvas, Size size, Color color, Color accent, double t) {
    final cx = size.width / 2, cy = size.height / 2;
    final wf = sin(t * 10) * 0.4;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: size.width * 0.7, height: size.height * 0.6), Paint()..color = color);
    canvas.drawPath(Path()..moveTo(cx - 2, cy - 2)..lineTo(cx - size.width * 0.4, cy - size.height * 0.5 + wf * 10)..lineTo(cx + 2, cy - 4)..close(), Paint()..color = accent);
    canvas.drawPath(Path()..moveTo(cx + size.width * 0.35, cy - 1)..lineTo(cx + size.width * 0.5, cy + 1)..lineTo(cx + size.width * 0.35, cy + 3)..close(), Paint()..color = const Color(0xFFFF9800));
    canvas.drawCircle(Offset(cx + 5, cy - 2), 1.5, Paint()..color = const Color(0xFF1A1A1A));
  }

  static void _renderButterfly(Canvas canvas, Size size, Color color, Color accent, double t) {
    final cx = size.width / 2, cy = size.height / 2;
    final ws = 0.7 + sin(t * 8) * 0.3;
    final wp = Paint()..color = color;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 5, cy - 2), width: size.width * 0.4 * ws, height: size.height * 0.7), wp);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 5, cy - 2), width: size.width * 0.4 * ws, height: size.height * 0.7), wp);
    final bp = Paint()..color = const Color(0xFF4A4A4A)..strokeWidth = 2..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy - 6), Offset(cx, cy + 6), bp);
    canvas.drawLine(Offset(cx, cy - 6), Offset(cx - 4, cy - 10), bp);
    canvas.drawLine(Offset(cx, cy - 6), Offset(cx + 4, cy - 10), bp);
  }

  // ========== Forest ==========

  static void _renderGoblin(Canvas canvas, Size size, Color color, Color accent, double t) {
    final cx = size.width / 2, cy = size.height / 2;
    final sway = sin(t * 5) * 1.5;
    // Body
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + sway, cy + 4), width: size.width * 0.7, height: size.height * 0.6), Paint()..color = color);
    // Head
    canvas.drawCircle(Offset(cx + sway, cy - size.height * 0.15), size.width * 0.28, Paint()..color = color);
    // Ears (pointy)
    final earP = Paint()..color = accent;
    canvas.drawPath(Path()..moveTo(cx - 8 + sway, cy - size.height * 0.2)..lineTo(cx - 14 + sway, cy - size.height * 0.45)..lineTo(cx - 3 + sway, cy - size.height * 0.25)..close(), earP);
    canvas.drawPath(Path()..moveTo(cx + 8 + sway, cy - size.height * 0.2)..lineTo(cx + 14 + sway, cy - size.height * 0.45)..lineTo(cx + 3 + sway, cy - size.height * 0.25)..close(), earP);
    // Eyes
    final ep = Paint()..color = const Color(0xFFFF0000);
    canvas.drawCircle(Offset(cx - 3 + sway, cy - size.height * 0.18), 2, ep);
    canvas.drawCircle(Offset(cx + 3 + sway, cy - size.height * 0.18), 2, ep);
  }

  static void _renderSpider(Canvas canvas, Size size, Color color, Color accent, double t) {
    final cx = size.width / 2, cy = size.height / 2;
    // Body
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: size.width * 0.6, height: size.height * 0.5), Paint()..color = color);
    // Legs (4 pairs)
    final lp = Paint()..color = accent..strokeWidth = 1.5..strokeCap = StrokeCap.round;
    for (var i = 0; i < 4; i++) {
      final legX = cx - 6 + i * 4.0;
      final legAnim = sin(t * 8 + i * 1.5) * 3;
      canvas.drawLine(Offset(legX, cy), Offset(legX - 8, cy + 10 + legAnim), lp);
      canvas.drawLine(Offset(legX, cy), Offset(legX + 8, cy + 10 - legAnim), lp);
    }
    // Eyes (8 dots)
    final ep = Paint()..color = const Color(0xFFFF0000);
    for (var i = 0; i < 4; i++) {
      canvas.drawCircle(Offset(cx - 4 + i * 2.5, cy - 3), 1.2, ep);
    }
  }

  static void _renderBat(Canvas canvas, Size size, Color color, Color accent, double t) {
    final cx = size.width / 2, cy = size.height / 2;
    final wf = sin(t * 12) * 0.5;
    // Body
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: size.width * 0.4, height: size.height * 0.7), Paint()..color = color);
    // Wings
    final wp = Paint()..color = accent;
    canvas.drawPath(Path()..moveTo(cx, cy)..lineTo(cx - size.width * 0.5, cy - size.height * 0.3 + wf * 12)..lineTo(cx - size.width * 0.3, cy + 2)..close(), wp);
    canvas.drawPath(Path()..moveTo(cx, cy)..lineTo(cx + size.width * 0.5, cy - size.height * 0.3 + wf * 12)..lineTo(cx + size.width * 0.3, cy + 2)..close(), wp);
    // Eyes
    canvas.drawCircle(Offset(cx - 3, cy - 3), 1.5, Paint()..color = const Color(0xFFFF5252));
    canvas.drawCircle(Offset(cx + 3, cy - 3), 1.5, Paint()..color = const Color(0xFFFF5252));
  }

  static void _renderFairy(Canvas canvas, Size size, Color color, Color accent, double t) {
    final cx = size.width / 2, cy = size.height / 2;
    final glow = 0.5 + sin(t * 6) * 0.3;
    // Glow
    canvas.drawCircle(Offset(cx, cy), size.width * 0.45, Paint()..color = color.withValues(alpha: glow * 0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    // Body
    canvas.drawCircle(Offset(cx, cy), size.width * 0.2, Paint()..color = color);
    // Wings
    final ws = 0.6 + sin(t * 10) * 0.4;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 4, cy - 2), width: size.width * 0.35 * ws, height: size.height * 0.5), Paint()..color = accent.withValues(alpha: 0.7));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 4, cy - 2), width: size.width * 0.35 * ws, height: size.height * 0.5), Paint()..color = accent.withValues(alpha: 0.7));
  }

  // ========== Desert ==========

  static void _renderScorpion(Canvas canvas, Size size, Color color, Color accent, double t) {
    final cx = size.width / 2, cy = size.height / 2;
    // Body
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 2), width: size.width * 0.6, height: size.height * 0.5), Paint()..color = color);
    // Tail (curved up)
    final tailAnim = sin(t * 4) * 0.2;
    final tp = Paint()..color = accent..strokeWidth = 2.5..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    canvas.drawPath(Path()..moveTo(cx - size.width * 0.25, cy)..quadraticBezierTo(cx - size.width * 0.4, cy - size.height * 0.6 + tailAnim * 10, cx - size.width * 0.2, cy - size.height * 0.7), tp);
    // Stinger
    canvas.drawCircle(Offset(cx - size.width * 0.2, cy - size.height * 0.7), 2, Paint()..color = const Color(0xFFFF0000));
    // Claws
    final cp = Paint()..color = accent..strokeWidth = 2..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx + size.width * 0.2, cy), Offset(cx + size.width * 0.4, cy - 4), cp);
    canvas.drawLine(Offset(cx + size.width * 0.4, cy - 4), Offset(cx + size.width * 0.35, cy - 8), cp);
    // Eyes
    canvas.drawCircle(Offset(cx + 3, cy - 2), 1.5, Paint()..color = const Color(0xFF1A1A1A));
  }

  static void _renderMummy(Canvas canvas, Size size, Color color, Color accent, double t) {
    final cx = size.width / 2, cy = size.height / 2;
    final sway = sin(t * 3) * 1;
    // Body
    canvas.drawRect(Rect.fromCenter(center: Offset(cx + sway, cy + 4), width: size.width * 0.5, height: size.height * 0.7), Paint()..color = color);
    // Head
    canvas.drawCircle(Offset(cx + sway, cy - size.height * 0.2), size.width * 0.22, Paint()..color = color);
    // Bandage lines
    final bp = Paint()..color = accent..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = cy - 4 + i * 8.0;
      canvas.drawLine(Offset(cx - 8 + sway, y), Offset(cx + 8 + sway, y + 2), bp);
    }
    // Glowing eyes
    canvas.drawCircle(Offset(cx - 3 + sway, cy - size.height * 0.22), 2, Paint()..color = const Color(0xFF00E676));
    canvas.drawCircle(Offset(cx + 3 + sway, cy - size.height * 0.22), 2, Paint()..color = const Color(0xFF00E676));
  }

  static void _renderEagle(Canvas canvas, Size size, Color color, Color accent, double t) {
    final cx = size.width / 2, cy = size.height / 2;
    final wf = sin(t * 8) * 0.3;
    // Body
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: size.width * 0.5, height: size.height * 0.6), Paint()..color = color);
    // Wide wings
    final wp = Paint()..color = accent;
    canvas.drawPath(Path()..moveTo(cx, cy - 2)..lineTo(cx - size.width * 0.5, cy - size.height * 0.2 + wf * 15)..lineTo(cx - size.width * 0.3, cy + 4)..close(), wp);
    canvas.drawPath(Path()..moveTo(cx, cy - 2)..lineTo(cx + size.width * 0.5, cy - size.height * 0.2 + wf * 15)..lineTo(cx + size.width * 0.3, cy + 4)..close(), wp);
    // Beak
    canvas.drawPath(Path()..moveTo(cx + size.width * 0.25, cy - 2)..lineTo(cx + size.width * 0.4, cy)..lineTo(cx + size.width * 0.25, cy + 2)..close(), Paint()..color = const Color(0xFFFF9800));
    canvas.drawCircle(Offset(cx + 6, cy - 3), 1.5, Paint()..color = const Color(0xFF1A1A1A));
  }

  // ========== Shared: Spirit ==========

  static void _renderSpirit(Canvas canvas, Size size, Color color, Color accent, double t) {
    final cx = size.width / 2, cy = size.height / 2;
    final pulse = 0.8 + sin(t * 5) * 0.2;
    // Glow aura
    canvas.drawCircle(Offset(cx, cy), size.width * 0.4 * pulse, Paint()..color = color.withValues(alpha: 0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    // Core
    canvas.drawCircle(Offset(cx, cy), size.width * 0.25 * pulse, Paint()..color = color);
    // Inner
    canvas.drawCircle(Offset(cx, cy - 2), size.width * 0.12, Paint()..color = accent);
    // Eyes
    canvas.drawCircle(Offset(cx - 3, cy - 1), 1.5, Paint()..color = const Color(0xFF1A1A1A));
    canvas.drawCircle(Offset(cx + 3, cy - 1), 1.5, Paint()..color = const Color(0xFF1A1A1A));
  }

  // ========== Snowfield ==========

  static void _renderGolem(Canvas canvas, Size size, Color color, Color accent, double t) {
    final cx = size.width / 2, cy = size.height / 2;
    final shake = sin(t * 6) * 0.5;
    // Body (big rectangle)
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx + shake, cy + 4), width: size.width * 0.75, height: size.height * 0.7), const Radius.circular(4)),
      Paint()..color = color,
    );
    // Head
    canvas.drawCircle(Offset(cx + shake, cy - size.height * 0.2), size.width * 0.25, Paint()..color = color);
    // Ice crystals on head
    canvas.drawCircle(Offset(cx - 5 + shake, cy - size.height * 0.35), 3, Paint()..color = accent);
    canvas.drawCircle(Offset(cx + 5 + shake, cy - size.height * 0.32), 2.5, Paint()..color = accent);
    // Eyes
    canvas.drawCircle(Offset(cx - 4 + shake, cy - size.height * 0.22), 2, Paint()..color = const Color(0xFF42A5F5));
    canvas.drawCircle(Offset(cx + 4 + shake, cy - size.height * 0.22), 2, Paint()..color = const Color(0xFF42A5F5));
  }

  static void _renderWolf(Canvas canvas, Size size, Color color, Color accent, double t) {
    final cx = size.width / 2, cy = size.height / 2;
    final run = sin(t * 8) * 2;
    // Body
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 2), width: size.width * 0.8, height: size.height * 0.5), Paint()..color = color);
    // Head
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + size.width * 0.25, cy - 3), width: size.width * 0.35, height: size.height * 0.4), Paint()..color = color);
    // Ears
    final ep = Paint()..color = accent;
    canvas.drawPath(Path()..moveTo(cx + size.width * 0.18, cy - 8)..lineTo(cx + size.width * 0.15, cy - 16)..lineTo(cx + size.width * 0.25, cy - 8)..close(), ep);
    canvas.drawPath(Path()..moveTo(cx + size.width * 0.3, cy - 8)..lineTo(cx + size.width * 0.32, cy - 16)..lineTo(cx + size.width * 0.38, cy - 8)..close(), ep);
    // Eye
    canvas.drawCircle(Offset(cx + size.width * 0.3, cy - 5), 1.5, Paint()..color = const Color(0xFFFFEB3B));
    // Legs
    final lp = Paint()..color = color..strokeWidth = 3..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 6, cy + 6), Offset(cx - 7, cy + 12 + run), lp);
    canvas.drawLine(Offset(cx + 6, cy + 6), Offset(cx + 7, cy + 12 - run), lp);
  }

  static void _renderOwl(Canvas canvas, Size size, Color color, Color accent, double t) {
    final cx = size.width / 2, cy = size.height / 2;
    // Body
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 2), width: size.width * 0.6, height: size.height * 0.7), Paint()..color = color);
    // Head
    canvas.drawCircle(Offset(cx, cy - size.height * 0.15), size.width * 0.28, Paint()..color = color);
    // Ear tufts
    canvas.drawPath(Path()..moveTo(cx - 6, cy - size.height * 0.25)..lineTo(cx - 9, cy - size.height * 0.45)..lineTo(cx - 2, cy - size.height * 0.3)..close(), Paint()..color = accent);
    canvas.drawPath(Path()..moveTo(cx + 6, cy - size.height * 0.25)..lineTo(cx + 9, cy - size.height * 0.45)..lineTo(cx + 2, cy - size.height * 0.3)..close(), Paint()..color = accent);
    // Big eyes
    final blink = sin(t * 2) > 0.95 ? 0.1 : 1.0;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 4, cy - size.height * 0.15), width: 6, height: 6 * blink), Paint()..color = const Color(0xFFFFD600));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 4, cy - size.height * 0.15), width: 6, height: 6 * blink), Paint()..color = const Color(0xFFFFD600));
    canvas.drawCircle(Offset(cx - 4, cy - size.height * 0.15), 1.5 * blink, Paint()..color = const Color(0xFF1A1A1A));
    canvas.drawCircle(Offset(cx + 4, cy - size.height * 0.15), 1.5 * blink, Paint()..color = const Color(0xFF1A1A1A));
  }

  // ========== Volcano ==========

  static void _renderImp(Canvas canvas, Size size, Color color, Color accent, double t) {
    final cx = size.width / 2, cy = size.height / 2;
    final hop = sin(t * 7) * 2;
    // Body
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 3 + hop), width: size.width * 0.6, height: size.height * 0.55), Paint()..color = color);
    // Head
    canvas.drawCircle(Offset(cx, cy - size.height * 0.1 + hop), size.width * 0.23, Paint()..color = color);
    // Horns
    final hp = Paint()..color = const Color(0xFF4A0000)..strokeWidth = 2..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 5, cy - size.height * 0.2 + hop), Offset(cx - 8, cy - size.height * 0.4 + hop), hp);
    canvas.drawLine(Offset(cx + 5, cy - size.height * 0.2 + hop), Offset(cx + 8, cy - size.height * 0.4 + hop), hp);
    // Flame glow
    canvas.drawCircle(Offset(cx, cy + hop), size.width * 0.15, Paint()..color = accent.withValues(alpha: 0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    // Eyes
    canvas.drawCircle(Offset(cx - 3, cy - size.height * 0.12 + hop), 2, Paint()..color = const Color(0xFFFFD600));
    canvas.drawCircle(Offset(cx + 3, cy - size.height * 0.12 + hop), 2, Paint()..color = const Color(0xFFFFD600));
  }

  static void _renderDragonkin(Canvas canvas, Size size, Color color, Color accent, double t) {
    final cx = size.width / 2, cy = size.height / 2;
    final breathe = sin(t * 3) * 1;
    // Body
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 4 + breathe), width: size.width * 0.7, height: size.height * 0.6), Paint()..color = color);
    // Head
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + size.width * 0.15, cy - size.height * 0.1), width: size.width * 0.4, height: size.height * 0.35), Paint()..color = color);
    // Horns
    final hp = Paint()..color = accent..strokeWidth = 2..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx + 4, cy - size.height * 0.2), Offset(cx, cy - size.height * 0.42), hp);
    canvas.drawLine(Offset(cx + size.width * 0.2, cy - size.height * 0.2), Offset(cx + size.width * 0.28, cy - size.height * 0.42), hp);
    // Tail
    canvas.drawPath(
      Path()..moveTo(cx - size.width * 0.3, cy + 5)..quadraticBezierTo(cx - size.width * 0.5, cy, cx - size.width * 0.4, cy - 8),
      Paint()..color = color..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round,
    );
    // Eye
    canvas.drawCircle(Offset(cx + size.width * 0.2, cy - size.height * 0.14), 2, Paint()..color = const Color(0xFFFFD600));
  }

  static void _renderPhoenix(Canvas canvas, Size size, Color color, Color accent, double t) {
    final cx = size.width / 2, cy = size.height / 2;
    final wf = sin(t * 7) * 0.4;
    // Flame aura
    canvas.drawCircle(Offset(cx, cy), size.width * 0.4, Paint()..color = color.withValues(alpha: 0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    // Body
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: size.width * 0.5, height: size.height * 0.55), Paint()..color = color);
    // Wings (fiery)
    final wp = Paint()..color = accent;
    canvas.drawPath(Path()..moveTo(cx, cy - 2)..lineTo(cx - size.width * 0.5, cy - size.height * 0.3 + wf * 14)..lineTo(cx - size.width * 0.2, cy + 4)..close(), wp);
    canvas.drawPath(Path()..moveTo(cx, cy - 2)..lineTo(cx + size.width * 0.5, cy - size.height * 0.3 + wf * 14)..lineTo(cx + size.width * 0.2, cy + 4)..close(), wp);
    // Tail flames
    final tailFlicker = sin(t * 15) * 3;
    canvas.drawPath(Path()..moveTo(cx - size.width * 0.2, cy + 4)..lineTo(cx - size.width * 0.35, cy + 8 + tailFlicker)..lineTo(cx - size.width * 0.1, cy + 6)..close(), Paint()..color = const Color(0xFFFFD600));
    // Head crest
    canvas.drawCircle(Offset(cx + size.width * 0.15, cy - size.height * 0.15), size.width * 0.12, Paint()..color = color);
    canvas.drawCircle(Offset(cx + size.width * 0.18, cy - size.height * 0.18), 1.5, Paint()..color = const Color(0xFF1A1A1A));
  }

  // ========== Generic fallback ==========

  static void _renderGeneric(Canvas canvas, Size size, Color color, Color accent, double t, EnemyType type) {
    final cx = size.width / 2, cy = size.height / 2;
    final anim = sin(t * 5) * 2;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + anim), width: size.width * 0.7, height: size.height * 0.6), Paint()..color = color);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - 2 + anim), width: size.width * 0.3, height: size.height * 0.2), Paint()..color = accent);
    final ep = Paint()..color = const Color(0xFF1A1A1A);
    canvas.drawCircle(Offset(cx - 3, cy - 2 + anim), 2, ep);
    canvas.drawCircle(Offset(cx + 3, cy - 2 + anim), 2, ep);
  }
}
