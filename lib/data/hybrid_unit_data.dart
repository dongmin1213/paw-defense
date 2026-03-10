/// Hybrid unit definitions for cross-breed merge system.
/// Two different unit types (both Lv3+) can merge into a hybrid unit.
/// 8 base types → 28 possible pairs, 12 key hybrids implemented.

/// A hybrid unit recipe: two parent types → one hybrid.
class HybridRecipe {
  final String parentA;
  final String parentB;
  final String hybridId;

  const HybridRecipe({
    required this.parentA,
    required this.parentB,
    required this.hybridId,
  });

  /// Check if two unit types match this recipe (order-independent).
  bool matches(String typeA, String typeB) {
    return (typeA == parentA && typeB == parentB) ||
        (typeA == parentB && typeB == parentA);
  }
}

/// Static data for a hybrid unit.
class HybridUnitData {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final String parentA;
  final String parentB;
  final double baseAtk;
  final double baseAtkSpeed;
  final double range;
  final bool isMelee;
  final bool isSplash;
  final bool isPiercing;
  final bool canHitAir;
  final String specialAbility;
  final String specialAbilityDesc;

  const HybridUnitData({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.parentA,
    required this.parentB,
    required this.baseAtk,
    required this.baseAtkSpeed,
    required this.range,
    this.isMelee = false,
    this.isSplash = false,
    this.isPiercing = false,
    this.canHitAir = false,
    required this.specialAbility,
    required this.specialAbilityDesc,
  });
}

/// Database of all hybrid unit recipes and data.
class HybridDatabase {
  HybridDatabase._();

  static const List<HybridRecipe> recipes = [
    // 12 key hybrid recipes
    HybridRecipe(parentA: 'cat_archer', parentB: 'fox_assassin', hybridId: 'hybrid_flame_hunter'),
    HybridRecipe(parentA: 'dog_warrior', parentB: 'bear_tanker', hybridId: 'hybrid_iron_warrior'),
    HybridRecipe(parentA: 'rabbit_mage', parentB: 'owl_wizard', hybridId: 'hybrid_archmage'),
    HybridRecipe(parentA: 'turtle_healer', parentB: 'bear_tanker', hybridId: 'hybrid_mountain_guard'),
    HybridRecipe(parentA: 'cat_archer', parentB: 'bird_scout', hybridId: 'hybrid_storm_archer'),
    HybridRecipe(parentA: 'fox_assassin', parentB: 'bird_scout', hybridId: 'hybrid_wind_thief'),
    HybridRecipe(parentA: 'dog_warrior', parentB: 'turtle_healer', hybridId: 'hybrid_holy_knight'),
    HybridRecipe(parentA: 'rabbit_mage', parentB: 'turtle_healer', hybridId: 'hybrid_mystic_sage'),
    HybridRecipe(parentA: 'bear_tanker', parentB: 'owl_wizard', hybridId: 'hybrid_wise_bear'),
    HybridRecipe(parentA: 'fox_assassin', parentB: 'owl_wizard', hybridId: 'hybrid_shadow_sage'),
    HybridRecipe(parentA: 'dog_warrior', parentB: 'fox_assassin', hybridId: 'hybrid_wolf_blade'),
    HybridRecipe(parentA: 'cat_archer', parentB: 'rabbit_mage', hybridId: 'hybrid_spell_sniper'),
  ];

  static const List<HybridUnitData> all = [
    // 🐱+🦊 불꽃 사냥꾼: 크리 시 화상 도트 + 관통
    HybridUnitData(
      id: 'hybrid_flame_hunter',
      name: '불꽃 사냥꾼',
      emoji: '🔥',
      description: '화염 화살로 적을 관통하며 불태운다',
      parentA: 'cat_archer',
      parentB: 'fox_assassin',
      baseAtk: 35,
      baseAtkSpeed: 1.2,
      range: 120,
      isPiercing: true,
      canHitAir: true,
      specialAbility: 'burn_pierce',
      specialAbilityDesc: '크리 시 화상 도트 + 관통',
    ),
    // 🐶+🐻 철벽 전사: 근접 광역 + 넉백 + 슬로우
    HybridUnitData(
      id: 'hybrid_iron_warrior',
      name: '철벽 전사',
      emoji: '🛡️',
      description: '강력한 근접 광역 공격으로 적을 밀어낸다',
      parentA: 'dog_warrior',
      parentB: 'bear_tanker',
      baseAtk: 22,
      baseAtkSpeed: 0.7,
      range: 45,
      isMelee: true,
      isSplash: true,
      specialAbility: 'cleave_stun',
      specialAbilityDesc: '근접 광역 + 넉백 + 슬로우',
    ),
    // 🐰+🦉 대마법사: 거대 스플래시 + 장거리
    HybridUnitData(
      id: 'hybrid_archmage',
      name: '대마법사',
      emoji: '🌟',
      description: '거대한 마법 폭발로 넓은 범위를 초토화한다',
      parentA: 'rabbit_mage',
      parentB: 'owl_wizard',
      baseAtk: 40,
      baseAtkSpeed: 0.4,
      range: 140,
      isSplash: true,
      canHitAir: true,
      specialAbility: 'mega_splash',
      specialAbilityDesc: '초대형 스플래시 + 장거리',
    ),
    // 🐢+🐻 산악 수호자: 성벽 회복 + 주변 적 슬로우
    HybridUnitData(
      id: 'hybrid_mountain_guard',
      name: '산악 수호자',
      emoji: '🏔️',
      description: '성벽을 회복하며 주변 적을 둔화시킨다',
      parentA: 'turtle_healer',
      parentB: 'bear_tanker',
      baseAtk: 12,
      baseAtkSpeed: 0.5,
      range: 50,
      isMelee: true,
      specialAbility: 'area_slow_heal',
      specialAbilityDesc: '성벽 자동 회복 + 주변 적 슬로우',
    ),
    // 🐱+🐦 폭풍 궁수: 3연발 + 대공
    HybridUnitData(
      id: 'hybrid_storm_archer',
      name: '폭풍 궁수',
      emoji: '🌪️',
      description: '3연발 화살을 쏘며 공중 적도 격추한다',
      parentA: 'cat_archer',
      parentB: 'bird_scout',
      baseAtk: 12,
      baseAtkSpeed: 2.0,
      range: 115,
      canHitAir: true,
      isPiercing: true,
      specialAbility: 'triple_shot',
      specialAbilityDesc: '3연발 + 대공 + 관통',
    ),
    // 🦊+🐦 바람 도적: 이동하며 공격 + 회피
    HybridUnitData(
      id: 'hybrid_wind_thief',
      name: '바람 도적',
      emoji: '💨',
      description: '빠르게 이동하며 회피하는 원거리 공격수',
      parentA: 'fox_assassin',
      parentB: 'bird_scout',
      baseAtk: 28,
      baseAtkSpeed: 1.0,
      range: 100,
      canHitAir: true,
      specialAbility: 'evasion_shot',
      specialAbilityDesc: '30% 회피 + 이동 사격',
    ),
    // 🐶+🐢 수호 기사: 근접 + 성벽 자동회복
    HybridUnitData(
      id: 'hybrid_holy_knight',
      name: '수호 기사',
      emoji: '⚜️',
      description: '적을 공격할 때마다 성벽을 회복시킨다',
      parentA: 'dog_warrior',
      parentB: 'turtle_healer',
      baseAtk: 15,
      baseAtkSpeed: 0.7,
      range: 40,
      isMelee: true,
      isSplash: true,
      specialAbility: 'holy_strike',
      specialAbilityDesc: '근접 광역 + 타격당 성벽 회복',
    ),
    // 🐰+🐢 신비술사: 범위 힐 + 범위 공격 동시
    HybridUnitData(
      id: 'hybrid_mystic_sage',
      name: '신비술사',
      emoji: '🔮',
      description: '적을 공격하면서 동시에 성벽을 치유한다',
      parentA: 'rabbit_mage',
      parentB: 'turtle_healer',
      baseAtk: 18,
      baseAtkSpeed: 0.5,
      range: 80,
      isSplash: true,
      specialAbility: 'heal_blast',
      specialAbilityDesc: '범위 공격 + 공격마다 성벽 HP 3% 회복',
    ),
    // 🐻+🦉 현자곰: 슬로우 + 장거리 광역
    HybridUnitData(
      id: 'hybrid_wise_bear',
      name: '현자곰',
      emoji: '📚',
      description: '장거리에서 둔화 마법을 내리꽂는다',
      parentA: 'bear_tanker',
      parentB: 'owl_wizard',
      baseAtk: 16,
      baseAtkSpeed: 0.5,
      range: 110,
      isSplash: true,
      canHitAir: true,
      specialAbility: 'slow_blast',
      specialAbilityDesc: '장거리 광역 + 피격 적 둔화 40%',
    ),
    // 🦊+🦉 그림자 현자: 크리 + 광역 + 투명화
    HybridUnitData(
      id: 'hybrid_shadow_sage',
      name: '그림자 현자',
      emoji: '🌑',
      description: '그림자에서 치명적인 광역 마법을 날린다',
      parentA: 'fox_assassin',
      parentB: 'owl_wizard',
      baseAtk: 30,
      baseAtkSpeed: 0.6,
      range: 120,
      isSplash: true,
      canHitAir: true,
      specialAbility: 'shadow_magic',
      specialAbilityDesc: '크리 확률 30% + 광역 + 적에게 타겟 불가',
    ),
    // 🐶+🦊 늑대 전사: 빠른 근접 + 크리
    HybridUnitData(
      id: 'hybrid_wolf_blade',
      name: '늑대 전사',
      emoji: '🐺',
      description: '빠른 연속 공격으로 치명타를 노린다',
      parentA: 'dog_warrior',
      parentB: 'fox_assassin',
      baseAtk: 22,
      baseAtkSpeed: 1.2,
      range: 50,
      isMelee: true,
      specialAbility: 'frenzy_crit',
      specialAbilityDesc: '빠른 근접 연타 + 크리 확률 25%',
    ),
    // 🐱+🐰 스펠 스나이퍼: 초장거리 마법 저격
    HybridUnitData(
      id: 'hybrid_spell_sniper',
      name: '스펠 스나이퍼',
      emoji: '🎯',
      description: '가장 먼 적을 마법 화살로 저격한다',
      parentA: 'cat_archer',
      parentB: 'rabbit_mage',
      baseAtk: 32,
      baseAtkSpeed: 0.8,
      range: 150,
      canHitAir: true,
      specialAbility: 'spell_snipe',
      specialAbilityDesc: '초장거리 + 가장 먼 적 우선 타겟',
    ),
  ];

  static final Map<String, HybridUnitData> _byId = {
    for (final h in all) h.id: h,
  };

  /// Get hybrid data by ID.
  static HybridUnitData? get(String id) => _byId[id];

  /// Find a hybrid recipe matching two unit types.
  /// Returns null if no hybrid exists for this combination.
  static HybridRecipe? findRecipe(String typeA, String typeB) {
    for (final recipe in recipes) {
      if (recipe.matches(typeA, typeB)) return recipe;
    }
    return null;
  }

  /// Get all hybrid IDs.
  static List<String> get allIds => all.map((h) => h.id).toList();

  /// Check if a unit ID is a hybrid.
  static bool isHybrid(String unitTypeId) => _byId.containsKey(unitTypeId);
}
