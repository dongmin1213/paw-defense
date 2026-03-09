import 'dart:math';
import '../data/mission_data.dart';

/// 미니 퀘스트/미션 시스템 매니저
/// - 일일 미션 3개 (매일 리셋)
/// - 도전 미션 (영구, 한번만 완료)
class MissionManager {
  // 일일 미션 (3개)
  final List<ActiveMission> _dailyMissions = [];
  int _lastDailyResetDay = 0; // yyyyMMdd 형태

  // 도전 미션 진행
  final Map<String, int> _challengeProgress = {};
  final Set<String> _completedChallenges = {};

  // 세션 카운터 (일일 미션 추적용)
  int _sessionKills = 0;
  int _sessionAirKills = 0;
  int _sessionGoldenKills = 0;
  int _sessionBossKills = 0;
  int _sessionBoxes = 0;
  int _sessionMaxCombo = 0;
  double _sessionMaxDistance = 0;
  double _sessionCoinsCollected = 0;

  // 누적 카운터 (도전 미션용)
  int _totalKills = 0;
  int _totalAirKills = 0;
  int _totalGoldenKills = 0;
  int _totalBossKills = 0;
  int _totalBoxes = 0;

  // 최근 완료된 미션 (UI 알림용)
  final List<MissionData> _recentlyCompleted = [];

  // 장애물 무충돌 거리 추적
  double _noObstacleDistance = 0;
  bool _hitObstacle = false;

  // 보스 처치 시간 추적
  double _bossStartTime = 0;
  double _lastBossKillTime = 0;

  List<ActiveMission> get dailyMissions => _dailyMissions;
  Set<String> get completedChallenges => _completedChallenges;
  List<MissionData> get recentlyCompleted => _recentlyCompleted;

  int get completedDailyCount =>
      _dailyMissions.where((m) => m.isCompleted).length;

  /// 도전 미션 진행도 가져오기
  int challengeProgress(String id) {
    if (_completedChallenges.contains(id)) {
      final data = MissionDatabase.get(id);
      return data?.target ?? 0;
    }
    return _challengeProgress[id] ?? 0;
  }

  bool isChallengeCompleted(String id) => _completedChallenges.contains(id);

  /// 일일 미션 초기화/리셋 체크
  void checkDailyReset() {
    final now = DateTime.now();
    final today = now.year * 10000 + now.month * 100 + now.day;
    if (today != _lastDailyResetDay) {
      _generateDailyMissions(today);
    }
  }

  void _generateDailyMissions(int today) {
    _lastDailyResetDay = today;
    _dailyMissions.clear();
    _sessionKills = 0;
    _sessionAirKills = 0;
    _sessionGoldenKills = 0;
    _sessionBossKills = 0;
    _sessionBoxes = 0;
    _sessionMaxCombo = 0;
    _sessionMaxDistance = 0;
    _sessionCoinsCollected = 0;

    // 풀에서 3개 랜덤 선택 (시드: 날짜)
    final rng = Random(today);
    final pool = List<MissionData>.from(MissionDatabase.dailyPool);
    pool.shuffle(rng);
    for (var i = 0; i < 3 && i < pool.length; i++) {
      _dailyMissions.add(ActiveMission(data: pool[i]));
    }
  }

  // === 이벤트 핸들러 ===

  void onEnemyKill({bool isAir = false, bool isGolden = false}) {
    _sessionKills++;
    _totalKills++;
    if (isAir) {
      _sessionAirKills++;
      _totalAirKills++;
    }
    if (isGolden) {
      _sessionGoldenKills++;
      _totalGoldenKills++;
    }
    _updateProgress();
  }

  void onBossKill(double killTimeSeconds) {
    _sessionBossKills++;
    _totalBossKills++;
    _lastBossKillTime = killTimeSeconds;
    _updateProgress();
  }

  void onBossStart(double gameTime) {
    _bossStartTime = gameTime;
  }

  void onComboUpdate(int combo) {
    if (combo > _sessionMaxCombo) {
      _sessionMaxCombo = combo;
    }
    _updateProgress();
  }

  void onDistanceUpdate(double distanceM) {
    _sessionMaxDistance = distanceM;
    if (!_hitObstacle) {
      _noObstacleDistance = distanceM;
    }
    _updateProgress();
  }

  void onCoinsCollected(double amount) {
    _sessionCoinsCollected += amount;
    _updateProgress();
  }

  void onObstacleHit() {
    _hitObstacle = true;
    _noObstacleDistance = 0;
  }

  void onBoxOpened() {
    _sessionBoxes++;
    _totalBoxes++;
    _updateProgress();
  }

  void clearRecentlyCompleted() {
    _recentlyCompleted.clear();
  }

  void _updateProgress() {
    // 일일 미션 체크
    for (final mission in _dailyMissions) {
      if (mission.isCompleted) continue;
      final newProgress = _getProgressForMission(mission.data);
      if (newProgress > mission.progress) {
        mission.progress = newProgress;
        if (mission.progress >= mission.data.target) {
          mission.isCompleted = true;
          _recentlyCompleted.add(mission.data);
        }
      }
    }

    // 도전 미션 체크
    for (final challenge in MissionDatabase.challenges) {
      if (_completedChallenges.contains(challenge.id)) continue;
      final progress = _getProgressForChallenge(challenge);
      _challengeProgress[challenge.id] = progress;
      if (progress >= challenge.target) {
        _completedChallenges.add(challenge.id);
        _recentlyCompleted.add(challenge);
      }
    }
  }

  int _getProgressForMission(MissionData data) {
    switch (data.type) {
      case MissionType.killEnemies:
        return _sessionKills;
      case MissionType.killAirEnemies:
        return _sessionAirKills;
      case MissionType.killGoldenEnemies:
        return _sessionGoldenKills;
      case MissionType.reachCombo:
        return _sessionMaxCombo;
      case MissionType.reachDistance:
        return _sessionMaxDistance.floor();
      case MissionType.collectCoins:
        return _sessionCoinsCollected.floor();
      case MissionType.killBoss:
        return _sessionBossKills;
      case MissionType.noObstacleRun:
        return _noObstacleDistance.floor();
      case MissionType.openTreasure:
        return _sessionBoxes;
      case MissionType.killBossFast:
        return _lastBossKillTime > 0 && _lastBossKillTime <= data.target ? 1 : 0;
    }
  }

  int _getProgressForChallenge(MissionData data) {
    switch (data.type) {
      case MissionType.killEnemies:
        return _totalKills;
      case MissionType.killAirEnemies:
        return _totalAirKills;
      case MissionType.killGoldenEnemies:
        return _totalGoldenKills;
      case MissionType.reachCombo:
        return _sessionMaxCombo; // 한 런의 최고 콤보
      case MissionType.reachDistance:
        return _sessionMaxDistance.floor(); // 한 런의 최고 거리
      case MissionType.collectCoins:
        return _sessionCoinsCollected.floor();
      case MissionType.killBoss:
        return _totalBossKills;
      case MissionType.noObstacleRun:
        return _noObstacleDistance.floor();
      case MissionType.openTreasure:
        return _totalBoxes;
      case MissionType.killBossFast:
        return _lastBossKillTime > 0 && _lastBossKillTime <= data.target ? 1 : 0;
    }
  }

  // === 저장/로드 ===

  Map<String, dynamic> toMap() {
    return {
      'lastDailyResetDay': _lastDailyResetDay,
      'dailyMissions': _dailyMissions.map((m) => {
        'id': m.data.id,
        'progress': m.progress,
        'completed': m.isCompleted,
      }).toList(),
      'completedChallenges': _completedChallenges.toList(),
      'challengeProgress': _challengeProgress,
      'totalKills': _totalKills,
      'totalAirKills': _totalAirKills,
      'totalGoldenKills': _totalGoldenKills,
      'totalBossKills': _totalBossKills,
      'totalBoxes': _totalBoxes,
    };
  }

  void loadFromMap(Map<String, dynamic> data) {
    _lastDailyResetDay = data['lastDailyResetDay'] as int? ?? 0;
    _totalKills = data['totalKills'] as int? ?? 0;
    _totalAirKills = data['totalAirKills'] as int? ?? 0;
    _totalGoldenKills = data['totalGoldenKills'] as int? ?? 0;
    _totalBossKills = data['totalBossKills'] as int? ?? 0;
    _totalBoxes = data['totalBoxes'] as int? ?? 0;

    _completedChallenges.clear();
    final completed = data['completedChallenges'] as List<dynamic>?;
    if (completed != null) {
      _completedChallenges.addAll(completed.cast<String>());
    }

    final cpMap = data['challengeProgress'] as Map<String, dynamic>?;
    if (cpMap != null) {
      _challengeProgress.clear();
      for (final entry in cpMap.entries) {
        _challengeProgress[entry.key] = entry.value as int;
      }
    }

    // 일일 미션 복원
    _dailyMissions.clear();
    final dailyList = data['dailyMissions'] as List<dynamic>?;
    if (dailyList != null) {
      for (final item in dailyList) {
        final map = item as Map<String, dynamic>;
        final missionData = MissionDatabase.get(map['id'] as String);
        if (missionData != null) {
          _dailyMissions.add(ActiveMission(
            data: missionData,
            progress: map['progress'] as int? ?? 0,
            isCompleted: map['completed'] as bool? ?? false,
          ));
        }
      }
    }

    // 일일 리셋 체크
    checkDailyReset();
  }
}

/// 활성 미션 인스턴스 (진행도 추적)
class ActiveMission {
  final MissionData data;
  int progress;
  bool isCompleted;

  ActiveMission({
    required this.data,
    this.progress = 0,
    this.isCompleted = false,
  });
}
