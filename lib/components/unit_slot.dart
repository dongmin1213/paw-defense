import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../game/defense_game.dart';
import 'defense_unit.dart';

/// A placement slot around the wall where a [DefenseUnit] can be placed.
/// 8 slots arranged in a circle — professional rounded visual with subtle glow.
class UnitSlot extends PositionComponent with HasGameReference<DefenseGame> {
  final int slotIndex;
  DefenseUnit? placedUnit;

  bool isHighlighted = false;
  double _animTimer = 0;

  static const double slotSize = 28.0;
  static const double slotRadius = 60.0;

  // Refined colors for professional look
  static const Color emptyColor = Color(0x2240A0FF);       // subtle blue
  static const Color highlightColor = Color(0x6660FFAA);   // bright green
  static const Color occupiedColor = Color(0x22FFFFFF);     // subtle white
  static const Color _borderColor = Color(0x3360A0FF);     // blue border
  static const Color _highlightBorder = Color(0x8860FFAA); // green border
  static const Color _crossColor = Color(0x3360A0FF);      // blue cross

  UnitSlot({required this.slotIndex})
      : super(
          size: Vector2.all(slotSize),
          anchor: Anchor.center,
          priority: 8,
        );

  bool get isEmpty => placedUnit == null;

  /// Place a unit in this slot. Returns false if already occupied.
  bool placeUnit(DefenseUnit unit) {
    if (!isEmpty) return false;
    placedUnit = unit;
    unit.position = position.clone();
    unit.slotIndex = slotIndex;
    game.world.add(unit);
    return true;
  }

  /// Remove the unit from this slot and return it (or null).
  DefenseUnit? removeUnit() {
    final unit = placedUnit;
    if (unit != null) {
      placedUnit = null;
      unit.removeFromParent();
    }
    return unit;
  }

  /// Generate positions for [count] slots in a circle around [center].
  static List<Vector2> generateSlotPositions({
    required Vector2 center,
    required int count,
    double radius = slotRadius,
  }) {
    final positions = <Vector2>[];
    for (var i = 0; i < count; i++) {
      final angle = (2 * pi * i / count) - (pi / 2); // start from top
      positions.add(Vector2(
        center.x + cos(angle) * radius,
        center.y + sin(angle) * radius,
      ));
    }
    return positions;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _animTimer += dt;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..isAntiAlias = false;
    final cx = size.x / 2;
    final cy = size.y / 2;
    final r = size.x / 2 - 1;

    if (isEmpty) {
      // Subtle breathing alpha
      final alpha = isHighlighted
          ? 0.5
          : (0.15 + 0.08 * _sin(_animTimer * 2));

      // Background circle
      paint.color = isHighlighted
          ? highlightColor
          : emptyColor.withValues(alpha: alpha);
      paint.style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.x, size.y),
          const Radius.circular(6),
        ),
        paint,
      );

      // Border
      paint.color = isHighlighted ? _highlightBorder : _borderColor;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 1;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0.5, 0.5, size.x - 1, size.y - 1),
          const Radius.circular(6),
        ),
        paint,
      );

      // Inner cross to indicate "place here"
      paint.color = isHighlighted
          ? const Color(0x9960FFAA)
          : _crossColor;
      paint.style = PaintingStyle.fill;
      const armLen = 5.0;
      const thickness = 1.5;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, cy), width: armLen * 2, height: thickness),
          const Radius.circular(1),
        ),
        paint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, cy), width: thickness, height: armLen * 2),
          const Radius.circular(1),
        ),
        paint,
      );
    } else {
      // Occupied — subtle rounded indicator ring
      paint.color = occupiedColor;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 1;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0.5, 0.5, size.x - 1, size.y - 1),
          const Radius.circular(6),
        ),
        paint,
      );
    }
  }

  double _sin(double x) {
    x = x % 6.2832;
    if (x < 0) x += 6.2832;
    if (x > 3.1416) {
      x -= 3.1416;
      return -(x * (4 - x * 1.2732) * 0.405 + x * (4 - x * 1.2732) * 0.595);
    }
    return x * (4 - x * 1.2732) * 0.405 + x * (4 - x * 1.2732) * 0.595;
  }
}
