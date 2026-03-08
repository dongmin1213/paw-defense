import 'dart:ui';
import 'dart:math';
import '../data/enemy_data.dart';

class EnemyRenderer {
  static void render(Canvas canvas, Size size, EnemyData data, {required double animTimer, bool isHit = false}) {
    final color = isHit ? const Color(0xFFFFFFFF) : data.color;
    final accent = isHit ? const Color(0xFFFFFFFF) : data.accentColor;

    switch (data.id) {
      case 'slime':
        _renderSlime(canvas, size, color, accent, animTimer);
        break;
      case 'mushroom':
        _renderMushroom(canvas, size, color, accent, animTimer);
        break;
      case 'bird':
        _renderBird(canvas, size, color, accent, animTimer);
        break;
      case 'butterfly':
        _renderButterfly(canvas, size, color, accent, animTimer);
        break;
      default:
        _renderSlime(canvas, size, color, accent, animTimer);
    }
  }

  static void _renderSlime(Canvas canvas, Size size, Color color, Color accent, double t) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final bounce = sin(t * 4) * 2;

    // Body
    final bodyPaint = Paint()..color = color;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + 2 + bounce),
        width: size.width * 0.85,
        height: size.height * 0.7 - bounce,
      ),
      bodyPaint,
    );

    // Highlight
    final highlightPaint = Paint()..color = accent;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - 3, cy - 2 + bounce),
        width: size.width * 0.3,
        height: size.height * 0.25,
      ),
      highlightPaint,
    );

    // Eyes
    final eyePaint = Paint()..color = const Color(0xFF1A1A1A);
    canvas.drawCircle(Offset(cx - 4, cy - 1 + bounce), 2, eyePaint);
    canvas.drawCircle(Offset(cx + 4, cy - 1 + bounce), 2, eyePaint);
  }

  static void _renderMushroom(Canvas canvas, Size size, Color color, Color accent, double t) {
    final cx = size.width / 2;
    final bottom = size.height;

    // Stem
    final stemPaint = Paint()..color = const Color(0xFFF5E6D0);
    canvas.drawRect(
      Rect.fromLTWH(cx - 4, size.height * 0.4, 8, size.height * 0.6),
      stemPaint,
    );

    // Cap
    final capPaint = Paint()..color = color;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, size.height * 0.4), width: size.width * 0.9, height: size.height * 0.7),
      pi, pi, true, capPaint,
    );

    // Spots
    final spotPaint = Paint()..color = accent;
    canvas.drawCircle(Offset(cx - 4, size.height * 0.25), 3, spotPaint);
    canvas.drawCircle(Offset(cx + 5, size.height * 0.2), 2, spotPaint);

    // Eyes
    final eyePaint = Paint()..color = const Color(0xFF1A1A1A);
    canvas.drawCircle(Offset(cx - 3, size.height * 0.5), 1.5, eyePaint);
    canvas.drawCircle(Offset(cx + 3, size.height * 0.5), 1.5, eyePaint);
  }

  static void _renderBird(Canvas canvas, Size size, Color color, Color accent, double t) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final wingFlap = sin(t * 10) * 0.4;

    // Body
    final bodyPaint = Paint()..color = color;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: size.width * 0.7, height: size.height * 0.6),
      bodyPaint,
    );

    // Wings
    final wingPaint = Paint()..color = accent;
    // Top wing
    final wingPath = Path()
      ..moveTo(cx - 2, cy - 2)
      ..lineTo(cx - size.width * 0.4, cy - size.height * 0.5 + wingFlap * 10)
      ..lineTo(cx + 2, cy - 4)
      ..close();
    canvas.drawPath(wingPath, wingPaint);

    // Beak
    final beakPaint = Paint()..color = const Color(0xFFFF9800);
    canvas.drawPath(
      Path()
        ..moveTo(cx + size.width * 0.35, cy - 1)
        ..lineTo(cx + size.width * 0.5, cy + 1)
        ..lineTo(cx + size.width * 0.35, cy + 3)
        ..close(),
      beakPaint,
    );

    // Eye
    final eyePaint = Paint()..color = const Color(0xFF1A1A1A);
    canvas.drawCircle(Offset(cx + 5, cy - 2), 1.5, eyePaint);
  }

  static void _renderButterfly(Canvas canvas, Size size, Color color, Color accent, double t) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final wingScale = 0.7 + sin(t * 8) * 0.3;

    // Wings
    final wingPaint = Paint()..color = color;
    // Left wing
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - 5, cy - 2),
        width: size.width * 0.4 * wingScale,
        height: size.height * 0.7,
      ),
      wingPaint,
    );
    // Right wing
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + 5, cy - 2),
        width: size.width * 0.4 * wingScale,
        height: size.height * 0.7,
      ),
      wingPaint,
    );

    // Body
    final bodyPaint = Paint()
      ..color = const Color(0xFF4A4A4A)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy - 6), Offset(cx, cy + 6), bodyPaint);

    // Antennae
    canvas.drawLine(Offset(cx, cy - 6), Offset(cx - 4, cy - 10), bodyPaint);
    canvas.drawLine(Offset(cx, cy - 6), Offset(cx + 4, cy - 10), bodyPaint);
  }
}
