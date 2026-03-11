import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:paw_defense/systems/sound_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SoundManager manager;

  setUp(() {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    manager = SoundManager();
  });

  group('SoundManager defaults', () {
    test('BGM is enabled by default', () {
      expect(manager.bgmEnabled, isTrue);
    });

    test('SFX is enabled by default', () {
      expect(manager.sfxEnabled, isTrue);
    });

    test('vibration is enabled by default', () {
      expect(manager.vibrationEnabled, isTrue);
    });

    test('BGM volume default is 0.7', () {
      expect(manager.bgmVolume, 0.7);
    });

    test('SFX volume default is 1.0', () {
      expect(manager.sfxVolume, 1.0);
    });
  });

  group('SoundManager toggles', () {
    test('setBgmEnabled changes state', () {
      manager.setBgmEnabled(false);
      expect(manager.bgmEnabled, isFalse);
    });

    test('setSfxEnabled changes state', () {
      manager.setSfxEnabled(false);
      expect(manager.sfxEnabled, isFalse);
    });

    test('setVibrationEnabled changes state', () {
      manager.setVibrationEnabled(false);
      expect(manager.vibrationEnabled, isFalse);
    });
  });

  group('Volume controls', () {
    test('setBgmVolume clamps to 0-1', () {
      manager.setBgmVolume(1.5);
      expect(manager.bgmVolume, 1.0);
      manager.setBgmVolume(-0.5);
      expect(manager.bgmVolume, 0.0);
    });

    test('setSfxVolume clamps to 0-1', () {
      manager.setSfxVolume(2.0);
      expect(manager.sfxVolume, 1.0);
      manager.setSfxVolume(-1.0);
      expect(manager.sfxVolume, 0.0);
    });

    test('normal volume values work', () {
      manager.setBgmVolume(0.5);
      expect(manager.bgmVolume, 0.5);
      manager.setSfxVolume(0.3);
      expect(manager.sfxVolume, 0.3);
    });
  });
}
