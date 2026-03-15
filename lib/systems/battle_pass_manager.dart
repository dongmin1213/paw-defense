import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Battle pass tier reward definition.
class BattlePassReward {
  final int tier;
  final String name;
  final String description;
  final String icon;
  final BattlePassRewardType type;
  final int amount;

  const BattlePassReward({
    required this.tier,
    required this.name,
    required this.description,
    required this.icon,
    required this.type,
    required this.amount,
  });
}

enum BattlePassRewardType {
  stars,
  gold,
  relicQuality,
  startingGold,
  cosmetic,
}

/// Season-based battle pass with 30 tiers.
/// XP earned from gameplay actions, resets monthly.
class BattlePassManager {
  static const String _prefix = 'battlepass_';
  static const String _keyXp = '${_prefix}xp';
  static const String _keyTier = '${_prefix}tier';
  static const String _keySeason = '${_prefix}season';
  static const String _keyClaimed = '${_prefix}claimed';

  late SharedPreferences _prefs;

  int _xp = 0;
  int _tier = 0;
  int _season = 0;
  Set<int> _claimedTiers = {};

  // XP per tier escalates: tier * 100 + 200
  static int xpForTier(int tier) => tier * 100 + 200;

  /// Total XP needed to reach a given tier.
  static int totalXpForTier(int tier) {
    int total = 0;
    for (int i = 1; i <= tier; i++) {
      total += xpForTier(i);
    }
    return total;
  }

  // === 30 tier rewards ===
  static const List<BattlePassReward> rewards = [
    BattlePassReward(tier: 1, name: '별 50', description: '별 50개', icon: '⭐', type: BattlePassRewardType.stars, amount: 50),
    BattlePassReward(tier: 2, name: '별 75', description: '별 75개', icon: '⭐', type: BattlePassRewardType.stars, amount: 75),
    BattlePassReward(tier: 3, name: '초기 골드+', description: '런 시작 골드 +20', icon: '💰', type: BattlePassRewardType.startingGold, amount: 20),
    BattlePassReward(tier: 4, name: '별 100', description: '별 100개', icon: '⭐', type: BattlePassRewardType.stars, amount: 100),
    BattlePassReward(tier: 5, name: '유물 품질+', description: '유물 드롭 품질 +5%', icon: '🔮', type: BattlePassRewardType.relicQuality, amount: 5),
    BattlePassReward(tier: 6, name: '별 100', description: '별 100개', icon: '⭐', type: BattlePassRewardType.stars, amount: 100),
    BattlePassReward(tier: 7, name: '별 125', description: '별 125개', icon: '⭐', type: BattlePassRewardType.stars, amount: 125),
    BattlePassReward(tier: 8, name: '초기 골드++', description: '런 시작 골드 +30', icon: '💰', type: BattlePassRewardType.startingGold, amount: 30),
    BattlePassReward(tier: 9, name: '별 150', description: '별 150개', icon: '⭐', type: BattlePassRewardType.stars, amount: 150),
    BattlePassReward(tier: 10, name: '유물 품질++', description: '유물 드롭 품질 +10%', icon: '🔮', type: BattlePassRewardType.relicQuality, amount: 10),
    BattlePassReward(tier: 11, name: '별 150', description: '별 150개', icon: '⭐', type: BattlePassRewardType.stars, amount: 150),
    BattlePassReward(tier: 12, name: '별 175', description: '별 175개', icon: '⭐', type: BattlePassRewardType.stars, amount: 175),
    BattlePassReward(tier: 13, name: '초기 골드+++', description: '런 시작 골드 +50', icon: '💰', type: BattlePassRewardType.startingGold, amount: 50),
    BattlePassReward(tier: 14, name: '별 200', description: '별 200개', icon: '⭐', type: BattlePassRewardType.stars, amount: 200),
    BattlePassReward(tier: 15, name: '유물 품질+++', description: '유물 드롭 품질 +15%', icon: '🔮', type: BattlePassRewardType.relicQuality, amount: 15),
    BattlePassReward(tier: 16, name: '별 200', description: '별 200개', icon: '⭐', type: BattlePassRewardType.stars, amount: 200),
    BattlePassReward(tier: 17, name: '별 225', description: '별 225개', icon: '⭐', type: BattlePassRewardType.stars, amount: 225),
    BattlePassReward(tier: 18, name: '별 250', description: '별 250개', icon: '⭐', type: BattlePassRewardType.stars, amount: 250),
    BattlePassReward(tier: 19, name: '별 275', description: '별 275개', icon: '⭐', type: BattlePassRewardType.stars, amount: 275),
    BattlePassReward(tier: 20, name: '대형 보상', description: '별 500개 + 유물 품질 +20%', icon: '🏆', type: BattlePassRewardType.stars, amount: 500),
    BattlePassReward(tier: 21, name: '별 300', description: '별 300개', icon: '⭐', type: BattlePassRewardType.stars, amount: 300),
    BattlePassReward(tier: 22, name: '별 325', description: '별 325개', icon: '⭐', type: BattlePassRewardType.stars, amount: 325),
    BattlePassReward(tier: 23, name: '별 350', description: '별 350개', icon: '⭐', type: BattlePassRewardType.stars, amount: 350),
    BattlePassReward(tier: 24, name: '별 375', description: '별 375개', icon: '⭐', type: BattlePassRewardType.stars, amount: 375),
    BattlePassReward(tier: 25, name: '큰 보상', description: '별 750개', icon: '🌟', type: BattlePassRewardType.stars, amount: 750),
    BattlePassReward(tier: 26, name: '별 400', description: '별 400개', icon: '⭐', type: BattlePassRewardType.stars, amount: 400),
    BattlePassReward(tier: 27, name: '별 425', description: '별 425개', icon: '⭐', type: BattlePassRewardType.stars, amount: 425),
    BattlePassReward(tier: 28, name: '별 450', description: '별 450개', icon: '⭐', type: BattlePassRewardType.stars, amount: 450),
    BattlePassReward(tier: 29, name: '별 475', description: '별 475개', icon: '⭐', type: BattlePassRewardType.stars, amount: 475),
    BattlePassReward(tier: 30, name: '시즌 마스터', description: '별 1000개 + 전설 보장', icon: '👑', type: BattlePassRewardType.stars, amount: 1000),
  ];

  static const int maxTier = 30;

  // === Getters ===
  int get xp => _xp;
  int get tier => _tier;
  int get season => _season;
  double get tierProgress {
    if (_tier >= maxTier) return 1.0;
    final needed = xpForTier(_tier + 1);
    final currentXp = _xp - totalXpForTier(_tier);
    return (currentXp / needed).clamp(0.0, 1.0);
  }

  bool isTierClaimed(int tier) => _claimedTiers.contains(tier);
  bool canClaimTier(int tier) => _tier >= tier && !_claimedTiers.contains(tier);

  /// Get current season number based on year/month.
  static int currentSeason() {
    final now = DateTime.now().toUtc();
    return now.year * 12 + now.month;
  }

  int get daysRemainingInSeason {
    final now = DateTime.now().toUtc();
    final lastDay = DateTime.utc(now.year, now.month + 1, 0);
    return lastDay.day - now.day;
  }

  // === XP Sources ===

  /// Add XP from a gameplay action.
  void addXp(int amount) {
    _xp += amount;
    // Check tier ups
    while (_tier < maxTier && _xp >= totalXpForTier(_tier + 1)) {
      _tier++;
    }
    _save();
  }

  /// XP rewards for common actions.
  static const int xpPerKill = 1;
  static const int xpPerWave = 20;
  static const int xpPerBossKill = 50;
  static const int xpPerMerge = 5;
  static const int xpPerHybrid = 25;
  static const int xpPerRun = 10;

  // === Claim Rewards ===

  /// Claim a tier reward. Returns the reward, or null if already claimed.
  BattlePassReward? claimTier(int tier) {
    if (!canClaimTier(tier)) return null;
    _claimedTiers.add(tier);
    _save();
    final reward = rewards.where((r) => r.tier == tier).firstOrNull;
    return reward;
  }

  /// Get list of unclaimed available rewards.
  List<BattlePassReward> get unclaimedRewards {
    return rewards.where((r) => r.tier <= _tier && !_claimedTiers.contains(r.tier)).toList();
  }

  // === Persistence ===

  Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
    _load();
    _checkSeasonReset();
  }

  void _load() {
    _xp = _prefs.getInt(_keyXp) ?? 0;
    _tier = _prefs.getInt(_keyTier) ?? 0;
    _season = _prefs.getInt(_keySeason) ?? 0;
    final claimedStr = _prefs.getString(_keyClaimed) ?? '';
    _claimedTiers = claimedStr.isEmpty
        ? {}
        : claimedStr.split(',').map((s) => int.tryParse(s) ?? 0).toSet();
  }

  Future<void> _save() async {
    await _prefs.setInt(_keyXp, _xp);
    await _prefs.setInt(_keyTier, _tier);
    await _prefs.setInt(_keySeason, _season);
    await _prefs.setString(_keyClaimed, _claimedTiers.join(','));
  }

  void _checkSeasonReset() {
    final current = currentSeason();
    if (_season != current) {
      // New season — reset progress
      _xp = 0;
      _tier = 0;
      _claimedTiers.clear();
      _season = current;
      _save();
    }
  }
}
