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

  /// Remove all active particles.
  void clear() {
    _particles.clear();
  }

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

  /// Get type-specific death colors for an enemy.
  static List<Color> _deathColorsForEnemy(String enemyId) {
    // Extract base type (e.g., 'boss_goblin' → 'goblin', 'slime_boss' → 'slime')
    final id = enemyId.toLowerCase();
    if (id.contains('slime')) {
      return const [Color(0xFF4CAF50), Color(0xFF66BB6A), Color(0xFF2E7D32), Color(0xFF81C784)];
    } else if (id.contains('goblin')) {
      return const [Color(0xFF8D6E63), Color(0xFFA1887F), Color(0xFF6D4C41), Color(0xFFBCAAA4)];
    } else if (id.contains('bat') || id.contains('ghost')) {
      return const [Color(0xFF9C27B0), Color(0xFFBA68C8), Color(0xFF7B1FA2), Color(0xFFCE93D8)];
    } else if (id.contains('orc')) {
      return const [Color(0xFF2E7D32), Color(0xFF388E3C), Color(0xFF1B5E20), Color(0xFF4CAF50)];
    } else if (id.contains('skeleton')) {
      return const [Color(0xFFEEEEEE), Color(0xFFBDBDBD), Color(0xFFE0E0E0), Color(0xFFFFFFFF)];
    } else if (id.contains('bomber')) {
      return const [Color(0xFFFF6600), Color(0xFFFF8800), Color(0xFFFF4400), Color(0xFFFFAA00)];
    } else if (id.contains('healer')) {
      return const [Color(0xFF66BB6A), Color(0xFF81C784), Color(0xFF4CAF50), Color(0xFFA5D6A7)];
    } else if (id.contains('shield')) {
      return const [Color(0xFF42A5F5), Color(0xFF64B5F6), Color(0xFF1E88E5), Color(0xFF90CAF9)];
    } else if (id.contains('mushroom')) {
      return const [Color(0xFF7B1FA2), Color(0xFF4CAF50), Color(0xFF9C27B0), Color(0xFF66BB6A)];
    } else if (id.contains('golem')) {
      return const [Color(0xFF888888), Color(0xFF6D4C41), Color(0xFFAAAAAA), Color(0xFF8D6E63)];
    }
    // Default: red/orange
    return const [Color(0xFFFF4444), Color(0xFFFF6666), Color(0xFFCC3333), Color(0xFFFFAA44)];
  }

  /// Enemy death burst — type-specific colors with enhanced particles.
  void spawnEnemyDeath(double wx, double wy, {String enemyId = ''}) {
    final rng = Random();
    final colors = _deathColorsForEnemy(enemyId);
    final isBomber = enemyId.contains('bomber');
    final count = isBomber ? 22 : 15; // Bombers get extra particles

    for (var i = 0; i < count; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = (isBomber ? 60 : 40) + rng.nextDouble() * (isBomber ? 120 : 80);
      _particles.add(_FxParticle(
        x: wx + (rng.nextDouble() - 0.5) * (isBomber ? 10 : 6),
        y: wy + (rng.nextDouble() - 0.5) * (isBomber ? 10 : 6),
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 25,
        size: (isBomber ? 3 : 2) + rng.nextDouble() * (isBomber ? 4 : 3),
        life: 0.3 + rng.nextDouble() * (isBomber ? 0.5 : 0.3),
        color: colors[rng.nextInt(colors.length)],
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

  /// Unit merge effect — rainbow sparkle burst, scales with resulting level.
  void spawnMerge(double wx, double wy, {int level = 1}) {
    final rng = Random();
    final count = 10 + level * 5; // Lv2=15, Lv3=20, Lv4=25, Lv5=30
    final sizeScale = 1.0 + (level - 1) * 0.2;
    final speedScale = 1.0 + (level - 1) * 0.15;
    for (var i = 0; i < count; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = (30 + rng.nextDouble() * 50) * speedScale;
      final hue = (i / count * 360).toDouble();
      _particles.add(_FxParticle(
        x: wx + (rng.nextDouble() - 0.5) * level * 4,
        y: wy + (rng.nextDouble() - 0.5) * level * 4,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 20,
        size: (2 + rng.nextDouble() * 3) * sizeScale,
        life: 0.5 + rng.nextDouble() * 0.3 + level * 0.05,
        color: HSVColor.fromAHSV(1.0, hue, 0.8, 1.0).toColor(),
      ));
    }
    // Lv5 (evolution): extra gold burst
    if (level >= 5) {
      for (var i = 0; i < 12; i++) {
        final angle = rng.nextDouble() * 2 * pi;
        final speed = 50 + rng.nextDouble() * 80;
        _particles.add(_FxParticle(
          x: wx,
          y: wy,
          vx: cos(angle) * speed,
          vy: sin(angle) * speed - 30,
          size: 3 + rng.nextDouble() * 3,
          life: 0.6 + rng.nextDouble() * 0.3,
          color: const Color(0xFFFFD700),
        ));
      }
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

  /// Projectile hit impact — small burst at hit point.
  void spawnProjectileHit(double wx, double wy, Color color) {
    final rng = Random();
    for (var i = 0; i < 4; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = 20 + rng.nextDouble() * 30;
      _particles.add(_FxParticle(
        x: wx,
        y: wy,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 10,
        size: 1.5 + rng.nextDouble() * 1.5,
        life: 0.15 + rng.nextDouble() * 0.1,
        color: color,
      ));
    }
  }

  /// Skill activation — large radial burst with skill color.
  void spawnSkillActivation(double wx, double wy, Color color) {
    final rng = Random();
    for (var i = 0; i < 35; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = 60 + rng.nextDouble() * 120;
      _particles.add(_FxParticle(
        x: wx + (rng.nextDouble() - 0.5) * 60,
        y: wy + (rng.nextDouble() - 0.5) * 30,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 30,
        size: 3 + rng.nextDouble() * 4,
        life: 0.4 + rng.nextDouble() * 0.4,
        color: color,
      ));
    }
  }

  /// Heal sparkle effect — green/white particles rising up.
  void spawnHealEffect(double wx, double wy) {
    final rng = Random();
    for (var i = 0; i < 10; i++) {
      final angle = -pi / 2 + (rng.nextDouble() - 0.5) * pi * 0.4;
      final speed = 30 + rng.nextDouble() * 50;
      const colors = [
        Color(0xFF4CAF50),
        Color(0xFF81C784),
        Color(0xFFFFFFFF),
        Color(0xFFA5D6A7),
      ];
      _particles.add(_FxParticle(
        x: wx + (rng.nextDouble() - 0.5) * 30,
        y: wy,
        vx: cos(angle) * speed * 0.3,
        vy: sin(angle) * speed,
        size: 2 + rng.nextDouble() * 2,
        life: 0.5 + rng.nextDouble() * 0.3,
        color: colors[rng.nextInt(colors.length)],
      ));
    }
  }

  /// Wall damage impact — directional sparks + debris.
  void spawnWallDamage(double wx, double wy, double fromX, double fromY) {
    final rng = Random();
    final hitAngle = atan2(wy - fromY, wx - fromX);
    for (var i = 0; i < 10; i++) {
      final angle = hitAngle + pi + (rng.nextDouble() - 0.5) * pi * 0.6;
      final speed = 40 + rng.nextDouble() * 60;
      const colors = [
        Color(0xFF8D6E63),
        Color(0xFFBCAAA4),
        Color(0xFFFF8A65),
        Color(0xFF888888),
      ];
      _particles.add(_FxParticle(
        x: wx,
        y: wy,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 20,
        size: 2 + rng.nextDouble() * 3,
        life: 0.3 + rng.nextDouble() * 0.2,
        color: colors[rng.nextInt(colors.length)],
      ));
    }
  }

  /// Evolution transformation — golden spiral burst.
  void spawnEvolution(double wx, double wy) {
    final rng = Random();
    for (var i = 0; i < 30; i++) {
      final angle = i / 30 * 2 * pi;
      final speed = 40 + rng.nextDouble() * 80;
      const colors = [
        Color(0xFFFFD700),
        Color(0xFFFFE44D),
        Color(0xFFFFFFFF),
        Color(0xFFFFA000),
      ];
      _particles.add(_FxParticle(
        x: wx,
        y: wy,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 30,
        size: 3 + rng.nextDouble() * 4,
        life: 0.6 + rng.nextDouble() * 0.4,
        color: colors[rng.nextInt(colors.length)],
      ));
    }
  }

  /// Skill activation — ring burst expanding outward.
  void spawnSkillRing(double wx, double wy, Color color) {
    final rng = Random();
    for (var i = 0; i < 40; i++) {
      final angle = i / 40 * 2 * pi;
      final speed = 80 + rng.nextDouble() * 40;
      _particles.add(_FxParticle(
        x: wx,
        y: wy,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        size: 3 + rng.nextDouble() * 2,
        life: 0.4 + rng.nextDouble() * 0.2,
        color: color,
      ));
    }
  }

  /// Scaled enemy death effect — size proportional to combo, type-specific colors.
  void spawnEnemyDeathScaled(double wx, double wy, double scale,
      {String enemyId = ''}) {
    final rng = Random();
    final count = (15 * scale).clamp(8, 40).toInt();
    final colors = _deathColorsForEnemy(enemyId);
    for (var i = 0; i < count; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = (50 + rng.nextDouble() * 90) * scale;
      _particles.add(_FxParticle(
        x: wx + (rng.nextDouble() - 0.5) * 8 * scale,
        y: wy + (rng.nextDouble() - 0.5) * 8 * scale,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 30 * scale,
        size: (2.5 + rng.nextDouble() * 3) * scale,
        life: (0.4 + rng.nextDouble() * 0.3) * scale.clamp(1.0, 2.0),
        color: colors[rng.nextInt(colors.length)],
      ));
    }
  }

  /// Shockwave ring — expanding ring of particles (boss kill, big combos).
  void spawnShockwaveRing(double wx, double wy, Color color) {
    for (int i = 0; i < 24; i++) {
      final angle = i / 24 * 2 * pi;
      _particles.add(_FxParticle(
        x: wx,
        y: wy,
        vx: cos(angle) * 200,
        vy: sin(angle) * 200,
        size: 3,
        life: 0.35,
        color: color,
      ));
    }
  }

  /// Muzzle flash on attack — small burst of color at unit position.
  /// Scales with level: Lv1=2 particles, Lv5=6 particles.
  void spawnMuzzleFlash(double wx, double wy, Color color, {int level = 1}) {
    final rng = Random();
    final count = 1 + level; // Lv1=2, Lv3=4, Lv5=6
    final isEvolved = level >= 5;
    for (var i = 0; i < count; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = 25 + rng.nextDouble() * 40;
      _particles.add(_FxParticle(
        x: wx + (rng.nextDouble() - 0.5) * 4,
        y: wy + (rng.nextDouble() - 0.5) * 4,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 15,
        size: 1.5 + rng.nextDouble() * (isEvolved ? 2.5 : 1.5),
        life: 0.12 + rng.nextDouble() * 0.1,
        color: isEvolved ? const Color(0xFFFFD700) : color,
      ));
    }
  }

  /// Gold scatter on kill — homing particles that fly toward the wall.
  void spawnGoldScatter(double wx, double wy, int amount,
      double wallX, double wallY) {
    final rng = Random();
    final count = amount.clamp(1, 5);
    for (int i = 0; i < count; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = 40 + rng.nextDouble() * 60;
      _particles.add(_FxParticle(
        x: wx,
        y: wy,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 30,
        size: 3 + rng.nextDouble() * 2,
        life: 0.8 + rng.nextDouble() * 0.4,
        color: const Color(0xFFFFD700),
        isHoming: true,
        homeX: wallX,
        homeY: wallY,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    for (final p in _particles) {
      if (p.isHoming && p.life < p.maxLife * 0.5) {
        // Homing: accelerate toward wall after initial burst
        final dx = p.homeX - p.x;
        final dy = p.homeY - p.y;
        final dist = sqrt(dx * dx + dy * dy);
        if (dist > 1) {
          const accel = 400.0;
          p.vx += (dx / dist) * accel * dt;
          p.vy += (dy / dist) * accel * dt;
        }
      } else {
        p.vy += 50 * dt; // light gravity for non-homing
      }
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.life -= dt;
    }

    _particles.removeWhere((p) => p.life <= 0);

    // Adaptive cap: 600 base, reduced when too many
    if (_particles.length > 600) {
      _particles.removeRange(0, _particles.length - 600);
    }
  }

  @override
  void render(Canvas canvas) {
    // No camera offset — fixed viewport for defense game
    final paint = Paint()..isAntiAlias = false;
    for (final p in _particles) {
      final alpha = (p.life * 2.5).clamp(0.0, 1.0);
      if (alpha < 0.05) continue; // Skip nearly-invisible particles
      paint.color = p.color.withValues(alpha: alpha * p.color.a);
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
  final double maxLife;
  final Color color;
  final bool isHoming;
  final double homeX;
  final double homeY;

  _FxParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required double life,
    required this.color,
    this.isHoming = false,
    this.homeX = 0,
    this.homeY = 0,
  })  : life = life,
        maxLife = life;
}
