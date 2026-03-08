import 'dart:math';
import 'dart:ui';

class BossRenderer {
  static void render(Canvas canvas, String regionId, Size size, double animTimer) {
    switch (regionId) {
      case 'meadow':
        _renderMeadowBoss(canvas, size, animTimer);
        break;
      case 'forest':
        _renderForestBoss(canvas, size, animTimer);
        break;
      case 'desert':
        _renderDesertBoss(canvas, size, animTimer);
        break;
      case 'snowfield':
        _renderSnowfieldBoss(canvas, size, animTimer);
        break;
      case 'volcano':
        _renderVolcanoBoss(canvas, size, animTimer);
        break;
      default:
        _renderMeadowBoss(canvas, size, animTimer);
    }
  }

  // 초원 보스: 킹슬라임 (거대 슬라임)
  static void _renderMeadowBoss(Canvas canvas, Size size, double t) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final squish = sin(t * 3) * 3;

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + size.height * 0.4), width: size.width * 0.7, height: 8),
      Paint()..color = const Color(0x44000000),
    );

    // Body (bouncy)
    final bodyPaint = Paint()..color = const Color(0xFF66BB6A);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + squish * 0.3),
        width: size.width * 0.8 + squish,
        height: size.height * 0.7 - squish,
      ),
      bodyPaint,
    );

    // Shiny spot
    final shinePaint = Paint()..color = const Color(0xFFA5D6A7).withValues(alpha: 0.6);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 8, cy - 8 + squish * 0.3), width: 10, height: 8),
      shinePaint,
    );

    // Crown
    final crownPaint = Paint()..color = const Color(0xFFFFD600);
    final crownY = cy - size.height * 0.25 + squish * 0.2;
    canvas.drawPath(
      Path()
        ..moveTo(cx - 12, crownY)
        ..lineTo(cx - 10, crownY - 10)
        ..lineTo(cx - 5, crownY - 4)
        ..lineTo(cx, crownY - 12)
        ..lineTo(cx + 5, crownY - 4)
        ..lineTo(cx + 10, crownY - 10)
        ..lineTo(cx + 12, crownY)
        ..close(),
      crownPaint,
    );

    // Eyes (angry)
    final eyePaint = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 8, cy - 2), width: 10, height: 8), eyePaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 8, cy - 2), width: 10, height: 8), eyePaint);
    final pupilPaint = Paint()..color = const Color(0xFF1B5E20);
    canvas.drawCircle(Offset(cx - 7, cy - 1), 3, pupilPaint);
    canvas.drawCircle(Offset(cx + 9, cy - 1), 3, pupilPaint);
    // Angry brows
    final browPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx - 13, cy - 8), Offset(cx - 4, cy - 6), browPaint);
    canvas.drawLine(Offset(cx + 4, cy - 6), Offset(cx + 13, cy - 8), browPaint);

    // Mouth
    final mouthPaint = Paint()
      ..color = const Color(0xFF1B5E20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy + 6), width: 16, height: 8),
      0, pi, false, mouthPaint,
    );
  }

  // 숲 보스: 트렌트 (나무 괴물)
  static void _renderForestBoss(Canvas canvas, Size size, double t) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final sway = sin(t * 1.5) * 2;

    // Roots
    final rootPaint = Paint()..color = const Color(0xFF5D4037);
    for (var i = -2; i <= 2; i++) {
      canvas.drawLine(
        Offset(cx + i * 8, cy + size.height * 0.3),
        Offset(cx + i * 12 + sway, cy + size.height * 0.45),
        rootPaint..strokeWidth = 3,
      );
    }

    // Trunk
    final trunkPaint = Paint()..color = const Color(0xFF6D4C41);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + sway * 0.5, cy), width: size.width * 0.4, height: size.height * 0.6),
        const Radius.circular(6),
      ),
      trunkPaint,
    );

    // Branches/arms
    final branchPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 10 + sway, cy - 5), Offset(cx - 22 + sway * 1.5, cy - 15), branchPaint);
    canvas.drawLine(Offset(cx + 10 + sway, cy - 5), Offset(cx + 22 + sway * 1.5, cy - 10), branchPaint);

    // Leaves crown
    final leafPaint = Paint()..color = const Color(0xFF388E3C);
    canvas.drawCircle(Offset(cx + sway, cy - size.height * 0.25), 14, leafPaint);
    canvas.drawCircle(Offset(cx - 8 + sway, cy - size.height * 0.2), 10, leafPaint);
    canvas.drawCircle(Offset(cx + 8 + sway, cy - size.height * 0.2), 10, leafPaint);

    // Face on trunk
    final eyePaint = Paint()..color = const Color(0xFFFFD600);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 5 + sway * 0.5, cy - 4), width: 6, height: 8), eyePaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 5 + sway * 0.5, cy - 4), width: 6, height: 8), eyePaint);
    final pupilPaint = Paint()..color = const Color(0xFF333333);
    canvas.drawCircle(Offset(cx - 5 + sway * 0.5, cy - 3), 2, pupilPaint);
    canvas.drawCircle(Offset(cx + 5 + sway * 0.5, cy - 3), 2, pupilPaint);

    // Mouth (hollow)
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + sway * 0.5, cy + 8), width: 8, height: 6),
      Paint()..color = const Color(0xFF3E2723),
    );
  }

  // 사막 보스: 스핑크스
  static void _renderDesertBoss(Canvas canvas, Size size, double t) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final breathe = sin(t * 2) * 1;

    // Body (lion-like)
    final bodyPaint = Paint()..color = const Color(0xFFD4A574);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 5 + breathe), width: size.width * 0.8, height: size.height * 0.4),
      bodyPaint,
    );

    // Head
    final headPaint = Paint()..color = const Color(0xFFDEB887);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 8 + breathe), width: size.width * 0.5, height: size.height * 0.4),
      headPaint,
    );

    // Headdress
    final dressPaint = Paint()..color = const Color(0xFFFFD600);
    canvas.drawPath(
      Path()
        ..moveTo(cx - 15, cy - 8 + breathe)
        ..lineTo(cx - 18, cy - 22 + breathe)
        ..lineTo(cx, cy - 28 + breathe)
        ..lineTo(cx + 18, cy - 22 + breathe)
        ..lineTo(cx + 15, cy - 8 + breathe)
        ..close(),
      dressPaint,
    );
    // Blue stripes
    final stripePaint = Paint()
      ..color = const Color(0xFF1565C0)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(cx - 10, cy - 18 + breathe), Offset(cx - 12, cy - 8 + breathe), stripePaint);
    canvas.drawLine(Offset(cx + 10, cy - 18 + breathe), Offset(cx + 12, cy - 8 + breathe), stripePaint);

    // Eyes (mystical)
    final eyePaint = Paint()..color = const Color(0xFF00BCD4);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 6, cy - 10 + breathe), width: 7, height: 5), eyePaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 6, cy - 10 + breathe), width: 7, height: 5), eyePaint);
    // Eyeliner
    final linerPaint = Paint()
      ..color = const Color(0xFF333333)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx - 10, cy - 10 + breathe), Offset(cx - 2, cy - 10 + breathe), linerPaint);
    canvas.drawLine(Offset(cx + 2, cy - 10 + breathe), Offset(cx + 10, cy - 10 + breathe), linerPaint);

    // Paws
    final pawPaint = Paint()..color = const Color(0xFFD4A574);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 12, cy + 18 + breathe), width: 10, height: 6), pawPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 12, cy + 18 + breathe), width: 10, height: 6), pawPaint);
  }

  // 설산 보스: 이무기 (얼음 서펜트)
  static void _renderSnowfieldBoss(Canvas canvas, Size size, double t) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Serpentine body segments
    final bodyPaint = Paint()..color = const Color(0xFFB3E5FC);
    final darkPaint = Paint()..color = const Color(0xFF4FC3F7);
    for (var i = 4; i >= 0; i--) {
      final segX = cx - 5 + sin(t * 3 + i * 0.8) * 6;
      final segY = cy + i * 8 - 10;
      final segSize = 10.0 - i * 0.5;
      canvas.drawCircle(Offset(segX, segY), segSize, i % 2 == 0 ? bodyPaint : darkPaint);
    }

    // Head
    final headPaint = Paint()..color = const Color(0xFFE1F5FE);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + sin(t * 3) * 6, cy - 15), width: 22, height: 18),
      headPaint,
    );

    // Horns (icy)
    final hornPaint = Paint()..color = const Color(0xFF81D4FA);
    canvas.drawPath(
      Path()..moveTo(cx - 6 + sin(t * 3) * 6, cy - 20)..lineTo(cx - 10 + sin(t * 3) * 6, cy - 32)..lineTo(cx - 2 + sin(t * 3) * 6, cy - 20)..close(),
      hornPaint,
    );
    canvas.drawPath(
      Path()..moveTo(cx + 2 + sin(t * 3) * 6, cy - 20)..lineTo(cx + 10 + sin(t * 3) * 6, cy - 32)..lineTo(cx + 6 + sin(t * 3) * 6, cy - 20)..close(),
      hornPaint,
    );

    // Eyes
    final eyePaint = Paint()..color = const Color(0xFF0288D1);
    canvas.drawCircle(Offset(cx - 4 + sin(t * 3) * 6, cy - 17), 3, eyePaint);
    canvas.drawCircle(Offset(cx + 4 + sin(t * 3) * 6, cy - 17), 3, eyePaint);
    final glowPaint = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawCircle(Offset(cx - 4 + sin(t * 3) * 6, cy - 18), 1, glowPaint);
    canvas.drawCircle(Offset(cx + 4 + sin(t * 3) * 6, cy - 18), 1, glowPaint);

    // Ice particles
    final icePaint = Paint()..color = const Color(0xFFE1F5FE).withValues(alpha: 0.5);
    for (var i = 0; i < 4; i++) {
      final px = cx + cos(t * 2 + i * 1.5) * 20;
      final py = cy + sin(t * 1.5 + i * 2) * 15;
      canvas.drawCircle(Offset(px, py), 1.5, icePaint);
    }
  }

  // 화산 보스: 용 (화염 드래곤)
  static void _renderVolcanoBoss(Canvas canvas, Size size, double t) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final hover = sin(t * 2) * 3;

    // Fire aura
    final auraPaint = Paint()..color = const Color(0xFFFF6F00).withValues(alpha: (sin(t * 6) * 0.15 + 0.2).clamp(0, 1));
    canvas.drawCircle(Offset(cx, cy + hover), size.width * 0.5, auraPaint);

    // Wings (large)
    final wingPaint = Paint()..color = const Color(0xFFBF360C);
    final wingFlap = sin(t * 4) * 5;
    canvas.drawPath(
      Path()
        ..moveTo(cx - 8, cy - 5 + hover)
        ..lineTo(cx - 28, cy - 20 + hover - wingFlap)
        ..lineTo(cx - 22, cy + 5 + hover)
        ..close(),
      wingPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx + 8, cy - 5 + hover)
        ..lineTo(cx + 28, cy - 20 + hover - wingFlap)
        ..lineTo(cx + 22, cy + 5 + hover)
        ..close(),
      wingPaint,
    );

    // Body
    final bodyPaint = Paint()..color = const Color(0xFFD32F2F);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 3 + hover), width: size.width * 0.55, height: size.height * 0.45),
      bodyPaint,
    );

    // Belly
    final bellyPaint = Paint()..color = const Color(0xFFFF8A65);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 5 + hover), width: size.width * 0.3, height: size.height * 0.3),
      bellyPaint,
    );

    // Head
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 12 + hover), width: size.width * 0.4, height: size.height * 0.3),
      bodyPaint,
    );

    // Horns
    final hornPaint = Paint()..color = const Color(0xFF4E342E);
    canvas.drawPath(
      Path()..moveTo(cx - 6, cy - 18 + hover)..lineTo(cx - 12, cy - 30 + hover)..lineTo(cx - 2, cy - 18 + hover)..close(),
      hornPaint,
    );
    canvas.drawPath(
      Path()..moveTo(cx + 2, cy - 18 + hover)..lineTo(cx + 12, cy - 30 + hover)..lineTo(cx + 6, cy - 18 + hover)..close(),
      hornPaint,
    );

    // Eyes (fierce)
    final eyePaint = Paint()..color = const Color(0xFFFFD600);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 6, cy - 14 + hover), width: 7, height: 5), eyePaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 6, cy - 14 + hover), width: 7, height: 5), eyePaint);
    final slitPaint = Paint()..color = const Color(0xFF333333);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx - 6, cy - 14 + hover), width: 1.5, height: 4), slitPaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx + 6, cy - 14 + hover), width: 1.5, height: 4), slitPaint);

    // Fire breath
    if ((t * 1.5) % 5 < 2) {
      final firePaint = Paint()..color = const Color(0xFFFF9800).withValues(alpha: 0.7);
      final fire2Paint = Paint()..color = const Color(0xFFFFEB3B).withValues(alpha: 0.5);
      final breathX = cx + 15;
      final breathY = cy - 8 + hover;
      canvas.drawOval(Rect.fromCenter(center: Offset(breathX, breathY), width: 12, height: 6), firePaint);
      canvas.drawOval(Rect.fromCenter(center: Offset(breathX + 6, breathY), width: 8, height: 4), fire2Paint);
    }

    // Tail
    final tailPaint = Paint()
      ..color = const Color(0xFFD32F2F)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx - 10, cy + 15 + hover),
      Offset(cx - 18 + sin(t * 3) * 3, cy + 22 + hover),
      tailPaint,
    );
    // Tail flame
    final tailFirePaint = Paint()..color = const Color(0xFFFF9800);
    canvas.drawCircle(Offset(cx - 18 + sin(t * 3) * 3, cy + 22 + hover), 3, tailFirePaint);
  }
}
