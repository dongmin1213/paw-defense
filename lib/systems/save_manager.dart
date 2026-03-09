import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'upgrade_manager.dart';
import 'ascension_manager.dart';
import 'companion_manager.dart';
import 'achievement_manager.dart';
import 'daily_bonus_manager.dart';
import '../data/upgrade_data.dart';
import '../data/soul_upgrade_data.dart';

class SaveManager {
  static const String _keyCoins = 'coins';
  static const String _keyTotalCoins = 'total_coins_earned';
  static const String _keyHighScore = 'high_score';
  static const String _keySouls = 'souls';
  static const String _keyAscensionCount = 'ascension_count';
  static const String _keyLastOnline = 'last_online_time';
  static const String _keyCurrentRegion = 'current_region';
  static const String _keyCompanions = 'companions_data';
  static const String _keyAchievements = 'achievements_data';
  static const String _keyDailyBonus = 'daily_bonus_data';
  static const String _upgradePrefix = 'upgrade_';
  static const String _soulUpgradePrefix = 'soul_upgrade_';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // === Coins ===
  double get coins => _prefs.getDouble(_keyCoins) ?? 0;
  set coins(double v) => _prefs.setDouble(_keyCoins, v);

  double get totalCoinsEarned => _prefs.getDouble(_keyTotalCoins) ?? 0;
  set totalCoinsEarned(double v) => _prefs.setDouble(_keyTotalCoins, v);

  // === High Score ===
  double get highScore => _prefs.getDouble(_keyHighScore) ?? 0;
  set highScore(double v) => _prefs.setDouble(_keyHighScore, v);

  // === Souls & Ascension ===
  int get souls => _prefs.getInt(_keySouls) ?? 0;
  set souls(int v) => _prefs.setInt(_keySouls, v);

  int get ascensionCount => _prefs.getInt(_keyAscensionCount) ?? 0;
  set ascensionCount(int v) => _prefs.setInt(_keyAscensionCount, v);

  // === Region ===
  String get currentRegion => _prefs.getString(_keyCurrentRegion) ?? 'meadow';
  set currentRegion(String v) => _prefs.setString(_keyCurrentRegion, v);

  // === Last Online ===
  int get lastOnlineTime => _prefs.getInt(_keyLastOnline) ?? 0;
  set lastOnlineTime(int v) => _prefs.setInt(_keyLastOnline, v);

  // === Regular Upgrades ===
  void saveUpgrades(UpgradeManager manager) {
    final map = manager.toMap();
    for (final entry in map.entries) {
      _prefs.setInt('$_upgradePrefix${entry.key}', entry.value);
    }
  }

  void loadUpgrades(UpgradeManager manager) {
    final map = <String, int>{};
    for (final id in UpgradeId.values) {
      final val = _prefs.getInt('$_upgradePrefix${id.name}');
      if (val != null) map[id.name] = val;
    }
    manager.loadFromMap(map);
  }

  // === Ascension / Soul Upgrades ===
  void saveAscension(AscensionManager manager) {
    souls = manager.souls;
    ascensionCount = manager.ascensionCount;
    final map = manager.toMap();
    for (final entry in map.entries) {
      _prefs.setInt('$_soulUpgradePrefix${entry.key}', entry.value);
    }
  }

  void loadAscension(AscensionManager manager) {
    manager.souls = souls;
    manager.ascensionCount = ascensionCount;
    final map = <String, int>{};
    for (final id in SoulUpgradeId.values) {
      final val = _prefs.getInt('$_soulUpgradePrefix${id.name}');
      if (val != null) map[id.name] = val;
    }
    manager.loadFromMap(map);
  }

  // === Companions ===
  void saveCompanions(CompanionManager manager) {
    final data = manager.toMap();
    _prefs.setString(_keyCompanions, jsonEncode(data));
  }

  void loadCompanions(CompanionManager manager) {
    final jsonStr = _prefs.getString(_keyCompanions);
    if (jsonStr != null) {
      try {
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        manager.loadFromMap(data);
      } catch (_) {}
    }
  }

  // === Achievements ===
  void saveAchievements(AchievementManager manager) {
    _prefs.setString(_keyAchievements, jsonEncode(manager.toMap()));
  }

  void loadAchievements(AchievementManager manager) {
    final jsonStr = _prefs.getString(_keyAchievements);
    if (jsonStr != null) {
      try {
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        manager.loadFromMap(data);
      } catch (_) {}
    }
  }

  // === Daily Bonus ===
  void saveDailyBonus(DailyBonusManager manager) {
    _prefs.setString(_keyDailyBonus, jsonEncode(manager.toMap()));
  }

  void loadDailyBonus(DailyBonusManager manager) {
    final jsonStr = _prefs.getString(_keyDailyBonus);
    if (jsonStr != null) {
      try {
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        manager.loadFromMap(data);
      } catch (_) {}
    }
  }

  // === Save All ===
  void saveGameState({
    required double coins,
    required double totalCoinsEarned,
    required double highScore,
    required UpgradeManager upgradeManager,
    required AscensionManager ascensionManager,
    required CompanionManager companionManager,
    required AchievementManager achievementManager,
    required DailyBonusManager dailyBonusManager,
    required String currentRegion,
  }) {
    this.coins = coins;
    this.totalCoinsEarned = totalCoinsEarned;
    if (highScore > this.highScore) {
      this.highScore = highScore;
    }
    this.currentRegion = currentRegion;
    saveUpgrades(upgradeManager);
    saveAscension(ascensionManager);
    saveCompanions(companionManager);
    saveAchievements(achievementManager);
    saveDailyBonus(dailyBonusManager);
    lastOnlineTime = DateTime.now().millisecondsSinceEpoch;
  }

  // === Reset on Ascension ===
  void resetForAscension() {
    coins = 0;
    totalCoinsEarned = 0;
    for (final id in UpgradeId.values) {
      _prefs.remove('$_upgradePrefix${id.name}');
    }
    // Note: companions are NOT reset on ascension
  }
}
