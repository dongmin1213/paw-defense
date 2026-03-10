import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Achievement definition.
class AchievementDef {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int starReward;
  final AchievementType type;
  final int target;

  const AchievementDef({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.starReward,
    required this.type,
    required this.target,
  });
}

enum AchievementType {
  kills,
  waves,
  merges,
  combos,
  relics,
  bosses,
  hybrids,
  gold,
}

/// Master list of all achievements.
class AchievementDatabase {
  AchievementDatabase._();

  static const List<AchievementDef> all = [
    // ── Kill achievements ──
    AchievementDef(id: 'kill_100', name: '초보 사냥꾼', description: '적 100마리 처치', icon: '🗡️', starReward: 5, type: AchievementType.kills, target: 100),
    AchievementDef(id: 'kill_500', name: '숙련 전사', description: '적 500마리 처치', icon: '⚔️', starReward: 10, type: AchievementType.kills, target: 500),
    AchievementDef(id: 'kill_1000', name: '학살자', description: '적 1,000마리 처치', icon: '💀', starReward: 20, type: AchievementType.kills, target: 1000),
    AchievementDef(id: 'kill_5000', name: '전장의 왕', description: '적 5,000마리 처치', icon: '👑', starReward: 50, type: AchievementType.kills, target: 5000),
    AchievementDef(id: 'kill_10000', name: '전설의 영웅', description: '적 10,000마리 처치', icon: '🏆', starReward: 100, type: AchievementType.kills, target: 10000),

    // ── Wave achievements ──
    AchievementDef(id: 'wave_10', name: '10파 돌파', description: '웨이브 10 도달', icon: '🌊', starReward: 5, type: AchievementType.waves, target: 10),
    AchievementDef(id: 'wave_20', name: '20파 돌파', description: '웨이브 20 도달', icon: '🌊', starReward: 15, type: AchievementType.waves, target: 20),
    AchievementDef(id: 'wave_30', name: '30파 돌파', description: '웨이브 30 도달', icon: '🌊', starReward: 30, type: AchievementType.waves, target: 30),
    AchievementDef(id: 'wave_50', name: '50파 돌파', description: '웨이브 50 도달', icon: '🏅', starReward: 50, type: AchievementType.waves, target: 50),

    // ── Combo achievements ──
    AchievementDef(id: 'combo_10', name: '콤보 초보', description: '10 콤보 달성', icon: '🔥', starReward: 5, type: AchievementType.combos, target: 10),
    AchievementDef(id: 'combo_25', name: '콤보 마스터', description: '25 콤보 달성', icon: '🔥', starReward: 10, type: AchievementType.combos, target: 25),
    AchievementDef(id: 'combo_50', name: '콤보 킹', description: '50 콤보 달성', icon: '💥', starReward: 20, type: AchievementType.combos, target: 50),
    AchievementDef(id: 'combo_100', name: '콤보 갓', description: '100 콤보 달성', icon: '⚡', starReward: 50, type: AchievementType.combos, target: 100),

    // ── Boss achievements ──
    AchievementDef(id: 'boss_1', name: '첫 보스 처치', description: '보스 1마리 처치', icon: '👹', starReward: 5, type: AchievementType.bosses, target: 1),
    AchievementDef(id: 'boss_5', name: '보스 사냥꾼', description: '보스 5마리 처치', icon: '👹', starReward: 15, type: AchievementType.bosses, target: 5),
    AchievementDef(id: 'boss_10', name: '보스 슬레이어', description: '보스 10마리 처치', icon: '🐲', starReward: 30, type: AchievementType.bosses, target: 10),

    // ── Hybrid achievements ──
    AchievementDef(id: 'hybrid_1', name: '첫 하이브리드', description: '하이브리드 유닛 1마리 생성', icon: '🧬', starReward: 10, type: AchievementType.hybrids, target: 1),
    AchievementDef(id: 'hybrid_5', name: '교배 전문가', description: '하이브리드 유닛 5마리 생성', icon: '🧬', starReward: 25, type: AchievementType.hybrids, target: 5),
    AchievementDef(id: 'hybrid_12', name: '하이브리드 마스터', description: '모든 하이브리드 발견', icon: '🌈', starReward: 100, type: AchievementType.hybrids, target: 12),

    // ── Gold achievements ──
    AchievementDef(id: 'gold_1000', name: '부자', description: '한 런에서 골드 1,000 획득', icon: '💰', starReward: 10, type: AchievementType.gold, target: 1000),
    AchievementDef(id: 'gold_5000', name: '재벌', description: '한 런에서 골드 5,000 획득', icon: '💎', starReward: 30, type: AchievementType.gold, target: 5000),
  ];

  static final Map<String, AchievementDef> _byId = {
    for (final a in all) a.id: a,
  };

  static AchievementDef? get(String id) => _byId[id];
}

/// Manages achievement progress and completion state.
class AchievementManager {
  final Map<String, bool> _completed = {};
  final Map<String, int> _progress = {};

  // Cumulative stats tracked for achievements
  int totalHybridsCreated = 0;

  /// Whether an achievement has been completed.
  bool isCompleted(String id) => _completed[id] ?? false;

  /// Current progress toward an achievement.
  int getProgress(String id) => _progress[id] ?? 0;

  /// Update progress for a stat type. Returns list of newly completed achievement IDs.
  List<String> updateProgress(AchievementType type, int value) {
    final newlyCompleted = <String>[];
    for (final def in AchievementDatabase.all) {
      if (def.type != type) continue;
      if (isCompleted(def.id)) continue;

      _progress[def.id] = value;
      if (value >= def.target) {
        _completed[def.id] = true;
        newlyCompleted.add(def.id);
      }
    }
    return newlyCompleted;
  }

  /// Get total star reward from all completed achievements.
  int get totalStarReward {
    int total = 0;
    for (final def in AchievementDatabase.all) {
      if (isCompleted(def.id)) {
        total += def.starReward;
      }
    }
    return total;
  }

  /// Get completion percentage (0.0 ~ 1.0).
  double get completionPercent {
    if (AchievementDatabase.all.isEmpty) return 0.0;
    final completed = AchievementDatabase.all.where((a) => isCompleted(a.id)).length;
    return completed / AchievementDatabase.all.length;
  }

  /// Get list of uncompleted achievements.
  List<AchievementDef> get uncompletedAchievements =>
      AchievementDatabase.all.where((a) => !isCompleted(a.id)).toList();

  /// Get list of completed achievements.
  List<AchievementDef> get completedAchievements =>
      AchievementDatabase.all.where((a) => isCompleted(a.id)).toList();

  // ── Persistence ──
  static const String _saveKey = 'defense_achievements';
  static const String _progressKey = 'defense_achievement_progress';
  static const String _hybridCountKey = 'defense_hybrid_count';

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final completedIds = _completed.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    await prefs.setString(_saveKey, jsonEncode(completedIds));

    final progressMap = _progress.map((k, v) => MapEntry(k, v));
    await prefs.setString(_progressKey, jsonEncode(progressMap));
    await prefs.setInt(_hybridCountKey, totalHybridsCreated);
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final completedJson = prefs.getString(_saveKey);
    if (completedJson != null) {
      final List<dynamic> ids = jsonDecode(completedJson);
      for (final id in ids) {
        _completed[id as String] = true;
      }
    }

    final progressJson = prefs.getString(_progressKey);
    if (progressJson != null) {
      final Map<String, dynamic> map = jsonDecode(progressJson);
      for (final entry in map.entries) {
        _progress[entry.key] = (entry.value as num).toInt();
      }
    }

    totalHybridsCreated = prefs.getInt(_hybridCountKey) ?? 0;
  }
}
