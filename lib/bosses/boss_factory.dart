import '../game/boss_rush_game.dart';
import 'boss_base.dart';
import 'boss1_guardian.dart';

class BossFactory {
  static BossBase createBoss(int index, BossRushGame gameRef) {
    switch (index) {
      case 0:
        return Boss1Guardian(gameRef);
      // Future bosses will be added here:
      // case 1: return Boss2Speedster(gameRef);
      // case 2: return Boss3BulletHell(gameRef);
      // case 3: return Boss4Colossus(gameRef);
      // case 4: return Boss5Trickster(gameRef);
      // case 5: return Boss6Swarm(gameRef);
      // case 6: return Boss7Elemental(gameRef);
      // case 7: return Boss8Final(gameRef);
      default:
        return Boss1Guardian(gameRef);
    }
  }

  static String getBossName(int index) {
    const names = [
      'Stone Guardian',
      'Shadow Dasher',
      'Bullet Witch',
      'Iron Colossus',
      'Mirror Trickster',
      'Hive Queen',
      'Storm Elemental',
      'The Overlord',
    ];
    return index < names.length ? names[index] : 'Unknown';
  }

  static bool isBossAvailable(int index) {
    // For now only boss 0 is implemented
    return index == 0;
  }
}
