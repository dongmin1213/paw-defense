import 'dart:math';
import 'dart:ui';

class CompanionRenderer {
  static void render(Canvas canvas, String id, Size size, double animTimer) {
    switch (id) {
      case 'cat':
        _renderCat(canvas, size, animTimer);
        break;
      case 'hamster':
        _renderHamster(canvas, size, animTimer);
        break;
      case 'rabbit':
        _renderRabbit(canvas, size, animTimer);
        break;
      case 'owl':
        _renderOwl(canvas, size, animTimer);
        break;
      case 'fox':
        _renderFox(canvas, size, animTimer);
        break;
      case 'penguin':
        _renderPenguin(canvas, size, animTimer);
        break;
      case 'wolf_c':
        _renderWolf(canvas, size, animTimer);
        break;
      case 'unicorn':
        _renderUnicorn(canvas, size, animTimer);
        break;
      case 'dragon_c':
        _renderDragon(canvas, size, animTimer);
        break;
      case 'phoenix_c':
        _renderPhoenix(canvas, size, animTimer);
        break;
      default:
        _renderDefault(canvas, size, animTimer);
    }
  }

  static void _renderCat(Canvas canvas, Size size, double t) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final bounce = sin(t * 4) * 1.5;

    // Body
    final bodyPaint = Paint()..color = const Color(0xFFFF9800);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + bounce), width: size.width * 0.7, height: size.height * 0.5), bodyPaint);

    // Head
    canvas.drawCircle(Offset(cx, cy - size.height * 0.15 + bounce), size.width * 0.25, bodyPaint);

    // Ears
    final earPaint = Paint()..color = const Color(0xFFFF9800);
    final earInnerPaint = Paint()..color = const Color(0xFFFFE0B2);
    // Left ear
    canvas.drawPath(
      Path()
        ..moveTo(cx - 6, cy - size.height * 0.3 + bounce)
        ..lineTo(cx - 10, cy - size.height * 0.5 + bounce)
        ..lineTo(cx - 2, cy - size.height * 0.3 + bounce)
        ..close(),
      earPaint,
    );
    // Right ear
    canvas.drawPath(
      Path()
        ..moveTo(cx + 2, cy - size.height * 0.3 + bounce)
        ..lineTo(cx + 10, cy - size.height * 0.5 + bounce)
        ..lineTo(cx + 6, cy - size.height * 0.3 + bounce)
        ..close(),
      earPaint,
    );

    // Eyes
    final eyePaint = Paint()..color = const Color(0xFF333333);
    canvas.drawCircle(Offset(cx - 4, cy - size.height * 0.15 + bounce), 1.5, eyePaint);
    canvas.drawCircle(Offset(cx + 4, cy - size.height * 0.15 + bounce), 1.5, eyePaint);

    // Tail
    final tailPaint = Paint()
      ..color = const Color(0xFFFF9800)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx + size.width * 0.3, cy + bounce), width: 10, height: 12),
      0, pi * 0.8, false, tailPaint,
    );
  }

  static void _renderHamster(Canvas canvas, Size size, double t) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final bounce = sin(t * 5) * 1.5;

    // Round body
    final bodyPaint = Paint()..color = const Color(0xFFFFCC80);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + bounce), width: size.width * 0.7, height: size.height * 0.6), bodyPaint);

    // Cheeks (puffy)
    final cheekPaint = Paint()..color = const Color(0xFFFFE0B2);
    canvas.drawCircle(Offset(cx - 5, cy + 2 + bounce), 4, cheekPaint);
    canvas.drawCircle(Offset(cx + 5, cy + 2 + bounce), 4, cheekPaint);

    // Ears
    canvas.drawCircle(Offset(cx - 6, cy - size.height * 0.25 + bounce), 3, bodyPaint);
    canvas.drawCircle(Offset(cx + 6, cy - size.height * 0.25 + bounce), 3, bodyPaint);
    final earInner = Paint()..color = const Color(0xFFFFAB91);
    canvas.drawCircle(Offset(cx - 6, cy - size.height * 0.25 + bounce), 1.5, earInner);
    canvas.drawCircle(Offset(cx + 6, cy - size.height * 0.25 + bounce), 1.5, earInner);

    // Eyes
    final eyePaint = Paint()..color = const Color(0xFF333333);
    canvas.drawCircle(Offset(cx - 3, cy - 3 + bounce), 1.5, eyePaint);
    canvas.drawCircle(Offset(cx + 3, cy - 3 + bounce), 1.5, eyePaint);

    // Nose
    final nosePaint = Paint()..color = const Color(0xFFFF8A65);
    canvas.drawCircle(Offset(cx, cy + bounce), 1, nosePaint);
  }

  static void _renderRabbit(Canvas canvas, Size size, double t) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final bounce = sin(t * 3) * 2;

    // Body
    final bodyPaint = Paint()..color = const Color(0xFFF5F5F5);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 2 + bounce), width: size.width * 0.6, height: size.height * 0.5), bodyPaint);

    // Head
    canvas.drawCircle(Offset(cx, cy - 4 + bounce), size.width * 0.22, bodyPaint);

    // Long ears
    final earPaint = Paint()..color = const Color(0xFFF5F5F5);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 4, cy - size.height * 0.4 + bounce), width: 4, height: 12), earPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 4, cy - size.height * 0.4 + bounce), width: 4, height: 12), earPaint);
    final innerEar = Paint()..color = const Color(0xFFFFCDD2);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 4, cy - size.height * 0.4 + bounce), width: 2, height: 8), innerEar);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 4, cy - size.height * 0.4 + bounce), width: 2, height: 8), innerEar);

    // Eyes
    final eyePaint = Paint()..color = const Color(0xFFE53935);
    canvas.drawCircle(Offset(cx - 3, cy - 5 + bounce), 1.5, eyePaint);
    canvas.drawCircle(Offset(cx + 3, cy - 5 + bounce), 1.5, eyePaint);

    // Nose
    final nosePaint = Paint()..color = const Color(0xFFFFCDD2);
    canvas.drawCircle(Offset(cx, cy - 2 + bounce), 1, nosePaint);
  }

  static void _renderOwl(Canvas canvas, Size size, double t) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final headTilt = sin(t * 2) * 0.05;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(headTilt);
    canvas.translate(-cx, -cy);

    // Body
    final bodyPaint = Paint()..color = const Color(0xFF8D6E63);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 2), width: size.width * 0.65, height: size.height * 0.55), bodyPaint);

    // Belly
    final bellyPaint = Paint()..color = const Color(0xFFD7CCC8);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 4), width: size.width * 0.4, height: size.height * 0.35), bellyPaint);

    // Head
    canvas.drawCircle(Offset(cx, cy - 5), size.width * 0.25, bodyPaint);

    // Big eyes
    final eyeWhite = Paint()..color = const Color(0xFFFFFFFF);
    final eyePupil = Paint()..color = const Color(0xFF333333);
    canvas.drawCircle(Offset(cx - 4, cy - 6), 3.5, eyeWhite);
    canvas.drawCircle(Offset(cx + 4, cy - 6), 3.5, eyeWhite);
    // Blink
    final blinkPhase = (t * 0.5) % 3;
    if (blinkPhase < 0.1) {
      canvas.drawRect(Rect.fromCenter(center: Offset(cx - 4, cy - 6), width: 7, height: 1), Paint()..color = const Color(0xFF8D6E63));
      canvas.drawRect(Rect.fromCenter(center: Offset(cx + 4, cy - 6), width: 7, height: 1), Paint()..color = const Color(0xFF8D6E63));
    } else {
      canvas.drawCircle(Offset(cx - 4, cy - 6), 2, eyePupil);
      canvas.drawCircle(Offset(cx + 4, cy - 6), 2, eyePupil);
    }

    // Ear tufts
    canvas.drawPath(
      Path()..moveTo(cx - 7, cy - 9)..lineTo(cx - 10, cy - 15)..lineTo(cx - 4, cy - 10)..close(),
      bodyPaint,
    );
    canvas.drawPath(
      Path()..moveTo(cx + 4, cy - 10)..lineTo(cx + 10, cy - 15)..lineTo(cx + 7, cy - 9)..close(),
      bodyPaint,
    );

    // Beak
    final beakPaint = Paint()..color = const Color(0xFFFFB300);
    canvas.drawPath(
      Path()..moveTo(cx - 2, cy - 3)..lineTo(cx, cy - 1)..lineTo(cx + 2, cy - 3)..close(),
      beakPaint,
    );

    canvas.restore();
  }

  static void _renderFox(Canvas canvas, Size size, double t) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final bounce = sin(t * 3.5) * 1;

    // Body
    final bodyPaint = Paint()..color = const Color(0xFFFF5722);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 2 + bounce), width: size.width * 0.7, height: size.height * 0.45), bodyPaint);

    // Head (pointed)
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 2, cy - 4 + bounce), width: size.width * 0.45, height: size.height * 0.3), bodyPaint);

    // Ears
    canvas.drawPath(
      Path()..moveTo(cx - 4, cy - 8 + bounce)..lineTo(cx - 8, cy - 16 + bounce)..lineTo(cx, cy - 8 + bounce)..close(),
      bodyPaint,
    );
    canvas.drawPath(
      Path()..moveTo(cx + 2, cy - 8 + bounce)..lineTo(cx + 8, cy - 16 + bounce)..lineTo(cx + 6, cy - 8 + bounce)..close(),
      bodyPaint,
    );

    // White chest
    final whitePaint = Paint()..color = const Color(0xFFFFCCBC);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 4 + bounce), width: size.width * 0.35, height: size.height * 0.25), whitePaint);

    // Eyes
    final eyePaint = Paint()..color = const Color(0xFF333333);
    canvas.drawCircle(Offset(cx - 3, cy - 5 + bounce), 1.5, eyePaint);
    canvas.drawCircle(Offset(cx + 5, cy - 5 + bounce), 1.5, eyePaint);

    // Nose
    canvas.drawCircle(Offset(cx + 7, cy - 3 + bounce), 1, eyePaint);

    // Tail
    final tailPaint = Paint()..color = const Color(0xFFFF5722);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - size.width * 0.35, cy + bounce), width: 8, height: 5), tailPaint);
    final tipPaint = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawCircle(Offset(cx - size.width * 0.4, cy + bounce), 2, tipPaint);
  }

  static void _renderPenguin(Canvas canvas, Size size, double t) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final waddle = sin(t * 4) * 1;

    // Body
    final bodyPaint = Paint()..color = const Color(0xFF263238);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + waddle, cy + 2), width: size.width * 0.6, height: size.height * 0.65), bodyPaint);

    // White belly
    final bellyPaint = Paint()..color = const Color(0xFFECEFF1);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + waddle, cy + 3), width: size.width * 0.4, height: size.height * 0.5), bellyPaint);

    // Head
    canvas.drawCircle(Offset(cx + waddle, cy - 6), size.width * 0.22, bodyPaint);

    // Eyes
    final eyePaint = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawCircle(Offset(cx - 3 + waddle, cy - 7), 2, eyePaint);
    canvas.drawCircle(Offset(cx + 3 + waddle, cy - 7), 2, eyePaint);
    final pupilPaint = Paint()..color = const Color(0xFF333333);
    canvas.drawCircle(Offset(cx - 3 + waddle, cy - 7), 1, pupilPaint);
    canvas.drawCircle(Offset(cx + 3 + waddle, cy - 7), 1, pupilPaint);

    // Beak
    final beakPaint = Paint()..color = const Color(0xFFFF9800);
    canvas.drawPath(
      Path()..moveTo(cx - 2 + waddle, cy - 5)..lineTo(cx + waddle, cy - 3)..lineTo(cx + 2 + waddle, cy - 5)..close(),
      beakPaint,
    );

    // Feet
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 3 + waddle, cy + size.height * 0.32), width: 5, height: 2), beakPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 3 + waddle, cy + size.height * 0.32), width: 5, height: 2), beakPaint);
  }

  static void _renderWolf(Canvas canvas, Size size, double t) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final breathe = sin(t * 2) * 0.5;

    // Body
    final bodyPaint = Paint()..color = const Color(0xFF546E7A);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 2 + breathe), width: size.width * 0.75, height: size.height * 0.45), bodyPaint);

    // Head
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 4, cy - 4 + breathe), width: size.width * 0.4, height: size.height * 0.3), bodyPaint);

    // Muzzle
    final lightPaint = Paint()..color = const Color(0xFFB0BEC5);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 8, cy - 2 + breathe), width: 6, height: 4), lightPaint);

    // Ears
    canvas.drawPath(
      Path()..moveTo(cx - 2, cy - 8 + breathe)..lineTo(cx - 5, cy - 15 + breathe)..lineTo(cx + 2, cy - 8 + breathe)..close(),
      bodyPaint,
    );
    canvas.drawPath(
      Path()..moveTo(cx + 4, cy - 8 + breathe)..lineTo(cx + 9, cy - 15 + breathe)..lineTo(cx + 7, cy - 8 + breathe)..close(),
      bodyPaint,
    );

    // Eyes (fierce)
    final eyePaint = Paint()..color = const Color(0xFFFFEB3B);
    canvas.drawCircle(Offset(cx + 1, cy - 5 + breathe), 2, eyePaint);
    canvas.drawCircle(Offset(cx + 7, cy - 5 + breathe), 2, eyePaint);
    final pupilPaint = Paint()..color = const Color(0xFF333333);
    canvas.drawCircle(Offset(cx + 1, cy - 5 + breathe), 1, pupilPaint);
    canvas.drawCircle(Offset(cx + 7, cy - 5 + breathe), 1, pupilPaint);

    // Nose
    canvas.drawCircle(Offset(cx + 10, cy - 2 + breathe), 1, pupilPaint);
  }

  static void _renderUnicorn(Canvas canvas, Size size, double t) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final float_ = sin(t * 2.5) * 2;

    // Sparkle effect
    final sparklePaint = Paint()..color = Color.fromRGBO(255, 255, 255, (sin(t * 6) * 0.3 + 0.5).clamp(0, 1));
    for (var i = 0; i < 3; i++) {
      final sx = cx + cos(t * 3 + i * 2.1) * 10;
      final sy = cy + sin(t * 2 + i * 1.7) * 8 + float_;
      canvas.drawCircle(Offset(sx, sy), 1, sparklePaint);
    }

    // Body
    final bodyPaint = Paint()..color = const Color(0xFFF3E5F5);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 2 + float_), width: size.width * 0.65, height: size.height * 0.4), bodyPaint);

    // Head
    canvas.drawCircle(Offset(cx + 2, cy - 4 + float_), size.width * 0.2, bodyPaint);

    // Horn (rainbow shimmer)
    final hornHue = (t * 60) % 360;
    final hornColor = HSVColor.fromAHSV(1.0, hornHue, 0.6, 1.0).toColor();
    final hornPaint = Paint()..color = hornColor;
    canvas.drawPath(
      Path()..moveTo(cx, cy - 8 + float_)..lineTo(cx + 2, cy - 18 + float_)..lineTo(cx + 4, cy - 8 + float_)..close(),
      hornPaint,
    );

    // Mane (purple)
    final manePaint = Paint()..color = const Color(0xFFCE93D8);
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(Offset(cx - 3 + i * 2.0, cy - 3 + i * 2 + float_), 3 - i * 0.5, manePaint);
    }

    // Eyes
    final eyePaint = Paint()..color = const Color(0xFF7B1FA2);
    canvas.drawCircle(Offset(cx + 1, cy - 5 + float_), 1.5, eyePaint);

    // Legs
    final legPaint = Paint()
      ..color = const Color(0xFFF3E5F5)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(cx - 5, cy + 6 + float_), Offset(cx - 5, cy + 12 + float_), legPaint);
    canvas.drawLine(Offset(cx + 5, cy + 6 + float_), Offset(cx + 5, cy + 12 + float_), legPaint);
  }

  static void _renderDragon(Canvas canvas, Size size, double t) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final hover = sin(t * 3) * 2;

    // Wings
    final wingPaint = Paint()..color = const Color(0xFFEF5350).withValues(alpha: 0.7);
    canvas.drawPath(
      Path()
        ..moveTo(cx - 4, cy - 2 + hover)
        ..lineTo(cx - 14, cy - 10 + hover)
        ..lineTo(cx - 10, cy + hover)
        ..close(),
      wingPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx + 4, cy - 2 + hover)
        ..lineTo(cx + 14, cy - 10 + hover)
        ..lineTo(cx + 10, cy + hover)
        ..close(),
      wingPaint,
    );

    // Body
    final bodyPaint = Paint()..color = const Color(0xFFD32F2F);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 2 + hover), width: size.width * 0.55, height: size.height * 0.4), bodyPaint);

    // Head
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 3, cy - 5 + hover), width: size.width * 0.35, height: size.height * 0.25), bodyPaint);

    // Horns
    final hornPaint = Paint()..color = const Color(0xFFFFCDD2);
    canvas.drawPath(
      Path()..moveTo(cx - 1, cy - 9 + hover)..lineTo(cx - 4, cy - 15 + hover)..lineTo(cx + 1, cy - 9 + hover)..close(),
      hornPaint,
    );
    canvas.drawPath(
      Path()..moveTo(cx + 4, cy - 9 + hover)..lineTo(cx + 8, cy - 14 + hover)..lineTo(cx + 6, cy - 9 + hover)..close(),
      hornPaint,
    );

    // Eyes (glowing)
    final eyeGlow = Paint()..color = const Color(0xFFFFD600);
    canvas.drawCircle(Offset(cx + 1, cy - 6 + hover), 2, eyeGlow);
    canvas.drawCircle(Offset(cx + 6, cy - 6 + hover), 2, eyeGlow);
    final pupilPaint = Paint()..color = const Color(0xFF333333);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx + 1, cy - 6 + hover), width: 1, height: 3), pupilPaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx + 6, cy - 6 + hover), width: 1, height: 3), pupilPaint);

    // Fire breath (occasional)
    if ((t * 2) % 4 < 1) {
      final firePaint = Paint()..color = const Color(0xFFFF9800).withValues(alpha: 0.6);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx + 12, cy - 4 + hover), width: 6, height: 3), firePaint);
    }

    // Tail
    final tailPaint = Paint()
      ..color = const Color(0xFFD32F2F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx - 8, cy + 4 + hover), width: 10, height: 8),
      pi * 0.5, pi * 0.8, false, tailPaint,
    );
  }

  static void _renderPhoenix(Canvas canvas, Size size, double t) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final hover = sin(t * 3) * 2;

    // Fire aura
    final auraPaint = Paint()..color = const Color(0xFFFF6F00).withValues(alpha: (sin(t * 8) * 0.2 + 0.3).clamp(0, 1));
    canvas.drawCircle(Offset(cx, cy + hover), size.width * 0.45, auraPaint);

    // Wings (flaming)
    final wingPaint = Paint()..color = const Color(0xFFFF8F00);
    final wingSpan = sin(t * 5) * 3;
    canvas.drawPath(
      Path()
        ..moveTo(cx - 3, cy + hover)
        ..lineTo(cx - 14 - wingSpan, cy - 8 + hover)
        ..lineTo(cx - 8, cy + 3 + hover)
        ..close(),
      wingPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx + 3, cy + hover)
        ..lineTo(cx + 14 + wingSpan, cy - 8 + hover)
        ..lineTo(cx + 8, cy + 3 + hover)
        ..close(),
      wingPaint,
    );

    // Body
    final bodyPaint = Paint()..color = const Color(0xFFFF6F00);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 1 + hover), width: size.width * 0.45, height: size.height * 0.35), bodyPaint);

    // Head
    canvas.drawCircle(Offset(cx, cy - 5 + hover), size.width * 0.17, bodyPaint);

    // Crest
    final crestPaint = Paint()..color = const Color(0xFFFFD600);
    canvas.drawPath(
      Path()..moveTo(cx - 2, cy - 8 + hover)..lineTo(cx, cy - 14 + hover)..lineTo(cx + 2, cy - 8 + hover)..close(),
      crestPaint,
    );

    // Eyes
    final eyePaint = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawCircle(Offset(cx - 2, cy - 6 + hover), 1.5, eyePaint);
    canvas.drawCircle(Offset(cx + 2, cy - 6 + hover), 1.5, eyePaint);

    // Tail feathers (flame)
    final tailPaint = Paint()..color = const Color(0xFFFFE082);
    for (var i = 0; i < 3; i++) {
      final tailY = cy + 5 + i * 3 + hover;
      final sway = sin(t * 6 + i * 0.5) * 2;
      canvas.drawOval(Rect.fromCenter(center: Offset(cx + sway, tailY), width: 4 - i.toDouble(), height: 3), tailPaint);
    }
  }

  static void _renderDefault(Canvas canvas, Size size, double t) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final bounce = sin(t * 3) * 2;

    final paint = Paint()..color = const Color(0xFF9E9E9E);
    canvas.drawCircle(Offset(cx, cy + bounce), size.width * 0.3, paint);

    final eyePaint = Paint()..color = const Color(0xFF333333);
    canvas.drawCircle(Offset(cx - 3, cy - 2 + bounce), 1.5, eyePaint);
    canvas.drawCircle(Offset(cx + 3, cy - 2 + bounce), 1.5, eyePaint);
  }
}
