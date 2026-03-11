import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../game/defense_game.dart';
import '../data/balance_config.dart';

/// Dynamic background that reacts to game intensity.
/// - Color shifts from calm navy to intense crimson
/// - Ambient stars/dust drift for depth
/// - Radial pulse on wave start / boss kill
class ReactiveBackground extends PositionComponent
    with HasGameReference<DefenseGame> {
  // Pre-allocated ambient stars for zero-alloc rendering
  static const int _starCount = 40;
  final List<_BgStar> _stars = [];
  final Random _rng = Random();

  // Radial pulse state
  double _pulseTimer = 0;
  double _pulseDuration = 0;
  Color _pulseColor = const Color(0x00000000);

  ReactiveBackground()
      : super(
          priority: -10, // render behind everything
          size: Vector2(BalanceConfig.gameWidth, BalanceConfig.gameHeight),
        );

  @override
  Future<void> onLoad() async {
    // Initialize ambient stars
    for (int i = 0; i < _starCount; i++) {
      _stars.add(_BgStar(
        x: _rng.nextDouble() * BalanceConfig.gameWidth,
        y: _rng.nextDouble() * BalanceConfig.gameHeight,
        speed: 3 + _rng.nextDouble() * 8,
        size: 1.0 + _rng.nextDouble() * 1.5,
        alpha: 0.15 + _rng.nextDouble() * 0.25,
      ));
    }
  }

  /// Game intensity: 0.0 (peaceful) → 1.0 (chaos)
  double get _intensity {
    if (!game.isPlaying) return 0.0;
    final enemyCount = game.livingEnemies.length;
    final comboScale = game.comboManager.effectSizeMultiplier - 1.0;
    final waveProgress = game.currentWave / 50.0;
    // Enemy density is most intuitive — weighted higher, saturates faster
    return ((enemyCount / 30.0) * 0.5 +
            (comboScale / 2.0) * 0.2 +
            waveProgress * 0.3)
        .clamp(0.0, 1.0);
  }

  /// Trigger a radial pulse effect (e.g., wave start, boss kill).
  void pulse(Color color, {double duration = 0.6}) {
    _pulseTimer = duration;
    _pulseDuration = duration;
    _pulseColor = color;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Drift stars downward — accelerate with intensity
    final intensity = _intensity;
    for (final star in _stars) {
      star.y += star.speed * (1.0 + intensity * 2.0) * dt;
      if (star.y > BalanceConfig.gameHeight + 2) {
        star.y = -2;
        star.x = _rng.nextDouble() * BalanceConfig.gameWidth;
      }
    }

    // Pulse timer
    if (_pulseTimer > 0) {
      _pulseTimer -= dt;
      if (_pulseTimer < 0) _pulseTimer = 0;
    }
  }

  @override
  void render(Canvas canvas) {
    final intensity = _intensity;

    // ── Background color shift ──
    // Calm: deep navy (18,18,48) → Intense: deep crimson (65,12,12)
    final r = (18 + (47 * intensity)).toInt().clamp(0, 255);
    final g = (18 - (6 * intensity)).toInt().clamp(0, 255);
    final b = (48 - (36 * intensity)).toInt().clamp(0, 255);
    final bgPaint = Paint()..color = Color.fromARGB(255, r, g, b);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, BalanceConfig.gameWidth, BalanceConfig.gameHeight),
      bgPaint,
    );

    // ── Ambient stars ──
    final starPaint = Paint()..isAntiAlias = false;
    for (final star in _stars) {
      // Stars get noticeably brighter with intensity
      final a = (star.alpha + intensity * 0.35).clamp(0.0, 0.8);
      starPaint.color = Color.fromARGB(
        (a * 255).toInt(), 255, 255, 255,
      );
      canvas.drawRect(
        Rect.fromLTWH(star.x, star.y, star.size, star.size),
        starPaint,
      );
    }

    // ── Radial pulse ──
    if (_pulseTimer > 0 && _pulseDuration > 0) {
      final progress = 1.0 - (_pulseTimer / _pulseDuration);
      final pulseAlpha = (1.0 - progress) * 0.12;
      final pulseRadius = 50 + progress * 250;
      final wallX = game.wall.position.x;
      final wallY = game.wall.position.y;
      final pulsePaint = Paint()
        ..shader = Gradient.radial(
          Offset(wallX, wallY),
          pulseRadius,
          [
            _pulseColor.withValues(alpha: pulseAlpha),
            _pulseColor.withValues(alpha: 0.0),
          ],
        );
      canvas.drawRect(
        Rect.fromLTWH(0, 0, BalanceConfig.gameWidth, BalanceConfig.gameHeight),
        pulsePaint,
      );
    }
  }
}

class _BgStar {
  double x, y;
  final double speed;
  final double size;
  final double alpha;

  _BgStar({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.alpha,
  });
}
