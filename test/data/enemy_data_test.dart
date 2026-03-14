import 'package:flutter_test/flutter_test.dart';
import 'package:paw_defense/data/enemy_data.dart';

void main() {
  group('DefenseEnemyDatabase', () {
    test('has exactly 16 enemy types', () {
      expect(DefenseEnemyDatabase.all.length, 16);
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
      // wave30 should include all enemies with unlockWave <= 30
      final expectedCount = DefenseEnemyDatabase.all.where((e) => e.unlockWave <= 30).length;
      expect(wave30.length, expectedCount);

      final waveMax = DefenseEnemyDatabase.availableAt(100);
      expect(waveMax.length, DefenseEnemyDatabase.all.length);
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

      final dragonWhelp = DefenseEnemyDatabase.get('dragon_whelp')!;
      expect(dragonWhelp.isFlying, true);
    });

    test('new enemies have correct unlock waves', () {
      expect(DefenseEnemyDatabase.get('necromancer')!.unlockWave, 25);
      expect(DefenseEnemyDatabase.get('shadow')!.unlockWave, 28);
      expect(DefenseEnemyDatabase.get('ice_mage')!.unlockWave, 30);
      expect(DefenseEnemyDatabase.get('dragon_whelp')!.unlockWave, 35);
      expect(DefenseEnemyDatabase.get('lich')!.unlockWave, 40);
    });

    test('late-game enemies are stronger', () {
      final lich = DefenseEnemyDatabase.get('lich')!;
      final slime = DefenseEnemyDatabase.get('slime')!;
      expect(lich.baseHp, greaterThan(slime.baseHp * 5));
      expect(lich.goldDrop, greaterThan(slime.goldDrop * 5));
    });
  });
}
