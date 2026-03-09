/// 업적 데이터 정의 — Idle Slayer 스타일 마일스톤 업적
enum AchievementCategory {
  combat,    // 전투 관련
  economy,   // 코인/경제
  progress,  // 진행도
  collection,// 수집
  special,   // 특수 조건
}

class AchievementData {
  final String id;
  final String name;
  final String description;
  final AchievementCategory category;
  final IconType iconType;
  final double coinReward;   // 코인 보상
  final int soulReward;      // 소울 보상 (0이면 없음)

  const AchievementData({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.iconType = IconType.star,
    this.coinReward = 0,
    this.soulReward = 0,
  });
}

enum IconType {
  star,
  sword,
  coin,
  run,
  trophy,
  fire,
  pet,
  crown,
  magic,
  shield,
}

class AchievementDatabase {
  static const List<AchievementData> achievements = [
    // ── 전투 ──
    AchievementData(id: 'kill_10', name: '초보 사냥꾼', description: '적 10마리 처치',
        category: AchievementCategory.combat, iconType: IconType.sword, coinReward: 50),
    AchievementData(id: 'kill_100', name: '숙련 전사', description: '적 100마리 처치',
        category: AchievementCategory.combat, iconType: IconType.sword, coinReward: 500),
    AchievementData(id: 'kill_500', name: '베테랑 전사', description: '적 500마리 처치',
        category: AchievementCategory.combat, iconType: IconType.sword, coinReward: 2000),
    AchievementData(id: 'kill_1000', name: '전설의 전사', description: '적 1,000마리 처치',
        category: AchievementCategory.combat, iconType: IconType.sword, coinReward: 5000, soulReward: 1),
    AchievementData(id: 'kill_5000', name: '멸망의 검', description: '적 5,000마리 처치',
        category: AchievementCategory.combat, iconType: IconType.crown, coinReward: 20000, soulReward: 3),
    AchievementData(id: 'kill_10000', name: '학살자', description: '적 10,000마리 처치',
        category: AchievementCategory.combat, iconType: IconType.crown, coinReward: 50000, soulReward: 5),
    AchievementData(id: 'boss_1', name: '보스 슬레이어', description: '보스 1마리 처치',
        category: AchievementCategory.combat, iconType: IconType.trophy, coinReward: 200),
    AchievementData(id: 'boss_5', name: '보스 헌터', description: '보스 5마리 처치',
        category: AchievementCategory.combat, iconType: IconType.trophy, coinReward: 1000, soulReward: 1),
    AchievementData(id: 'boss_20', name: '보스 마스터', description: '보스 20마리 처치',
        category: AchievementCategory.combat, iconType: IconType.trophy, coinReward: 5000, soulReward: 3),
    AchievementData(id: 'combo_10', name: '콤보 입문', description: '10 콤보 달성',
        category: AchievementCategory.combat, iconType: IconType.fire, coinReward: 100),
    AchievementData(id: 'combo_30', name: '콤보 마스터', description: '30 콤보 달성',
        category: AchievementCategory.combat, iconType: IconType.fire, coinReward: 500),
    AchievementData(id: 'combo_50', name: '콤보 레전드', description: '50 콤보 달성',
        category: AchievementCategory.combat, iconType: IconType.fire, coinReward: 2000, soulReward: 1),
    AchievementData(id: 'combo_100', name: '미친 콤보', description: '100 콤보 달성',
        category: AchievementCategory.combat, iconType: IconType.crown, coinReward: 10000, soulReward: 5),
    AchievementData(id: 'golden_1', name: '황금의 기회', description: '황금 적 1마리 처치',
        category: AchievementCategory.combat, iconType: IconType.coin, coinReward: 200),
    AchievementData(id: 'golden_10', name: '골든 헌터', description: '황금 적 10마리 처치',
        category: AchievementCategory.combat, iconType: IconType.coin, coinReward: 2000),
    AchievementData(id: 'golden_50', name: '황금 사냥꾼', description: '황금 적 50마리 처치',
        category: AchievementCategory.combat, iconType: IconType.crown, coinReward: 10000, soulReward: 2),
    AchievementData(id: 'air_10', name: '에어 킬러', description: '공중 적 10마리 처치',
        category: AchievementCategory.combat, iconType: IconType.sword, coinReward: 150),
    AchievementData(id: 'air_100', name: '스카이 마스터', description: '공중 적 100마리 처치',
        category: AchievementCategory.combat, iconType: IconType.sword, coinReward: 1500, soulReward: 1),

    // ── 경제 ──
    AchievementData(id: 'coin_100', name: '동전 줍기', description: '코인 100개 획득',
        category: AchievementCategory.economy, iconType: IconType.coin, coinReward: 50),
    AchievementData(id: 'coin_1000', name: '부자의 길', description: '코인 1,000개 획득',
        category: AchievementCategory.economy, iconType: IconType.coin, coinReward: 200),
    AchievementData(id: 'coin_10k', name: '만수르', description: '코인 10,000개 획득',
        category: AchievementCategory.economy, iconType: IconType.coin, coinReward: 1000),
    AchievementData(id: 'coin_100k', name: '재벌', description: '코인 100,000개 획득',
        category: AchievementCategory.economy, iconType: IconType.coin, coinReward: 5000, soulReward: 2),
    AchievementData(id: 'coin_1m', name: '코인 킹', description: '코인 1,000,000개 획득',
        category: AchievementCategory.economy, iconType: IconType.crown, coinReward: 20000, soulReward: 5),
    AchievementData(id: 'upgrade_5', name: '성장 시작', description: '업그레이드 5회 구매',
        category: AchievementCategory.economy, iconType: IconType.star, coinReward: 100),
    AchievementData(id: 'upgrade_25', name: '강화 매니아', description: '업그레이드 25회 구매',
        category: AchievementCategory.economy, iconType: IconType.star, coinReward: 500),
    AchievementData(id: 'upgrade_100', name: '업그레이드 중독', description: '업그레이드 100회 구매',
        category: AchievementCategory.economy, iconType: IconType.star, coinReward: 2000, soulReward: 1),

    // ── 진행도 ──
    AchievementData(id: 'dist_100', name: '산책', description: '100m 달리기',
        category: AchievementCategory.progress, iconType: IconType.run, coinReward: 30),
    AchievementData(id: 'dist_500', name: '조깅', description: '500m 달리기',
        category: AchievementCategory.progress, iconType: IconType.run, coinReward: 100),
    AchievementData(id: 'dist_1000', name: '마라토너', description: '1,000m 달리기',
        category: AchievementCategory.progress, iconType: IconType.run, coinReward: 300),
    AchievementData(id: 'dist_5000', name: '울트라 러너', description: '5,000m 달리기',
        category: AchievementCategory.progress, iconType: IconType.run, coinReward: 1000, soulReward: 1),
    AchievementData(id: 'dist_10000', name: '무한 질주', description: '10,000m 달리기',
        category: AchievementCategory.progress, iconType: IconType.crown, coinReward: 5000, soulReward: 3),
    AchievementData(id: 'ascend_1', name: '초월자', description: '첫 번째 초월',
        category: AchievementCategory.progress, iconType: IconType.magic, coinReward: 0, soulReward: 2),
    AchievementData(id: 'ascend_3', name: '전생 마스터', description: '3회 초월',
        category: AchievementCategory.progress, iconType: IconType.magic, coinReward: 0, soulReward: 5),
    AchievementData(id: 'ascend_10', name: '윤회의 지배자', description: '10회 초월',
        category: AchievementCategory.progress, iconType: IconType.crown, coinReward: 0, soulReward: 10),

    // ── 수집 ──
    AchievementData(id: 'companion_1', name: '첫 동료', description: '동료 1마리 획득',
        category: AchievementCategory.collection, iconType: IconType.pet, coinReward: 200),
    AchievementData(id: 'companion_5', name: '동물 애호가', description: '동료 5마리 획득',
        category: AchievementCategory.collection, iconType: IconType.pet, coinReward: 1000, soulReward: 1),
    AchievementData(id: 'companion_all', name: '동물원장', description: '모든 동료 획득',
        category: AchievementCategory.collection, iconType: IconType.crown, coinReward: 10000, soulReward: 5),
    AchievementData(id: 'region_2', name: '모험가', description: '2개 지역 해금',
        category: AchievementCategory.collection, iconType: IconType.run, coinReward: 500),
    AchievementData(id: 'region_all', name: '세계 정복자', description: '모든 지역 해금',
        category: AchievementCategory.collection, iconType: IconType.crown, coinReward: 20000, soulReward: 10),

    // ── 특수 ──
    AchievementData(id: 'box_1', name: '보물 사냥꾼', description: '보물상자 1개 열기',
        category: AchievementCategory.special, iconType: IconType.star, coinReward: 100),
    AchievementData(id: 'box_10', name: '트레저 헌터', description: '보물상자 10개 열기',
        category: AchievementCategory.special, iconType: IconType.star, coinReward: 1000),
    AchievementData(id: 'box_50', name: '보물 마스터', description: '보물상자 50개 열기',
        category: AchievementCategory.special, iconType: IconType.crown, coinReward: 5000, soulReward: 2),
    AchievementData(id: 'bonus_1', name: '보너스 타임!', description: '보너스 스테이지 1회 진입',
        category: AchievementCategory.special, iconType: IconType.trophy, coinReward: 300),
    AchievementData(id: 'bonus_10', name: '보너스 마니아', description: '보너스 스테이지 10회 진입',
        category: AchievementCategory.special, iconType: IconType.trophy, coinReward: 3000, soulReward: 2),
    AchievementData(id: 'daily_7', name: '성실한 러너', description: '7일 연속 출석',
        category: AchievementCategory.special, iconType: IconType.shield, coinReward: 1000),
    AchievementData(id: 'daily_30', name: '한 달의 약속', description: '30일 연속 출석',
        category: AchievementCategory.special, iconType: IconType.crown, coinReward: 10000, soulReward: 5),
  ];

  static AchievementData? get(String id) {
    try {
      return achievements.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<AchievementData> getByCategory(AchievementCategory category) {
    return achievements.where((a) => a.category == category).toList();
  }
}
