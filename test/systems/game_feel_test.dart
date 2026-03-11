import 'package:flutter_test/flutter_test.dart';
import 'package:paw_defense/systems/defense_game_feel.dart';

void main() {
  late DefenseGameFeel gameFeel;

  setUp(() {
    gameFeel = DefenseGameFeel();
  });

  group('Hit Stop', () {
    test('is not hit stopped initially', () {
      expect(gameFeel.isHitStopped, isFalse);
    });

    test('hitStop sets timer', () {
      gameFeel.hitStop(duration: 0.1);
      expect(gameFeel.isHitStopped, isTrue);
    });
  });

  group('Slow Motion', () {
    test('time scale is 1.0 initially', () {
      expect(gameFeel.timeScale, 1.0);
    });
  });

  group('Zoom Punch', () {
    test('current zoom is 1.0 initially', () {
      expect(gameFeel.currentZoom, 1.0);
    });
  });

  group('Screen Shake', () {
    test('is not shaking initially', () {
      expect(gameFeel.isShaking, isFalse);
    });

    test('shake offsets are 0 initially', () {
      expect(gameFeel.shakeOffsetX, 0.0);
      expect(gameFeel.shakeOffsetY, 0.0);
    });

    test('screenShake enables shaking', () {
      gameFeel.screenShake(intensity: 4.0, duration: 0.3);
      expect(gameFeel.isShaking, isTrue);
    });
  });

  group('Screen Flash', () {
    test('flash alpha is 0 initially', () {
      expect(gameFeel.flashAlpha, 0.0);
    });

    test('screenFlash sets flash state', () {
      gameFeel.screenFlash(color: 0xFFFF0000, duration: 0.2);
      expect(gameFeel.flashAlpha, greaterThan(0.0));
    });
  });

  group('Auto Systems', () {
    test('auto merge is disabled initially', () {
      expect(gameFeel.autoMergeEnabled, isFalse);
    });

    test('auto place is disabled initially', () {
      expect(gameFeel.autoPlaceEnabled, isFalse);
    });

    test('auto merge interval is 1.5s', () {
      expect(DefenseGameFeel.autoMergeInterval, 1.5);
    });

    test('auto place interval is 3.0s', () {
      expect(DefenseGameFeel.autoPlaceInterval, 3.0);
    });
  });

  group('Preset Feedback', () {
    test('onBossKill activates multiple effects', () {
      gameFeel.onBossKill();
      expect(gameFeel.isHitStopped, isTrue);
      expect(gameFeel.isShaking, isTrue);
    });

    test('onWallHit heavy triggers shake and flash', () {
      gameFeel.onWallHit(isHeavy: true);
      expect(gameFeel.isShaking, isTrue);
      expect(gameFeel.flashAlpha, greaterThan(0.0));
    });

    test('onWallHit normal triggers only shake', () {
      gameFeel.onWallHit(isHeavy: false);
      expect(gameFeel.isShaking, isTrue);
    });

    test('onEvolve activates hit stop, shake, and flash', () {
      gameFeel.onEvolve();
      expect(gameFeel.isHitStopped, isTrue);
      expect(gameFeel.isShaking, isTrue);
      expect(gameFeel.flashAlpha, greaterThan(0.0));
    });

    test('onHybridMerge activates hit stop and flash', () {
      gameFeel.onHybridMerge();
      expect(gameFeel.isHitStopped, isTrue);
      expect(gameFeel.flashAlpha, greaterThan(0.0));
    });

    test('onPerfectWave triggers flash', () {
      gameFeel.onPerfectWave();
      expect(gameFeel.flashAlpha, greaterThan(0.0));
    });

    test('onSkillActivation triggers hit stop', () {
      gameFeel.onSkillActivation();
      expect(gameFeel.isHitStopped, isTrue);
    });

    test('onRelicAcquired triggers flash', () {
      gameFeel.onRelicAcquired();
      expect(gameFeel.flashAlpha, greaterThan(0.0));
    });
  });
}
