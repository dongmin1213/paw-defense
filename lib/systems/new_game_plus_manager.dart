import 'package:shared_preferences/shared_preferences.dart';

/// New Game+ system — escalating difficulty with permanent bonuses.
/// Each ascension increases difficulty but grants permanent perks.
class NewGamePlusManager {
  static const String _prefix = 'ngplus_';
  static const String _keyLevel = '${_prefix}level';
  static const String _keyUnlockedPerks = '${_prefix}perks';
  static const String _keyHighestLevel = '${_prefix}highest';

  late SharedPreferences _prefs;

  int _level = 0; // Current NG+ level (0 = normal, 1 = NG+1, etc.)
  int _highestLevel = 0;
  Set<String> _unlockedPerks = {};

  // === Getters ===
  int get level => _level;
  int get highestLevel => _highestLevel;
  bool get isNewGamePlus => _level > 0;
  String get displayName => _level == 0 ? '일반' : 'NG+$_level';

  // === Difficulty Scaling ===

  /// Enemy HP multiplier for current NG+ level.
  double get enemyHpMultiplier => 1.0 + _level * 0.25;

  /// Enemy speed multiplier for current NG+ level.
  double get enemySpeedMultiplier => 1.0 + _level * 0.05;

  /// Enemy damage multiplier for current NG+ level.
  double get enemyDamageMultiplier => 1.0 + _level * 0.15;

  /// Wave at which enemies get additional scaling.
  int get extraScalingWave => (30 - _level * 2).clamp(15, 30);

  // === Player Bonuses (compensating difficulty) ===

  /// Starting gold bonus per NG+ level.
  int get startingGoldBonus => _level * 15;

  /// Star multiplier per NG+ level.
  double get starMultiplier => 1.0 + _level * 0.20;

  /// XP multiplier for battle pass per NG+ level.
  double get xpMultiplier => 1.0 + _level * 0.15;

  // === Perks ===

  static const List<NewGamePlusPerk> allPerks = [
    NewGamePlusPerk(
      id: 'perk_extra_slot',
      name: '추가 슬롯',
      description: 'NG+1 달성: 유닛 슬롯 +1',
      requiredLevel: 1,
      icon: '🔲',
    ),
    NewGamePlusPerk(
      id: 'perk_starting_relic',
      name: '시작 유물',
      description: 'NG+2 달성: 런 시작 시 유물 1개 보유',
      requiredLevel: 2,
      icon: '🔮',
    ),
    NewGamePlusPerk(
      id: 'perk_fast_merge',
      name: '빠른 합체',
      description: 'NG+3 달성: 머지 필요 유닛 2개로 감소',
      requiredLevel: 3,
      icon: '🔀',
    ),
    NewGamePlusPerk(
      id: 'perk_crit_base',
      name: '기본 치명타',
      description: 'NG+4 달성: 기본 치명타 확률 +5%',
      requiredLevel: 4,
      icon: '💥',
    ),
    NewGamePlusPerk(
      id: 'perk_double_combo',
      name: '더블 콤보',
      description: 'NG+5 달성: 콤보 골드 보너스 2배',
      requiredLevel: 5,
      icon: '🔥',
    ),
  ];

  bool hasPerk(String perkId) => _unlockedPerks.contains(perkId);

  int get extraSlots => hasPerk('perk_extra_slot') ? 1 : 0;
  bool get hasStartingRelic => hasPerk('perk_starting_relic');
  bool get hasFastMerge => hasPerk('perk_fast_merge');
  double get baseCritBonus => hasPerk('perk_crit_base') ? 0.05 : 0.0;
  double get comboGoldMultiplier => hasPerk('perk_double_combo') ? 2.0 : 1.0;

  // === Ascend (activate NG+) ===

  /// Check if player can ascend (requires reaching wave 30+).
  bool canAscend(int highestWave) => highestWave >= 30;

  /// Ascend to next NG+ level. Returns newly unlocked perk, if any.
  NewGamePlusPerk? ascend() {
    _level++;
    if (_level > _highestLevel) {
      _highestLevel = _level;
    }

    // Unlock perks for this level
    NewGamePlusPerk? newPerk;
    for (final perk in allPerks) {
      if (perk.requiredLevel <= _highestLevel && !_unlockedPerks.contains(perk.id)) {
        _unlockedPerks.add(perk.id);
        newPerk = perk;
      }
    }

    _save();
    return newPerk;
  }

  /// Reset to normal difficulty (keep perks).
  void resetToNormal() {
    _level = 0;
    _save();
  }

  /// Set specific NG+ level (up to highest achieved).
  void setLevel(int level) {
    _level = level.clamp(0, _highestLevel);
    _save();
  }

  // === Persistence ===

  Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
    _level = prefs.getInt(_keyLevel) ?? 0;
    _highestLevel = prefs.getInt(_keyHighestLevel) ?? 0;
    final perksStr = prefs.getString(_keyUnlockedPerks) ?? '';
    _unlockedPerks = perksStr.isEmpty ? {} : perksStr.split(',').toSet();
  }

  Future<void> _save() async {
    await _prefs.setInt(_keyLevel, _level);
    await _prefs.setInt(_keyHighestLevel, _highestLevel);
    await _prefs.setString(_keyUnlockedPerks, _unlockedPerks.join(','));
  }
}

/// A permanent perk unlocked by reaching NG+ milestones.
class NewGamePlusPerk {
  final String id;
  final String name;
  final String description;
  final int requiredLevel;
  final String icon;

  const NewGamePlusPerk({
    required this.id,
    required this.name,
    required this.description,
    required this.requiredLevel,
    required this.icon,
  });
}
