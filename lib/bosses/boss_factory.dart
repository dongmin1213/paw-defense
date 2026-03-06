import '../game/boss_rush_game.dart';
import 'boss_base.dart';
import 'boss1_guardian.dart';
import 'boss2_shadow_dasher.dart';
import 'boss3_bullet_witch.dart';
import 'boss4_iron_colossus.dart';
import 'boss5_mirror_trickster.dart';
import 'boss6_hive_queen.dart';
import 'boss7_storm_elemental.dart';
import 'boss8_overlord.dart';

class BossFactory {
  static BossBase createBoss(int index, BossRushGame gameRef) {
    switch (index) {
      case 0:
        return Boss1Guardian(gameRef);
      case 1:
        return Boss2ShadowDasher(gameRef);
      case 2:
        return Boss3BulletWitch(gameRef);
      case 3:
        return Boss4IronColossus(gameRef);
      case 4:
        return Boss5MirrorTrickster(gameRef);
      case 5:
        return Boss6HiveQueen(gameRef);
      case 6:
        return Boss7StormElemental(gameRef);
      case 7:
        return Boss8Overlord(gameRef);
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
    return index < 8;
  }
}
