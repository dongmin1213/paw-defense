import 'package:shared_preferences/shared_preferences.dart';

/// Daily challenge & login reward system.
/// Tracks login streak and daily challenge completion.
class DailyManager {
  static const String _prefix = 'daily_';
  static const String _keyLastLogin = '${_prefix}lastLogin';
  static const String _keyStreak = '${_prefix}streak';
  static const String _keyTodayClaimed = '${_prefix}todayClaimed';
  static const String _keyChallengeComplete = '${_prefix}challengeComplete';
  static const String _keyChallengeWave = '${_prefix}challengeWave';

  late SharedPreferences _prefs;

  // Login streak (7-day cycle)
  static const List<int> streakRewards = [50, 75, 100, 125, 150, 200, 500];

  Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
    _checkNewDay();
  }

  void _checkNewDay() {
    final lastLogin = _prefs.getString(_keyLastLogin) ?? '';
    final today = _todayString();
    if (lastLogin != today) {
      // New day!
      if (lastLogin == _yesterdayString()) {
        // Consecutive day
        streak = (streak % 7) + 1;
      } else if (lastLogin.isEmpty) {
        streak = 1;
      } else {
        // Streak broken
        streak = 1;
      }
      _prefs.setString(_keyLastLogin, today);
      _prefs.setBool(_keyTodayClaimed, false);
      _prefs.setBool(_keyChallengeComplete, false);
    }
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

  /// Whether the user has unclaimed daily rewards.
  bool get hasUnclaimedReward => !todayClaimed && streak > 0;

  /// Get today's reward amount (stars).
  int get todayReward {
    final idx = ((streak - 1) % 7).clamp(0, 6);
    return streakRewards[idx];
  }

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
}
