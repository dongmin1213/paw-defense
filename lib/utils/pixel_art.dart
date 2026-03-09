import 'dart:ui';

/// Pixel art sprite renderer.
/// Sprites are defined as a list of strings where each character maps to a color.
/// '.' = transparent, other characters map to the provided palette.
class PixelArt {
  /// Renders a pixel art sprite on the canvas.
  /// [sprite] is a list of strings, each string is a row of pixels.
  /// [palette] maps characters to colors.
  /// [pixelSize] is the size of each pixel block.
  /// [offsetX], [offsetY] is the top-left position.
  static void draw(
    Canvas canvas,
    List<String> sprite,
    Map<String, Color> palette, {
    double pixelSize = 2.0,
    double offsetX = 0,
    double offsetY = 0,
  }) {
    final paint = Paint()..isAntiAlias = false;

    for (var row = 0; row < sprite.length; row++) {
      final line = sprite[row];
      for (var col = 0; col < line.length; col++) {
        final ch = line[col];
        if (ch == '.' || ch == ' ') continue;
        final color = palette[ch];
        if (color == null) continue;
        paint.color = color;
        canvas.drawRect(
          Rect.fromLTWH(
            offsetX + col * pixelSize,
            offsetY + row * pixelSize,
            pixelSize,
            pixelSize,
          ),
          paint,
        );
      }
    }
  }

  /// Renders a pixel art sprite centered in the given size.
  static void drawCentered(
    Canvas canvas,
    List<String> sprite,
    Map<String, Color> palette,
    Size size, {
    double pixelSize = 2.0,
  }) {
    if (sprite.isEmpty) return;
    final spriteW = sprite[0].length * pixelSize;
    final spriteH = sprite.length * pixelSize;
    final offsetX = (size.width - spriteW) / 2;
    final offsetY = (size.height - spriteH) / 2;
    draw(canvas, sprite, palette, pixelSize: pixelSize, offsetX: offsetX, offsetY: offsetY);
  }

  /// Renders with horizontal flip (for facing left).
  static void drawCenteredFlipped(
    Canvas canvas,
    List<String> sprite,
    Map<String, Color> palette,
    Size size, {
    double pixelSize = 2.0,
  }) {
    if (sprite.isEmpty) return;
    final flipped = sprite.map((row) => String.fromCharCodes(row.codeUnits.reversed)).toList();
    drawCentered(canvas, flipped, palette, size, pixelSize: pixelSize);
  }

  /// Draw a simple glow/shadow effect behind a sprite.
  static void drawGlow(
    Canvas canvas,
    Size size,
    Color color,
    double radius,
  ) {
    final paint = Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
      ..isAntiAlias = false;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius, paint);
  }

  /// Draw a simple ground shadow.
  static void drawShadow(Canvas canvas, double cx, double cy, double w) {
    final paint = Paint()
      ..color = const Color(0x33000000)
      ..isAntiAlias = false;
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy), width: w, height: 3),
      paint,
    );
  }
}
