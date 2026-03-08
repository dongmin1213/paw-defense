import 'package:shared_preferences/shared_preferences.dart';
import 'upgrade_manager.dart';
import '../data/upgrade_data.dart';

class SaveManager {
  static const String _keyCoins = 'coins';
  static const String _keyTotalCoins = 'total_coins_earned';
  static const String _keyHighScore = 'high_score';
  static const String _keySouls = 'souls';
  static const String _keyAscensionCount = 'ascension_count';
  static const String _keyLastOnline = 'last_online_time';
  static const String _upgradePrefix = 'upgrade_';

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

  // === Last Online (for offline rewards) ===
  int get lastOnlineTime => _prefs.getInt(_keyLastOnline) ?? 0;
  set lastOnlineTime(int v) => _prefs.setInt(_keyLastOnline, v);

  // === Upgrades ===
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
      if (val != null) {
        map[id.name] = val;
      }
    }
    manager.loadFromMap(map);
  }

  // === Save All Game State ===
  void saveGameState({
    required double coins,
    required double totalCoinsEarned,
    required double highScore,
    required UpgradeManager upgradeManager,
  }) {
    this.coins = coins;
    this.totalCoinsEarned = totalCoinsEarned;
    if (highScore > this.highScore) {
      this.highScore = highScore;
    }
    saveUpgrades(upgradeManager);
    lastOnlineTime = DateTime.now().millisecondsSinceEpoch;
  }

  // === Reset on Ascension ===
  void resetForAscension() {
    coins = 0;
    // Note: totalCoinsEarned and highScore persist
    // Upgrades are reset by UpgradeManager.resetAll()
  }
}
