# 하이브리드 유닛 시스템 (Hybrid Units)

> 이 문서만 읽으면 하이브리드 유닛 관련 작업을 독립적으로 수행할 수 있습니다.

## 소스 파일

| 파일 | 역할 |
|------|------|
| `lib/data/hybrid_unit_data.dart` | 28종 하이브리드 레시피 + 데이터 정의 |
| `lib/systems/merge_manager.dart` | 동종 머지 + 이종 크로스브리드 로직 |
| `lib/components/defense_unit.dart` | 하이브리드 유닛 전투 로직 |
| `lib/renderers/unit_renderer.dart` | 하이브리드 픽셀아트 렌더링 |
| `lib/data/balance_config.dart` | 하이브리드 관련 밸런스 상수 |

## 머지 규칙

- **동종 머지**: 같은 종 유닛 3마리(합성의서 2마리) → 레벨+1
- **이종 머지 (크로스브리드)**: **서로 다른** 종 2마리, **둘 다 Lv3 이상** → 하이브리드 유닛
- 하이브리드 유닛은 더 이상 머지 불가
- C(8,2) = 28종 전체 조합 구현

## 전체 하이브리드 목록 (28종)

### 원본 12종

| # | 부모 A | 부모 B | ID | 이름 | ATK | 공속 | 사거리 | 근접 | 범위 | 관통 | 대공 | 특수 능력 |
|---|--------|--------|----|------|-----|------|--------|------|------|------|------|-----------|
| 1 | cat_archer | fox_assassin | `hybrid_flame_hunter` | 불꽃 사냥꾼 🔥 | 35 | 1.2 | 120 | - | - | O | O | 크리 시 화상 DoT + 관통 |
| 2 | dog_warrior | bear_tanker | `hybrid_iron_warrior` | 철벽 전사 🛡️ | 22 | 0.7 | 45 | O | O | - | - | 근접 광역 + 넉백 + 슬로우 |
| 3 | rabbit_mage | owl_wizard | `hybrid_archmage` | 대마법사 🌟 | 40 | 0.4 | 140 | - | O | - | O | 초대형 스플래시 + 장거리 |
| 4 | turtle_healer | bear_tanker | `hybrid_mountain_guard` | 산악 수호자 🏔️ | 12 | 0.5 | 50 | O | - | - | - | 성벽 자동 회복 + 주변 적 슬로우 |
| 5 | cat_archer | bird_scout | `hybrid_storm_archer` | 폭풍 궁수 🌪️ | 12 | 2.0 | 115 | - | - | O | O | 3연발 + 대공 + 관통 |
| 6 | fox_assassin | bird_scout | `hybrid_wind_thief` | 바람 도적 💨 | 28 | 1.0 | 100 | - | - | - | O | 30% 회피 + 이동 사격 |
| 7 | dog_warrior | turtle_healer | `hybrid_holy_knight` | 수호 기사 ⚜️ | 15 | 0.7 | 40 | O | O | - | - | 근접 광역 + 타격당 성벽 회복 |
| 8 | rabbit_mage | turtle_healer | `hybrid_mystic_sage` | 신비술사 🔮 | 18 | 0.5 | 80 | - | O | - | - | 범위 공격 + 성벽 HP 3% 회복 |
| 9 | bear_tanker | owl_wizard | `hybrid_wise_bear` | 현자곰 📚 | 16 | 0.5 | 110 | - | O | - | O | 장거리 광역 + 둔화 40% |
| 10 | fox_assassin | owl_wizard | `hybrid_shadow_sage` | 그림자 현자 🌑 | 30 | 0.6 | 120 | - | O | - | O | 크리 30% + 광역 |
| 11 | dog_warrior | fox_assassin | `hybrid_wolf_blade` | 늑대 전사 🐺 | 22 | 1.2 | 50 | O | - | - | - | 빠른 근접 연타 + 크리 25% |
| 12 | cat_archer | rabbit_mage | `hybrid_spell_sniper` | 스펠 스나이퍼 🎯 | 32 | 0.8 | 150 | - | - | - | O | 초장거리 + 가장 먼 적 우선 |

### 신규 16종

| # | 부모 A | 부모 B | ID | 이름 | ATK | 공속 | 사거리 | 근접 | 범위 | 관통 | 대공 | 특수 능력 |
|---|--------|--------|----|------|-----|------|--------|------|------|------|------|-----------|
| 13 | cat_archer | dog_warrior | `hybrid_battle_archer` | 전투 궁수 🏹 | 20 | 1.0 | 70 | - | - | - | O | 근접/원거리 자동 전환 |
| 14 | cat_archer | bear_tanker | `hybrid_hunter_bear` | 사냥꾼 곰 🐾 | 20 | 0.7 | 90 | - | - | - | - | 장거리 + 둔화 공격 |
| 15 | cat_archer | turtle_healer | `hybrid_healing_archer` | 치유 궁수 💚 | 14 | 1.0 | 100 | - | - | - | - | 공격 시 성벽 1% 회복 |
| 16 | cat_archer | owl_wizard | `hybrid_magic_sniper` | 마법 저격수 🔭 | 25 | 0.5 | 130 | - | - | O | - | 초장거리 + 마법 관통 |
| 17 | dog_warrior | rabbit_mage | `hybrid_charge_mage` | 돌격 마법사 💫 | 22 | 0.9 | 50 | O | O | - | - | 근접 범위 + 마법 폭발 |
| 18 | dog_warrior | bird_scout | `hybrid_assault_flyer` | 돌격 비행사 🪂 | 20 | 1.0 | 45 | O | - | - | O | 대공 근접 + 넉백 |
| 19 | dog_warrior | owl_wizard | `hybrid_tactical_commander` | 전술 지휘관 🎖️ | 18 | 0.8 | 80 | - | - | - | - | 인접 유닛 ATK +20% 오라 |
| 20 | rabbit_mage | bear_tanker | `hybrid_earth_mage` | 대지 마법사 🌋 | 24 | 0.5 | 90 | - | O | - | - | 스플래시 + 둔화 장판 |
| 21 | rabbit_mage | fox_assassin | `hybrid_illusion_caster` | 환영 술사 🃏 | 16 | 1.2 | 100 | - | - | - | - | 분신 투사체 (2중 발사) |
| 22 | rabbit_mage | bird_scout | `hybrid_sky_mage` | 하늘 마법사 ☁️ | 20 | 0.7 | 110 | - | O | - | O | 대공 스플래시 |
| 23 | bear_tanker | fox_assassin | `hybrid_rage_beast` | 분노의 야수 🔱 | 28 | 0.6 | 40 | O | - | - | - | 저 HP 시 ATK x3 + 크리 |
| 24 | bear_tanker | bird_scout | `hybrid_sky_guardian` | 하늘 수호자 🦅 | 18 | 0.7 | 85 | - | O | - | O | 대공 + 광역 둔화 |
| 25 | fox_assassin | turtle_healer | `hybrid_venom_ninja` | 독안개 닌자 🌫️ | 20 | 1.3 | 70 | - | - | O | - | 독 DoT + 관통 + 회피 25% |
| 26 | bird_scout | turtle_healer | `hybrid_nature_scout` | 자연 정찰병 🌿 | 12 | 0.9 | 95 | - | - | - | O | 대공 + 성벽 2% 회복 |
| 27 | bird_scout | owl_wizard | `hybrid_celestial_mage` | 천공 마도사 🌠 | 22 | 0.6 | 130 | - | - | O | O | 초장거리 + 관통 마법 |
| 28 | turtle_healer | owl_wizard | `hybrid_time_sage` | 시간 현자 ⏳ | 14 | 0.5 | 100 | - | O | - | - | 주변 적 속도 -50% 오라 |

## 하이브리드 특수 스탯 (BalanceConfig)

| 상수 | 값 | 적용 대상 |
|------|-----|-----------|
| `hybridFlameHunterCrit` | 0.20 (20%) | 불꽃 사냥꾼 크리 확률 |
| `hybridShadowSageCrit` | 0.30 (30%) | 그림자 현자 크리 확률 |
| `hybridWolfBladeCrit` | 0.25 (25%) | 늑대 전사 크리 확률 |
| `hybridWiseBearSlowIntensity` | 0.40 (40%) | 현자곰 둔화 강도 |
| `hybridMysticSageHealFraction` | 0.03 (3%) | 신비술사 성벽 회복률 |

## 투사체 비주얼

- 하이브리드 투사체는 **이중 색상** (부모 A + B 블렌딩)
- 보라색 코어
- 진화 시 골드 트레일
- 크기 보너스: `+0.3` (`BalanceConfig.projectileVisualScaleHybrid`)

## 머지 이펙트

| 이벤트 | 파티클 수 | Game Feel |
|--------|-----------|-----------|
| 하이브리드 머지 | 25 (`particleHybridMerge`) | 히트스탑 0.1s, 슬로모 0.4x/0.6s, 줌 1.05x |
| 머지 플래시 색상 | 보라 (`0xFFE040FB`) | 0.25s 페이드 |

## 영구 업그레이드

| ID | 이름 | 효과 | 최대 레벨 |
|----|------|------|-----------|
| `hybridBonus` | 하이브리드 강화 | 하이브리드 ATK +5%/Lv | 10 |

## 새 하이브리드 추가 방법

1. `HybridDatabase.recipes`에 `HybridRecipe` 추가
2. `HybridDatabase.all`에 `HybridUnitData` 추가
3. `renderers/unit_renderer.dart`에 렌더링 케이스 추가
4. 특수 능력 로직 → `defense_unit.dart`
5. 테스트: `test/data/hybrid_unit_data_test.dart` 업데이트
