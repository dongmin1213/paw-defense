import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../game/defense_game.dart';
import '../data/balance_config.dart';

/// Type of field drop for visual differentiation.
enum FieldDropType {
  gold,   // yellow coin
  gem,    // blue/purple gem (star currency)
  health, // green orb (heals wall)
}

/// A physical drop item that scatters on the ground when enemies die,
/// then homes toward the wall and gets absorbed.
/// Mimics the coin/gem scatter effect from games like Crazy Gunner.
class FieldDrop extends PositionComponent
    with HasGameReference<DefenseGame> {
  final FieldDropType type;
  final int value;

  // Physics state
  double _vx, _vy;
  final double _gravity = 120.0;
  final double _groundY;
  bool _grounded = false;
  double _groundTimer = 0;
  double _homeTimer = 0;
  bool _homing = false;
  double _alpha = 1.0;
  double _bobTimer = 0;
  double _sparkleTimer = 0;

  static final Random _rng = Random();
  static final Paint _paint = Paint()..isAntiAlias = false;
  static final Paint _glowPaint = Paint()..isAntiAlias = false;

  // Time on ground before auto-homing starts
  static const double _groundDelay = 0.8;
  // Homing speed (accelerates)
  static const double _homeAccel = 800.0;
  static const double _homeMaxSpeed = 500.0;

  /// Max active field drops to prevent performance issues.
  static const int maxDrops = 150;

  FieldDrop({
    required Vector2 spawnPosition,
    required this.type,
    this.value = 1,
  })  : _vx = (_rng.nextDouble() - 0.5) * 120,
        _vy = -80 - _rng.nextDouble() * 60,
        _groundY = spawnPosition.y + 10 + _rng.nextDouble() * 30,
        super(
          position: spawnPosition.clone(),
          size: Vector2(6, 6),
          anchor: Anchor.center,
          priority: 12,
        );

  /// Colors for each drop type.
  static const Map<FieldDropType, Color> _coreColors = {
    FieldDropType.gold: Color(0xFFFFD700),
    FieldDropType.gem: Color(0xFF7C4DFF),
    FieldDropType.health: Color(0xFF66BB6A),
  };

  static const Map<FieldDropType, Color> _glowColors = {
    FieldDropType.gold: Color(0xFFFFF176),
    FieldDropType.gem: Color(0xFFB388FF),
    FieldDropType.health: Color(0xFFA5D6A7),
  };

  @override
  void update(double dt) {
    super.update(dt);
    _sparkleTimer += dt;

    if (!_homing && !_grounded) {
      // Scatter physics: arc trajectory
      _vx *= 0.98; // air friction
      _vy += _gravity * dt;
      position.x += _vx * dt;
      position.y += _vy * dt;

      // Clamp to screen bounds
      position.x = position.x.clamp(5.0, BalanceConfig.gameWidth - 5.0);

      // Hit ground
      if (position.y >= _groundY) {
        position.y = _groundY;
        _grounded = true;
        _vy = 0;
        _vx = 0;
      }
    } else if (_grounded && !_homing) {
      // Bob on ground, wait for homing
      _groundTimer += dt;
      _bobTimer += dt;
      if (_groundTimer >= _groundDelay) {
        _homing = true;
      }
    } else if (_homing) {
      // Home toward wall — stop if wall is destroyed
      if (game.wall.isDestroyed) {
        _remove();
        return;
      }
      _homeTimer += dt;
      final wallPos = game.wall.position;
      final dx = wallPos.x - position.x;
      final dy = wallPos.y - position.y;
      final dist = sqrt(dx * dx + dy * dy);

      if (dist < 10) {
        _onAbsorbed();
        _remove();
        return;
      }

      final speed = (_homeAccel * _homeTimer * _homeTimer).clamp(0.0, _homeMaxSpeed);
      final nx = dx / dist;
      final ny = dy / dist;
      position.x += nx * speed * dt;
      position.y += ny * speed * dt;

      // Fade in the last moments
      if (dist < 30) {
        _alpha = (dist / 30).clamp(0.3, 1.0);
      }
    }
  }

  void _remove() {
    game.onFieldDropRemoved();
    removeFromParent();
  }

  void _onAbsorbed() {
    switch (type) {
      case FieldDropType.gold:
        game.addGold(value);
        break;
      case FieldDropType.gem:
        // Gems add to star currency — small bonus
        game.addGold(value * 2);
        break;
      case FieldDropType.health:
        if (!game.wall.isDestroyed) {
          game.wall.heal(value.toDouble());
        }
        break;
    }
    // Small sparkle on absorb
    game.particleEffect.spawnMuzzleFlash(
      game.wall.position.x,
      game.wall.position.y,
      _coreColors[type] ?? const Color(0xFFFFD700),
      level: 1,
    );
  }

  @override
  void render(Canvas canvas) {
    final core = _coreColors[type] ?? const Color(0xFFFFD700);
    final glow = _glowColors[type] ?? const Color(0xFFFFF176);

    final cx = size.x / 2;
    final cy = size.y / 2;

    // Bob animation when grounded
    double bobOffset = 0;
    if (_grounded && !_homing) {
      bobOffset = sin(_bobTimer * 4) * 1.5;
    }

    // Glow aura
    final glowAlpha = (0.3 + sin(_sparkleTimer * 6) * 0.15).clamp(0.0, 1.0) * _alpha;
    _glowPaint.color = glow.withValues(alpha: glowAlpha);
    canvas.drawCircle(Offset(cx, cy + bobOffset), 4.5, _glowPaint);

    // Core shape
    _paint.color = core.withValues(alpha: _alpha);

    switch (type) {
      case FieldDropType.gold:
        // Coin: small square with highlight
        canvas.drawRect(
          Rect.fromCenter(center: Offset(cx, cy + bobOffset), width: 4, height: 4),
          _paint,
        );
        // Highlight pixel
        _paint.color = const Color(0xFFFFFFFF).withValues(alpha: _alpha * 0.7);
        canvas.drawRect(
          Rect.fromLTWH(cx - 1, cy - 1 + bobOffset, 1, 1),
          _paint,
        );
        break;

      case FieldDropType.gem:
        // Diamond shape: rotated square
        final path = Path()
          ..moveTo(cx, cy - 3 + bobOffset)
          ..lineTo(cx + 2.5, cy + bobOffset)
          ..lineTo(cx, cy + 3 + bobOffset)
          ..lineTo(cx - 2.5, cy + bobOffset)
          ..close();
        canvas.drawPath(path, _paint);
        // Sparkle highlight
        _paint.color = const Color(0xFFFFFFFF).withValues(alpha: _alpha * 0.5);
        canvas.drawRect(
          Rect.fromLTWH(cx - 0.5, cy - 1.5 + bobOffset, 1, 1),
          _paint,
        );
        break;

      case FieldDropType.health:
        // Cross/plus shape
        canvas.drawRect(
          Rect.fromCenter(center: Offset(cx, cy + bobOffset), width: 4, height: 2),
          _paint,
        );
        canvas.drawRect(
          Rect.fromCenter(center: Offset(cx, cy + bobOffset), width: 2, height: 4),
          _paint,
        );
        break;
    }
  }
}
