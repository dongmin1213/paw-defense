import 'package:flame_audio/flame_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sound and vibration settings manager.
/// Manages BGM/SFX/vibration toggles and volume levels.
/// Audio playback via flame_audio.
class SoundManager {
  bool _bgmEnabled = true;
  bool _sfxEnabled = true;
  bool _vibrationEnabled = true;
  double _bgmVolume = 0.7;
  double _sfxVolume = 1.0;
  bool _bgmPlaying = false;

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

  void playHit() => _playSfx('sfx/hit.ogg');

  void playMerge() => _playSfx('sfx/merge.ogg');

  void playBuy() => _playSfx('sfx/buy.ogg');

  void playWaveClear() => _playSfx('sfx/wave_clear.ogg');

  void playBossKill() => _playSfx('sfx/boss_kill.ogg');

  void playRewardSelect() => _playSfx('sfx/reward.ogg');

  void playGameOver() => _playSfx('sfx/game_over.ogg');

  void playButtonTap() => _playSfx('sfx/tap.ogg', volumeScale: 0.5);

  // === BGM playback ===

  void startBgm() {
    if (!_bgmEnabled) return;
    try {
      FlameAudio.bgm.play('bgm/bg1.ogg', volume: _bgmVolume);
      _bgmPlaying = true;
    } catch (_) {
      // Silently ignore if file not found
    }
  }

  void stopBgm() {
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
    FlameAudio.bgm.dispose();
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
