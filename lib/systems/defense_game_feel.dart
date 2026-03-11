import 'dart:math';
import 'package:flame/components.dart';
import '../game/defense_game.dart';

/// Game feel system for castle defense.
/// Provides hit stop, slow motion, zoom punch,
/// and auto-merge / auto-place systems.
class DefenseGameFeel extends Component with HasGameReference<DefenseGame> {
  // ── Hit Stop (frame freeze) ──
  double _hitStopTimer = 0;
  bool get isHitStopped => _hitStopTimer > 0;

  // ── Slow Motion ──
  double _slowMotionTimer = 0;
  double _slowMotionScale = 1.0;
  double get timeScale => _slowMotionTimer > 0 ? _slowMotionScale : 1.0;

  // ── Zoom Punch ──
  double _zoomPunchTimer = 0;
  double _zoomPunchDuration = 0.3;
  double _zoomPunchTarget = 1.0;
  double currentZoom = 1.0;

  // ── Screen Flash ──
  double _flashTimer = 0;
  double _flashDuration = 0;
  int flashColor = 0x00FFFFFF;
  double get flashAlpha =>
      _flashTimer > 0 ? (_flashTimer / _flashDuration).clamp(0.0, 1.0) * 0.3 : 0.0;

  // ── Auto Systems ──
  double _autoMergeTimer = 0;
  double _autoPlaceTimer = 0;
  bool autoMergeEnabled = false;
  bool autoPlaceEnabled = false;

  /// Auto-merge check interval in seconds.
  static const double autoMergeInterval = 1.5;

  /// Auto-place check interval in seconds.
  static const double autoPlaceInterval = 3.0;

  @override
  void update(double dt) {
    _updateHitStop(dt);
    _updateSlowMotion(dt);
    _updateZoomPunch(dt);
    _updateFlash(dt);
    _updateAutoSystems(dt);
  }

  // ══════════════════════════════════════
  // Hit Stop
  // ══════════════════════════════════════

  /// Freeze the game for [duration] seconds (frame freeze effect).
  void hitStop({double duration = 0.05}) {
    _hitStopTimer = duration;
  }

  void _updateHitStop(double dt) {
    if (_hitStopTimer > 0) {
      _hitStopTimer -= dt;
    }
  }

  // ══════════════════════════════════════
  // Slow Motion
  // ══════════════════════════════════════

  /// Apply slow motion for [duration] seconds at [scale] time scale.
  void slowMotion({double scale = 0.5, double duration = 0.5}) {
    _slowMotionScale = scale;
    _slowMotionTimer = duration;
  }

  void _updateSlowMotion(double dt) {
    if (_slowMotionTimer > 0) {
      _slowMotionTimer -= dt;
    }
  }

  // ══════════════════════════════════════
  // Zoom Punch
  // ══════════════════════════════════════

  /// Zoom punch disabled — causes distracting screen shake.
  void zoomPunch({double targetZoom = 1.05, double duration = 0.3}) {
    // Intentionally disabled: zoom punch felt like unwanted screen shake.
  }

  void _updateZoomPunch(double dt) {
    if (_zoomPunchTimer > 0) {
      _zoomPunchTimer -= dt;
      final t = (_zoomPunchTimer / _zoomPunchDuration).clamp(0.0, 1.0);
      currentZoom =
          1.0 + (_zoomPunchTarget - 1.0) * _easeOutElastic(1.0 - t);
      if (_zoomPunchTimer <= 0) {
        currentZoom = 1.0;
      }
    }
  }

  double _easeOutElastic(double t) {
    if (t == 0 || t == 1) return t;
    return pow(2, -10 * t) * sin((t - 0.1) * 5 * pi) + 1;
  }

  // ══════════════════════════════════════
  // Screen Flash
  // ══════════════════════════════════════

  /// Flash the screen with a color overlay that fades out.
  void screenFlash({int color = 0xFFFFFFFF, double duration = 0.15}) {
    flashColor = color;
    _flashDuration = duration;
    _flashTimer = duration;
  }

  void _updateFlash(double dt) {
    if (_flashTimer > 0) {
      _flashTimer -= dt;
    }
  }

  // ══════════════════════════════════════
  // Castle Defense Presets
  // ══════════════════════════════════════

  /// Feedback when a normal enemy is killed.
  /// [comboTier] is the current combo tier index (0=none, 3=amazing, 5=godlike).
  void onEnemyKill({int comboTier = 0}) {
    // Every kill: micro hit stop (1 frame ≈ 0.015s)
    hitStop(duration: 0.015);

    // Amazing (25+ combo) and above: subtle screen flash
    if (comboTier >= 3) {
      screenFlash(color: 0x44FFFFFF, duration: 0.08);
    }
  }


  /// Feedback when a boss takes a hit.
  void onBossHit() {
    hitStop(duration: 0.04);
  }

  /// Dramatic feedback when a boss is killed.
  void onBossKill() {
    hitStop(duration: 0.25);
    slowMotion(scale: 0.2, duration: 1.0);
    zoomPunch(targetZoom: 1.08, duration: 0.5);
    screenFlash(color: 0xFFFFAA00, duration: 0.3);
  }

  /// Feedback when the wall takes a hit.
  void onWallHit({bool isHeavy = false}) {
    if (isHeavy) {
      screenFlash(color: 0xFFFF4444, duration: 0.2);
    }
  }

  /// Feedback when the wall HP drops below critical threshold.
  void onWallCritical() {
    screenFlash(color: 0xFFFF0000, duration: 0.4);
  }

  /// Feedback when units are merged. Scales with resulting level.
  void onMerge(int newLevel) {
    zoomPunch(
      targetZoom: 1.02 + newLevel * 0.01,
      duration: 0.2,
    );
  }

  /// Dramatic feedback when a unit evolves (Lv5 + relic).
  void onEvolve() {
    hitStop(duration: 0.15);
    slowMotion(scale: 0.3, duration: 0.8);
    zoomPunch(targetZoom: 1.06, duration: 0.4);
    screenFlash(color: 0xFFFFD700, duration: 0.3);
  }

  /// Feedback when a hybrid unit is created.
  void onHybridMerge() {
    hitStop(duration: 0.1);
    slowMotion(scale: 0.4, duration: 0.6);
    zoomPunch(targetZoom: 1.05, duration: 0.3);
    screenFlash(color: 0xFFE040FB, duration: 0.25);
  }

  /// Feedback for ascension (prestige reset).
  void onAscension() {
    slowMotion(scale: 0.2, duration: 1.5);
    screenFlash(color: 0xFFFFFFFF, duration: 0.5);
  }

  /// Feedback for completing a wave without wall damage.
  void onPerfectWave() {
    zoomPunch(targetZoom: 1.03, duration: 0.3);
    screenFlash(color: 0xFF4CAF50, duration: 0.2);
  }

  /// Feedback for skill activation.
  void onSkillActivation() {
    hitStop(duration: 0.08);
    slowMotion(scale: 0.3, duration: 0.5);
    zoomPunch(targetZoom: 1.04, duration: 0.3);
  }

  /// Feedback for combo tier change.
  void onComboTierChange(int tierColor) {
    screenFlash(color: tierColor, duration: 0.3);
    hitStop(duration: 0.06);
  }

  /// Feedback for relic acquisition.
  void onRelicAcquired() {
    zoomPunch(targetZoom: 1.03, duration: 0.2);
    screenFlash(color: 0xFFE040FB, duration: 0.2);
  }

  // ══════════════════════════════════════
  // Auto Systems
  // ══════════════════════════════════════

  void _updateAutoSystems(double dt) {
    if (autoMergeEnabled) {
      _autoMergeTimer += dt;
      if (_autoMergeTimer >= autoMergeInterval) {
        _autoMergeTimer = 0;
        _tryAutoMerge();
      }
    }

    if (autoPlaceEnabled) {
      _autoPlaceTimer += dt;
      if (_autoPlaceTimer >= autoPlaceInterval) {
        _autoPlaceTimer = 0;
        _tryAutoPlace();
      }
    }
  }

  /// Automatically merge units if 3 of the same type+level exist.
  void _tryAutoMerge() {
    // Delegate to DefenseGame's internal merge logic
    game.tryAutoMerge();
  }

  /// Automatically buy and place a unit in an empty slot if affordable.
  void _tryAutoPlace() {
    game.buyUnit();
  }
}
