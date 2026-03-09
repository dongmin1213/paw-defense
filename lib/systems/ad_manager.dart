/// Ad Manager — Placeholder stub
///
/// google_mobile_ads requires native Android/iOS setup (manifest, app ID etc.)
/// This stub provides the same API so game logic can reference ads
/// without compile errors. Replace with real implementation when SDK is configured.

import 'dart:async';

class AdManager {
  bool _initialized = false;
  bool _rewardedAdReady = false;

  // Daily limits
  int _companionAdsToday = 0;
  int _interstitialCount = 0;
  static const int maxCompanionAdsPerDay = 5;
  static const int maxInterstitialsPerDay = 10;
  DateTime _lastResetDate = DateTime(2000);

  Future<void> init() async {
    // TODO: Replace with MobileAds.instance.initialize()
    _initialized = true;
    _loadRewardedAd();
    _loadInterstitialAd();
    _resetDailyCounters();
  }

  void _resetDailyCounters() {
    final now = DateTime.now();
    if (now.day != _lastResetDate.day ||
        now.month != _lastResetDate.month ||
        now.year != _lastResetDate.year) {
      _companionAdsToday = 0;
      _interstitialCount = 0;
      _lastResetDate = now;
    }
  }

  void _loadRewardedAd() {
    // TODO: Load actual rewarded ad
    _rewardedAdReady = true; // Stub: always ready
  }

  void _loadInterstitialAd() {
    // TODO: Load actual interstitial ad
  }

  bool get isRewardedAdReady => _initialized && _rewardedAdReady;

  /// Show rewarded video ad. Calls onReward on completion.
  /// In stub mode, always calls onReward immediately.
  void showRewardedAd({required void Function() onReward}) {
    _resetDailyCounters();
    // Stub: grant reward immediately
    onReward();
    _loadRewardedAd();
  }

  /// Show interstitial ad at natural pause points
  void showInterstitialAd() {
    _resetDailyCounters();
    if (_interstitialCount >= maxInterstitialsPerDay) return;
    _interstitialCount++;
    // TODO: Show actual interstitial
    _loadInterstitialAd();
  }

  /// Companion ad — upgrade rarity
  bool canShowCompanionAd() {
    _resetDailyCounters();
    return _companionAdsToday < maxCompanionAdsPerDay;
  }

  void showCompanionAd({required void Function() onReward}) {
    if (!canShowCompanionAd()) return;
    _companionAdsToday++;
    showRewardedAd(onReward: onReward);
  }

  /// Whether to show interstitial (every 5th upgrade purchase)
  bool shouldShowInterstitial(int purchaseCount) {
    return purchaseCount > 0 && purchaseCount % 5 == 0;
  }
}
