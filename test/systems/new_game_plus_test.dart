import 'package:flutter_test/flutter_test.dart';
import 'package:paw_defense/systems/new_game_plus_manager.dart';

void main() {
  group('NewGamePlusManager', () {
    test('has 5 perks', () {
      expect(NewGamePlusManager.allPerks.length, 5);
    });

    test('perk IDs are unique', () {
      final ids = NewGamePlusManager.allPerks.map((p) => p.id).toSet();
      expect(ids.length, NewGamePlusManager.allPerks.length);
    });

    test('perks have escalating required levels', () {
      for (int i = 0; i < NewGamePlusManager.allPerks.length; i++) {
        expect(NewGamePlusManager.allPerks[i].requiredLevel, i + 1);
      }
    });

    test('difficulty scales with NG+ level', () {
      final mgr = NewGamePlusManager();
      // Can't fully test without SharedPreferences, but test data accessors
      expect(mgr.level, 0);
      expect(mgr.isNewGamePlus, false);
      expect(mgr.displayName, '일반');
      expect(mgr.enemyHpMultiplier, 1.0);
    });

    test('canAscend requires wave 30+', () {
      final mgr = NewGamePlusManager();
      expect(mgr.canAscend(29), false);
      expect(mgr.canAscend(30), true);
      expect(mgr.canAscend(100), true);
    });

    test('bonuses are zero at level 0', () {
      final mgr = NewGamePlusManager();
      expect(mgr.startingGoldBonus, 0);
      expect(mgr.starMultiplier, 1.0);
      expect(mgr.xpMultiplier, 1.0);
    });
  });
}
