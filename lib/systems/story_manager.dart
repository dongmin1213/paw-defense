import 'package:shared_preferences/shared_preferences.dart';

/// Story chapter definition.
class StoryChapter {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int requiredWave;
  final String? unlockReward;

  const StoryChapter({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.requiredWave,
    this.unlockReward,
  });
}

/// Story progression manager — unlocks narrative chapters at wave milestones.
/// Persisted via SharedPreferences.
class StoryManager {
  static const String _prefsKey = 'story_unlocked';

  static const List<StoryChapter> chapters = [
    StoryChapter(
      id: 'chapter_1',
      title: '어둠의 시작',
      description: '성벽에 첫 번째 그림자가 드리웁니다...',
      emoji: '🌑',
      requiredWave: 1,
    ),
    StoryChapter(
      id: 'chapter_2',
      title: '첫 번째 시련',
      description: '적들의 공세가 거세집니다',
      emoji: '⚔️',
      requiredWave: 5,
    ),
    StoryChapter(
      id: 'chapter_3',
      title: '어둠의 왕',
      description: '강력한 보스가 나타났습니다!',
      emoji: '👹',
      requiredWave: 10,
      unlockReward: '첫 번째 보스 처치 보너스 별 x10',
    ),
    StoryChapter(
      id: 'chapter_4',
      title: '숨겨진 동맹',
      description: '하이브리드 유닛의 비밀이 밝혀집니다',
      emoji: '🧬',
      requiredWave: 15,
      unlockReward: '하이브리드 머지 해금',
    ),
    StoryChapter(
      id: 'chapter_5',
      title: '절망의 벽',
      description: '성벽이 흔들리기 시작합니다...',
      emoji: '🏚️',
      requiredWave: 20,
    ),
    StoryChapter(
      id: 'chapter_6',
      title: '반격의 서막',
      description: '유물의 힘으로 반격을 시작합니다',
      emoji: '💎',
      requiredWave: 25,
      unlockReward: '유물 드롭률 소폭 증가',
    ),
    StoryChapter(
      id: 'chapter_7',
      title: '폭풍 전야',
      description: '최강의 적들이 모습을 드러냅니다',
      emoji: '🌩️',
      requiredWave: 30,
    ),
    StoryChapter(
      id: 'chapter_8',
      title: '영웅의 각성',
      description: '진화한 유닛들이 전장을 지배합니다',
      emoji: '🦁',
      requiredWave: 35,
      unlockReward: '진화 확률 소폭 증가',
    ),
    StoryChapter(
      id: 'chapter_9',
      title: '최후의 결전',
      description: '모든 것을 걸고 싸울 때입니다',
      emoji: '🔥',
      requiredWave: 40,
    ),
    StoryChapter(
      id: 'chapter_10',
      title: '전설의 시작',
      description: '당신은 이미 전설입니다',
      emoji: '⭐',
      requiredWave: 45,
      unlockReward: '전설 칭호 해금',
    ),
    StoryChapter(
      id: 'chapter_11',
      title: '끝나지 않는 전쟁',
      description: '하지만 전쟁은 계속됩니다...',
      emoji: '♾️',
      requiredWave: 50,
    ),
    StoryChapter(
      id: 'chapter_12',
      title: '신의 영역',
      description: '신조차 인정하는 수호자',
      emoji: '👼',
      requiredWave: 100,
      unlockReward: '신화 등급 칭호 해금',
    ),
  ];

  late SharedPreferences _prefs;
  final Set<String> _unlockedIds = {};

  /// Initialize from SharedPreferences.
  Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
    _load();
  }

  void _load() {
    final raw = _prefs.getString(_prefsKey) ?? '';
    if (raw.isNotEmpty) {
      _unlockedIds.addAll(raw.split(','));
    }
  }

  void _save() {
    _prefs.setString(_prefsKey, _unlockedIds.join(','));
  }

  /// All chapters that have been unlocked so far, in wave order.
  List<StoryChapter> get unlockedChapters {
    return chapters
        .where((ch) => _unlockedIds.contains(ch.id))
        .toList();
  }

  /// Check if reaching [wave] unlocks a new chapter.
  /// Returns the newly unlocked chapter, or null if nothing new.
  StoryChapter? checkWaveUnlock(int wave) {
    for (final chapter in chapters) {
      if (chapter.requiredWave <= wave && !_unlockedIds.contains(chapter.id)) {
        _unlockedIds.add(chapter.id);
        _save();
        return chapter;
      }
    }
    return null;
  }

  /// Whether a specific chapter has been unlocked.
  bool isUnlocked(String chapterId) => _unlockedIds.contains(chapterId);

  /// Completion percentage (0.0 – 1.0).
  double get completionPercent {
    if (chapters.isEmpty) return 1.0;
    return _unlockedIds.length / chapters.length;
  }

  /// The next locked chapter (lowest requiredWave among locked chapters).
  StoryChapter? get nextChapter {
    for (final chapter in chapters) {
      if (!_unlockedIds.contains(chapter.id)) {
        return chapter;
      }
    }
    return null;
  }
}
