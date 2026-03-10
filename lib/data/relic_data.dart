/// Relic rarity tiers with drop weight.
enum RelicRarity {
  common(weight: 40, label: '일반', labelEn: 'common'),
  rare(weight: 30, label: '레어', labelEn: 'rare'),
  epic(weight: 20, label: '에픽', labelEn: 'epic'),
  legendary(weight: 8, label: '전설', labelEn: 'legendary'),
  mythic(weight: 2, label: '신화', labelEn: 'mythic');

  final int weight;
  final String label;
  final String labelEn;
  const RelicRarity({required this.weight, required this.label, required this.labelEn});
}

/// Relic effect category for UI grouping.
enum RelicCategory { attack, defense, economy, merge, rule }

/// Static definition of a single relic.
class RelicDef {
  final String id;
  final String name;
  final String icon;
  final String description;
  final RelicRarity rarity;
  final RelicCategory category;

  const RelicDef({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.rarity,
    required this.category,
  });
}

/// Master registry of all relics in the game.
class RelicDatabase {
  RelicDatabase._();

  static const List<RelicDef> all = [
    // ══════════════════════════════════════
    // Evolution relics (8) — epic
    // ══════════════════════════════════════
    RelicDef(id: 'evolve_cat_archer', name: '궁수 진화석', icon: '🏹', description: '고양이 궁수를 진화시킵니다', rarity: RelicRarity.epic, category: RelicCategory.attack),
    RelicDef(id: 'evolve_dog_warrior', name: '기사 진화석', icon: '🗡️', description: '강아지 전사를 진화시킵니다', rarity: RelicRarity.epic, category: RelicCategory.attack),
    RelicDef(id: 'evolve_rabbit_mage', name: '마법사 진화석', icon: '🔮', description: '토끼 마법사를 진화시킵니다', rarity: RelicRarity.epic, category: RelicCategory.attack),
    RelicDef(id: 'evolve_bear_tanker', name: '수호자 진화석', icon: '🛡️', description: '곰 탱커를 진화시킵니다', rarity: RelicRarity.epic, category: RelicCategory.defense),
    RelicDef(id: 'evolve_fox_assassin', name: '암살자 진화석', icon: '🗡️', description: '여우 암살자를 진화시킵니다', rarity: RelicRarity.epic, category: RelicCategory.attack),
    RelicDef(id: 'evolve_bird_scout', name: '정찰대 진화석', icon: '🦅', description: '새 정찰대를 진화시킵니다', rarity: RelicRarity.epic, category: RelicCategory.attack),
    RelicDef(id: 'evolve_turtle_healer', name: '힐러 진화석', icon: '💚', description: '거북이 힐러를 진화시킵니다', rarity: RelicRarity.epic, category: RelicCategory.defense),
    RelicDef(id: 'evolve_owl_wizard', name: '마도사 진화석', icon: '🌙', description: '부엉이 마도사를 진화시킵니다', rarity: RelicRarity.epic, category: RelicCategory.attack),

    // ══════════════════════════════════════
    // Common (15) — 숫자 버프
    // ══════════════════════════════════════
    RelicDef(id: 'relic_atk_boost', name: '분노의 부적', icon: '⚔️', description: '전체 유닛 공격력 +15%', rarity: RelicRarity.common, category: RelicCategory.attack),
    RelicDef(id: 'relic_speed_boost', name: '신속의 부적', icon: '⚡', description: '전체 유닛 공격속도 +15%', rarity: RelicRarity.common, category: RelicCategory.attack),
    RelicDef(id: 'relic_gold_boost', name: '황금 나침반', icon: '💰', description: '골드 획득량 +30%', rarity: RelicRarity.common, category: RelicCategory.economy),
    RelicDef(id: 'relic_wall_shield', name: '수호의 방패', icon: '🛡️', description: '성벽 피해 -20%', rarity: RelicRarity.common, category: RelicCategory.defense),
    RelicDef(id: 'relic_crit_chance', name: '치명의 반지', icon: '💥', description: '치명타 확률 +10%', rarity: RelicRarity.common, category: RelicCategory.attack),
    RelicDef(id: 'relic_star_magnet', name: '별의 나침반', icon: '⭐', description: '런 종료 시 별 +20%', rarity: RelicRarity.common, category: RelicCategory.economy),
    RelicDef(id: 'relic_range_boost', name: '매의 눈', icon: '👁️', description: '전체 유닛 사거리 +20%', rarity: RelicRarity.common, category: RelicCategory.attack),
    RelicDef(id: 'relic_proj_speed', name: '질풍의 화살', icon: '🏃', description: '투사체 속도 +30%', rarity: RelicRarity.common, category: RelicCategory.attack),
    RelicDef(id: 'relic_kill_heal', name: '생명의 수확', icon: '🌿', description: '적 처치 시 성벽 HP +1', rarity: RelicRarity.common, category: RelicCategory.defense),
    RelicDef(id: 'relic_wave_gold', name: '전쟁 자금', icon: '🪙', description: '웨이브 시작 시 골드 +10', rarity: RelicRarity.common, category: RelicCategory.economy),
    RelicDef(id: 'relic_crit_dmg', name: '파멸의 반지', icon: '💎', description: '치명타 데미지 +50%', rarity: RelicRarity.common, category: RelicCategory.attack),
    RelicDef(id: 'relic_slow_aura', name: '빙결의 오라', icon: '❄️', description: '성벽 근처 적 둔화 -20%', rarity: RelicRarity.common, category: RelicCategory.defense),
    RelicDef(id: 'relic_lifesteal', name: '흡혈의 보석', icon: '🩸', description: '유닛 데미지의 2% 성벽 회복', rarity: RelicRarity.common, category: RelicCategory.defense),
    RelicDef(id: 'relic_thorns', name: '가시 갑옷', icon: '🌹', description: '성벽 피격 시 반사 데미지 10', rarity: RelicRarity.common, category: RelicCategory.defense),
    RelicDef(id: 'relic_boss_gold', name: '보스 사냥꾼', icon: '👑', description: '보스 골드 +50%', rarity: RelicRarity.common, category: RelicCategory.economy),

    // ══════════════════════════════════════
    // Rare (15) — 메카닉 변형
    // ══════════════════════════════════════
    RelicDef(id: 'relic_split_shot', name: '분열탄', icon: '🔱', description: '투사체 충돌 시 2개로 분열', rarity: RelicRarity.rare, category: RelicCategory.attack),
    RelicDef(id: 'relic_chain_lightning', name: '연쇄 번개', icon: '⛈️', description: '적 처치 시 주변 적 1마리에 50% 데미지', rarity: RelicRarity.rare, category: RelicCategory.attack),
    RelicDef(id: 'relic_splash', name: '폭발의 룬', icon: '💫', description: '원거리 유닛 범위 공격 획득', rarity: RelicRarity.rare, category: RelicCategory.attack),
    RelicDef(id: 'relic_lifesteal_up', name: '강화 흡혈', icon: '🧛', description: '라이프스틸 2% → 5%', rarity: RelicRarity.rare, category: RelicCategory.defense),
    RelicDef(id: 'relic_gold_rush', name: '골드 러시', icon: '🏆', description: '10콤보마다 골드 x2', rarity: RelicRarity.rare, category: RelicCategory.economy),
    RelicDef(id: 'relic_berserker', name: '광전사', icon: '🔥', description: 'HP 30% 이하 시 전체 ATK x2', rarity: RelicRarity.rare, category: RelicCategory.attack),
    RelicDef(id: 'relic_rapid_fire', name: '속사포', icon: '🔫', description: '공속 +30% 대신 ATK -15%', rarity: RelicRarity.rare, category: RelicCategory.attack),
    RelicDef(id: 'relic_pierce_all', name: '관통 강화', icon: '🎯', description: '모든 원거리 유닛 관통탄', rarity: RelicRarity.rare, category: RelicCategory.attack),
    RelicDef(id: 'relic_gambler', name: '도박사', icon: '🎰', description: '유닛 뽑기 50% 무료 / 50% 비용x2', rarity: RelicRarity.rare, category: RelicCategory.economy),
    RelicDef(id: 'relic_recycle', name: '재활용', icon: '♻️', description: '판매 환불 50% → 80%', rarity: RelicRarity.rare, category: RelicCategory.economy),
    RelicDef(id: 'relic_last_stand', name: '근성', icon: '💪', description: '성벽 HP 1로 1회 생존', rarity: RelicRarity.rare, category: RelicCategory.defense),
    RelicDef(id: 'relic_twin', name: '쌍둥이', icon: '👯', description: '유닛 구매 시 30% 확률 2마리', rarity: RelicRarity.rare, category: RelicCategory.merge),
    RelicDef(id: 'relic_giant', name: '거인', icon: '🗿', description: '유닛 크기 +50%, 사거리 +30%', rarity: RelicRarity.rare, category: RelicCategory.attack),
    RelicDef(id: 'relic_tiny', name: '소형화', icon: '🔬', description: '유닛 크기 -30%, 공속 +40%', rarity: RelicRarity.rare, category: RelicCategory.attack),
    RelicDef(id: 'relic_double_merge', name: '합성의 서', icon: '📖', description: '2마리만으로 합성 가능', rarity: RelicRarity.rare, category: RelicCategory.merge),

    // ══════════════════════════════════════
    // Epic (12) — 게임 규칙 변경
    // ══════════════════════════════════════
    RelicDef(id: 'relic_living_wall', name: '살아있는 성벽', icon: '🏰', description: '성벽이 직접 공격 (초당 15 데미지)', rarity: RelicRarity.epic, category: RelicCategory.rule),
    RelicDef(id: 'relic_convert', name: '적 전향', icon: '🔄', description: '적 처치 시 5% 확률 아군으로 변환', rarity: RelicRarity.epic, category: RelicCategory.rule),
    RelicDef(id: 'relic_time_warp', name: '시간 왜곡', icon: '⏳', description: '매 5웨이브 시작 시 3초 슬로모션', rarity: RelicRarity.epic, category: RelicCategory.rule),
    RelicDef(id: 'relic_infinite_merge', name: '무한 머지', icon: '♾️', description: '최대 레벨 5 → 7', rarity: RelicRarity.epic, category: RelicCategory.merge),
    RelicDef(id: 'relic_merge_bomb', name: '폭발 머지', icon: '💣', description: '머지 시 주변 적에게 범위 데미지', rarity: RelicRarity.epic, category: RelicCategory.merge),
    RelicDef(id: 'relic_ghost_unit', name: '유령 유닛', icon: '👻', description: '모든 유닛 공격력 +20%', rarity: RelicRarity.epic, category: RelicCategory.attack),
    RelicDef(id: 'relic_blessing_rain', name: '축복의 비', icon: '🌧️', description: '3웨이브마다 전체 HP 15% 회복', rarity: RelicRarity.epic, category: RelicCategory.defense),
    RelicDef(id: 'relic_doppelganger', name: '도플갱어', icon: '🪞', description: '유닛 구매 시 가장 많은 유닛과 같은 종류', rarity: RelicRarity.epic, category: RelicCategory.merge),
    RelicDef(id: 'relic_elemental', name: '원소 폭풍', icon: '🌀', description: '투사체에 랜덤 원소 효과 (불/얼음/독)', rarity: RelicRarity.epic, category: RelicCategory.attack),
    RelicDef(id: 'relic_treasure_hunter', name: '보물 사냥꾼', icon: '🗺️', description: '보스 보상 골드 x3', rarity: RelicRarity.epic, category: RelicCategory.economy),
    RelicDef(id: 'relic_auto_evolve', name: '자동 진화', icon: '🧬', description: 'Lv5 유닛 자동 진화 (진화유물 불필요)', rarity: RelicRarity.epic, category: RelicCategory.merge),
    RelicDef(id: 'relic_wall_turret', name: '성벽 포탑', icon: '🔫', description: '성벽에 자동 포탑 추가 (초당 20 데미지)', rarity: RelicRarity.epic, category: RelicCategory.rule),

    // ══════════════════════════════════════
    // Legendary (6) — 런 정의 변경
    // ══════════════════════════════════════
    RelicDef(id: 'relic_phoenix', name: '불사조', icon: '🔥', description: '성벽 파괴 시 1회 부활 + 5초 무적', rarity: RelicRarity.legendary, category: RelicCategory.rule),
    RelicDef(id: 'relic_rift', name: '차원 균열', icon: '🌀', description: '매 웨이브 시작 랜덤 유닛 1개 무료 소환', rarity: RelicRarity.legendary, category: RelicCategory.rule),
    RelicDef(id: 'relic_midas', name: '마이다스', icon: '✋', description: '모든 데미지를 골드로 변환, ATK=0', rarity: RelicRarity.legendary, category: RelicCategory.rule),
    RelicDef(id: 'relic_war_god', name: '전쟁의 신', icon: '⚔️', description: 'ATK x3 대신 성벽 HP -50%', rarity: RelicRarity.legendary, category: RelicCategory.rule),
    RelicDef(id: 'relic_infinity', name: '무한의 돌', icon: '💠', description: '유물 슬롯 +2', rarity: RelicRarity.legendary, category: RelicCategory.rule),
    RelicDef(id: 'relic_time_sand', name: '시간의 모래', icon: '⌛', description: '웨이브 시간 20초→10초, 적 속도 -30%', rarity: RelicRarity.legendary, category: RelicCategory.rule),

    // ══════════════════════════════════════
    // Mythic (2) — 런 자체를 바꿈
    // ══════════════════════════════════════
    RelicDef(id: 'relic_chaos', name: '카오스', icon: '🌪️', description: '매 웨이브마다 보유 유물 효과 랜덤 변경', rarity: RelicRarity.mythic, category: RelicCategory.rule),
    RelicDef(id: 'relic_reverse', name: '역전의 법칙', icon: '☯️', description: '성벽 HP가 낮을수록 전체 ATK 폭증', rarity: RelicRarity.mythic, category: RelicCategory.rule),
  ];

  /// Quick lookup by ID.
  static final Map<String, RelicDef> _byId = {
    for (final r in all) r.id: r,
  };

  /// Get relic definition by ID. Returns null if not found.
  static RelicDef? get(String id) => _byId[id];

  /// All relic IDs.
  static List<String> get allIds => all.map((r) => r.id).toList();

  /// Filter relics by rarity.
  static List<RelicDef> byRarity(RelicRarity rarity) =>
      all.where((r) => r.rarity == rarity).toList();
}
