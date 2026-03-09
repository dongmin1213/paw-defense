import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Particle burst effect when an enemy or boss dies
class DeathEffect extends PositionComponent {
  final Color color;
  final double radius;
  double _lifetime = 0;
  static const double _duration = 0.4;
  late final List<_Particle> _particles;

  DeathEffect({
    required Vector2 center,
    this.color = Colors.white,
    this.radius = 20,
  }) : super(position: center) {
    final rng = Random();
    _particles = List.generate(10, (_) {
      final angle = rng.nextDouble() * pi * 2;
      final speed = 80 + rng.nextDouble() * 120;
      final size = 2.0 + rng.nextDouble() * 3.0;
      return _Particle(
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        size: size,
      );
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    _lifetime += dt;
    for (final p in _particles) {
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vy += 200 * dt; // gravity
    }
    if (_lifetime >= _duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final t = (_lifetime / _duration).clamp(0.0, 1.0);
    final alpha = (1.0 - t).clamp(0.0, 1.0);

    final paint = Paint()..color = color.withValues(alpha: alpha);
    for (final p in _particles) {
      final s = p.size * (1.0 - t * 0.5);
      canvas.drawRect(
        Rect.fromCenter(center: Offset(p.x, p.y), width: s, height: s),
        paint,
      );
    }
  }
}

class _Particle {
  double x = 0;
  double y = 0;
  final double vx;
  double vy;
  final double size;

  _Particle({required this.vx, required this.vy, required this.size});
}
