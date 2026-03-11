import 'package:shared_preferences/shared_preferences.dart';

/// Monetization system — manages ads, IAP, and cosmetic purchases.
/// Designed for non-invasive, F2P-friendly monetization.
///
/// Revenue streams:
/// 1. Rewarded ads (voluntary, bonus rewards)
/// 2. IAP (ad removal, premium currency, battle pass)
/// 3. Cosmetics (unit skins, castle themes, particle effects)
class MonetizationManager {
  static const String _prefix = 'monetize_';

  late SharedPreferences _prefs;

  // === Ad state ===
  bool _adsRemoved = false;
  int _rewardedAdsWatchedToday = 0;
  static const int maxDailyRewardedAds = 5;

  // === Premium currency (Gems) ===
  int _gems = 0;

  // === Battle Pass ===
  bool _hasBattlePass = false;
  int _battlePassLevel = 0;
  int _battlePassXp = 0;
  static const int xpPerLevel = 100;
  static const int maxBattlePassLevel = 30;

  // === Cosmetics ===
  final Set<String> _ownedSkins = {};
  String _activeCastleSkin = 'default';
  String _activeParticleTheme = 'default';

  // === IAP Product IDs ===
  static const String iapRemoveAds = 'remove_ads';
  static const String iapGems100 = 'gems_100';
  static const String iapGems500 = 'gems_500';
  static const String iapGems1200 = 'gems_1200';
  static const String iapBattlePass = 'battle_pass';
  static const String iapStarterPack = 'starter_pack';

  // === Skin Definitions ===
  static const List<CosmeticItem> castleSkins = [
    CosmeticItem('default', '기본 성', 0, CosmeticRarity.free),
    CosmeticItem('golden_castle', '황금 성', 200, CosmeticRarity.rare),
    CosmeticItem('crystal_castle', '크리스탈 성', 500, CosmeticRarity.epic),
    CosmeticItem('dark_castle', '암흑 성', 300, CosmeticRarity.rare),
    CosmeticItem('cherry_blossom', '벚꽃 성', 400, CosmeticRarity.epic),
    CosmeticItem('ice_castle', '얼음 성', 350, CosmeticRarity.rare),
    CosmeticItem('dragon_castle', '용의 성', 800, CosmeticRarity.legendary),
    CosmeticItem('celestial_castle', '천상의 성', 1500, CosmeticRarity.mythic),
  ];

  static const List<CosmeticItem> particleThemes = [
    CosmeticItem('default', '기본', 0, CosmeticRarity.free),
    CosmeticItem('golden_sparkle', '황금 반짝임', 150, CosmeticRarity.rare),
    CosmeticItem('fire_burst', '불꽃 폭발', 250, CosmeticRarity.rare),
    CosmeticItem('ice_crystal', '얼음 결정', 250, CosmeticRarity.rare),
    CosmeticItem('rainbow', '무지개', 400, CosmeticRarity.epic),
    CosmeticItem('galaxy', '은하수', 600, CosmeticRarity.epic),
    CosmeticItem('cherry_petal', '벚꽃잎', 350, CosmeticRarity.epic),
    CosmeticItem('lightning', '번개', 500, CosmeticRarity.legendary),
  ];

  // === Rewarded Ad Slots ===
  static const List<RewardedAdSlot> rewardedAdSlots = [
    RewardedAdSlot('double_stars', '별 x2', '런 종료 시 획득 별 2배', 1),
    RewardedAdSlot('free_reroll', '무료 리롤', '유닛 리롤 1회 무료', 2),
    RewardedAdSlot('revival', '부활', '성벽 HP 30% 회복 후 재개', 1),
    RewardedAdSlot('daily_bonus', '일일 보너스', '일일 보상 2배', 1),
    RewardedAdSlot('extra_relic', '추가 유물', '보스 처치 시 유물 1개 추가', 1),
  ];

  // === Public Getters ===
  bool get adsRemoved => _adsRemoved;
  int get gems => _gems;
  bool get hasBattlePass => _hasBattlePass;
  int get battlePassLevel => _battlePassLevel;
  int get battlePassXp => _battlePassXp;
  int get rewardedAdsWatchedToday => _rewardedAdsWatchedToday;
  bool get canWatchRewardedAd =>
      !_adsRemoved && _rewardedAdsWatchedToday < maxDailyRewardedAds;
  String get activeCastleSkin => _activeCastleSkin;
  String get activeParticleTheme => _activeParticleTheme;
  Set<String> get ownedSkins => Set.unmodifiable(_ownedSkins);

  // === Initialization ===

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _load();
  }

  void _load() {
    _adsRemoved = _prefs.getBool('${_prefix}adsRemoved') ?? false;
    _gems = _prefs.getInt('${_prefix}gems') ?? 0;
    _hasBattlePass = _prefs.getBool('${_prefix}battlePass') ?? false;
    _battlePassLevel = _prefs.getInt('${_prefix}bpLevel') ?? 0;
    _battlePassXp = _prefs.getInt('${_prefix}bpXp') ?? 0;
    _rewardedAdsWatchedToday =
        _prefs.getInt('${_prefix}rewardedAdsToday') ?? 0;
    _activeCastleSkin =
        _prefs.getString('${_prefix}castleSkin') ?? 'default';
    _activeParticleTheme =
        _prefs.getString('${_prefix}particleTheme') ?? 'default';

    final skinList = _prefs.getString('${_prefix}ownedSkins') ?? 'default';
    _ownedSkins.addAll(skinList.split(',').where((s) => s.isNotEmpty));

    // Check for day reset
    _checkDayReset();
  }

  Future<void> _save() async {
    await _prefs.setBool('${_prefix}adsRemoved', _adsRemoved);
    await _prefs.setInt('${_prefix}gems', _gems);
    await _prefs.setBool('${_prefix}battlePass', _hasBattlePass);
    await _prefs.setInt('${_prefix}bpLevel', _battlePassLevel);
    await _prefs.setInt('${_prefix}bpXp', _battlePassXp);
    await _prefs.setInt('${_prefix}rewardedAdsToday', _rewardedAdsWatchedToday);
    await _prefs.setString('${_prefix}castleSkin', _activeCastleSkin);
    await _prefs.setString('${_prefix}particleTheme', _activeParticleTheme);
    await _prefs.setString('${_prefix}ownedSkins', _ownedSkins.join(','));
  }

  void _checkDayReset() {
    final lastDay = _prefs.getString('${_prefix}lastDay') ?? '';
    final today = _todayString();
    if (lastDay != today) {
      _rewardedAdsWatchedToday = 0;
      _prefs.setString('${_prefix}lastDay', today);
      _save();
    }
  }

  String _todayString() {
    final now = DateTime.now().toUtc();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // === Rewarded Ads ===

  /// Record a rewarded ad watch. Returns true if allowed.
  bool onRewardedAdWatched() {
    if (_rewardedAdsWatchedToday >= maxDailyRewardedAds) return false;
    _rewardedAdsWatchedToday++;
    _save();
    return true;
  }

  // === IAP ===

  /// Process a successful IAP purchase.
  void onPurchaseComplete(String productId) {
    switch (productId) {
      case iapRemoveAds:
        _adsRemoved = true;
        break;
      case iapGems100:
        _gems += 100;
        break;
      case iapGems500:
        _gems += 500;
        break;
      case iapGems1200:
        _gems += 1200;
        break;
      case iapBattlePass:
        _hasBattlePass = true;
        break;
      case iapStarterPack:
        _gems += 300;
        _adsRemoved = true;
        break;
    }
    _save();
  }

  // === Gems ===

  /// Spend gems. Returns true if successful.
  bool spendGems(int amount) {
    if (_gems < amount) return false;
    _gems -= amount;
    _save();
    return true;
  }

  /// Add gems (from rewards, ads, etc.)
  void addGems(int amount) {
    _gems += amount;
    _save();
  }

  // === Cosmetics ===

  /// Purchase a cosmetic with gems. Returns true if successful.
  bool purchaseSkin(String skinId, int gemCost) {
    if (_ownedSkins.contains(skinId)) return false;
    if (!spendGems(gemCost)) return false;
    _ownedSkins.add(skinId);
    _save();
    return true;
  }

  /// Set active castle skin.
  bool setCastleSkin(String skinId) {
    if (!_ownedSkins.contains(skinId) && skinId != 'default') return false;
    _activeCastleSkin = skinId;
    _save();
    return true;
  }

  /// Set active particle theme.
  bool setParticleTheme(String themeId) {
    if (!_ownedSkins.contains(themeId) && themeId != 'default') return false;
    _activeParticleTheme = themeId;
    _save();
    return true;
  }

  // === Battle Pass ===

  /// Add XP to the battle pass. Returns list of newly earned levels.
  List<int> addBattlePassXp(int xp) {
    if (!_hasBattlePass) return [];
    if (_battlePassLevel >= maxBattlePassLevel) return [];

    _battlePassXp += xp;
    final newLevels = <int>[];

    while (_battlePassXp >= xpPerLevel &&
        _battlePassLevel < maxBattlePassLevel) {
      _battlePassXp -= xpPerLevel;
      _battlePassLevel++;
      newLevels.add(_battlePassLevel);
    }

    _save();
    return newLevels;
  }

  /// Get battle pass reward for a level.
  static BattlePassReward getReward(int level) {
    // Every 5 levels = premium reward, others = standard
    if (level % 10 == 0) {
      return BattlePassReward(
          type: BattlePassRewardType.gems, amount: 100, label: '100 보석');
    } else if (level % 5 == 0) {
      return BattlePassReward(
          type: BattlePassRewardType.skin,
          amount: 1,
          label: '특별 스킨',
          skinId: 'bp_skin_$level');
    } else if (level % 3 == 0) {
      return BattlePassReward(
          type: BattlePassRewardType.gems, amount: 30, label: '30 보석');
    } else {
      return BattlePassReward(
          type: BattlePassRewardType.stars, amount: 100, label: '100 별');
    }
  }
}

// === Data classes ===

enum CosmeticRarity { free, rare, epic, legendary, mythic }

class CosmeticItem {
  final String id;
  final String name;
  final int gemCost;
  final CosmeticRarity rarity;
  const CosmeticItem(this.id, this.name, this.gemCost, this.rarity);
}

class RewardedAdSlot {
  final String id;
  final String name;
  final String description;
  final int maxPerDay;
  const RewardedAdSlot(this.id, this.name, this.description, this.maxPerDay);
}

enum BattlePassRewardType { stars, gems, skin }

class BattlePassReward {
  final BattlePassRewardType type;
  final int amount;
  final String label;
  final String? skinId;
  const BattlePassReward({
    required this.type,
    required this.amount,
    required this.label,
    this.skinId,
  });
}
