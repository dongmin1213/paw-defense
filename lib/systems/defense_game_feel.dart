import 'dart:math';
import 'package:flame/components.dart';
import '../data/balance_config.dart';
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
  static double get autoMergeInterval => BalanceConfig.autoMergeInterval;

  /// Auto-place check interval in seconds.
  static double get autoPlaceInterval => BalanceConfig.autoPlaceInterval;

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

  /// Subtle zoom punch — gentler than original to avoid distracting shake.
  void zoomPunch({double targetZoom = 1.05, double duration = 0.3}) {
    // Re-enabled with reduced intensity for satisfying impact feedback.
    final clampedZoom = targetZoom.clamp(1.0, 1.06);
    _zoomPunchTarget = clampedZoom;
    _zoomPunchDuration = duration;
    _zoomPunchTimer = duration;
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
    hitStop(duration: BalanceConfig.feelEnemyKillHitStop);

    if (comboTier >= BalanceConfig.feelEnemyKillComboThreshold) {
      screenFlash(color: BalanceConfig.feelEnemyKillFlashColor, duration: BalanceConfig.feelEnemyKillFlashDuration);
    }
  }


  /// Feedback when a boss takes a hit.
  void onBossHit() {
    hitStop(duration: BalanceConfig.feelBossHitHitStop);
  }

  /// Dramatic feedback when a boss is killed.
  void onBossKill() {
    hitStop(duration: BalanceConfig.feelBossKillHitStop);
    slowMotion(scale: BalanceConfig.feelBossKillSlowScale, duration: BalanceConfig.feelBossKillSlowDuration);
    zoomPunch(targetZoom: BalanceConfig.feelBossKillZoom, duration: BalanceConfig.feelBossKillZoomDuration);
    screenFlash(color: BalanceConfig.feelBossKillFlashColor, duration: BalanceConfig.feelBossKillFlashDuration);
  }

  /// Feedback when the wall takes a hit.
  void onWallHit({bool isHeavy = false}) {
    if (isHeavy) {
      screenFlash(color: BalanceConfig.feelWallHitFlashColor, duration: BalanceConfig.feelWallHitFlashDuration);
    }
  }

  /// Feedback when the wall HP drops below critical threshold.
  void onWallCritical() {
    screenFlash(color: BalanceConfig.feelWallCriticalFlashColor, duration: BalanceConfig.feelWallCriticalFlashDuration);
  }

  /// Feedback when units are merged. Scales with resulting level.
  void onMerge(int newLevel) {
    zoomPunch(
      targetZoom: BalanceConfig.feelMergeZoomBase + newLevel * BalanceConfig.feelMergeZoomPerLevel,
      duration: BalanceConfig.feelMergeZoomDuration,
    );
  }

  /// Dramatic feedback when a unit evolves (Lv5 + relic).
  void onEvolve() {
    hitStop(duration: BalanceConfig.feelEvolveHitStop);
    slowMotion(scale: BalanceConfig.feelEvolveSlowScale, duration: BalanceConfig.feelEvolveSlowDuration);
    zoomPunch(targetZoom: BalanceConfig.feelEvolveZoom, duration: BalanceConfig.feelEvolveZoomDuration);
    screenFlash(color: BalanceConfig.feelEvolveFlashColor, duration: BalanceConfig.feelEvolveFlashDuration);
  }

  /// Feedback when a hybrid unit is created.
  void onHybridMerge() {
    hitStop(duration: BalanceConfig.feelHybridHitStop);
    slowMotion(scale: BalanceConfig.feelHybridSlowScale, duration: BalanceConfig.feelHybridSlowDuration);
    zoomPunch(targetZoom: BalanceConfig.feelHybridZoom, duration: BalanceConfig.feelHybridZoomDuration);
    screenFlash(color: BalanceConfig.feelHybridFlashColor, duration: BalanceConfig.feelHybridFlashDuration);
  }

  /// Feedback for ascension (prestige reset).
  void onAscension() {
    slowMotion(scale: BalanceConfig.feelAscensionSlowScale, duration: BalanceConfig.feelAscensionSlowDuration);
    screenFlash(color: BalanceConfig.feelAscensionFlashColor, duration: BalanceConfig.feelAscensionFlashDuration);
  }

  /// Feedback for completing a wave without wall damage.
  void onPerfectWave() {
    zoomPunch(targetZoom: BalanceConfig.feelPerfectWaveZoom, duration: BalanceConfig.feelPerfectWaveZoomDuration);
    screenFlash(color: BalanceConfig.feelPerfectWaveFlashColor, duration: BalanceConfig.feelPerfectWaveFlashDuration);
  }

  /// Feedback for skill activation.
  void onSkillActivation() {
    hitStop(duration: BalanceConfig.feelSkillHitStop);
    slowMotion(scale: BalanceConfig.feelSkillSlowScale, duration: BalanceConfig.feelSkillSlowDuration);
    zoomPunch(targetZoom: BalanceConfig.feelSkillZoom, duration: BalanceConfig.feelSkillZoomDuration);
  }

  /// Feedback for combo tier change.
  void onComboTierChange(int tierColor) {
    screenFlash(color: tierColor, duration: BalanceConfig.feelComboTierFlashDuration);
    hitStop(duration: BalanceConfig.feelComboTierHitStop);
  }

  /// Feedback for relic acquisition.
  void onRelicAcquired() {
    zoomPunch(targetZoom: BalanceConfig.feelRelicZoom, duration: BalanceConfig.feelRelicZoomDuration);
    screenFlash(color: BalanceConfig.feelRelicFlashColor, duration: BalanceConfig.feelRelicFlashDuration);
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
