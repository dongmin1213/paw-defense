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
  // Pre-allocated ambient stars — reduced for mobile performance
  static const int _starCount = 40;
  final List<_BgStar> _stars = [];
  final Random _rng = Random();

  // Radial pulse state
  double _pulseTimer = 0;
  double _pulseDuration = 0;
  Color _pulseColor = const Color(0x00000000);

  // Cached Paint objects to avoid per-frame allocation
  final Paint _bgPaint = Paint();
  final Paint _starPaint = Paint()..isAntiAlias = false;
  final Paint _pulsePaint = Paint();

  static final Rect _fullScreenRect = Rect.fromLTWH(
      0, 0, BalanceConfig.gameWidth, BalanceConfig.gameHeight);

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
        speed: 5 + _rng.nextDouble() * 15,
        size: 1.0 + _rng.nextDouble() * 2.5,
        alpha: 0.2 + _rng.nextDouble() * 0.4,
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
    // Calm: deep navy (12,12,36) → Intense: deep crimson (80,8,8)
    final r = (12 + (68 * intensity)).toInt().clamp(0, 255);
    final g = (12 - (4 * intensity)).toInt().clamp(0, 255);
    final b = (36 - (28 * intensity)).toInt().clamp(0, 255);
    _bgPaint.color = Color.fromARGB(255, r, g, b);
    canvas.drawRect(_fullScreenRect, _bgPaint);

    // ── Ambient stars ──
    for (final star in _stars) {
      // Stars get much brighter with intensity
      final a = (star.alpha + intensity * 0.5).clamp(0.0, 0.95);
      _starPaint.color = Color.fromARGB(
        (a * 255).toInt(), 255, 255, 255,
      );
      canvas.drawRect(
        Rect.fromLTWH(star.x, star.y, star.size, star.size),
        _starPaint,
      );
    }

    // ── Radial pulse ──
    if (_pulseTimer > 0 && _pulseDuration > 0) {
      final progress = 1.0 - (_pulseTimer / _pulseDuration);
      final pulseAlpha = (1.0 - progress) * 0.3;
      final pulseRadius = 80 + progress * 400;
      final wallX = game.wall.position.x;
      final wallY = game.wall.position.y;
      _pulsePaint.shader = Gradient.radial(
        Offset(wallX, wallY),
        pulseRadius,
        [
          _pulseColor.withValues(alpha: pulseAlpha),
          _pulseColor.withValues(alpha: 0.0),
        ],
      );
      canvas.drawRect(_fullScreenRect, _pulsePaint);
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
