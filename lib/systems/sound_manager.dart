import 'package:shared_preferences/shared_preferences.dart';

/// Sound and vibration settings manager.
/// Manages BGM/SFX/vibration toggles and volume levels.
/// Actual audio playback is handled via flame_audio when assets are available.
class SoundManager {
  bool _bgmEnabled = true;
  bool _sfxEnabled = true;
  bool _vibrationEnabled = true;
  double _bgmVolume = 0.7;
  double _sfxVolume = 1.0;

  bool get bgmEnabled => _bgmEnabled;
  bool get sfxEnabled => _sfxEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  double get bgmVolume => _bgmVolume;
  double get sfxVolume => _sfxVolume;

  void setBgmEnabled(bool v) {
    _bgmEnabled = v;
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
    _save();
  }

  void setSfxVolume(double v) {
    _sfxVolume = v.clamp(0.0, 1.0);
    _save();
  }

  // === SFX playback stubs ===
  // These will play actual sounds when audio assets are added.
  // For now they respect the enabled/volume settings.

  void playHit() {
    if (!_sfxEnabled) return;
    // TODO: FlameAudio.play('hit.wav', volume: _sfxVolume);
  }

  void playMerge() {
    if (!_sfxEnabled) return;
    // TODO: FlameAudio.play('merge.wav', volume: _sfxVolume);
  }

  void playBuy() {
    if (!_sfxEnabled) return;
    // TODO: FlameAudio.play('buy.wav', volume: _sfxVolume);
  }

  void playWaveClear() {
    if (!_sfxEnabled) return;
    // TODO: FlameAudio.play('wave_clear.wav', volume: _sfxVolume);
  }

  void playBossKill() {
    if (!_sfxEnabled) return;
    // TODO: FlameAudio.play('boss_kill.wav', volume: _sfxVolume);
  }

  void playRewardSelect() {
    if (!_sfxEnabled) return;
    // TODO: FlameAudio.play('reward.wav', volume: _sfxVolume);
  }

  void playGameOver() {
    if (!_sfxEnabled) return;
    // TODO: FlameAudio.play('game_over.wav', volume: _sfxVolume);
  }

  void playButtonTap() {
    if (!_sfxEnabled) return;
    // TODO: FlameAudio.play('tap.wav', volume: _sfxVolume * 0.5);
  }

  void startBgm() {
    if (!_bgmEnabled) return;
    // TODO: FlameAudio.bgm.play('bgm.mp3', volume: _bgmVolume);
  }

  void stopBgm() {
    // TODO: FlameAudio.bgm.stop();
  }

  void pauseBgm() {
    // TODO: FlameAudio.bgm.pause();
  }

  void resumeBgm() {
    if (!_bgmEnabled) return;
    // TODO: FlameAudio.bgm.resume();
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
