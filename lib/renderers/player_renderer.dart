import 'dart:ui';
import 'dart:math';

class PlayerRenderer {
  static void render(Canvas canvas, Size size, {required bool isRunning, required double animTimer, required bool isJumping, required bool isAttacking}) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Body (white oval)
    final bodyPaint = Paint()..color = const Color(0xFFFAFAFA);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX, centerY + 4), width: size.width * 0.7, height: size.height * 0.55),
      bodyPaint,
    );

    // Head (white circle)
    final headPaint = Paint()..color = const Color(0xFFFFFFFF);
    final headY = centerY - size.height * 0.18;
    canvas.drawCircle(Offset(centerX + 2, headY), size.width * 0.32, headPaint);

    // Fluffy fur texture
    final furPaint = Paint()
      ..color = const Color(0xFFF5F5F5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (var i = 0; i < 5; i++) {
      final angle = i * 1.2 + 0.3;
      final fx = centerX + 2 + cos(angle) * size.width * 0.28;
      final fy = headY + sin(angle) * size.width * 0.28;
      canvas.drawCircle(Offset(fx, fy), 3, furPaint);
    }

    // Eyes
    final eyePaint = Paint()..color = const Color(0xFF2C2C2C);
    canvas.drawCircle(Offset(centerX + 5, headY - 2), 2.5, eyePaint);
    canvas.drawCircle(Offset(centerX - 3, headY - 2), 2.5, eyePaint);

    // Eye shine
    final shinePaint = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawCircle(Offset(centerX + 6, headY - 3), 1.0, shinePaint);
    canvas.drawCircle(Offset(centerX - 2, headY - 3), 1.0, shinePaint);

    // Nose
    final nosePaint = Paint()..color = const Color(0xFF333333);
    canvas.drawCircle(Offset(centerX + 4, headY + 3), 2, nosePaint);

    // Ears
    final earPaint = Paint()..color = const Color(0xFFF0E8D8);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX - 8, headY - 10), width: 8, height: 12),
      earPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX + 10, headY - 10), width: 8, height: 12),
      earPaint,
    );

    // Legs (animated)
    final legPaint = Paint()
      ..color = const Color(0xFFF0F0F0)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final legOffset = isJumping ? 0.0 : sin(animTimer * 12) * 5;
    // Front legs
    canvas.drawLine(
      Offset(centerX + 6, centerY + size.height * 0.2),
      Offset(centerX + 8, centerY + size.height * 0.42 + legOffset),
      legPaint,
    );
    canvas.drawLine(
      Offset(centerX - 4, centerY + size.height * 0.2),
      Offset(centerX - 6, centerY + size.height * 0.42 - legOffset),
      legPaint,
    );

    // Tail (wagging)
    final tailWag = sin(animTimer * 8) * 0.4;
    final tailPaint = Paint()
      ..color = const Color(0xFFF5F5F5)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final tailPath = Path()
      ..moveTo(centerX - size.width * 0.3, centerY)
      ..quadraticBezierTo(
        centerX - size.width * 0.45,
        centerY - 10 + tailWag * 15,
        centerX - size.width * 0.4,
        centerY - 15 + tailWag * 20,
      );
    canvas.drawPath(tailPath, tailPaint);

    // Sword (when attacking)
    if (isAttacking) {
      final swordPaint = Paint()
        ..color = const Color(0xFFB0B0B0)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      final swordAngle = sin(animTimer * 20) * 0.5 - 0.5;
      final swordLen = size.width * 0.5;
      canvas.drawLine(
        Offset(centerX + size.width * 0.2, centerY),
        Offset(
          centerX + size.width * 0.2 + cos(swordAngle) * swordLen,
          centerY + sin(swordAngle) * swordLen,
        ),
        swordPaint,
      );
      // Sword guard
      final guardPaint = Paint()..color = const Color(0xFFFFD700);
      canvas.drawCircle(
        Offset(centerX + size.width * 0.2, centerY),
        3,
        guardPaint,
      );
    }
  }
}
