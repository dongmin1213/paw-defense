import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../game/defense_game.dart';
import '../data/balance_config.dart';

/// Full-screen visual overlay for active skill effects.
/// Each skill type gets a unique, screen-filling visual that lasts
/// for the skill's duration, making activations feel impactful.
class SkillEffectOverlay extends PositionComponent
    with HasGameReference<DefenseGame> {
  String? _activeEffect;
  double _timer = 0;
  double _maxDuration = 0;
  final Random _rng = Random();

  // Pre-allocated particle pools per effect type
  final List<_SkillParticle> _particles = [];
  static const int _maxParticles = 60;

  // Cached Paint objects to avoid per-frame allocation
  final Paint _particlePaint = Paint()..isAntiAlias = false;
  final Paint _ambientPaint = Paint();
  final Paint _specialPaint = Paint();
  final Paint _tipPaint = Paint()
    ..isAntiAlias = false
    ..color = const Color(0xFFFFFFFF);
  final Paint _corePaint = Paint()
    ..isAntiAlias = false
    ..color = const Color(0xFFFFFF00);
  final Paint _sparklePaint = Paint()
    ..isAntiAlias = false
    ..color = const Color(0xFFFFFFFF);
  final Paint _smallPaint = Paint()..isAntiAlias = false;

  static final Rect _fullScreenRect = Rect.fromLTWH(
      0, 0, BalanceConfig.gameWidth, BalanceConfig.gameHeight);

  SkillEffectOverlay()
      : super(
          priority: 15, // above projectiles, below HUD
          size: Vector2(BalanceConfig.gameWidth, BalanceConfig.gameHeight),
        );

  /// Activate a skill visual effect.
  void activate(String effectId, double duration) {
    _activeEffect = effectId;
    _timer = duration;
    _maxDuration = duration;
    _particles.clear();
    _spawnInitialParticles(effectId);
  }

  /// Progress 0.0 → 1.0 over the effect duration.
  double get _progress =>
      _maxDuration > 0 ? (1.0 - _timer / _maxDuration).clamp(0.0, 1.0) : 1.0;

  void _spawnInitialParticles(String effectId) {
    switch (effectId) {
      case 'arrow_rain':
        // Gold arrows falling from top
        for (int i = 0; i < _maxParticles; i++) {
          _particles.add(_SkillParticle(
            x: _rng.nextDouble() * BalanceConfig.gameWidth,
            y: -10 - _rng.nextDouble() * BalanceConfig.gameHeight,
            vx: -15 + _rng.nextDouble() * 30,
            vy: 200 + _rng.nextDouble() * 300,
            size: 2 + _rng.nextDouble() * 3,
            type: _ParticleType.arrow,
          ));
        }
        break;
      case 'meteor':
        // Embers rising from center
        for (int i = 0; i < 40; i++) {
          final angle = _rng.nextDouble() * 2 * pi;
          final speed = 20 + _rng.nextDouble() * 80;
          _particles.add(_SkillParticle(
            x: BalanceConfig.gameWidth / 2 + (_rng.nextDouble() - 0.5) * 100,
            y: BalanceConfig.gameHeight / 2 - 40 + (_rng.nextDouble() - 0.5) * 100,
            vx: cos(angle) * speed,
            vy: sin(angle) * speed - 40,
            size: 2 + _rng.nextDouble() * 4,
            type: _ParticleType.ember,
          ));
        }
        break;
      case 'ice_wall':
        // Frost crystals drifting from edges
        for (int i = 0; i < _maxParticles; i++) {
          final edge = _rng.nextInt(4);
          double x, y;
          switch (edge) {
            case 0:
              x = _rng.nextDouble() * BalanceConfig.gameWidth;
              y = 0;
              break;
            case 1:
              x = _rng.nextDouble() * BalanceConfig.gameWidth;
              y = BalanceConfig.gameHeight;
              break;
            case 2:
              x = 0;
              y = _rng.nextDouble() * BalanceConfig.gameHeight;
              break;
            default:
              x = BalanceConfig.gameWidth;
              y = _rng.nextDouble() * BalanceConfig.gameHeight;
              break;
          }
          final cx = BalanceConfig.gameWidth / 2;
          final cy = BalanceConfig.gameHeight / 2;
          final dx = cx - x;
          final dy = cy - y;
          final dist = sqrt(dx * dx + dy * dy);
          final speed = 10 + _rng.nextDouble() * 30;
          _particles.add(_SkillParticle(
            x: x,
            y: y,
            vx: dist > 0 ? (dx / dist) * speed : 0,
            vy: dist > 0 ? (dy / dist) * speed : 0,
            size: 2 + _rng.nextDouble() * 3,
            type: _ParticleType.frost,
          ));
        }
        break;
      case 'war_cry':
        // Red energy pulsing outward from wall
        for (int i = 0; i < 30; i++) {
          final angle = _rng.nextDouble() * 2 * pi;
          final speed = 30 + _rng.nextDouble() * 60;
          _particles.add(_SkillParticle(
            x: BalanceConfig.gameWidth / 2,
            y: BalanceConfig.gameHeight / 2 - 40,
            vx: cos(angle) * speed,
            vy: sin(angle) * speed,
            size: 3 + _rng.nextDouble() * 3,
            type: _ParticleType.energy,
          ));
        }
        break;
      case 'storm_call':
        // Lightning bolts + wind streaks
        for (int i = 0; i < _maxParticles; i++) {
          _particles.add(_SkillParticle(
            x: _rng.nextDouble() * BalanceConfig.gameWidth,
            y: _rng.nextDouble() * BalanceConfig.gameHeight,
            vx: -80 + _rng.nextDouble() * 60,
            vy: 100 + _rng.nextDouble() * 150,
            size: 1 + _rng.nextDouble() * 2,
            type: _ParticleType.wind,
          ));
        }
        break;
      case 'assassin_mark':
        // Dark swirling marks
        for (int i = 0; i < 25; i++) {
          final angle = (i / 25) * 2 * pi;
          final radius = 40 + _rng.nextDouble() * 80;
          _particles.add(_SkillParticle(
            x: BalanceConfig.gameWidth / 2 + cos(angle) * radius,
            y: BalanceConfig.gameHeight / 2 - 40 + sin(angle) * radius,
            vx: -sin(angle) * 60,
            vy: cos(angle) * 60,
            size: 2 + _rng.nextDouble() * 2,
            type: _ParticleType.mark,
          ));
        }
        break;
      case 'wall_heal':
        // Green healing sparkles rising
        for (int i = 0; i < 40; i++) {
          _particles.add(_SkillParticle(
            x: BalanceConfig.gameWidth / 2 + (_rng.nextDouble() - 0.5) * 120,
            y: BalanceConfig.gameHeight / 2 - 40 + (_rng.nextDouble() - 0.5) * 60,
            vx: (_rng.nextDouble() - 0.5) * 30,
            vy: -20 - _rng.nextDouble() * 40,
            size: 2 + _rng.nextDouble() * 3,
            type: _ParticleType.heal,
          ));
        }
        break;
      case 'mana_burst':
        // Purple shockwave expanding
        for (int i = 0; i < 40; i++) {
          final angle = _rng.nextDouble() * 2 * pi;
          final speed = 50 + _rng.nextDouble() * 100;
          _particles.add(_SkillParticle(
            x: BalanceConfig.gameWidth / 2,
            y: BalanceConfig.gameHeight / 2 - 40,
            vx: cos(angle) * speed,
            vy: sin(angle) * speed,
            size: 2 + _rng.nextDouble() * 4,
            type: _ParticleType.arcane,
          ));
        }
        break;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_activeEffect == null || _timer <= 0) return;

    _timer -= dt;
    if (_timer <= 0) {
      _activeEffect = null;
      _particles.clear();
      return;
    }

    // Continuous spawning for long-duration effects
    if (_activeEffect == 'arrow_rain' || _activeEffect == 'storm_call') {
      // Spawn new particles to maintain density
      if (_particles.length < _maxParticles && _rng.nextDouble() < 0.4) {
        if (_activeEffect == 'arrow_rain') {
          _particles.add(_SkillParticle(
            x: _rng.nextDouble() * BalanceConfig.gameWidth,
            y: -10,
            vx: -15 + _rng.nextDouble() * 30,
            vy: 200 + _rng.nextDouble() * 300,
            size: 2 + _rng.nextDouble() * 3,
            type: _ParticleType.arrow,
          ));
        } else {
          _particles.add(_SkillParticle(
            x: _rng.nextDouble() * BalanceConfig.gameWidth,
            y: -10,
            vx: -80 + _rng.nextDouble() * 60,
            vy: 100 + _rng.nextDouble() * 150,
            size: 1 + _rng.nextDouble() * 2,
            type: _ParticleType.wind,
          ));
        }
      }
    }

    // Continuous spawning for healing effect
    if (_activeEffect == 'wall_heal' &&
        _particles.length < 40 &&
        _rng.nextDouble() < 0.3) {
      _particles.add(_SkillParticle(
        x: BalanceConfig.gameWidth / 2 + (_rng.nextDouble() - 0.5) * 120,
        y: BalanceConfig.gameHeight / 2 - 40 + _rng.nextDouble() * 30,
        vx: (_rng.nextDouble() - 0.5) * 30,
        vy: -20 - _rng.nextDouble() * 40,
        size: 2 + _rng.nextDouble() * 3,
        type: _ParticleType.heal,
      ));
    }

    // War cry: re-pulse energy outward periodically
    if (_activeEffect == 'war_cry' &&
        _particles.length < 30 &&
        _rng.nextDouble() < 0.15) {
      final angle = _rng.nextDouble() * 2 * pi;
      final speed = 30 + _rng.nextDouble() * 60;
      _particles.add(_SkillParticle(
        x: BalanceConfig.gameWidth / 2,
        y: BalanceConfig.gameHeight / 2 - 40,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        size: 3 + _rng.nextDouble() * 3,
        type: _ParticleType.energy,
      ));
    }

    // Update particles
    _particles.removeWhere((p) {
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.life += dt;

      // Remove off-screen particles
      return p.x < -20 ||
          p.x > BalanceConfig.gameWidth + 20 ||
          p.y < -20 ||
          p.y > BalanceConfig.gameHeight + 20 ||
          p.life > 5.0;
    });
  }

  @override
  void render(Canvas canvas) {
    if (_activeEffect == null || _timer <= 0) return;

    final progress = _progress;

    // ── Screen-wide ambient overlay based on effect type ──
    _renderAmbient(canvas, progress);

    // ── Render particles ──
    for (final p in _particles) {
      final alpha = _particleAlpha(p, progress);
      if (alpha <= 0) continue;
      _particlePaint.color = _particleColor(p.type).withValues(alpha: alpha);
      _renderParticle(canvas, p, _particlePaint, alpha);
    }

    // ── Per-effect special overlays ──
    _renderSpecial(canvas, progress);
  }

  /// Subtle tinted screen overlay for atmosphere.
  void _renderAmbient(Canvas canvas, double progress) {
    final fadeAlpha = (1.0 - progress) * 0.06; // very subtle
    Color ambientColor;
    switch (_activeEffect) {
      case 'arrow_rain':
        ambientColor = const Color(0xFFFFD700);
        break;
      case 'meteor':
        ambientColor = const Color(0xFFFF3D00);
        break;
      case 'ice_wall':
        ambientColor = const Color(0xFF42A5F5);
        break;
      case 'war_cry':
        ambientColor = const Color(0xFFFF6D00);
        break;
      case 'storm_call':
        ambientColor = const Color(0xFF90CAF9);
        break;
      case 'assassin_mark':
        ambientColor = const Color(0xFFE040FB);
        break;
      case 'wall_heal':
        ambientColor = const Color(0xFF66BB6A);
        break;
      case 'mana_burst':
        ambientColor = const Color(0xFF651FFF);
        break;
      default:
        return;
    }
    _ambientPaint.color = ambientColor.withValues(alpha: fadeAlpha);
    canvas.drawRect(_fullScreenRect, _ambientPaint);
  }

  double _particleAlpha(_SkillParticle p, double progress) {
    // Fade in quickly, fade out at end of effect
    final fadeIn = (p.life * 3).clamp(0.0, 1.0);
    final fadeOut = (1.0 - progress).clamp(0.0, 1.0);
    return (fadeIn * fadeOut * 0.7).clamp(0.0, 0.7);
  }

  Color _particleColor(_ParticleType type) {
    switch (type) {
      case _ParticleType.arrow:
        return const Color(0xFFFFD700);
      case _ParticleType.ember:
        return const Color(0xFFFF6600);
      case _ParticleType.frost:
        return const Color(0xFF90CAF9);
      case _ParticleType.energy:
        return const Color(0xFFFF6D00);
      case _ParticleType.wind:
        return const Color(0xFFB0BEC5);
      case _ParticleType.mark:
        return const Color(0xFFE040FB);
      case _ParticleType.heal:
        return const Color(0xFF66BB6A);
      case _ParticleType.arcane:
        return const Color(0xFFB388FF);
    }
  }

  void _renderParticle(Canvas canvas, _SkillParticle p, Paint paint, double alpha) {
    switch (p.type) {
      case _ParticleType.arrow:
        // Elongated vertical (falling arrow)
        canvas.drawRect(
            Rect.fromLTWH(p.x, p.y, p.size * 0.5, p.size * 2), paint);
        // Arrow tip
        _tipPaint.color = const Color(0xFFFFFFFF).withValues(alpha: alpha * 0.71);
        canvas.drawRect(
            Rect.fromLTWH(p.x - p.size * 0.25, p.y, p.size, p.size * 0.6),
            _tipPaint);
        break;
      case _ParticleType.ember:
        // Flickering square
        final flicker = sin(p.life * 12) * 0.3 + 0.7;
        final size = p.size * flicker;
        canvas.drawRect(
            Rect.fromCenter(
                center: Offset(p.x, p.y), width: size, height: size),
            paint);
        // Hot core
        _corePaint.color = const Color(0xFFFFFF00).withValues(alpha: alpha * 0.57);
        canvas.drawRect(
            Rect.fromCenter(
                center: Offset(p.x, p.y),
                width: size * 0.4,
                height: size * 0.4),
            _corePaint);
        break;
      case _ParticleType.frost:
        // + shaped crystal
        canvas.drawRect(
            Rect.fromCenter(
                center: Offset(p.x, p.y),
                width: p.size,
                height: p.size * 0.3),
            paint);
        canvas.drawRect(
            Rect.fromCenter(
                center: Offset(p.x, p.y),
                width: p.size * 0.3,
                height: p.size),
            paint);
        break;
      case _ParticleType.energy:
        // Expanding energy blob
        canvas.drawRect(
            Rect.fromCenter(
                center: Offset(p.x, p.y),
                width: p.size,
                height: p.size),
            paint);
        break;
      case _ParticleType.wind:
        // Horizontal streak
        canvas.drawRect(
            Rect.fromLTWH(p.x, p.y, p.size * 3, p.size * 0.4), paint);
        break;
      case _ParticleType.mark:
        // X-shaped mark
        canvas.drawRect(
            Rect.fromCenter(
                center: Offset(p.x, p.y),
                width: p.size * 1.5,
                height: p.size * 0.4),
            paint);
        canvas.drawRect(
            Rect.fromCenter(
                center: Offset(p.x, p.y),
                width: p.size * 0.4,
                height: p.size * 1.5),
            paint);
        break;
      case _ParticleType.heal:
        // + shaped heal
        canvas.drawRect(
            Rect.fromCenter(
                center: Offset(p.x, p.y),
                width: p.size,
                height: p.size * 0.4),
            paint);
        canvas.drawRect(
            Rect.fromCenter(
                center: Offset(p.x, p.y),
                width: p.size * 0.4,
                height: p.size),
            paint);
        // White sparkle
        _sparklePaint.color = const Color(0xFFFFFFFF).withValues(alpha: alpha * 0.43);
        canvas.drawRect(
            Rect.fromCenter(
                center: Offset(p.x, p.y),
                width: p.size * 0.2,
                height: p.size * 0.2),
            _sparklePaint);
        break;
      case _ParticleType.arcane:
        // Star shape (cross + diagonal)
        canvas.drawRect(
            Rect.fromCenter(
                center: Offset(p.x, p.y),
                width: p.size,
                height: p.size * 0.3),
            paint);
        canvas.drawRect(
            Rect.fromCenter(
                center: Offset(p.x, p.y),
                width: p.size * 0.3,
                height: p.size),
            paint);
        // Diagonal arms (approximated with small squares)
        final half = p.size * 0.35;
        _smallPaint.color = paint.color.withValues(alpha: alpha * 0.71);
        canvas.drawRect(Rect.fromLTWH(p.x - half, p.y - half, 2, 2), _smallPaint);
        canvas.drawRect(Rect.fromLTWH(p.x + half - 2, p.y - half, 2, 2), _smallPaint);
        canvas.drawRect(Rect.fromLTWH(p.x - half, p.y + half - 2, 2, 2), _smallPaint);
        canvas.drawRect(Rect.fromLTWH(p.x + half - 2, p.y + half - 2, 2, 2), _smallPaint);
        break;
    }
  }

  /// Per-effect special overlay rendering (rings, frost borders, etc.)
  void _renderSpecial(Canvas canvas, double progress) {
    switch (_activeEffect) {
      case 'ice_wall':
        _renderFrostBorder(canvas, progress);
        break;
      case 'meteor':
        _renderMeteorGlow(canvas, progress);
        break;
      case 'mana_burst':
        _renderArcaneRing(canvas, progress);
        break;
      case 'assassin_mark':
        _renderAssassinAura(canvas, progress);
        break;
      case 'storm_call':
        _renderLightningFlash(canvas, progress);
        break;
      default:
        break;
    }
  }

  /// Ice wall: frost border creeping in from edges.
  void _renderFrostBorder(Canvas canvas, double progress) {
    final thickness = 12.0 * (1.0 - progress);
    final alpha = (1.0 - progress) * 0.15;
    _specialPaint.color = const Color(0xFF42A5F5).withValues(alpha: alpha);
    _specialPaint.shader = null;
    _specialPaint.style = PaintingStyle.fill;
    // Top
    canvas.drawRect(
        Rect.fromLTWH(0, 0, BalanceConfig.gameWidth, thickness), _specialPaint);
    // Bottom
    canvas.drawRect(
        Rect.fromLTWH(0, BalanceConfig.gameHeight - thickness,
            BalanceConfig.gameWidth, thickness),
        _specialPaint);
    // Left
    canvas.drawRect(
        Rect.fromLTWH(0, 0, thickness, BalanceConfig.gameHeight), _specialPaint);
    // Right
    canvas.drawRect(
        Rect.fromLTWH(BalanceConfig.gameWidth - thickness, 0, thickness,
            BalanceConfig.gameHeight),
        _specialPaint);
  }

  /// Meteor: radial glow at center.
  void _renderMeteorGlow(Canvas canvas, double progress) {
    if (progress > 0.5) return; // Only first half
    final intensity = (0.5 - progress) * 2.0;
    final radius = 60 + progress * 100;
    final cx = BalanceConfig.gameWidth / 2;
    final cy = BalanceConfig.gameHeight / 2 - 40;
    _specialPaint.color = const Color(0x00000000); // reset color
    _specialPaint.style = PaintingStyle.fill;
    _specialPaint.shader = Gradient.radial(
      Offset(cx, cy),
      radius,
      [
        const Color(0xFFFF3D00).withValues(alpha: intensity * 0.15),
        const Color(0xFFFF3D00).withValues(alpha: 0.0),
      ],
    );
    canvas.drawRect(_fullScreenRect, _specialPaint);
    _specialPaint.shader = null;
  }

  /// Mana burst: expanding purple ring.
  void _renderArcaneRing(Canvas canvas, double progress) {
    if (progress > 0.6) return;
    final ringProgress = progress / 0.6;
    final radius = 30 + ringProgress * 200;
    final alpha = (1.0 - ringProgress) * 0.12;
    final cx = BalanceConfig.gameWidth / 2;
    final cy = BalanceConfig.gameHeight / 2 - 40;
    _specialPaint.color = const Color(0x00000000);
    _specialPaint.style = PaintingStyle.fill;
    _specialPaint.shader = Gradient.radial(
      Offset(cx, cy),
      radius,
      [
        const Color(0xFF651FFF).withValues(alpha: 0.0),
        const Color(0xFF651FFF).withValues(alpha: alpha),
        const Color(0xFF651FFF).withValues(alpha: 0.0),
      ],
      [0.7, 0.85, 1.0],
    );
    canvas.drawRect(_fullScreenRect, _specialPaint);
    _specialPaint.shader = null;
  }

  /// Assassin mark: pulsing purple aura.
  void _renderAssassinAura(Canvas canvas, double progress) {
    final pulse = (sin(progress * 10 * pi) * 0.5 + 0.5);
    final alpha = (1.0 - progress) * pulse * 0.08;
    _specialPaint.shader = null;
    _specialPaint.style = PaintingStyle.fill;
    _specialPaint.color = const Color(0xFFE040FB).withValues(alpha: alpha);
    canvas.drawRect(_fullScreenRect, _specialPaint);
  }

  /// Storm call: random lightning flash.
  void _renderLightningFlash(Canvas canvas, double progress) {
    // Brief white flash at random intervals
    final flashCycle = (progress * 20) % 1.0;
    if (flashCycle < 0.05) {
      final alpha = (1.0 - progress) * 0.08;
      _specialPaint.shader = null;
      _specialPaint.style = PaintingStyle.fill;
      _specialPaint.color = const Color(0xFFFFFFFF).withValues(alpha: alpha);
      canvas.drawRect(_fullScreenRect, _specialPaint);
    }
  }
}

enum _ParticleType {
  arrow,
  ember,
  frost,
  energy,
  wind,
  mark,
  heal,
  arcane,
}

class _SkillParticle {
  double x, y;
  double vx, vy;
  final double size;
  final _ParticleType type;
  double life;

  _SkillParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.type,
    this.life = 0,
  });
}
