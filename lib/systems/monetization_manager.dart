import 'package:shared_preferences/shared_preferences.dart';

/// Monetization system — rewarded ads only (사업자 불필요).
/// F2P 완전 무료, 광고는 자발적 시청만.
class MonetizationManager {
  static const String _prefix = 'monetize_';

  late SharedPreferences _prefs;

  // === Ad state ===
  int _rewardedAdsWatchedToday = 0;
  static const int maxDailyRewardedAds = 5;

  // === Rewarded Ad Slots ===
  static const List<RewardedAdSlot> rewardedAdSlots = [
    RewardedAdSlot('double_stars', '별 x2', '런 종료 시 획득 별 2배', 1),
    RewardedAdSlot('free_reroll', '무료 리롤', '유닛 리롤 1회 무료', 2),
    RewardedAdSlot('revival', '부활', '성벽 HP 30% 회복 후 재개', 1),
    RewardedAdSlot('daily_bonus', '일일 보너스', '일일 보상 2배', 1),
    RewardedAdSlot('extra_relic', '추가 유물', '보스 처치 시 유물 1개 추가', 1),
  ];

  // === Public Getters ===
  int get rewardedAdsWatchedToday => _rewardedAdsWatchedToday;
  bool get canWatchRewardedAd =>
      _rewardedAdsWatchedToday < maxDailyRewardedAds;

  // === Initialization ===

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _load();
  }

  void _load() {
    _rewardedAdsWatchedToday =
        _prefs.getInt('${_prefix}rewardedAdsToday') ?? 0;
    _checkDayReset();
  }

  Future<void> _save() async {
    await _prefs.setInt(
        '${_prefix}rewardedAdsToday', _rewardedAdsWatchedToday);
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

  /// Check if a specific ad slot can be used today.
  bool canUseSlot(String slotId) {
    if (!canWatchRewardedAd) return false;
    // Per-slot daily limits tracked via prefs
    final key = '${_prefix}slot_$slotId';
    final used = _prefs.getInt(key) ?? 0;
    final slot = rewardedAdSlots.where((s) => s.id == slotId).firstOrNull;
    if (slot == null) return false;
    return used < slot.maxPerDay;
  }

  /// Record usage of a specific ad slot.
  void onSlotUsed(String slotId) {
    final key = '${_prefix}slot_$slotId';
    final used = _prefs.getInt(key) ?? 0;
    _prefs.setInt(key, used + 1);
    onRewardedAdWatched();
  }

  /// Reset all daily slot counters (called on day change).
  void resetDailySlots() {
    for (final slot in rewardedAdSlots) {
      _prefs.setInt('${_prefix}slot_${slot.id}', 0);
    }
  }
}

// === Data classes ===

class RewardedAdSlot {
  final String id;
  final String name;
  final String description;
  final int maxPerDay;
  const RewardedAdSlot(this.id, this.name, this.description, this.maxPerDay);
}
