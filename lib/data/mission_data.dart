/// 미니 퀘스트/미션 데이터 정의
/// 일일 미션 3개 + 도전 미션 (영구)

enum MissionCategory { daily, challenge }

enum MissionType {
  killEnemies,      // 적 N마리 처치
  killAirEnemies,   // 공중 적 N마리 처치
  killGoldenEnemies, // 황금 적 N마리 처치
  reachCombo,       // N콤보 달성
  reachDistance,    // N미터 도달
  collectCoins,    // 코인 N개 수집
  killBoss,        // 보스 N마리 처치
  noObstacleRun,   // 장애물 0충돌로 Nm
  openTreasure,    // 보물상자 N개 열기
  killBossFast,    // 보스 N초 내 처치
}

class MissionData {
  final String id;
  final String name;
  final String description;
  final MissionType type;
  final MissionCategory category;
  final int target;
  final double coinReward;
  final int soulReward;

  const MissionData({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.category,
    required this.target,
    this.coinReward = 0,
    this.soulReward = 0,
  });
}

class MissionDatabase {
  /// 일일 미션 풀 — 매일 3개 랜덤 선택
  static const List<MissionData> dailyPool = [
    // 전투 계열
    MissionData(
      id: 'd_kill_20', name: 'Hunter',
      description: 'Kill 20 enemies', type: MissionType.killEnemies,
      category: MissionCategory.daily, target: 20, coinReward: 300,
    ),
    MissionData(
      id: 'd_kill_50', name: 'Slayer',
      description: 'Kill 50 enemies', type: MissionType.killEnemies,
      category: MissionCategory.daily, target: 50, coinReward: 600,
    ),
    MissionData(
      id: 'd_air_10', name: 'Sky Strike',
      description: 'Kill 10 air enemies', type: MissionType.killAirEnemies,
      category: MissionCategory.daily, target: 10, coinReward: 400,
    ),
    MissionData(
      id: 'd_golden_3', name: 'Gold Rush',
      description: 'Kill 3 golden enemies', type: MissionType.killGoldenEnemies,
      category: MissionCategory.daily, target: 3, coinReward: 500,
    ),
    // 콤보 계열
    MissionData(
      id: 'd_combo_15', name: 'Combo Star',
      description: 'Reach 15 combo', type: MissionType.reachCombo,
      category: MissionCategory.daily, target: 15, coinReward: 350,
    ),
    MissionData(
      id: 'd_combo_30', name: 'Combo Master',
      description: 'Reach 30 combo', type: MissionType.reachCombo,
      category: MissionCategory.daily, target: 30, coinReward: 700,
    ),
    // 거리 계열
    MissionData(
      id: 'd_dist_200', name: 'Runner',
      description: 'Run 200m', type: MissionType.reachDistance,
      category: MissionCategory.daily, target: 200, coinReward: 250,
    ),
    MissionData(
      id: 'd_dist_500', name: 'Marathon',
      description: 'Run 500m', type: MissionType.reachDistance,
      category: MissionCategory.daily, target: 500, coinReward: 500,
    ),
    // 경제 계열
    MissionData(
      id: 'd_coins_500', name: 'Collector',
      description: 'Collect 500 coins', type: MissionType.collectCoins,
      category: MissionCategory.daily, target: 500, coinReward: 300,
    ),
    MissionData(
      id: 'd_coins_2000', name: 'Treasure Hoarder',
      description: 'Collect 2000 coins', type: MissionType.collectCoins,
      category: MissionCategory.daily, target: 2000, coinReward: 800,
    ),
    // 보스 계열
    MissionData(
      id: 'd_boss_1', name: 'Boss Slayer',
      description: 'Defeat a boss', type: MissionType.killBoss,
      category: MissionCategory.daily, target: 1, coinReward: 600,
    ),
    // 보물상자
    MissionData(
      id: 'd_box_3', name: 'Unboxer',
      description: 'Open 3 treasure boxes', type: MissionType.openTreasure,
      category: MissionCategory.daily, target: 3, coinReward: 400,
    ),
  ];

  /// 도전 미션 (영구, 한번만 완료)
  static const List<MissionData> challenges = [
    MissionData(
      id: 'c_combo_50', name: 'Combo Legend',
      description: 'Reach 50 combo in one run',
      type: MissionType.reachCombo, category: MissionCategory.challenge,
      target: 50, coinReward: 2000, soulReward: 1,
    ),
    MissionData(
      id: 'c_combo_100', name: 'Combo God',
      description: 'Reach 100 combo in one run',
      type: MissionType.reachCombo, category: MissionCategory.challenge,
      target: 100, coinReward: 5000, soulReward: 3,
    ),
    MissionData(
      id: 'c_kill_500', name: 'Exterminator',
      description: 'Kill 500 enemies total',
      type: MissionType.killEnemies, category: MissionCategory.challenge,
      target: 500, coinReward: 3000, soulReward: 2,
    ),
    MissionData(
      id: 'c_dist_2000', name: 'Ultra Runner',
      description: 'Run 2000m in one run',
      type: MissionType.reachDistance, category: MissionCategory.challenge,
      target: 2000, coinReward: 4000, soulReward: 2,
    ),
    MissionData(
      id: 'c_dist_5000', name: 'Infinity Runner',
      description: 'Run 5000m in one run',
      type: MissionType.reachDistance, category: MissionCategory.challenge,
      target: 5000, coinReward: 10000, soulReward: 5,
    ),
    MissionData(
      id: 'c_golden_25', name: 'Golden Hunter',
      description: 'Kill 25 golden enemies total',
      type: MissionType.killGoldenEnemies, category: MissionCategory.challenge,
      target: 25, coinReward: 3000, soulReward: 2,
    ),
    MissionData(
      id: 'c_boss_10', name: 'Boss Crusher',
      description: 'Defeat 10 bosses total',
      type: MissionType.killBoss, category: MissionCategory.challenge,
      target: 10, coinReward: 5000, soulReward: 3,
    ),
    MissionData(
      id: 'c_boss_fast', name: 'Speed Kill',
      description: 'Defeat a boss within 5 seconds',
      type: MissionType.killBossFast, category: MissionCategory.challenge,
      target: 5, coinReward: 3000, soulReward: 2,
    ),
    MissionData(
      id: 'c_air_100', name: 'Skyborn',
      description: 'Kill 100 air enemies total',
      type: MissionType.killAirEnemies, category: MissionCategory.challenge,
      target: 100, coinReward: 4000, soulReward: 2,
    ),
    MissionData(
      id: 'c_box_30', name: 'Treasure Master',
      description: 'Open 30 treasure boxes total',
      type: MissionType.openTreasure, category: MissionCategory.challenge,
      target: 30, coinReward: 5000, soulReward: 3,
    ),
  ];

  static MissionData? get(String id) {
    for (final m in dailyPool) {
      if (m.id == id) return m;
    }
    for (final m in challenges) {
      if (m.id == id) return m;
    }
    return null;
  }
}
