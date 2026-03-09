import 'package:shared_preferences/shared_preferences.dart';

/// Singleton for persistent game data
class GameData {
  static final GameData _instance = GameData._();
  static GameData get instance => _instance;
  GameData._();

  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // --- Coins ---
  int get totalCoins => _prefs.getInt('totalCoins') ?? 0;
  Future<void> addCoins(int amount) async {
    await _prefs.setInt('totalCoins', totalCoins + amount);
  }
  Future<void> spendCoins(int amount) async {
    await _prefs.setInt('totalCoins', (totalCoins - amount).clamp(0, 999999));
  }

  // --- Stage Progress ---
  int get maxClearedStage => _prefs.getInt('maxClearedStage') ?? -1;
  bool isStageUnlocked(int stage) => stage <= maxClearedStage + 1;
  Future<void> clearStage(int stage) async {
    if (stage > maxClearedStage) {
      await _prefs.setInt('maxClearedStage', stage);
    }
  }

  // --- Upgrades ---
  // Keys: 'upg_maxHp', 'upg_attack', 'upg_speed', 'upg_dashCd', 'upg_gauge'
  int getUpgradeLevel(String key) => _prefs.getInt('upg_$key') ?? 0;
  Future<void> setUpgradeLevel(String key, int level) async {
    await _prefs.setInt('upg_$key', level);
  }

  // --- Best Times ---
  double getBestTime(int stage) {
    return _prefs.getDouble('bestTime_$stage') ?? 0;
  }
  Future<void> setBestTime(int stage, double time) async {
    final current = getBestTime(stage);
    if (current <= 0 || time < current) {
      await _prefs.setDouble('bestTime_$stage', time);
    }
  }

  // --- Upgrade Definitions ---
  static const upgrades = <String, UpgradeDef>{
    'maxHp': UpgradeDef(
      name: 'MAX HP',
      description: '최대 체력 +1',
      maxLevel: 3,
      costs: [100, 300, 600],
    ),
    'attack': UpgradeDef(
      name: 'ATTACK',
      description: '공격력 +10%',
      maxLevel: 5,
      costs: [80, 160, 320, 500, 800],
    ),
    'speed': UpgradeDef(
      name: 'SPEED',
      description: '이동속도 +5%',
      maxLevel: 3,
      costs: [50, 150, 400],
    ),
    'dashCd': UpgradeDef(
      name: 'DASH',
      description: '대시 쿨다운 -10%',
      maxLevel: 3,
      costs: [100, 250, 500],
    ),
    'gauge': UpgradeDef(
      name: 'GAUGE',
      description: '게이지 충전 +15%',
      maxLevel: 3,
      costs: [120, 300, 600],
    ),
  };

  int getUpgradeCost(String key) {
    final def = upgrades[key]!;
    final level = getUpgradeLevel(key);
    if (level >= def.maxLevel) return -1; // maxed
    return def.costs[level];
  }

  bool canAffordUpgrade(String key) {
    final cost = getUpgradeCost(key);
    return cost > 0 && totalCoins >= cost;
  }

  Future<bool> buyUpgrade(String key) async {
    final cost = getUpgradeCost(key);
    if (cost <= 0 || totalCoins < cost) return false;
    await spendCoins(cost);
    await setUpgradeLevel(key, getUpgradeLevel(key) + 1);
    return true;
  }

  // --- Apply upgrades to stats ---
  int get bonusMaxHp => getUpgradeLevel('maxHp');
  double get attackMultiplier => 1.0 + getUpgradeLevel('attack') * 0.1;
  double get speedMultiplier => 1.0 + getUpgradeLevel('speed') * 0.05;
  double get dashCdMultiplier => 1.0 - getUpgradeLevel('dashCd') * 0.1;
  double get gaugeMultiplier => 1.0 + getUpgradeLevel('gauge') * 0.15;
}

class UpgradeDef {
  final String name;
  final String description;
  final int maxLevel;
  final List<int> costs;

  const UpgradeDef({
    required this.name,
    required this.description,
    required this.maxLevel,
    required this.costs,
  });
}
