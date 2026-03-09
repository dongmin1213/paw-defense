import '../data/achievement_data.dart';

class AchievementManager {
  final Set<String> _completed = {};
  final List<String> _recentlyUnlocked = []; // UI 팝업용

  // ── 추적 카운터 ──
  int totalKills = 0;
  int bossKills = 0;
  int goldenKills = 0;
  int airKills = 0;
  int maxCombo = 0;
  double totalCoinsEarned = 0;
  int totalUpgradesBought = 0;
  double maxDistance = 0;
  int ascensionCount = 0;
  int companionsOwned = 0;
  int regionsUnlocked = 1;
  int boxesOpened = 0;
  int bonusStagesEntered = 0;
  int dailyStreak = 0;

  bool isCompleted(String id) => _completed.contains(id);

  int get completedCount => _completed.length;
  int get totalCount => AchievementDatabase.achievements.length;
  double get completionPercent => totalCount > 0 ? completedCount / totalCount : 0;

  /// 최근 해금된 업적 목록 (팝업 표시 후 클리어)
  List<String> popRecentlyUnlocked() {
    final list = List<String>.from(_recentlyUnlocked);
    _recentlyUnlocked.clear();
    return list;
  }

  bool get hasRecentUnlock => _recentlyUnlocked.isNotEmpty;

  /// 업적 달성 체크 (게임 루프에서 호출)
  void checkAll() {
    _check('kill_10', totalKills >= 10);
    _check('kill_100', totalKills >= 100);
    _check('kill_500', totalKills >= 500);
    _check('kill_1000', totalKills >= 1000);
    _check('kill_5000', totalKills >= 5000);
    _check('kill_10000', totalKills >= 10000);

    _check('boss_1', bossKills >= 1);
    _check('boss_5', bossKills >= 5);
    _check('boss_20', bossKills >= 20);

    _check('combo_10', maxCombo >= 10);
    _check('combo_30', maxCombo >= 30);
    _check('combo_50', maxCombo >= 50);
    _check('combo_100', maxCombo >= 100);

    _check('golden_1', goldenKills >= 1);
    _check('golden_10', goldenKills >= 10);
    _check('golden_50', goldenKills >= 50);

    _check('air_10', airKills >= 10);
    _check('air_100', airKills >= 100);

    _check('coin_100', totalCoinsEarned >= 100);
    _check('coin_1000', totalCoinsEarned >= 1000);
    _check('coin_10k', totalCoinsEarned >= 10000);
    _check('coin_100k', totalCoinsEarned >= 100000);
    _check('coin_1m', totalCoinsEarned >= 1000000);

    _check('upgrade_5', totalUpgradesBought >= 5);
    _check('upgrade_25', totalUpgradesBought >= 25);
    _check('upgrade_100', totalUpgradesBought >= 100);

    _check('dist_100', maxDistance >= 1000); // 100m = 1000 distance units
    _check('dist_500', maxDistance >= 5000);
    _check('dist_1000', maxDistance >= 10000);
    _check('dist_5000', maxDistance >= 50000);
    _check('dist_10000', maxDistance >= 100000);

    _check('ascend_1', ascensionCount >= 1);
    _check('ascend_3', ascensionCount >= 3);
    _check('ascend_10', ascensionCount >= 10);

    _check('companion_1', companionsOwned >= 1);
    _check('companion_5', companionsOwned >= 5);
    _check('companion_all', companionsOwned >= 10);

    _check('region_2', regionsUnlocked >= 2);
    _check('region_all', regionsUnlocked >= 5);

    _check('box_1', boxesOpened >= 1);
    _check('box_10', boxesOpened >= 10);
    _check('box_50', boxesOpened >= 50);

    _check('bonus_1', bonusStagesEntered >= 1);
    _check('bonus_10', bonusStagesEntered >= 10);

    _check('daily_7', dailyStreak >= 7);
    _check('daily_30', dailyStreak >= 30);
  }

  void _check(String id, bool condition) {
    if (condition && !_completed.contains(id)) {
      _completed.add(id);
      _recentlyUnlocked.add(id);
    }
  }

  /// 이벤트 기반 카운터 업데이트
  void onEnemyKill({bool isGolden = false, bool isAir = false}) {
    totalKills++;
    if (isGolden) goldenKills++;
    if (isAir) airKills++;
  }

  void onBossKill() => bossKills++;

  void onComboUpdate(int combo) {
    if (combo > maxCombo) maxCombo = combo;
  }

  void onCoinsEarned(double total) => totalCoinsEarned = total;

  void onUpgradeBought() => totalUpgradesBought++;

  void onDistanceUpdate(double dist) {
    if (dist > maxDistance) maxDistance = dist;
  }

  void onAscension(int count) => ascensionCount = count;

  void onCompanionUpdate(int count) => companionsOwned = count;

  void onRegionUpdate(int count) => regionsUnlocked = count;

  void onBoxOpened() => boxesOpened++;

  void onBonusStage() => bonusStagesEntered++;

  void onDailyStreak(int streak) => dailyStreak = streak;

  // ── Save/Load ──

  Map<String, dynamic> toMap() {
    return {
      'completed': _completed.toList(),
      'totalKills': totalKills,
      'bossKills': bossKills,
      'goldenKills': goldenKills,
      'airKills': airKills,
      'maxCombo': maxCombo,
      'totalCoinsEarned': totalCoinsEarned,
      'totalUpgradesBought': totalUpgradesBought,
      'maxDistance': maxDistance,
      'ascensionCount': ascensionCount,
      'companionsOwned': companionsOwned,
      'regionsUnlocked': regionsUnlocked,
      'boxesOpened': boxesOpened,
      'bonusStagesEntered': bonusStagesEntered,
      'dailyStreak': dailyStreak,
    };
  }

  void loadFromMap(Map<String, dynamic> map) {
    _completed.clear();
    final list = map['completed'] as List<dynamic>?;
    if (list != null) {
      for (final id in list) {
        _completed.add(id as String);
      }
    }
    totalKills = (map['totalKills'] as num?)?.toInt() ?? 0;
    bossKills = (map['bossKills'] as num?)?.toInt() ?? 0;
    goldenKills = (map['goldenKills'] as num?)?.toInt() ?? 0;
    airKills = (map['airKills'] as num?)?.toInt() ?? 0;
    maxCombo = (map['maxCombo'] as num?)?.toInt() ?? 0;
    totalCoinsEarned = (map['totalCoinsEarned'] as num?)?.toDouble() ?? 0;
    totalUpgradesBought = (map['totalUpgradesBought'] as num?)?.toInt() ?? 0;
    maxDistance = (map['maxDistance'] as num?)?.toDouble() ?? 0;
    ascensionCount = (map['ascensionCount'] as num?)?.toInt() ?? 0;
    companionsOwned = (map['companionsOwned'] as num?)?.toInt() ?? 0;
    regionsUnlocked = (map['regionsUnlocked'] as num?)?.toInt() ?? 1;
    boxesOpened = (map['boxesOpened'] as num?)?.toInt() ?? 0;
    bonusStagesEntered = (map['bonusStagesEntered'] as num?)?.toInt() ?? 0;
    dailyStreak = (map['dailyStreak'] as num?)?.toInt() ?? 0;
  }
}
