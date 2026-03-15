import 'package:flutter_test/flutter_test.dart';
import 'package:paw_defense/data/balance_config.dart';
import 'package:paw_defense/systems/combo_manager.dart';

void main() {
  group('ComboTier', () {
    test('tier thresholds are ordered correctly', () {
      final tiers = ComboTier.values;
      for (int i = 1; i < tiers.length; i++) {
        expect(tiers[i].threshold, greaterThan(tiers[i - 1].threshold),
            reason: '${tiers[i].name} should have higher threshold than ${tiers[i - 1].name}');
      }
    });

    test('effect scales increase with tier', () {
      final tiers = ComboTier.values;
      for (int i = 1; i < tiers.length; i++) {
        expect(tiers[i].effectScale, greaterThanOrEqualTo(tiers[i - 1].effectScale),
            reason: '${tiers[i].name} should have >= effect scale than ${tiers[i - 1].name}');
      }
    });

    test('all non-none tiers have labels', () {
      for (final tier in ComboTier.values) {
        if (tier == ComboTier.none) continue;
        expect(tier.label, isNotEmpty, reason: '${tier.name} should have a label');
      }
    });

    test('all tiers have valid colors', () {
      for (final tier in ComboTier.values) {
        expect(tier.color, isNonZero, reason: '${tier.name} should have a color');
      }
    });

    test('tier count is 6 (none + 5 tiers)', () {
      expect(ComboTier.values.length, 6);
    });

    test('godlike has highest threshold at 100', () {
      expect(ComboTier.godlike.threshold, 100);
    });

    test('nice starts at 5 kills', () {
      expect(ComboTier.nice.threshold, 5);
    });

    test('gold bonus interval is 10', () {
      expect(BalanceConfig.comboGoldBonusInterval, 10);
    });
  });
}
