/// Hybrid unit definitions for cross-breed merge system.
/// Two different unit types (both Lv3+) can merge into a hybrid unit.
/// 8 base types → C(8,2) = 28 possible pairs, all 28 hybrids implemented.

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
/// All C(8,2) = 28 combinations of 8 base unit types:
///   cat_archer, dog_warrior, rabbit_mage, bear_tanker,
///   fox_assassin, bird_scout, turtle_healer, owl_wizard
class HybridDatabase {
  HybridDatabase._();

  static const List<HybridRecipe> recipes = [
    // ── Original 12 hybrid recipes ──
    // 1. cat+fox
    HybridRecipe(parentA: 'cat_archer', parentB: 'fox_assassin', hybridId: 'hybrid_flame_hunter'),
    // 2. dog+bear
    HybridRecipe(parentA: 'dog_warrior', parentB: 'bear_tanker', hybridId: 'hybrid_iron_warrior'),
    // 3. rabbit+owl
    HybridRecipe(parentA: 'rabbit_mage', parentB: 'owl_wizard', hybridId: 'hybrid_archmage'),
    // 4. turtle+bear
    HybridRecipe(parentA: 'turtle_healer', parentB: 'bear_tanker', hybridId: 'hybrid_mountain_guard'),
    // 5. cat+bird
    HybridRecipe(parentA: 'cat_archer', parentB: 'bird_scout', hybridId: 'hybrid_storm_archer'),
    // 6. fox+bird
    HybridRecipe(parentA: 'fox_assassin', parentB: 'bird_scout', hybridId: 'hybrid_wind_thief'),
    // 7. dog+turtle
    HybridRecipe(parentA: 'dog_warrior', parentB: 'turtle_healer', hybridId: 'hybrid_holy_knight'),
    // 8. rabbit+turtle
    HybridRecipe(parentA: 'rabbit_mage', parentB: 'turtle_healer', hybridId: 'hybrid_mystic_sage'),
    // 9. bear+owl
    HybridRecipe(parentA: 'bear_tanker', parentB: 'owl_wizard', hybridId: 'hybrid_wise_bear'),
    // 10. fox+owl
    HybridRecipe(parentA: 'fox_assassin', parentB: 'owl_wizard', hybridId: 'hybrid_shadow_sage'),
    // 11. dog+fox
    HybridRecipe(parentA: 'dog_warrior', parentB: 'fox_assassin', hybridId: 'hybrid_wolf_blade'),
    // 12. cat+rabbit
    HybridRecipe(parentA: 'cat_archer', parentB: 'rabbit_mage', hybridId: 'hybrid_spell_sniper'),

    // ── 16 new hybrid recipes (completing all C(8,2) = 28) ──
    // 13. cat+dog
    HybridRecipe(parentA: 'cat_archer', parentB: 'dog_warrior', hybridId: 'hybrid_battle_archer'),
    // 14. cat+bear
    HybridRecipe(parentA: 'cat_archer', parentB: 'bear_tanker', hybridId: 'hybrid_hunter_bear'),
    // 15. cat+turtle
    HybridRecipe(parentA: 'cat_archer', parentB: 'turtle_healer', hybridId: 'hybrid_healing_archer'),
    // 16. cat+owl
    HybridRecipe(parentA: 'cat_archer', parentB: 'owl_wizard', hybridId: 'hybrid_magic_sniper'),
    // 17. dog+rabbit
    HybridRecipe(parentA: 'dog_warrior', parentB: 'rabbit_mage', hybridId: 'hybrid_charge_mage'),
    // 18. dog+bird
    HybridRecipe(parentA: 'dog_warrior', parentB: 'bird_scout', hybridId: 'hybrid_assault_flyer'),
    // 19. dog+owl
    HybridRecipe(parentA: 'dog_warrior', parentB: 'owl_wizard', hybridId: 'hybrid_tactical_commander'),
    // 20. rabbit+bear
    HybridRecipe(parentA: 'rabbit_mage', parentB: 'bear_tanker', hybridId: 'hybrid_earth_mage'),
    // 21. rabbit+fox
    HybridRecipe(parentA: 'rabbit_mage', parentB: 'fox_assassin', hybridId: 'hybrid_illusion_caster'),
    // 22. rabbit+bird
    HybridRecipe(parentA: 'rabbit_mage', parentB: 'bird_scout', hybridId: 'hybrid_sky_mage'),
    // 23. bear+fox
    HybridRecipe(parentA: 'bear_tanker', parentB: 'fox_assassin', hybridId: 'hybrid_rage_beast'),
    // 24. bear+bird
    HybridRecipe(parentA: 'bear_tanker', parentB: 'bird_scout', hybridId: 'hybrid_sky_guardian'),
    // 25. fox+turtle
    HybridRecipe(parentA: 'fox_assassin', parentB: 'turtle_healer', hybridId: 'hybrid_venom_ninja'),
    // 26. bird+turtle
    HybridRecipe(parentA: 'bird_scout', parentB: 'turtle_healer', hybridId: 'hybrid_nature_scout'),
    // 27. bird+owl
    HybridRecipe(parentA: 'bird_scout', parentB: 'owl_wizard', hybridId: 'hybrid_celestial_mage'),
    // 28. turtle+owl
    HybridRecipe(parentA: 'turtle_healer', parentB: 'owl_wizard', hybridId: 'hybrid_time_sage'),
  ];

  static const List<HybridUnitData> all = [
    // ════════════════════════════════════════
    // Original 12 hybrids
    // ════════════════════════════════════════

    // #1 cat+fox
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
    // #2 dog+bear
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
    // #3 rabbit+owl
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
    // #4 turtle+bear
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
    // #5 cat+bird
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
    // #6 fox+bird
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
    // #7 dog+turtle
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
    // #8 rabbit+turtle
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
    // #9 bear+owl
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
    // #10 fox+owl
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
    // #11 dog+fox
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
    // #12 cat+rabbit
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

    // ════════════════════════════════════════
    // 16 new hybrids (completing all C(8,2) = 28)
    // ════════════════════════════════════════

    // #13 cat+dog 전투 궁수
    HybridUnitData(
      id: 'hybrid_battle_archer',
      name: '전투 궁수',
      emoji: '🏹',
      description: '검과 활을 동시에 사용하는 전투 궁수',
      parentA: 'cat_archer',
      parentB: 'dog_warrior',
      baseAtk: 20,
      baseAtkSpeed: 1.0,
      range: 70,
      canHitAir: true,
      specialAbility: 'dual_stance',
      specialAbilityDesc: '근접/원거리 자동 전환 + 대공',
    ),
    // #14 cat+bear 사냥꾼 곰
    HybridUnitData(
      id: 'hybrid_hunter_bear',
      name: '사냥꾼 곰',
      emoji: '🐾',
      description: '무거운 화살로 적을 둔화시키는 사냥꾼',
      parentA: 'cat_archer',
      parentB: 'bear_tanker',
      baseAtk: 20,
      baseAtkSpeed: 0.7,
      range: 90,
      specialAbility: 'slow_shot',
      specialAbilityDesc: '장거리 + 둔화 공격',
    ),
    // #15 cat+turtle 치유 궁수
    HybridUnitData(
      id: 'hybrid_healing_archer',
      name: '치유 궁수',
      emoji: '💚',
      description: '치유의 화살로 적을 공격하며 성벽을 회복한다',
      parentA: 'cat_archer',
      parentB: 'turtle_healer',
      baseAtk: 14,
      baseAtkSpeed: 1.0,
      range: 100,
      specialAbility: 'heal_shot',
      specialAbilityDesc: '공격 시 성벽 1% 회복',
    ),
    // #16 cat+owl 마법 저격수
    HybridUnitData(
      id: 'hybrid_magic_sniper',
      name: '마법 저격수',
      emoji: '🔭',
      description: '마법이 깃든 화살로 적을 관통하는 저격수',
      parentA: 'cat_archer',
      parentB: 'owl_wizard',
      baseAtk: 25,
      baseAtkSpeed: 0.5,
      range: 130,
      isPiercing: true,
      specialAbility: 'magic_pierce',
      specialAbilityDesc: '초장거리 + 마법 관통',
    ),
    // #17 dog+rabbit 돌격 마법사
    HybridUnitData(
      id: 'hybrid_charge_mage',
      name: '돌격 마법사',
      emoji: '💫',
      description: '돌격하며 마법 폭발을 일으키는 전사',
      parentA: 'dog_warrior',
      parentB: 'rabbit_mage',
      baseAtk: 22,
      baseAtkSpeed: 0.9,
      range: 50,
      isMelee: true,
      isSplash: true,
      specialAbility: 'charge_blast',
      specialAbilityDesc: '근접 범위 공격 + 마법 폭발',
    ),
    // #18 dog+bird 돌격 비행사
    HybridUnitData(
      id: 'hybrid_assault_flyer',
      name: '돌격 비행사',
      emoji: '🪂',
      description: '하늘에서 돌격하여 적을 밀어내는 전사',
      parentA: 'dog_warrior',
      parentB: 'bird_scout',
      baseAtk: 20,
      baseAtkSpeed: 1.0,
      range: 45,
      isMelee: true,
      canHitAir: true,
      specialAbility: 'air_assault',
      specialAbilityDesc: '대공 근접 + 넉백',
    ),
    // #19 dog+owl 전술 지휘관
    HybridUnitData(
      id: 'hybrid_tactical_commander',
      name: '전술 지휘관',
      emoji: '🎖️',
      description: '주변 아군의 공격력을 높이는 지휘관',
      parentA: 'dog_warrior',
      parentB: 'owl_wizard',
      baseAtk: 18,
      baseAtkSpeed: 0.8,
      range: 80,
      specialAbility: 'buff_aura',
      specialAbilityDesc: '인접 유닛 ATK +20% 오라',
    ),
    // #20 rabbit+bear 대지 마법사
    HybridUnitData(
      id: 'hybrid_earth_mage',
      name: '대지 마법사',
      emoji: '🌋',
      description: '대지의 마법으로 적을 둔화시키며 파괴한다',
      parentA: 'rabbit_mage',
      parentB: 'bear_tanker',
      baseAtk: 24,
      baseAtkSpeed: 0.5,
      range: 90,
      isSplash: true,
      specialAbility: 'slow_field',
      specialAbilityDesc: '스플래시 + 둔화 장판',
    ),
    // #21 rabbit+fox 환영 술사
    HybridUnitData(
      id: 'hybrid_illusion_caster',
      name: '환영 술사',
      emoji: '🃏',
      description: '분신을 만들어 두 갈래로 마법을 발사한다',
      parentA: 'rabbit_mage',
      parentB: 'fox_assassin',
      baseAtk: 16,
      baseAtkSpeed: 1.2,
      range: 100,
      specialAbility: 'double_shot',
      specialAbilityDesc: '분신 투사체 (2중 발사)',
    ),
    // #22 rabbit+bird 하늘 마법사
    HybridUnitData(
      id: 'hybrid_sky_mage',
      name: '하늘 마법사',
      emoji: '☁️',
      description: '하늘을 수놓는 광역 마법으로 공중 적을 소탕한다',
      parentA: 'rabbit_mage',
      parentB: 'bird_scout',
      baseAtk: 20,
      baseAtkSpeed: 0.7,
      range: 110,
      isSplash: true,
      canHitAir: true,
      specialAbility: 'air_splash',
      specialAbilityDesc: '대공 스플래시',
    ),
    // #23 bear+fox 분노의 야수
    HybridUnitData(
      id: 'hybrid_rage_beast',
      name: '분노의 야수',
      emoji: '🔱',
      description: '위기에 몰리면 폭주하여 엄청난 힘을 발휘한다',
      parentA: 'bear_tanker',
      parentB: 'fox_assassin',
      baseAtk: 28,
      baseAtkSpeed: 0.6,
      range: 40,
      isMelee: true,
      specialAbility: 'berserk',
      specialAbilityDesc: '저 HP 시 ATK x3 + 크리',
    ),
    // #24 bear+bird 하늘 수호자
    HybridUnitData(
      id: 'hybrid_sky_guardian',
      name: '하늘 수호자',
      emoji: '🦅',
      description: '하늘에서 적을 감시하며 광역 둔화를 건다',
      parentA: 'bear_tanker',
      parentB: 'bird_scout',
      baseAtk: 18,
      baseAtkSpeed: 0.7,
      range: 85,
      isSplash: true,
      canHitAir: true,
      specialAbility: 'air_slow',
      specialAbilityDesc: '대공 + 광역 둔화',
    ),
    // #25 fox+turtle 독안개 닌자
    HybridUnitData(
      id: 'hybrid_venom_ninja',
      name: '독안개 닌자',
      emoji: '🌫️',
      description: '독안개 속에서 관통하는 독침을 날린다',
      parentA: 'fox_assassin',
      parentB: 'turtle_healer',
      baseAtk: 20,
      baseAtkSpeed: 1.3,
      range: 70,
      isPiercing: true,
      specialAbility: 'poison_pierce',
      specialAbilityDesc: '독 DoT + 관통 + 회피 25%',
    ),
    // #26 bird+turtle 자연 정찰병
    HybridUnitData(
      id: 'hybrid_nature_scout',
      name: '자연 정찰병',
      emoji: '🌿',
      description: '자연의 힘으로 아군을 회복하며 정찰한다',
      parentA: 'bird_scout',
      parentB: 'turtle_healer',
      baseAtk: 12,
      baseAtkSpeed: 0.9,
      range: 95,
      canHitAir: true,
      specialAbility: 'nature_heal',
      specialAbilityDesc: '대공 + 공격 시 성벽 2% 회복',
    ),
    // #27 bird+owl 천공 마도사
    HybridUnitData(
      id: 'hybrid_celestial_mage',
      name: '천공 마도사',
      emoji: '🌠',
      description: '천상의 마법으로 초장거리에서 적을 관통한다',
      parentA: 'bird_scout',
      parentB: 'owl_wizard',
      baseAtk: 22,
      baseAtkSpeed: 0.6,
      range: 130,
      canHitAir: true,
      isPiercing: true,
      specialAbility: 'celestial_pierce',
      specialAbilityDesc: '초장거리 + 관통 마법',
    ),
    // #28 turtle+owl 시간 현자
    HybridUnitData(
      id: 'hybrid_time_sage',
      name: '시간 현자',
      emoji: '⏳',
      description: '시간을 조종하여 주변 적의 속도를 늦춘다',
      parentA: 'turtle_healer',
      parentB: 'owl_wizard',
      baseAtk: 14,
      baseAtkSpeed: 0.5,
      range: 100,
      isSplash: true,
      specialAbility: 'time_aura',
      specialAbilityDesc: '주변 적 속도 -50% 오라',
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
