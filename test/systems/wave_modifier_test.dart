import 'package:flutter_test/flutter_test.dart';
import 'package:paw_defense/systems/wave_modifier.dart';

void main() {
  late WaveModifier waveModifier;

  setUp(() {
    waveModifier = WaveModifier();
  });

  group('ModifierDef', () {
    test('has 10 modifiers defined', () {
      expect(WaveModifier.allModifiers.length, 10);
    });

    test('all modifiers have unique IDs', () {
      final ids = WaveModifier.allModifiers.map((m) => m.id).toSet();
      expect(ids.length, WaveModifier.allModifiers.length);
    });

    test('all modifiers have non-empty names', () {
      for (final m in WaveModifier.allModifiers) {
        expect(m.name, isNotEmpty, reason: '${m.id} should have a name');
      }
    });

    test('all modifiers have non-empty icons', () {
      for (final m in WaveModifier.allModifiers) {
        expect(m.icon, isNotEmpty, reason: '${m.id} should have an icon');
      }
    });

    test('all modifiers have non-empty descriptions', () {
      for (final m in WaveModifier.allModifiers) {
        expect(m.description, isNotEmpty,
            reason: '${m.id} should have a description');
      }
    });
  });

  group('Modifier roll rules', () {
    test('no modifier before wave 10', () {
      for (int w = 1; w < 10; w++) {
        expect(waveModifier.rollModifier(w), isNull,
            reason: 'Wave $w should have no modifier');
      }
    });

    test('no modifier on boss waves (multiples of 10)', () {
      for (final w in [10, 20, 30, 40, 50]) {
        expect(waveModifier.rollModifier(w), isNull,
            reason: 'Boss wave $w should have no modifier');
      }
    });

    test('modifier on wave 15, 25, 35, 45', () {
      // These should sometimes return a modifier (RNG dependent)
      // Run multiple times to verify it's possible
      int found = 0;
      for (int attempt = 0; attempt < 100; attempt++) {
        if (waveModifier.rollModifier(15) != null) found++;
      }
      expect(found, greaterThan(0),
          reason: 'Wave 15 should sometimes have modifiers');
    });

    test('no modifier on non-5-interval waves', () {
      for (final w in [11, 12, 13, 14, 16, 17, 18, 19]) {
        expect(waveModifier.rollModifier(w), isNull,
            reason: 'Wave $w should have no modifier');
      }
    });
  });

  group('Modifier multipliers', () {
    test('default multipliers are 1.0 when no modifier', () {
      waveModifier.reset();
      expect(waveModifier.enemyCountMultiplier, 1.0);
      expect(waveModifier.enemyHpMultiplier, 1.0);
      expect(waveModifier.enemySpeedMultiplier, 1.0);
      expect(waveModifier.goldMultiplier, 1.0);
      expect(waveModifier.unitRangeMultiplier, 1.0);
    });

    test('elite modifier: -50% count, x3 HP', () {
      waveModifier.currentModifier = WaveModifier.allModifiers
          .firstWhere((m) => m.id == 'elite');
      expect(waveModifier.enemyCountMultiplier, 0.5);
      expect(waveModifier.enemyHpMultiplier, 3.0);
    });

    test('swarm modifier: x3 count, -50% HP', () {
      waveModifier.currentModifier = WaveModifier.allModifiers
          .firstWhere((m) => m.id == 'swarm');
      expect(waveModifier.enemyCountMultiplier, 3.0);
      expect(waveModifier.enemyHpMultiplier, 0.5);
    });

    test('speed_run modifier: x2 speed, x1.5 gold', () {
      waveModifier.currentModifier = WaveModifier.allModifiers
          .firstWhere((m) => m.id == 'speed_run');
      expect(waveModifier.enemySpeedMultiplier, 2.0);
      expect(waveModifier.goldMultiplier, 1.5);
    });

    test('golden modifier: x3 gold', () {
      waveModifier.currentModifier = WaveModifier.allModifiers
          .firstWhere((m) => m.id == 'golden');
      expect(waveModifier.goldMultiplier, 3.0);
    });

    test('fog modifier: -40% unit range', () {
      waveModifier.currentModifier = WaveModifier.allModifiers
          .firstWhere((m) => m.id == 'fog');
      expect(waveModifier.unitRangeMultiplier, 0.6);
    });
  });

  group('Boolean modifiers', () {
    test('sky_threat makes all enemies flying', () {
      waveModifier.currentModifier = WaveModifier.allModifiers
          .firstWhere((m) => m.id == 'sky_threat');
      expect(waveModifier.allFlying, isTrue);
    });

    test('chain enables always chain lightning', () {
      waveModifier.currentModifier = WaveModifier.allModifiers
          .firstWhere((m) => m.id == 'chain');
      expect(waveModifier.alwaysChain, isTrue);
    });

    test('burning enables auto burn DoT', () {
      waveModifier.currentModifier = WaveModifier.allModifiers
          .firstWhere((m) => m.id == 'burning');
      expect(waveModifier.autoBurn, isTrue);
    });

    test('shield_march enables 50% shielded', () {
      waveModifier.currentModifier = WaveModifier.allModifiers
          .firstWhere((m) => m.id == 'shield_march');
      expect(waveModifier.shieldMarch, isTrue);
    });

    test('chaos enables unrestricted enemy spawn', () {
      waveModifier.currentModifier = WaveModifier.allModifiers
          .firstWhere((m) => m.id == 'chaos');
      expect(waveModifier.chaosSpawn, isTrue);
    });

    test('booleans are false when no modifier', () {
      waveModifier.reset();
      expect(waveModifier.allFlying, isFalse);
      expect(waveModifier.alwaysChain, isFalse);
      expect(waveModifier.autoBurn, isFalse);
      expect(waveModifier.shieldMarch, isFalse);
      expect(waveModifier.chaosSpawn, isFalse);
    });
  });

  group('Reset', () {
    test('reset clears current modifier', () {
      waveModifier.currentModifier = WaveModifier.allModifiers.first;
      expect(waveModifier.currentModifier, isNotNull);
      waveModifier.reset();
      expect(waveModifier.currentModifier, isNull);
    });
  });
}
