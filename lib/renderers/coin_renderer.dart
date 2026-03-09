import 'dart:ui';
import 'dart:math';

class CoinRenderer {
  static void render(Canvas canvas, Size size, {required double animTimer, bool isGolden = false}) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width * 0.4;

    // Glow
    final glowPaint = Paint()
      ..color = (isGolden ? const Color(0x40FFD700) : const Color(0x30FFD700))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(cx, cy), radius + 3, glowPaint);

    // Coin body
    final coinColor = isGolden ? const Color(0xFFFFD700) : const Color(0xFFFFC107);
    final coinPaint = Paint()..color = coinColor;
    canvas.drawCircle(Offset(cx, cy), radius, coinPaint);

    // Inner circle
    final innerPaint = Paint()
      ..color = isGolden ? const Color(0xFFFFE54C) : const Color(0xFFFFD54F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(cx, cy), radius * 0.7, innerPaint);

    // Shine highlight (rotating)
    final shineAngle = animTimer * 3;
    final shineX = cx + cos(shineAngle) * radius * 0.3;
    final shineY = cy + sin(shineAngle) * radius * 0.3 - radius * 0.15;
    final shinePaint = Paint()..color = const Color(0x80FFFFFF);
    canvas.drawCircle(Offset(shineX, shineY), radius * 0.25, shinePaint);
  }
}
