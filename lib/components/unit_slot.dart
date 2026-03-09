import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../game/defense_game.dart';
import 'defense_unit.dart';

/// A placement slot around the wall where a [DefenseUnit] can be placed.
/// 8 slots are arranged in a circle around the wall center.
class UnitSlot extends PositionComponent with HasGameReference<DefenseGame> {
  final int slotIndex;
  DefenseUnit? placedUnit;

  bool isHighlighted = false;
  double _animTimer = 0;

  static const double slotSize = 28.0;
  static const double slotRadius = 60.0;
  static const Color emptyColor = Color(0x4400FF00);
  static const Color highlightColor = Color(0x8800FFAA);
  static const Color occupiedColor = Color(0x44FFFFFF);

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

    if (isEmpty) {
      // Draw empty slot indicator
      final alpha = isHighlighted
          ? 0.6
          : (0.25 + 0.1 * _sin(_animTimer * 2));
      paint.color = isHighlighted
          ? highlightColor
          : emptyColor.withValues(alpha: alpha);

      // Dashed border effect via corner marks
      final rect = Rect.fromLTWH(0, 0, size.x, size.y);
      canvas.drawRect(rect, paint);

      // Inner cross to indicate "place here"
      paint.color = isHighlighted
          ? const Color(0xCC00FFAA)
          : const Color(0x4400FF00);
      final cx = size.x / 2;
      final cy = size.y / 2;
      const armLen = 5.0;
      const thickness = 2.0;
      canvas.drawRect(
        Rect.fromCenter(
            center: Offset(cx, cy), width: armLen * 2, height: thickness),
        paint,
      );
      canvas.drawRect(
        Rect.fromCenter(
            center: Offset(cx, cy), width: thickness, height: armLen * 2),
        paint,
      );
    } else {
      // Subtle occupied indicator ring
      paint.color = occupiedColor;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 1;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);
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
