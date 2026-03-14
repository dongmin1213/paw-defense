import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:paw_defense/systems/relic_manager.dart';
import 'package:paw_defense/data/balance_config.dart';

void main() {
  late RelicManager manager;

  setUp(() {
    manager = RelicManager();
  });

  group('Inventory management', () {
    test('starts empty', () {
      expect(manager.relicCount, 0);
      expect(manager.ownedRelics, isEmpty);
    });

    test('addRelic adds to inventory', () {
      expect(manager.addRelic('relic_atk_boost'), true);
      expect(manager.relicCount, 1);
      expect(manager.hasRelic('relic_atk_boost'), true);
    });

    test('cannot add duplicate relic', () {
      manager.addRelic('relic_atk_boost');
      expect(manager.addRelic('relic_atk_boost'), false);
      expect(manager.relicCount, 1);
    });

    test('max 5 relics by default', () {
      for (int i = 0; i < 5; i++) {
        expect(manager.addRelic('relic_$i'), true);
      }
      expect(manager.isFull, true);
      expect(manager.addRelic('relic_extra'), false);
    });

    test('max 7 relics with relic_infinity', () {
      manager.addRelic('relic_infinity');
      expect(manager.maxRelics, 7);
      for (int i = 0; i < 6; i++) {
        manager.addRelic('relic_fill_$i');
      }
      expect(manager.relicCount, 7);
      expect(manager.isFull, true);
    });

    test('removeRelic removes correctly', () {
      manager.addRelic('relic_atk_boost');
      expect(manager.removeRelic('relic_atk_boost'), true);
      expect(manager.hasRelic('relic_atk_boost'), false);
      expect(manager.relicCount, 0);
    });

    test('removeRelic returns false for absent relic', () {
      expect(manager.removeRelic('nonexistent'), false);
    });

    test('reset clears everything', () {
      manager.addRelic('relic_atk_boost');
      manager.addRelic('relic_speed_boost');
      manager.reset();
      expect(manager.relicCount, 0);
      expect(manager.ownedRelics, isEmpty);
    });
  });

  group('ATK multiplier', () {
    test('base is 1.0', () {
      expect(manager.atkMultiplier, 1.0);
    });

    test('atk_boost adds 15%', () {
      manager.addRelic('relic_atk_boost');
      expect(manager.atkMultiplier, closeTo(1.15, 0.001));
    });

    test('ghost_unit adds 20%', () {
      manager.addRelic('relic_ghost_unit');
      expect(manager.atkMultiplier, closeTo(1.20, 0.001));
    });

    test('rapid_fire reduces 15%', () {
      manager.addRelic('relic_rapid_fire');
      expect(manager.atkMultiplier, closeTo(0.85, 0.001));
    });

    test('war_god triples ATK', () {
      manager.addRelic('relic_war_god');
      expect(manager.atkMultiplier, closeTo(3.0, 0.001));
    });

    test('midas sets ATK to 0', () {
      manager.addRelic('relic_midas');
      expect(manager.atkMultiplier, 0.0);
    });

    test('midas overrides everything', () {
      manager.addRelic('relic_atk_boost');
      manager.addRelic('relic_war_god');
      manager.addRelic('relic_midas');
      expect(manager.atkMultiplier, 0.0);
    });
  });

  group('ATK speed multiplier', () {
    test('base is 1.0', () {
      expect(manager.atkSpeedMultiplier, 1.0);
    });

    test('speed_boost adds 15%', () {
      manager.addRelic('relic_speed_boost');
      expect(manager.atkSpeedMultiplier, closeTo(1.15, 0.001));
    });

    test('rapid_fire adds 30%', () {
      manager.addRelic('relic_rapid_fire');
      expect(manager.atkSpeedMultiplier, closeTo(1.30, 0.001));
    });

    test('tiny adds 40%', () {
      manager.addRelic('relic_tiny');
      expect(manager.atkSpeedMultiplier, closeTo(1.40, 0.001));
    });

    test('stacks additively', () {
      manager.addRelic('relic_speed_boost');
      manager.addRelic('relic_rapid_fire');
      manager.addRelic('relic_tiny');
      expect(manager.atkSpeedMultiplier, closeTo(1.85, 0.001));
    });
  });

  group('Other multipliers', () {
    test('range multiplier with giant', () {
      manager.addRelic('relic_giant');
      expect(manager.rangeMultiplier, closeTo(1.30, 0.001));
    });

    test('gold multiplier with gold_boost', () {
      manager.addRelic('relic_gold_boost');
      expect(manager.goldMultiplier, closeTo(1.30, 0.001));
    });

    test('boss gold with treasure_hunter', () {
      manager.addRelic('relic_treasure_hunter');
      expect(manager.bossGoldMultiplier, closeTo(3.0, 0.001));
    });

    test('boss gold stacks', () {
      manager.addRelic('relic_boss_gold');
      manager.addRelic('relic_treasure_hunter');
      expect(manager.bossGoldMultiplier, closeTo(4.5, 0.001));
    });

    test('wall damage reduction', () {
      manager.addRelic('relic_wall_shield');
      expect(manager.wallDamageReduction, closeTo(0.20, 0.001));
    });

    test('crit chance bonus', () {
      manager.addRelic('relic_crit_chance');
      expect(manager.critChanceBonus, closeTo(0.10, 0.001));
    });

    test('crit damage multiplier', () {
      expect(manager.critDamageMultiplier, 2.0);
      manager.addRelic('relic_crit_dmg');
      expect(manager.critDamageMultiplier, closeTo(2.5, 0.001));
    });

    test('sell refund with recycle', () {
      expect(manager.sellRefundRate, BalanceConfig.sellRefundRate);
      manager.addRelic('relic_recycle');
      expect(manager.sellRefundRate, 0.80);
    });

    test('max unit level with infinite_merge', () {
      expect(manager.maxUnitLevel, 5);
      manager.addRelic('relic_infinite_merge');
      expect(manager.maxUnitLevel, 7);
    });
  });

  group('Event effects', () {
    test('onWallFatalDamage with last_stand', () {
      manager.addRelic('relic_last_stand');
      expect(manager.onWallFatalDamage(), true); // first time
      expect(manager.onWallFatalDamage(), false); // used up
    });

    test('onWallFatalDamage with phoenix after last_stand used', () {
      manager.addRelic('relic_last_stand');
      manager.addRelic('relic_phoenix');
      expect(manager.onWallFatalDamage(), true); // last stand
      expect(manager.onWallFatalDamage(), true); // phoenix
      expect(manager.onWallFatalDamage(), false); // both used
    });

    test('onWaveStart gives gold with wave_gold', () {
      manager.addRelic('relic_wave_gold');
      expect(manager.onWaveStart(1, Random(42)), 10);
    });

    test('onWaveStartHeal with blessing_rain', () {
      manager.addRelic('relic_blessing_rain');
      expect(manager.onWaveStartHeal(3), 0.15); // wave 3 % 3 == 0
      expect(manager.onWaveStartHeal(4), 0.0);  // wave 4 % 3 != 0
      expect(manager.onWaveStartHeal(6), 0.15); // wave 6 % 3 == 0
    });

    test('shouldTimeWarp every 5 waves', () {
      manager.addRelic('relic_time_warp');
      expect(manager.shouldTimeWarp(5), true);
      expect(manager.shouldTimeWarp(10), true);
      expect(manager.shouldTimeWarp(7), false);
    });

    test('berserkerMultiplier', () {
      manager.addRelic('relic_berserker');
      expect(manager.berserkerMultiplier(0.50), 1.0); // HP > 30%
      expect(manager.berserkerMultiplier(0.29), 2.0); // HP < 30%
    });

    test('reverseMultiplier', () {
      manager.addRelic('relic_reverse');
      expect(manager.reverseMultiplier(1.0), closeTo(1.0, 0.001)); // full HP
      expect(manager.reverseMultiplier(0.0), closeTo(5.0, 0.001)); // 0% HP
      expect(manager.reverseMultiplier(0.5), closeTo(3.0, 0.001)); // 50% HP
    });

    test('waveDuration with time_sand', () {
      expect(manager.waveDurationOverride, BalanceConfig.waveDuration);
      manager.addRelic('relic_time_sand');
      expect(manager.waveDurationOverride, 10.0);
      expect(manager.enemySpeedMultiplier, closeTo(0.70, 0.001));
    });
  });

  group('generateRelicChoices', () {
    test('returns requested number of choices', () {
      final choices = manager.generateRelicChoices(Random(42), choiceCount: 3);
      expect(choices.length, 3);
    });

    test('no duplicates in choices', () {
      final choices = manager.generateRelicChoices(Random(42), choiceCount: 3);
      expect(choices.toSet().length, choices.length);
    });

    test('excludes owned relics', () {
      manager.addRelic('relic_atk_boost');
      manager.addRelic('relic_speed_boost');
      final choices = manager.generateRelicChoices(Random(42), choiceCount: 3);
      expect(choices.contains('relic_atk_boost'), false);
      expect(choices.contains('relic_speed_boost'), false);
    });
  });

  group('Pity system', () {
    test('pity counter starts at 0', () {
      expect(manager.pityCounter, 0);
    });

    test('pity counter resets on reset()', () {
      manager.reset();
      expect(manager.pityCounter, 0);
    });
  });

  group('Save/Load', () {
    test('toList/loadFromList roundtrip', () {
      manager.addRelic('relic_atk_boost');
      manager.addRelic('relic_speed_boost');
      manager.addRelic('relic_gold_boost');
      final list = manager.toList();

      final restored = RelicManager();
      restored.loadFromList(list);
      expect(restored.relicCount, 3);
      expect(restored.hasRelic('relic_atk_boost'), true);
      expect(restored.hasRelic('relic_speed_boost'), true);
      expect(restored.hasRelic('relic_gold_boost'), true);
    });

    test('loadFromList ignores invalid relic IDs', () {
      final restored = RelicManager();
      restored.loadFromList(['relic_atk_boost', 'invalid_relic_xyz']);
      expect(restored.relicCount, 1);
    });
  });
}
