import 'dart:ui';
import 'dart:math';
import '../utils/pixel_art.dart';

class PlayerRenderer {
  // Bichon Frise — fluffy white dog pixel art (18x20 pixels, drawn at 2x)
  // Facing right
  static const _idle = [
    '......WWWW........',
    '....WWFFFFWW......',
    '...WFFFFFFFW.....',
    '..eWFFWFFWFFW.....',
    '..WFFFNFFFFF......',
    '...WFFFFFFFW......',
    '....WWWWWWW.......',
    '......WWWWWW......',
    '.....WWWWWWWW.....',
    '....WWWWWWWWWW....',
    '....WWWWWWWWWW....',
    '....WWWWWWWWWWT...',
    '.....WWWWWWWWT....',
    '.....WWWWWWWT.....',
    '......WW.WW.......',
    '......WW.WW.......',
    '......LL.LL.......',
  ];

  static const _run1 = [
    '......WWWW........',
    '....WWFFFFWW......',
    '...WFFFFFFFW.....',
    '..eWFFWFFWFFW.....',
    '..WFFFNFFFFF......',
    '...WFFFFFFFW......',
    '....WWWWWWW.......',
    '......WWWWWW......',
    '.....WWWWWWWW.....',
    '....WWWWWWWWWW....',
    '....WWWWWWWWWW....',
    '....WWWWWWWWWWT...',
    '.....WWWWWWWWT....',
    '.....WWWWWWWT.....',
    '.....WW...WW......',
    '....WW.....WW.....',
    '....LL.....LL.....',
  ];

  static const _run2 = [
    '......WWWW........',
    '....WWFFFFWW......',
    '...WFFFFFFFW.....',
    '..eWFFWFFWFFW.....',
    '..WFFFNFFFFF......',
    '...WFFFFFFFW......',
    '....WWWWWWW.......',
    '......WWWWWW......',
    '.....WWWWWWWW.....',
    '....WWWWWWWWWW....',
    '....WWWWWWWWWW....',
    '....WWWWWWWWWWT...',
    '.....WWWWWWWWT....',
    '.....WWWWWWWT.....',
    '......WW.WW.......',
    '.......WWWW.......',
    '.......LL.........',
  ];

  static const _jump = [
    '......WWWW........',
    '....WWFFFFWW......',
    '...WFFFFFFFW.....',
    '..eWFFWFFWFFW.....',
    '..WFFFNFFFFF......',
    '...WFFFFFFFW......',
    '....WWWWWWW.......',
    '......WWWWWW......',
    '.....WWWWWWWW.....',
    '....WWWWWWWWWW....',
    '....WWWWWWWWWW....',
    '....WWWWWWWWWWT...',
    '.....WWWWWWWT.....',
    '....WW.WWWW.WW....',
    '...WW..WWWW..WW...',
    '...LL........LL...',
  ];

  static const _attack = [
    '......WWWW........',
    '....WWFFFFWW......',
    '...WFFFFFFFW.SSS..',
    '..eWFFWFFWFFWSGSS.',
    '..WFFFNFFFFFFSSSS.',
    '...WFFFFFFFW..SS..',
    '....WWWWWWW.......',
    '......WWWWWW......',
    '.....WWWWWWWW.....',
    '....WWWWWWWWWW....',
    '....WWWWWWWWWW....',
    '....WWWWWWWWWWT...',
    '.....WWWWWWWWT....',
    '.....WWWWWWWT.....',
    '......WW.WW.......',
    '......WW.WW.......',
    '......LL.LL.......',
  ];

  static const _palette = {
    'W': Color(0xFFFAFAFA), // White fur
    'F': Color(0xFFF5EDE0), // Face/fluff (cream)
    'e': Color(0xFFEAD8C4), // Ear
    'N': Color(0xFF222222), // Nose
    'L': Color(0xFFE0D5C8), // Leg/paw
    'T': Color(0xFFF0EAE0), // Tail
    'S': Color(0xFFB8B8C0), // Sword blade
    'G': Color(0xFFFFD700), // Sword guard (gold)
    't': Color(0xFFE8E0D5), // Tail tip
  };

  // Eye palette chars used in sprite: use special rendering
  static const _eyeColor = Color(0xFF2C2C2C);
  static const _eyeShine = Color(0xFFFFFFFF);

  static void render(Canvas canvas, Size size, {required bool isRunning, required double animTimer, required bool isJumping, required bool isAttacking, int combo = 0}) {
    List<String> sprite;

    if (isAttacking) {
      sprite = _attack;
    } else if (isJumping) {
      sprite = _jump;
    } else {
      // Alternate between run frames
      final frame = (animTimer * 8).toInt() % 2;
      sprite = frame == 0 ? _run1 : _run2;
    }

    // Calculate pixel size to fit the component
    final spriteW = sprite[0].length;
    final spriteH = sprite.length;
    final px = min(size.width / spriteW, size.height / spriteH);

    PixelArt.drawCentered(canvas, sprite, _palette, size, pixelSize: px);

    // === 콤보 글로우 이펙트 ===
    if (combo >= 10) {
      Color glowColor;
      double glowRadius;
      double glowAlpha;

      if (combo >= 50) {
        glowColor = const Color(0xFFFF1744); // INSANE - 빨강
        glowRadius = 18.0;
        glowAlpha = 0.5 + sin(animTimer * 6) * 0.2;
      } else if (combo >= 30) {
        glowColor = const Color(0xFFFF6D00); // EPIC - 오렌지
        glowRadius = 14.0;
        glowAlpha = 0.4 + sin(animTimer * 5) * 0.15;
      } else if (combo >= 20) {
        glowColor = const Color(0xFFFFD600); // GREAT - 골드
        glowRadius = 10.0;
        glowAlpha = 0.3 + sin(animTimer * 4) * 0.1;
      } else {
        glowColor = const Color(0xFF00E676); // NICE - 초록
        glowRadius = 7.0;
        glowAlpha = 0.2 + sin(animTimer * 3) * 0.08;
      }

      final center = Offset(size.width / 2, size.height / 2);
      final glowPaint = Paint()
        ..color = glowColor.withAlpha((glowAlpha * 255).toInt())
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(center, glowRadius, glowPaint);

      // 스피드 트레일 라인 (콤보 30+)
      if (combo >= 30) {
        final trailPaint = Paint()
          ..color = glowColor.withAlpha((glowAlpha * 180).toInt())
          ..strokeWidth = 1.5;
        for (var i = 0; i < 3; i++) {
          final offset = (animTimer * 3 + i * 1.2) % 3.0;
          final y = size.height * 0.3 + i * size.height * 0.2;
          final startX = -offset * 6;
          final endX = startX - 8 - i * 3;
          canvas.drawLine(Offset(startX, y), Offset(endX, y), trailPaint);
        }
      }
    }

    // Draw eyes on top (they need special sub-pixel detail)
    final offsetX = (size.width - spriteW * px) / 2;
    final offsetY = (size.height - spriteH * px) / 2;

    // Eyes are at row 3, cols 7 and 10 in the sprite (the 'W' positions after 'eW')
    final eyeY = offsetY + 3.5 * px;
    final eye1X = offsetX + 8 * px;
    final eye2X = offsetX + 11 * px;
    final eyeR = px * 0.6;

    final eyePaint = Paint()..color = _eyeColor..isAntiAlias = false;
    final shinePaint = Paint()..color = _eyeShine..isAntiAlias = false;
    canvas.drawRect(Rect.fromCenter(center: Offset(eye1X, eyeY), width: eyeR, height: eyeR), eyePaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(eye2X, eyeY), width: eyeR, height: eyeR), eyePaint);
    // Shine
    canvas.drawRect(Rect.fromLTWH(eye1X - eyeR * 0.1, eyeY - eyeR * 0.4, eyeR * 0.4, eyeR * 0.4), shinePaint);
    canvas.drawRect(Rect.fromLTWH(eye2X - eyeR * 0.1, eyeY - eyeR * 0.4, eyeR * 0.4, eyeR * 0.4), shinePaint);
  }
}
