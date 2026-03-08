import '../data/balance_config.dart';
import '../systems/upgrade_manager.dart';
import '../systems/ascension_manager.dart';
import '../systems/companion_manager.dart';

class OfflineRewardResult {
  final double coins;
  final int elapsedSeconds;
  final double cps;

  const OfflineRewardResult({
    required this.coins,
    required this.elapsedSeconds,
    required this.cps,
  });
}

class OfflineReward {
  /// Calculate offline earnings based on CpS and elapsed time
  static OfflineRewardResult calculate({
    required int lastOnlineTime,
    required UpgradeManager upgradeManager,
    required AscensionManager ascensionManager,
    required CompanionManager companionManager,
    required double regionCoinMultiplier,
  }) {
    if (lastOnlineTime == 0) {
      return const OfflineRewardResult(coins: 0, elapsedSeconds: 0, cps: 0);
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsed = ((now - lastOnlineTime) / 1000).floor();

    // Minimum 60 seconds to show offline reward
    if (elapsed < 60) {
      return const OfflineRewardResult(coins: 0, elapsedSeconds: 0, cps: 0);
    }

    // Cap at 24 hours (86400 seconds)
    final cappedElapsed = elapsed.clamp(0, 86400);

    // Estimate CpS: assume ~2 ground enemies per second, each drops base 1 coin
    const baseEnemiesPerSecond = 2.0;
    const baseCoinPerEnemy = 1.0;

    final coinMultiplier = upgradeManager.coinMultiplier;
    final soulCoinMultiplier = ascensionManager.soulCoinMultiplier;
    final companionCoinMultiplier = companionManager.coinMultiplier;
    final offlineEfficiencyUpgrade = ascensionManager.offlineEfficiencyBonus;

    final cps = baseEnemiesPerSecond *
        baseCoinPerEnemy *
        regionCoinMultiplier *
        coinMultiplier *
        soulCoinMultiplier *
        companionCoinMultiplier *
        BalanceConfig.offlineEfficiency *
        (1.0 + offlineEfficiencyUpgrade);

    final totalCoins = cps * cappedElapsed;

    return OfflineRewardResult(
      coins: totalCoins,
      elapsedSeconds: cappedElapsed,
      cps: cps,
    );
  }

  static String formatDuration(int seconds) {
    if (seconds >= 3600) {
      final hours = seconds ~/ 3600;
      final mins = (seconds % 3600) ~/ 60;
      return '${hours}시간 ${mins}분';
    } else if (seconds >= 60) {
      final mins = seconds ~/ 60;
      return '$mins분';
    }
    return '$seconds초';
  }
}
