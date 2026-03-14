import 'package:shared_preferences/shared_preferences.dart';

/// Daily challenge & login reward system.
/// Tracks login streak, daily/weekly challenge completion, and login history.
class DailyManager {
  static const String _prefix = 'daily_';
  static const String _keyLastLogin = '${_prefix}lastLogin';
  static const String _keyStreak = '${_prefix}streak';
  static const String _keyTodayClaimed = '${_prefix}todayClaimed';
  static const String _keyChallengeComplete = '${_prefix}challengeComplete';
  static const String _keyChallengeWave = '${_prefix}challengeWave';
  static const String _keyWeeklyComplete = '${_prefix}weeklyComplete';
  static const String _keyWeekNumber = '${_prefix}weekNumber';
  static const String _keyLoginHistory = '${_prefix}loginHistory';

  late SharedPreferences _prefs;

  // Login streak (30-day cycle)
  static const List<int> streakRewards = [
    // Week 1: 50-100
    50, 60, 70, 80, 90, 100, 150,
    // Week 2: 100-200
    100, 110, 120, 130, 140, 150, 250,
    // Week 3: 150-300
    150, 160, 170, 180, 190, 200, 350,
    // Week 4+: 200-500
    200, 220, 240, 260, 280, 300, 500,
  ];

  // Milestone bonus rewards at specific streak days
  static const Map<int, int> _milestones = {
    7: 100,
    14: 200,
    21: 300,
    30: 500,
  };

  Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
    _checkNewDay();
    _checkNewWeek();
  }

  void _checkNewDay() {
    final lastLogin = _prefs.getString(_keyLastLogin) ?? '';
    final today = _todayString();
    if (lastLogin != today) {
      // New day!
      if (lastLogin == _yesterdayString()) {
        // Consecutive day
        streak = (streak % 30) + 1;
      } else if (lastLogin.isEmpty) {
        streak = 1;
      } else {
        // Streak broken
        streak = 1;
      }
      _prefs.setString(_keyLastLogin, today);
      _prefs.setBool(_keyTodayClaimed, false);
      _prefs.setBool(_keyChallengeComplete, false);
      _recordLoginHistory(today);
    }
  }

  void _checkNewWeek() {
    final currentWeek = _currentWeekNumber();
    final storedWeek = _prefs.getInt(_keyWeekNumber) ?? 0;
    if (currentWeek != storedWeek) {
      _prefs.setInt(_keyWeekNumber, currentWeek);
      _prefs.setBool(_keyWeeklyComplete, false);
    }
  }

  int _currentWeekNumber() {
    final now = DateTime.now().toUtc();
    // ISO week number calculation
    final jan1 = DateTime.utc(now.year, 1, 1);
    final dayOfYear = now.difference(jan1).inDays + 1;
    return ((dayOfYear - now.weekday + 10) / 7).floor();
  }

  String _todayString() {
    final now = DateTime.now().toUtc();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _yesterdayString() {
    final yesterday = DateTime.now().toUtc().subtract(const Duration(days: 1));
    return '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
  }

  int get streak => _prefs.getInt(_keyStreak) ?? 0;
  set streak(int v) => _prefs.setInt(_keyStreak, v);

  bool get todayClaimed => _prefs.getBool(_keyTodayClaimed) ?? false;
  bool get challengeComplete => _prefs.getBool(_keyChallengeComplete) ?? false;
  bool get isWeeklyChallengeComplete =>
      _prefs.getBool(_keyWeeklyComplete) ?? false;

  /// Whether the user has unclaimed daily rewards.
  bool get hasUnclaimedReward => !todayClaimed && streak > 0;

  /// Get today's reward amount (stars).
  int get todayReward {
    final idx = ((streak - 1) % 30).clamp(0, 27);
    return streakRewards[idx];
  }

  /// Milestone bonus for current streak day. Returns 0 if not a milestone day.
  int get milestoneBonus => _milestones[streak] ?? 0;

  /// Claim today's daily reward. Returns stars earned.
  int claimDailyReward() {
    if (todayClaimed) return 0;
    _prefs.setBool(_keyTodayClaimed, true);
    return todayReward;
  }

  /// Get daily challenge target wave (based on date seed).
  int get challengeTargetWave {
    final seed = _todayString().hashCode;
    // Target between wave 15-30
    return 15 + (seed.abs() % 16);
  }

  /// Mark daily challenge as complete.
  void completeChallenge() {
    _prefs.setBool(_keyChallengeComplete, true);
  }

  /// Daily challenge star bonus (2x normal).
  int get challengeBonus => challengeComplete ? 0 : challengeTargetWave * 2;

  // --- Weekly Challenge ---

  /// Get weekly challenge target wave (25-40, based on week seed).
  int get weeklyTargetWave {
    final seed = _currentWeekNumber().hashCode;
    return 25 + (seed.abs() % 16);
  }

  /// Weekly challenge star bonus (3x daily bonus).
  int get weeklyBonus =>
      isWeeklyChallengeComplete ? 0 : weeklyTargetWave * 6;

  /// Mark weekly challenge as complete.
  void completeWeeklyChallenge() {
    _prefs.setBool(_keyWeeklyComplete, true);
  }

  int get weekNumber => _prefs.getInt(_keyWeekNumber) ?? 0;

  // --- Login History ---

  void _recordLoginHistory(String today) {
    final history = _prefs.getString(_keyLoginHistory) ?? '';
    final dates =
        history.isEmpty ? <String>[] : history.split(',');
    if (!dates.contains(today)) {
      dates.add(today);
    }
    // Keep only last 60 entries to avoid unbounded growth
    if (dates.length > 60) {
      dates.removeRange(0, dates.length - 60);
    }
    _prefs.setString(_keyLoginHistory, dates.join(','));
  }

  /// Returns last 30 days login status (index 0 = 29 days ago, index 29 = today).
  List<bool> get loginHistory {
    final history = _prefs.getString(_keyLoginHistory) ?? '';
    final dates =
        history.isEmpty ? <String>{} : history.split(',').toSet();
    final now = DateTime.now().toUtc();
    return List.generate(30, (i) {
      final day = now.subtract(Duration(days: 29 - i));
      final key =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      return dates.contains(key);
    });
  }
}
