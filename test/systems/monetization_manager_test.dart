import 'package:flutter_test/flutter_test.dart';
import 'package:paw_defense/systems/monetization_manager.dart';

void main() {
  group('Rewarded ad slots', () {
    test('has at least 3 ad reward types', () {
      expect(
          MonetizationManager.rewardedAdSlots.length, greaterThanOrEqualTo(3));
    });

    test('has 5 reward slots defined', () {
      expect(MonetizationManager.rewardedAdSlots.length, 5);
    });

    test('all slots have unique IDs', () {
      final ids =
          MonetizationManager.rewardedAdSlots.map((s) => s.id).toSet();
      expect(ids.length, MonetizationManager.rewardedAdSlots.length);
    });

    test('all slots have non-empty names', () {
      for (final s in MonetizationManager.rewardedAdSlots) {
        expect(s.name, isNotEmpty, reason: '${s.id} should have a name');
      }
    });

    test('all slots have non-empty descriptions', () {
      for (final s in MonetizationManager.rewardedAdSlots) {
        expect(s.description, isNotEmpty,
            reason: '${s.id} should have a description');
      }
    });

    test('all slots have positive max per day', () {
      for (final s in MonetizationManager.rewardedAdSlots) {
        expect(s.maxPerDay, greaterThan(0),
            reason: '${s.id} maxPerDay should be positive');
      }
    });

    test('max daily rewarded ads is 5', () {
      expect(MonetizationManager.maxDailyRewardedAds, 5);
    });
  });

  group('MonetizationManager state', () {
    late MonetizationManager manager;

    setUp(() {
      manager = MonetizationManager();
    });

    test('initial ads watched today is 0', () {
      expect(manager.rewardedAdsWatchedToday, 0);
    });

    test('can watch rewarded ad initially', () {
      expect(manager.canWatchRewardedAd, isTrue);
    });
  });
}
