import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// A single leaderboard run entry.
class LeaderboardEntry {
  final int wave;
  final int kills;
  final int gold;
  final String rank; // F, D, C, B, A, S, SS
  final int stars;
  final DateTime timestamp;
  final int maxCombo;
  final int bossKills;
  final List<String> relicIds;

  const LeaderboardEntry({
    required this.wave,
    required this.kills,
    required this.gold,
    required this.rank,
    required this.stars,
    required this.timestamp,
    required this.maxCombo,
    required this.bossKills,
    required this.relicIds,
  });

  Map<String, dynamic> toJson() => {
        'wave': wave,
        'kills': kills,
        'gold': gold,
        'rank': rank,
        'stars': stars,
        'timestamp': timestamp.toIso8601String(),
        'maxCombo': maxCombo,
        'bossKills': bossKills,
        'relicIds': relicIds,
      };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      wave: json['wave'] as int,
      kills: json['kills'] as int,
      gold: json['gold'] as int,
      rank: json['rank'] as String,
      stars: json['stars'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      maxCombo: json['maxCombo'] as int,
      bossKills: json['bossKills'] as int,
      relicIds: (json['relicIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }
}

/// Manages a local leaderboard of top 20 runs.
/// Uses SharedPreferences for persistent storage.
class LeaderboardManager {
  static const String _key = 'defense_leaderboard';
  static const int _maxEntries = 20;

  late SharedPreferences _prefs;
  List<LeaderboardEntry> _entries = [];

  /// Initialize from SharedPreferences. Must be called before other methods.
  Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
    _load();
  }

  // === Core API ===

  /// Insert a new entry, keep sorted by wave descending, cap at top 20.
  void addEntry(LeaderboardEntry entry) {
    _entries.add(entry);
    _entries.sort((a, b) => b.wave.compareTo(a.wave));
    if (_entries.length > _maxEntries) {
      _entries = _entries.sublist(0, _maxEntries);
    }
    _save();
  }

  /// All entries sorted by wave descending.
  List<LeaderboardEntry> get entries => List.unmodifiable(_entries);

  /// The highest wave run, or null if no entries.
  LeaderboardEntry? get bestRun => _entries.isEmpty ? null : _entries.first;

  /// Average wave across all recorded runs.
  double get averageWave {
    if (_entries.isEmpty) return 0.0;
    final total = _entries.fold<int>(0, (sum, e) => sum + e.wave);
    return total / _entries.length;
  }

  /// Total number of recorded runs (up to 20).
  int get totalRunsRecorded => _entries.length;

  /// Whether the given wave would place in the top 3.
  bool isTopRun(int wave) {
    if (_entries.length < 3) return true;
    return wave > _entries[2].wave;
  }

  // === Statistics ===

  /// Longest streak of consecutive runs where wave improved over the previous.
  int get longestWinStreak {
    if (_entries.length < 2) return _entries.length;

    // Sort by timestamp ascending to check chronological improvement.
    final chronological = List<LeaderboardEntry>.from(_entries)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    int longest = 1;
    int current = 1;
    for (int i = 1; i < chronological.length; i++) {
      if (chronological[i].wave >= chronological[i - 1].wave) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 1;
      }
    }
    return longest;
  }

  /// Count of each rank (F, D, C, B, A, S, SS) across all entries.
  Map<String, int> get rankDistribution {
    final dist = <String, int>{
      'F': 0,
      'D': 0,
      'C': 0,
      'B': 0,
      'A': 0,
      'S': 0,
      'SS': 0,
    };
    for (final entry in _entries) {
      dist[entry.rank] = (dist[entry.rank] ?? 0) + 1;
    }
    return dist;
  }

  // === Persistence ===

  void _save() {
    final jsonList = _entries.map((e) => e.toJson()).toList();
    _prefs.setString(_key, jsonEncode(jsonList));
  }

  void _load() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      _entries = [];
      return;
    }
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _entries = decoded
          .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      _entries.sort((a, b) => b.wave.compareTo(a.wave));
    } catch (_) {
      _entries = [];
    }
  }
}
