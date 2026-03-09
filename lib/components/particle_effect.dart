import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show HSVColor;

import '../game/runner_game.dart';

/// Lightweight particle system for visual feedback
class ParticleEffect extends PositionComponent with HasGameReference<RunnerGame> {
  final List<_FxParticle> _particles = [];

  ParticleEffect() : super(priority: 60);

  /// Spawn coin collect burst at world position
  void spawnCoinCollect(double wx, double wy) {
    final rng = Random();
    for (var i = 0; i < 6; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = 40 + rng.nextDouble() * 60;
      _particles.add(_FxParticle(
        x: wx,
        y: wy,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 30,
        size: 2 + rng.nextDouble() * 2,
        life: 0.4 + rng.nextDouble() * 0.3,
        color: const Color(0xFFFFD700),
      ));
    }
  }

  /// Spawn enemy death burst
  void spawnEnemyDeath(double wx, double wy, {bool isGolden = false}) {
    final rng = Random();
    final count = isGolden ? 12 : 8;
    final color = isGolden ? const Color(0xFFFFD600) : const Color(0xFFFF4444);
    for (var i = 0; i < count; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = 50 + rng.nextDouble() * 80;
      _particles.add(_FxParticle(
        x: wx,
        y: wy,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 20,
        size: 2 + rng.nextDouble() * 3,
        life: 0.3 + rng.nextDouble() * 0.4,
        color: color,
      ));
    }
  }

  /// Spawn boss death explosion
  void spawnBossExplosion(double wx, double wy) {
    final rng = Random();
    for (var i = 0; i < 30; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = 60 + rng.nextDouble() * 120;
      final colors = [
        const Color(0xFFFF4444),
        const Color(0xFFFFAA00),
        const Color(0xFFFFFF00),
        const Color(0xFFFF6600),
      ];
      _particles.add(_FxParticle(
        x: wx,
        y: wy,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 40,
        size: 3 + rng.nextDouble() * 4,
        life: 0.5 + rng.nextDouble() * 0.5,
        color: colors[rng.nextInt(colors.length)],
      ));
    }
  }

  /// Spawn dust trail behind player
  void spawnDustTrail(double wx, double wy) {
    final rng = Random();
    _particles.add(_FxParticle(
      x: wx - 5 + rng.nextDouble() * 10,
      y: wy,
      vx: -10 - rng.nextDouble() * 20,
      vy: -5 - rng.nextDouble() * 15,
      size: 2 + rng.nextDouble() * 3,
      life: 0.3 + rng.nextDouble() * 0.2,
      color: const Color(0x88AA9977),
    ));
  }

  /// Combo milestone burst
  void spawnComboMilestone(double wx, double wy) {
    final rng = Random();
    for (var i = 0; i < 15; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = 30 + rng.nextDouble() * 50;
      final hue = (i / 15 * 360).toDouble();
      _particles.add(_FxParticle(
        x: wx,
        y: wy,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        size: 2 + rng.nextDouble() * 2,
        life: 0.5 + rng.nextDouble() * 0.3,
        color: HSVColor.fromAHSV(1.0, hue, 0.8, 1.0).toColor(),
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    for (final p in _particles) {
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vy += 60 * dt; // gravity on particles
      p.life -= dt;
    }

    _particles.removeWhere((p) => p.life <= 0);

    // Cap
    if (_particles.length > 200) {
      _particles.removeRange(0, _particles.length - 200);
    }
  }

  @override
  void render(Canvas canvas) {
    final cameraX = game.camera.viewfinder.position.x;
    canvas.save();
    canvas.translate(-cameraX, 0);

    for (final p in _particles) {
      final alpha = (p.life * 2.5).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = p.color.withValues(alpha: alpha * (p.color.a / 255.0));
      canvas.drawCircle(Offset(p.x, p.y), p.size * alpha, paint);
    }

    canvas.restore();
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
