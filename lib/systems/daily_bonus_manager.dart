/// 일일 보너스 / 출석 체크 시스템
class DailyBonusManager {
  int streak = 0;
  int lastClaimDay = 0; // yyyyMMdd 형식
  bool hasClaimed = false;

  /// 오늘 날짜 (yyyyMMdd)
  static int _today() {
    final now = DateTime.now();
    return now.year * 10000 + now.month * 100 + now.day;
  }

  /// 어제 날짜
  static int _yesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return yesterday.year * 10000 + yesterday.month * 100 + yesterday.day;
  }

  /// 보상 수령 가능 여부
  bool get canClaim => lastClaimDay != _today();

  /// 다음 보상 배율 (연속 출석 기반)
  double get nextRewardMultiplier {
    final nextStreak = _getNextStreak();
    return 1.0 + (nextStreak - 1) * 0.5; // Day 1: x1.0, Day 2: x1.5, Day 7: x4.0
  }

  int _getNextStreak() {
    if (lastClaimDay == _yesterday()) {
      return streak + 1;
    }
    return 1; // 연속 아니면 1부터
  }

  /// 보상 목록 (7일 주기)
  static const List<DailyReward> rewards = [
    DailyReward(day: 1, coins: 100, description: '코인 100'),
    DailyReward(day: 2, coins: 200, description: '코인 200'),
    DailyReward(day: 3, coins: 350, description: '코인 350'),
    DailyReward(day: 4, coins: 500, description: '코인 500'),
    DailyReward(day: 5, coins: 750, description: '코인 750'),
    DailyReward(day: 6, coins: 1000, description: '코인 1000'),
    DailyReward(day: 7, coins: 2000, souls: 1, description: '코인 2000 + 소울 1'),
  ];

  /// 현재 주기의 보상
  DailyReward get currentReward {
    final nextStreak = _getNextStreak();
    final dayInCycle = ((nextStreak - 1) % 7); // 0-indexed
    return rewards[dayInCycle];
  }

  /// 보상 수령 — 반환: (coinReward, soulReward, newStreak)
  DailyClaimResult claim() {
    if (!canClaim) return DailyClaimResult(coins: 0, souls: 0, streak: streak);

    final today = _today();
    final nextStreak = _getNextStreak();
    streak = nextStreak;
    lastClaimDay = today;
    hasClaimed = true;

    final reward = rewards[((streak - 1) % 7)];
    final multiplier = 1.0 + (streak - 1) * 0.5;

    return DailyClaimResult(
      coins: (reward.coins * multiplier).toInt().toDouble(),
      souls: reward.souls,
      streak: streak,
    );
  }

  // ── Save/Load ──

  Map<String, dynamic> toMap() {
    return {
      'streak': streak,
      'lastClaimDay': lastClaimDay,
    };
  }

  void loadFromMap(Map<String, dynamic> map) {
    streak = (map['streak'] as num?)?.toInt() ?? 0;
    lastClaimDay = (map['lastClaimDay'] as num?)?.toInt() ?? 0;
    hasClaimed = lastClaimDay == _today();
  }
}

class DailyReward {
  final int day;
  final int coins;
  final int souls;
  final String description;

  const DailyReward({
    required this.day,
    required this.coins,
    this.souls = 0,
    required this.description,
  });
}

class DailyClaimResult {
  final double coins;
  final int souls;
  final int streak;

  const DailyClaimResult({
    required this.coins,
    required this.souls,
    required this.streak,
  });
}
