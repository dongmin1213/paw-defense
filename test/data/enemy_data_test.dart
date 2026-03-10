import 'package:flutter_test/flutter_test.dart';
import 'package:paw_defense/data/enemy_data.dart';

void main() {
  group('DefenseEnemyDatabase', () {
    test('has exactly 10 enemy types', () {
      expect(DefenseEnemyDatabase.all.length, 10);
    });

    test('all enemy IDs are unique', () {
      final ids = DefenseEnemyDatabase.all.map((e) => e.id).toSet();
      expect(ids.length, DefenseEnemyDatabase.all.length);
    });

    test('all enemies have positive stats', () {
      for (final enemy in DefenseEnemyDatabase.all) {
        expect(enemy.baseHp, greaterThan(0), reason: '${enemy.id} baseHp');
        expect(enemy.baseSpeed, greaterThan(0), reason: '${enemy.id} baseSpeed');
        expect(enemy.baseDamage, greaterThan(0), reason: '${enemy.id} baseDamage');
        expect(enemy.goldDrop, greaterThan(0), reason: '${enemy.id} goldDrop');
      }
    });

    test('get() returns correct enemy by ID', () {
      final slime = DefenseEnemyDatabase.get('slime');
      expect(slime, isNotNull);
      expect(slime!.name, '슬라임');
    });

    test('get() returns null for unknown ID', () {
      expect(DefenseEnemyDatabase.get('nonexistent'), isNull);
    });

    test('availableAt() returns only enemies unlocked at wave', () {
      final wave1 = DefenseEnemyDatabase.availableAt(1);
      expect(wave1.length, 1); // only slime at wave 1
      expect(wave1.first.id, 'slime');

      final wave7 = DefenseEnemyDatabase.availableAt(7);
      // slime(1), goblin(4), skeleton(6), bat(7)
      expect(wave7.length, 4);

      final wave30 = DefenseEnemyDatabase.availableAt(30);
      expect(wave30.length, DefenseEnemyDatabase.all.length);
    });

    test('slime is available from wave 1', () {
      final slime = DefenseEnemyDatabase.get('slime')!;
      expect(slime.unlockWave, 1);
    });

    test('flying enemies are identified correctly', () {
      final bat = DefenseEnemyDatabase.get('bat')!;
      expect(bat.isFlying, true);

      final slime = DefenseEnemyDatabase.get('slime')!;
      expect(slime.isFlying, false);
    });
  });
}
