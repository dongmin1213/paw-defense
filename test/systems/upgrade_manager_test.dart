import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:paw_defense/systems/defense_upgrade_manager.dart';

void main() {
  late DefenseUpgradeManager manager;

  setUp(() {
    manager = DefenseUpgradeManager();
  });

  group('DefenseUpgradeData.costAt', () {
    test('cost at level 0 is baseCost', () {
      final data = DefenseUpgradeDatabase.get(DefenseUpgradeId.wallHp);
      expect(data.costAt(0), data.baseCost);
    });

    test('cost increases by 12% per level', () {
      final data = DefenseUpgradeDatabase.get(DefenseUpgradeId.wallHp);
      final cost0 = data.costAt(0);
      final cost1 = data.costAt(1);
      expect(cost1, (data.baseCost * pow(1.12, 1)).ceil());
      expect(cost1, greaterThan(cost0));
    });

    test('cost at maxLevel is 0', () {
      final data = DefenseUpgradeDatabase.get(DefenseUpgradeId.wallHp);
      expect(data.costAt(data.maxLevel), 0);
    });
  });

  group('DefenseUpgradeManager levels', () {
    test('all upgrades start at level 0', () {
      for (final id in DefenseUpgradeId.values) {
        expect(manager.getLevel(id), 0);
      }
    });

    test('buy increases level', () {
      final cost = manager.buy(DefenseUpgradeId.wallHp, 100);
      expect(cost, greaterThan(0));
      expect(manager.getLevel(DefenseUpgradeId.wallHp), 1);
    });

    test('buy returns 0 when cannot afford', () {
      final cost = manager.buy(DefenseUpgradeId.wallHp, 0);
      expect(cost, 0);
      expect(manager.getLevel(DefenseUpgradeId.wallHp), 0);
    });

    test('isMaxed returns true at max level', () {
      final data = DefenseUpgradeDatabase.get(DefenseUpgradeId.startUnits);
      // startUnits maxLevel = 5, baseCost = 50
      int stars = 10000;
      for (int i = 0; i < data.maxLevel; i++) {
        stars -= manager.buy(DefenseUpgradeId.startUnits, stars);
      }
      expect(manager.isMaxed(DefenseUpgradeId.startUnits), true);
      expect(manager.buy(DefenseUpgradeId.startUnits, 1000), 0);
    });
  });

  group('Multiplier getters', () {
    test('wallHpMultiplier: +5% per level', () {
      expect(manager.wallHpMultiplier, 1.0);
      manager.buy(DefenseUpgradeId.wallHp, 1000);
      expect(manager.wallHpMultiplier, closeTo(1.05, 0.001));
    });

    test('wallRegenPerSec: +0.5 per level', () {
      expect(manager.wallRegenPerSec, 0.0);
      manager.buy(DefenseUpgradeId.wallRegen, 1000);
      expect(manager.wallRegenPerSec, closeTo(0.5, 0.001));
    });

    test('wallDefenseMultiplier clamped at 0.4', () {
      // wallDefense: -2% per level, maxLevel=20
      // At level 20: 1.0 - 20*0.02 = 0.6
      // At level 30 (hypothetical): 1.0 - 30*0.02 = 0.4 → clamped
      expect(manager.wallDefenseMultiplier, 1.0);
      int stars = 100000;
      for (int i = 0; i < 20; i++) {
        stars -= manager.buy(DefenseUpgradeId.wallDefense, stars);
      }
      expect(manager.wallDefenseMultiplier, closeTo(0.6, 0.001));
    });

    test('unitAtkMultiplier: +3% per level', () {
      manager.buy(DefenseUpgradeId.unitAtk, 1000);
      expect(manager.unitAtkMultiplier, closeTo(1.03, 0.001));
    });

    test('unitAtkSpeedMultiplier: +2% per level', () {
      manager.buy(DefenseUpgradeId.unitAtkSpeed, 1000);
      expect(manager.unitAtkSpeedMultiplier, closeTo(1.02, 0.001));
    });

    test('goldGainMultiplier: +5% per level', () {
      manager.buy(DefenseUpgradeId.goldGain, 1000);
      expect(manager.goldGainMultiplier, closeTo(1.05, 0.001));
    });

    test('totalSlots: base 8 + expansion', () {
      expect(manager.totalSlots, 8);
      manager.buy(DefenseUpgradeId.slotExpansion, 1000);
      expect(manager.totalSlots, 9);
    });

    test('startUnitCount: 0 base', () {
      expect(manager.startUnitCount, 0);
      manager.buy(DefenseUpgradeId.startUnits, 1000);
      expect(manager.startUnitCount, 1);
    });

    test('startGoldBonus: +20 per level', () {
      expect(manager.startGoldBonus, 0);
      manager.buy(DefenseUpgradeId.startGold, 1000);
      expect(manager.startGoldBonus, 20);
    });

    test('comboDurationBonus: +0.3s per level', () {
      expect(manager.comboDurationBonus, 0.0);
      manager.buy(DefenseUpgradeId.comboDuration, 1000);
      expect(manager.comboDurationBonus, closeTo(0.3, 0.001));
    });

    test('hybridAtkMultiplier: +5% per level', () {
      expect(manager.hybridAtkMultiplier, 1.0);
      manager.buy(DefenseUpgradeId.hybridBonus, 1000);
      expect(manager.hybridAtkMultiplier, closeTo(1.05, 0.001));
    });

    test('baseCritChance: +2% per level', () {
      expect(manager.baseCritChance, 0.0);
      manager.buy(DefenseUpgradeId.critChance, 1000);
      expect(manager.baseCritChance, closeTo(0.02, 0.001));
    });
  });

  group('Save/Load', () {
    test('toMap/loadFromMap roundtrip', () {
      manager.buy(DefenseUpgradeId.wallHp, 1000);
      manager.buy(DefenseUpgradeId.wallHp, 1000);
      manager.buy(DefenseUpgradeId.unitAtk, 1000);

      final map = manager.toMap();
      final restored = DefenseUpgradeManager();
      restored.loadFromMap(map.cast<String, int>());

      expect(restored.getLevel(DefenseUpgradeId.wallHp), 2);
      expect(restored.getLevel(DefenseUpgradeId.unitAtk), 1);
    });

    test('loadFromMap ignores unknown keys', () {
      final restored = DefenseUpgradeManager();
      restored.loadFromMap({'unknown_upgrade': 5, 'wallHp': 3});
      expect(restored.getLevel(DefenseUpgradeId.wallHp), 3);
    });

    test('resetAll sets all levels to 0', () {
      manager.buy(DefenseUpgradeId.wallHp, 1000);
      manager.buy(DefenseUpgradeId.unitAtk, 1000);
      manager.resetAll();
      expect(manager.getLevel(DefenseUpgradeId.wallHp), 0);
      expect(manager.getLevel(DefenseUpgradeId.unitAtk), 0);
    });
  });

  group('DefenseUpgradeDatabase', () {
    test('has 16 upgrades', () {
      expect(DefenseUpgradeDatabase.all.length, 16);
    });

    test('all upgrade IDs covered', () {
      for (final id in DefenseUpgradeId.values) {
        expect(() => DefenseUpgradeDatabase.get(id), returnsNormally);
      }
    });

    test('byCategory works', () {
      final wallUpgrades = DefenseUpgradeDatabase.byCategory('성벽');
      expect(wallUpgrades.length, 3);

      final unitUpgrades = DefenseUpgradeDatabase.byCategory('유닛');
      expect(unitUpgrades.length, 5);
    });
  });
}
