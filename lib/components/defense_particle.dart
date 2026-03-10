import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show HSVColor;

import '../game/defense_game.dart';

/// Particle effects for the defense game.
/// Unlike the runner game's particle system, this does not offset by camera X
/// since the defense game uses a fixed viewport with no horizontal scrolling.
class DefenseParticle extends PositionComponent
    with HasGameReference<DefenseGame> {
  final List<_FxParticle> _particles = [];

  DefenseParticle() : super(priority: 60);

  /// Gold coin collect burst at a world position.
  void spawnGoldCollect(double wx, double wy) {
    final rng = Random();
    for (var i = 0; i < 8; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = 40 + rng.nextDouble() * 60;
      const colors = [
        Color(0xFFFFD700),
        Color(0xFFFFE44D),
        Color(0xFFFFFFFF),
      ];
      _particles.add(_FxParticle(
        x: wx,
        y: wy,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 40,
        size: 2 + rng.nextDouble() * 2,
        life: 0.4 + rng.nextDouble() * 0.3,
        color: colors[rng.nextInt(colors.length)],
      ));
    }
  }

  /// Enemy death burst.
  void spawnEnemyDeath(double wx, double wy) {
    final rng = Random();
    for (var i = 0; i < 8; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = 40 + rng.nextDouble() * 70;
      _particles.add(_FxParticle(
        x: wx,
        y: wy,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 20,
        size: 2 + rng.nextDouble() * 3,
        life: 0.3 + rng.nextDouble() * 0.3,
        color: const Color(0xFFFF4444),
      ));
    }
  }

  /// Boss explosion — large burst with mixed fire colors.
  void spawnBossExplosion(double wx, double wy) {
    final rng = Random();
    for (var i = 0; i < 30; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = 50 + rng.nextDouble() * 120;
      const colors = [
        Color(0xFFFF4444),
        Color(0xFFFFAA00),
        Color(0xFFFFFF00),
        Color(0xFFFF6600),
      ];
      _particles.add(_FxParticle(
        x: wx,
        y: wy,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 30,
        size: 3 + rng.nextDouble() * 4,
        life: 0.5 + rng.nextDouble() * 0.5,
        color: colors[rng.nextInt(colors.length)],
      ));
    }
  }

  /// Unit merge effect — rainbow sparkle burst.
  void spawnMerge(double wx, double wy) {
    final rng = Random();
    for (var i = 0; i < 15; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = 30 + rng.nextDouble() * 50;
      final hue = (i / 15 * 360).toDouble();
      _particles.add(_FxParticle(
        x: wx,
        y: wy,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 20,
        size: 2 + rng.nextDouble() * 3,
        life: 0.5 + rng.nextDouble() * 0.3,
        color: HSVColor.fromAHSV(1.0, hue, 0.8, 1.0).toColor(),
      ));
    }
  }

  /// Wall hit impact — sparks from the wall.
  void spawnWallHit(double wx, double wy) {
    final rng = Random();
    for (var i = 0; i < 6; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = 30 + rng.nextDouble() * 40;
      const colors = [
        Color(0xFF888888),
        Color(0xFFAAAAAA),
        Color(0xFFFFCC00),
      ];
      _particles.add(_FxParticle(
        x: wx,
        y: wy,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 15,
        size: 2 + rng.nextDouble() * 2,
        life: 0.25 + rng.nextDouble() * 0.2,
        color: colors[rng.nextInt(colors.length)],
      ));
    }
  }

  /// Wave start celebration — upward burst.
  void spawnWaveStart(double wx, double wy) {
    final rng = Random();
    for (var i = 0; i < 12; i++) {
      final angle = -pi / 2 + (rng.nextDouble() - 0.5) * pi * 0.6;
      final speed = 60 + rng.nextDouble() * 80;
      final hue = (i / 12 * 120 + 30).toDouble(); // yellow-green range
      _particles.add(_FxParticle(
        x: wx + rng.nextDouble() * 40 - 20,
        y: wy,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        size: 2 + rng.nextDouble() * 2,
        life: 0.6 + rng.nextDouble() * 0.4,
        color: HSVColor.fromAHSV(1.0, hue, 0.9, 1.0).toColor(),
      ));
    }
  }

  /// Critical hit effect — star-shaped burst with white/yellow.
  void spawnCriticalHit(double wx, double wy, {double scale = 1.0}) {
    final rng = Random();
    final count = (12 * scale).toInt();
    for (var i = 0; i < count; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = (50 + rng.nextDouble() * 80) * scale;
      const colors = [
        Color(0xFFFFFFFF),
        Color(0xFFFFD700),
        Color(0xFFFFE44D),
      ];
      _particles.add(_FxParticle(
        x: wx,
        y: wy,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 30,
        size: (3 + rng.nextDouble() * 3) * scale,
        life: 0.3 + rng.nextDouble() * 0.2,
        color: colors[rng.nextInt(colors.length)],
      ));
    }
  }

  /// Chain kill effect — lightning arc between two points.
  void spawnChainKill(double x1, double y1, double x2, double y2) {
    final rng = Random();
    const steps = 8;
    for (var i = 0; i < steps; i++) {
      final t = i / steps;
      final px = x1 + (x2 - x1) * t + (rng.nextDouble() - 0.5) * 10;
      final py = y1 + (y2 - y1) * t + (rng.nextDouble() - 0.5) * 10;
      _particles.add(_FxParticle(
        x: px,
        y: py,
        vx: (rng.nextDouble() - 0.5) * 20,
        vy: (rng.nextDouble() - 0.5) * 20,
        size: 2 + rng.nextDouble() * 2,
        life: 0.2 + rng.nextDouble() * 0.15,
        color: const Color(0xFF42A5F5),
      ));
    }
  }

  /// Hybrid merge effect — two-color swirl.
  void spawnHybridMerge(double wx, double wy) {
    final rng = Random();
    const colorsA = [Color(0xFFFF6D00), Color(0xFFFFAB00)];
    const colorsB = [Color(0xFF2979FF), Color(0xFF00B0FF)];
    for (var i = 0; i < 25; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = 40 + rng.nextDouble() * 60;
      final isA = i % 2 == 0;
      final colors = isA ? colorsA : colorsB;
      _particles.add(_FxParticle(
        x: wx,
        y: wy,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 25,
        size: 3 + rng.nextDouble() * 3,
        life: 0.6 + rng.nextDouble() * 0.4,
        color: colors[rng.nextInt(colors.length)],
      ));
    }
  }

  /// Combo milestone effect — screen-wide flash burst.
  void spawnComboFlash(double centerX, double centerY, int comboColor) {
    final rng = Random();
    final color = Color(comboColor);
    for (var i = 0; i < 40; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = 80 + rng.nextDouble() * 150;
      _particles.add(_FxParticle(
        x: centerX + (rng.nextDouble() - 0.5) * 100,
        y: centerY + (rng.nextDouble() - 0.5) * 50,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 20,
        size: 3 + rng.nextDouble() * 4,
        life: 0.5 + rng.nextDouble() * 0.5,
        color: color,
      ));
    }
  }

  /// Scaled enemy death effect — size proportional to combo.
  void spawnEnemyDeathScaled(double wx, double wy, double scale) {
    final rng = Random();
    final count = (8 * scale).clamp(4, 20).toInt();
    for (var i = 0; i < count; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = (40 + rng.nextDouble() * 70) * scale;
      _particles.add(_FxParticle(
        x: wx,
        y: wy,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 20,
        size: (2 + rng.nextDouble() * 3) * scale,
        life: (0.3 + rng.nextDouble() * 0.3) * scale,
        color: const Color(0xFFFF4444),
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    for (final p in _particles) {
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vy += 50 * dt; // light gravity
      p.life -= dt;
    }

    _particles.removeWhere((p) => p.life <= 0);

    // Cap particle count (increased for late-game spectacle)
    if (_particles.length > 500) {
      _particles.removeRange(0, _particles.length - 500);
    }
  }

  @override
  void render(Canvas canvas) {
    // No camera offset — fixed viewport for defense game
    final paint = Paint()..isAntiAlias = false;
    for (final p in _particles) {
      final alpha = (p.life * 2.5).clamp(0.0, 1.0);
      paint.color = p.color.withValues(alpha: alpha * (p.color.a / 255.0));
      final s = p.size * alpha;
      // Pixel art style: square particles
      canvas.drawRect(
        Rect.fromCenter(center: Offset(p.x, p.y), width: s, height: s),
        paint,
      );
    }
  }
}

class _FxParticle {
  double x, y, vx, vy, size, life;
  final Color color;

  _FxParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.life,
    required this.color,
  });
}
