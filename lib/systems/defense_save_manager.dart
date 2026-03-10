import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'defense_upgrade_manager.dart';

/// Save manager for castle defense mode.
/// Uses SharedPreferences for persistent storage.
/// Handles both permanent (between-run) and mid-run save/load.
class DefenseSaveManager {
  static const String _prefix = 'defense_';
  static const String _keyStars = '${_prefix}stars';
  static const String _keySouls = '${_prefix}souls';
  static const String _keyHighestWave = '${_prefix}highestWave';
  static const String _keyAscensionCount = '${_prefix}ascensionCount';
  static const String _keyTotalKills = '${_prefix}totalKills';
  static const String _keyTotalRuns = '${_prefix}totalRuns';
  static const String _keyLastOnline = '${_prefix}lastOnline';
  static const String _keyUpgradePrefix = '${_prefix}upgrade_';
  static const String _keyRunState = '${_prefix}runState';
  static const String _keyTotalStarsEarned = '${_prefix}totalStarsEarned';
  static const String _keyTotalBossKills = '${_prefix}totalBossKills';

  late SharedPreferences _prefs;

  /// Initialize SharedPreferences. Must be called before any other method.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // === Simple values ===

  int get stars => _prefs.getInt(_keyStars) ?? 0;
  set stars(int v) => _prefs.setInt(_keyStars, v);

  int get souls => _prefs.getInt(_keySouls) ?? 0;
  set souls(int v) => _prefs.setInt(_keySouls, v);

  int get highestWave => _prefs.getInt(_keyHighestWave) ?? 0;
  set highestWave(int v) => _prefs.setInt(_keyHighestWave, v);

  int get ascensionCount => _prefs.getInt(_keyAscensionCount) ?? 0;
  set ascensionCount(int v) => _prefs.setInt(_keyAscensionCount, v);

  int get totalKills => _prefs.getInt(_keyTotalKills) ?? 0;
  set totalKills(int v) => _prefs.setInt(_keyTotalKills, v);

  int get totalRuns => _prefs.getInt(_keyTotalRuns) ?? 0;
  set totalRuns(int v) => _prefs.setInt(_keyTotalRuns, v);

  int get totalStarsEarned => _prefs.getInt(_keyTotalStarsEarned) ?? 0;
  set totalStarsEarned(int v) => _prefs.setInt(_keyTotalStarsEarned, v);

  int get totalBossKills => _prefs.getInt(_keyTotalBossKills) ?? 0;
  set totalBossKills(int v) => _prefs.setInt(_keyTotalBossKills, v);

  String get lastOnlineTime => _prefs.getString(_keyLastOnline) ?? '';
  set lastOnlineTime(String v) => _prefs.setString(_keyLastOnline, v);

  // === Upgrade Manager save/load ===

  void saveUpgrades(DefenseUpgradeManager mgr) {
    final map = mgr.toMap();
    for (final entry in map.entries) {
      _prefs.setInt('$_keyUpgradePrefix${entry.key}', entry.value);
    }
  }

  void loadUpgrades(DefenseUpgradeManager mgr) {
    final map = <String, int>{};
    for (final id in DefenseUpgradeId.values) {
      final val = _prefs.getInt('$_keyUpgradePrefix${id.name}');
      if (val != null) map[id.name] = val;
    }
    mgr.loadFromMap(map);
  }

  // === In-run save (for mid-run resume) ===

  /// Save the current run state as JSON.
  void saveRunState(Map<String, dynamic> state) {
    try {
      _prefs.setString(_keyRunState, jsonEncode(state));
    } catch (_) {
      // Silently fail on serialization error
    }
  }

  /// Load a previously saved run state. Returns null if none exists.
  Map<String, dynamic>? loadRunState() {
    final jsonStr = _prefs.getString(_keyRunState);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Clear any saved run state (after successful resume or run end).
  void clearRunState() {
    _prefs.remove(_keyRunState);
  }

  /// Check if there is a saved run to resume.
  bool get hasRunState => _prefs.containsKey(_keyRunState);

  // === Save All (end of run or periodic save) ===

  void saveAll({
    required int stars,
    required DefenseUpgradeManager upgrades,
    int? souls,
    int? highestWave,
    int? ascensionCount,
    int? totalKills,
    int? totalRuns,
    int? totalStarsEarned,
    int? totalBossKills,
  }) {
    this.stars = stars;
    if (souls != null) this.souls = souls;
    if (highestWave != null && highestWave > this.highestWave) {
      this.highestWave = highestWave;
    }
    if (ascensionCount != null) this.ascensionCount = ascensionCount;
    if (totalKills != null) this.totalKills = totalKills;
    if (totalRuns != null) this.totalRuns = totalRuns;
    if (totalStarsEarned != null) this.totalStarsEarned = totalStarsEarned;
    if (totalBossKills != null) this.totalBossKills = totalBossKills;
    saveUpgrades(upgrades);
    lastOnlineTime = DateTime.now().toIso8601String();
  }

  // === Reset ===

  /// Reset all defense save data. Use with caution.
  Future<void> resetAll() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith(_prefix));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
}
