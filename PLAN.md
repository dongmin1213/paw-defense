# Paw Defense 차별화 구현 계획

## 개요
뱀서/버섯커/스페이스xyz 대비 차별화를 위한 4대 개선 작업

> **상태**: ✅ 전체 완료 (2026-03-10)

---

## Phase 1: 유물 대개편 (10개 → 50개+) ✅

**영향도: ⭐⭐⭐⭐⭐ | 난이도: 중 | 가장 적은 코드로 가장 큰 빌드 다양성**

### 변경 파일
- `lib/data/relic_data.dart` **(신규)** — 유물 50개 데이터 정의 (RelicDef, RelicRarity, RelicDatabase)
- `lib/systems/relic_manager.dart` — 전면 리라이트: 가중 드롭, 50개 효과 쿼리, 이벤트 기반 효과
- `lib/data/balance_config.dart` — maxRelics=5, 유물 수치 추가
- `lib/ui/relic_selection_screen.dart` — RelicDatabase 기반 UI, 등급/효과 표시
- `lib/game/defense_game.dart` — 유물 효과 적용 (buyUnit, sellUnit, onEnemyKilled 등)
- `lib/components/wall.dart` — 근성/불사조 유물 연동
- `lib/components/defense_enemy.dart` — 가시갑옷(thorns), 시간의모래(속도감소) 연동
- `lib/components/defense_unit.dart` — 광전사/역전/크리/사거리/투사체 유물 연동
- `lib/systems/wave_manager.dart` — 시간의모래 웨이브 지속시간 오버라이드

### 유물 구성
- **진화석 8개** (에픽) — 유닛 8종 각각의 진화 재료
- **일반 15개** — 숫자 버프 (ATK, 공속, 사거리, 골드, 크리 등)
- **레어 15개** — 메카닉 변형 (분열탄, 관통강화, 광전사, 도박사 등)
- **에픽 12개** — 규칙 변경 (살아있는 성벽, 시간왜곡, 폭발머지 등)
- **전설 6개** — 런 정의 변경 (불사조, 마이다스, 전쟁의 신 등)
- **신화 2개** — 런 자체를 바꿈 (카오스, 역전의 법칙)

---

## Phase 2: 이종 머지 시스템 (Cross-Breed) ✅

**영향도: ⭐⭐⭐⭐⭐ | 난이도: 상 | 핵심 차별점**

### 변경 파일
- `lib/data/hybrid_unit_data.dart` **(신규)** — 12종 하이브리드 유닛 데이터 (HybridRecipe, HybridUnitData, HybridDatabase)
- `lib/systems/merge_manager.dart` — 크로스브리드 머지 로직 (findCrossBreedMerges, performCrossBreed)
- `lib/renderers/unit_renderer.dart` — 하이브리드 유닛 12종 픽셀아트 렌더링
- `lib/game/defense_game.dart` — _tryCrossBreedMerge(), _unitIcons에 하이브리드 이모지 추가
- `lib/components/defense_unit.dart` — isHybrid getter, 7개 static 룩업 메서드 (하이브리드 스탯 지원)

### 하이브리드 유닛 12종
| 조합 | ID | 이름 | 특수 능력 |
|------|-----|------|-----------|
| 🐱+🦊 | flame_hunter | 불꽃 사냥꾼 | 크리 20% + 관통 |
| 🐶+🐻 | iron_warrior | 철벽 전사 | 근접 광역 + 슬로우 |
| 🐰+🦉 | archmage | 대마법사 | 초대형 스플래시 + 장거리 |
| 🐢+🐻 | mountain_guard | 산악 수호자 | 성벽 회복 + 슬로우 |
| 🐱+🐦 | storm_archer | 폭풍 궁수 | 3연발 + 대공 + 관통 |
| 🦊+🐦 | wind_thief | 바람 도적 | 30% 회피 + 이동 사격 |
| 🐶+🐢 | holy_knight | 수호 기사 | 근접 광역 + 타격당 성벽 회복 |
| 🐰+🐢 | mystic_sage | 신비술사 | 범위 공격 + 성벽 HP 3% 회복 |
| 🐻+🦉 | wise_bear | 현자곰 | 장거리 광역 + 둔화 40% |
| 🦊+🦉 | shadow_sage | 그림자 현자 | 크리 30% + 광역 |
| 🐶+🦊 | wolf_blade | 늑대 전사 | 빠른 근접 + 크리 25% |
| 🐱+🐰 | spell_sniper | 스펠 스나이퍼 | 초장거리 저격 |

---

## Phase 3: 콤보 시스템 + 시각 이펙트 강화 ✅

**영향도: ⭐⭐⭐⭐ | 난이도: 중 | 도파민 루프의 핵심**

### 변경 파일
- `lib/systems/combo_manager.dart` **(신규)** — 5단계 콤보 티어, 2초 콤보 윈도우, 골드 보너스
- `lib/components/defense_particle.dart` — 500개 파티클 확장, 7종 신규 이펙트
- `lib/ui/defense_hud.dart` — 콤보 카운터 UI, 티어별 색상
- `lib/game/defense_game.dart` — comboManager 초기화, onEnemyKilled 콤보 연동
- `lib/systems/wave_manager.dart` — 후반 웨이브 적 대량 스케일링

### 콤보 티어
| 티어 | 연쇄 수 | 이펙트 크기 | 색상 |
|------|---------|------------|------|
| NICE | 5+ | x1.2 | 🟢 |
| GREAT | 10+ | x1.5 | 🔵 |
| AMAZING | 25+ | x2.0 | 🟣 |
| UNSTOPPABLE | 50+ | x2.5 | 🟡 |
| GODLIKE | 100+ | x3.0 | 🔴 |

### 후반 웨이브 적 수 스케일링
- 웨이브 15+: 20마리
- 웨이브 20+: 30마리
- 웨이브 24+: 40마리
- 웨이브 30+: 60마리

---

## Phase 4: 메타 진행 확장 ✅

**영향도: ⭐⭐⭐ | 난이도: 중 | 장기 리텐션**

### 변경 파일
- `lib/systems/defense_upgrade_manager.dart` — 5개 신규 영구 업그레이드 추가 + getter
- `lib/systems/achievement_manager.dart` **(신규)** — 업적 시스템 기반
- `lib/ui/achievement_screen.dart` **(신규)** — 업적 UI
- `lib/game/defense_game.dart` — startGoldBonus, relicQualityBonus 연동
- `lib/systems/combo_manager.dart` — comboDurationBonus 연동
- `lib/components/defense_unit.dart` — hybridAtkMultiplier, baseCritChance 연동
- `lib/systems/relic_manager.dart` — qualityBonus 가중 드롭 반영

### 신규 영구 업그레이드 5종
| ID | 이름 | 효과 | 최대 레벨 |
|----|------|------|----------|
| startGold | 초기 자금 | 런 시작 골드 +20/Lv | 10 |
| relicQuality | 유물 품질 | 고등급 유물 확률 +3%/Lv | 10 |
| comboDuration | 콤보 지속 | 콤보 유지 시간 +0.3초/Lv | 10 |
| hybridBonus | 하이브리드 강화 | 하이브리드 ATK +5%/Lv | 10 |
| critChance | 기본 크리티컬 | 기본 크리 확률 +2%/Lv | 10 |
