import 'package:flutter_test/flutter_test.dart';
import 'package:paw_defense/systems/skill_manager.dart';

void main() {
  group('SkillManager', () {
    test('has 8 skills defined (one per unit type)', () {
      expect(SkillManager.skills.length, 8);
    });

    test('all 8 base unit types have skills', () {
      const unitTypes = [
        'cat_archer',
        'dog_warrior',
        'rabbit_mage',
        'bear_tanker',
        'fox_assassin',
        'bird_scout',
        'turtle_healer',
        'owl_wizard',
      ];
      for (final type in unitTypes) {
        expect(SkillManager.skills.containsKey(type), isTrue,
            reason: '$type should have a skill');
      }
    });

    test('all skills have positive charge needed', () {
      for (final entry in SkillManager.skills.entries) {
        expect(entry.value.chargeNeeded, greaterThan(0),
            reason: '${entry.key} skill charge should be positive');
      }
    });

    test('all skills have non-empty names', () {
      for (final entry in SkillManager.skills.entries) {
        expect(entry.value.name, isNotEmpty,
            reason: '${entry.key} skill should have a name');
      }
    });

    test('all skills have non-empty icons', () {
      for (final entry in SkillManager.skills.entries) {
        expect(entry.value.icon, isNotEmpty,
            reason: '${entry.key} skill should have an icon');
      }
    });

    test('all skills have unique effect IDs', () {
      final effectIds =
          SkillManager.skills.values.map((s) => s.effectId).toSet();
      expect(effectIds.length, SkillManager.skills.length,
          reason: 'All skill effect IDs should be unique');
    });

    test('charge values are in reasonable range (20-40)', () {
      for (final entry in SkillManager.skills.entries) {
        expect(entry.value.chargeNeeded, greaterThanOrEqualTo(20),
            reason: '${entry.key} charge should be >= 20');
        expect(entry.value.chargeNeeded, lessThanOrEqualTo(40),
            reason: '${entry.key} charge should be <= 40');
      }
    });
  });

  group('SkillManager state', () {
    late SkillManager manager;

    setUp(() {
      manager = SkillManager();
    });

    test('initial charge is 0', () {
      expect(manager.currentCharge, 0);
    });

    test('initial skill is not ready', () {
      expect(manager.isReady, isFalse);
    });

    test('has no active effect initially', () {
      expect(manager.hasActiveEffect, isFalse);
    });

    test('charge percent is 0 initially', () {
      expect(manager.chargePercent, 0.0);
    });

    test('currentSkill returns a valid skill', () {
      expect(manager.currentSkill, isNotNull);
    });

    test('updateDominantType changes active skill', () {
      manager.updateDominantType({'rabbit_mage': 3, 'cat_archer': 1});
      expect(manager.activeUnitType, 'rabbit_mage');
    });

    test('updateDominantType picks highest count', () {
      manager.updateDominantType({
        'cat_archer': 2,
        'dog_warrior': 5,
        'rabbit_mage': 3,
      });
      expect(manager.activeUnitType, 'dog_warrior');
    });

    test('updateDominantType ignores empty map', () {
      final before = manager.activeUnitType;
      manager.updateDominantType({});
      expect(manager.activeUnitType, before);
    });
  });
}
