import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sound and vibration settings manager.
/// Manages BGM/SFX/vibration toggles and volume levels.
/// Audio playback via flame_audio, haptic via HapticFeedback.
class SoundManager {
  bool _bgmEnabled = true;
  bool _sfxEnabled = true;
  bool _vibrationEnabled = true;
  double _bgmVolume = 0.7;
  double _sfxVolume = 1.0;
  bool _bgmPlaying = false;
  String _currentBgmTrack = '';

  bool get bgmEnabled => _bgmEnabled;
  bool get sfxEnabled => _sfxEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  double get bgmVolume => _bgmVolume;
  double get sfxVolume => _sfxVolume;

  void setBgmEnabled(bool v) {
    _bgmEnabled = v;
    if (!v) {
      stopBgm();
    }
    _save();
  }

  void setSfxEnabled(bool v) {
    _sfxEnabled = v;
    _save();
  }

  void setVibrationEnabled(bool v) {
    _vibrationEnabled = v;
    _save();
  }

  void setBgmVolume(double v) {
    _bgmVolume = v.clamp(0.0, 1.0);
    if (_bgmPlaying) {
      FlameAudio.bgm.audioPlayer.setVolume(_bgmVolume);
    }
    _save();
  }

  void setSfxVolume(double v) {
    _sfxVolume = v.clamp(0.0, 1.0);
    _save();
  }

  // === SFX playback ===

  void _playSfx(String file, {double volumeScale = 1.0}) {
    if (!_sfxEnabled) return;
    try {
      FlameAudio.play(file, volume: _sfxVolume * volumeScale);
    } catch (_) {
      // Silently ignore if file not found
    }
  }

  // === Core SFX ===

  void playHit() {
    _playSfx('sfx/hit.ogg');
    hapticLight();
  }

  void playCriticalHit() {
    _playSfx('sfx/hit.ogg', volumeScale: 1.3);
    hapticMedium();
  }

  void playMerge() {
    _playSfx('sfx/merge.ogg');
    hapticMedium();
  }

  void playBuy() => _playSfx('sfx/buy.ogg');

  void playWaveClear() {
    _playSfx('sfx/wave_clear.ogg');
    hapticMedium();
  }

  void playBossKill() {
    _playSfx('sfx/boss_kill.ogg', volumeScale: 1.2);
    hapticHeavy();
  }

  void playRewardSelect() => _playSfx('sfx/reward.ogg');

  void playGameOver() {
    _playSfx('sfx/game_over.ogg');
    hapticHeavy();
  }

  void playButtonTap() => _playSfx('sfx/tap.ogg', volumeScale: 0.5);

  // === Extended SFX (AAA-level variety) ===

  void playEvolve() {
    _playSfx('sfx/merge.ogg', volumeScale: 1.3);
    hapticHeavy();
  }

  void playHybridMerge() {
    _playSfx('sfx/merge.ogg', volumeScale: 1.2);
    hapticHeavy();
  }

  void playWallHit() {
    _playSfx('sfx/hit.ogg', volumeScale: 0.8);
    hapticLight();
  }

  void playWallCritical() {
    _playSfx('sfx/hit.ogg', volumeScale: 1.0);
    hapticHeavy();
  }

  void playSkillActivation() {
    _playSfx('sfx/reward.ogg', volumeScale: 1.1);
    hapticMedium();
  }

  void playComboTierUp() {
    _playSfx('sfx/wave_clear.ogg', volumeScale: 0.8);
    hapticMedium();
  }

  void playRelicAcquired() {
    _playSfx('sfx/reward.ogg', volumeScale: 1.0);
    hapticMedium();
  }

  void playSell() => _playSfx('sfx/buy.ogg', volumeScale: 0.7);

  void playWaveStart() => _playSfx('sfx/tap.ogg', volumeScale: 0.8);

  void playBossSpawn() {
    _playSfx('sfx/boss_kill.ogg', volumeScale: 0.6);
    hapticMedium();
  }

  void playPerfectWave() {
    _playSfx('sfx/wave_clear.ogg', volumeScale: 1.2);
    hapticMedium();
  }

  void playAchievement() {
    _playSfx('sfx/reward.ogg', volumeScale: 1.0);
    hapticMedium();
  }

  // === Enhanced SFX (type-specific) ===

  /// Play kill SFX with pitch variation based on combo count.
  void playKill({int comboCount = 0}) {
    final pitch = 1.0 + (comboCount.clamp(0, 20) * 0.02);
    _playSfx('sfx/hit.ogg', volumeScale: (0.4 + pitch * 0.1).clamp(0.4, 1.0));
    if (comboCount >= 10) {
      hapticLight();
    }
  }

  /// Play unit-type-specific attack SFX.
  void playUnitAttack(String unitTypeId) {
    // Vary volume slightly for organic feel
    final variance = 0.9 + (unitTypeId.hashCode % 20) * 0.01;
    _playSfx('sfx/hit.ogg', volumeScale: variance * 0.5);
  }

  /// Play enemy death with intensity based on enemy tier.
  void playEnemyDeath({bool isBoss = false, bool isElite = false}) {
    if (isBoss) {
      playBossKill();
    } else if (isElite) {
      _playSfx('sfx/hit.ogg', volumeScale: 1.0);
      hapticMedium();
    } else {
      _playSfx('sfx/hit.ogg', volumeScale: 0.4);
    }
  }

  /// Play wall damage SFX scaled by damage percentage.
  void playWallDamage(double damagePercent) {
    if (damagePercent > 0.1) {
      _playSfx('sfx/hit.ogg', volumeScale: 0.8 + damagePercent * 0.4);
      hapticHeavy();
    } else {
      _playSfx('sfx/hit.ogg', volumeScale: 0.5);
      hapticLight();
    }
  }

  /// Play level-up / merge success with scale.
  void playMergeLevel(int newLevel) {
    _playSfx('sfx/merge.ogg', volumeScale: 0.8 + newLevel * 0.1);
    if (newLevel >= 4) {
      hapticHeavy();
    } else {
      hapticMedium();
    }
  }

  /// Play pity relic notification.
  void playPityRelic() {
    _playSfx('sfx/reward.ogg', volumeScale: 1.3);
    hapticHeavy();
  }

  /// Play story chapter unlock.
  void playStoryUnlock() {
    _playSfx('sfx/reward.ogg', volumeScale: 1.2);
    hapticHeavy();
  }

  // === Haptic Feedback ===

  void hapticLight() {
    if (!_vibrationEnabled) return;
    HapticFeedback.lightImpact();
  }

  void hapticMedium() {
    if (!_vibrationEnabled) return;
    HapticFeedback.mediumImpact();
  }

  void hapticHeavy() {
    if (!_vibrationEnabled) return;
    HapticFeedback.heavyImpact();
  }

  void hapticSelection() {
    if (!_vibrationEnabled) return;
    HapticFeedback.selectionClick();
  }

  /// Haptic pattern for combo milestones.
  void hapticComboMilestone(int comboTier) {
    if (!_vibrationEnabled) return;
    // Higher tiers get stronger haptic
    switch (comboTier) {
      case 1: // NICE
        HapticFeedback.lightImpact();
        break;
      case 2: // GREAT
        HapticFeedback.mediumImpact();
        break;
      case 3: // AMAZING
        HapticFeedback.heavyImpact();
        break;
      case >= 4: // UNSTOPPABLE+
        HapticFeedback.heavyImpact();
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_vibrationEnabled) HapticFeedback.heavyImpact();
        });
        break;
    }
  }

  /// Haptic for wave clear.
  void hapticWaveClear(bool isPerfect) {
    if (!_vibrationEnabled) return;
    HapticFeedback.mediumImpact();
    if (isPerfect) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (_vibrationEnabled) HapticFeedback.lightImpact();
      });
    }
  }

  // === BGM playback ===

  /// Start BGM with the given track. Falls back to bg1 if not found.
  void startBgm({String track = 'bgm/bg1.ogg'}) {
    if (!_bgmEnabled) return;
    // Avoid restarting the same track
    if (_bgmPlaying && _currentBgmTrack == track) return;
    try {
      FlameAudio.bgm.play(track, volume: _bgmVolume);
      _bgmPlaying = true;
      _currentBgmTrack = track;
    } catch (_) {
      // Fallback to default track
      if (track != 'bgm/bg1.ogg') {
        try {
          FlameAudio.bgm.play('bgm/bg1.ogg', volume: _bgmVolume);
          _bgmPlaying = true;
          _currentBgmTrack = 'bgm/bg1.ogg';
        } catch (_) {}
      }
    }
  }

  /// Switch BGM based on game state (adaptive audio).
  void updateGameMusic({required int wave, required double wallHpPercent}) {
    // Decide which track to play based on game intensity
    String targetTrack;
    if (wallHpPercent < 0.2) {
      targetTrack = 'bgm/bg1.ogg'; // Intense — use existing, future: crisis track
    } else if (wave > 0 && wave % 10 == 0) {
      targetTrack = 'bgm/bg1.ogg'; // Boss wave — future: boss track
    } else {
      targetTrack = 'bgm/bg1.ogg'; // Normal gameplay
    }
    startBgm(track: targetTrack);
  }

  void stopBgm() {
    if (!_bgmPlaying) {
      _bgmPlaying = false;
      return;
    }
    try {
      FlameAudio.bgm.stop();
    } catch (_) {}
    _bgmPlaying = false;
  }

  void pauseBgm() {
    if (_bgmPlaying) {
      try {
        FlameAudio.bgm.pause();
      } catch (_) {}
    }
  }

  void resumeBgm() {
    if (!_bgmEnabled || !_bgmPlaying) return;
    try {
      FlameAudio.bgm.resume();
    } catch (_) {}
  }

  /// Called when app goes to background — pause all audio.
  void onAppPaused() {
    pauseBgm();
  }

  /// Called when app returns to foreground — resume if was playing.
  void onAppResumed() {
    resumeBgm();
  }

  /// Dispose audio resources.
  void dispose() {
    stopBgm();
    try {
      FlameAudio.bgm.dispose();
    } catch (_) {}
  }

  // === Persistence ===

  static const _prefix = 'sound_';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _bgmEnabled = prefs.getBool('${_prefix}bgm') ?? true;
    _sfxEnabled = prefs.getBool('${_prefix}sfx') ?? true;
    _vibrationEnabled = prefs.getBool('${_prefix}vibration') ?? true;
    _bgmVolume = prefs.getDouble('${_prefix}bgmVol') ?? 0.7;
    _sfxVolume = prefs.getDouble('${_prefix}sfxVol') ?? 1.0;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('${_prefix}bgm', _bgmEnabled);
    prefs.setBool('${_prefix}sfx', _sfxEnabled);
    prefs.setBool('${_prefix}vibration', _vibrationEnabled);
    prefs.setDouble('${_prefix}bgmVol', _bgmVolume);
    prefs.setDouble('${_prefix}sfxVol', _sfxVolume);
  }
}
