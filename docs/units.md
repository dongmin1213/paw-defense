# 유닛 시스템 (Units)

> 이 문서만 읽으면 유닛 관련 작업을 독립적으로 수행할 수 있습니다.

## 소스 파일

| 파일 | 역할 |
|------|------|
| `lib/data/unit_data.dart` | 8종 기본 유닛 + 8종 진화 유닛 데이터 정의 |
| `lib/data/hybrid_unit_data.dart` | 28종 하이브리드 유닛 데이터 (별도 문서: `hybrids.md`) |
| `lib/components/defense_unit.dart` | 유닛 컴포넌트 (전투 로직, 타겟팅, 공격) |
| `lib/renderers/unit_renderer.dart` | 픽셀아트 렌더링 (static 메서드) |
| `lib/data/balance_config.dart` | 유닛 관련 밸런스 상수 |

## 기본 유닛 8종

| ID | 이름 | 이모지 | ATK | 공속 | 사거리 | 근접 | 대공 | 범위 | 관통 | 특징 |
|----|------|--------|-----|------|--------|------|------|------|------|------|
| `catArcher` | Cat Archer | 🐱 | 10 | 1.5 | 120 | - | O | - | - | 빠른 단일 타겟 원거리 |
| `dogWarrior` | Dog Warrior | 🐶 | 15 | 0.8 | 40 | O | - | O | - | 근접 스플래시 |
| `rabbitMage` | Rabbit Mage | 🐰 | 20 | 0.5 | 100 | - | - | O | - | 느리지만 강력한 AoE |
| `bearTanker` | Bear Tanker | 🐻 | 8 | 0.6 | 35 | O | - | - | - | 둔화 부여 (30%, 2.5초) |
| `foxAssassin` | Fox Assassin | 🦊 | 25 | 0.7 | 90 | - | - | - | - | 크리 확률 20%, 크리 배율 2.0x |
| `birdScout` | Bird Scout | 🐦 | 12 | 1.0 | 110 | - | O | - | O | 관통 + 대공 |
| `turtleHealer` | Turtle Healer | 🐢 | 5 | 0.4 | 60 | O | - | - | - | 공격 시 성벽 회복 (ATK의 50%) |
| `owlWizard` | Owl Wizard | 🦉 | 18 | 0.6 | 130 | - | O | O | - | 최장 사거리 AoE + 대공 |

## 레벨 스케일링

유닛은 동종 3마리(합성의서 유물 보유 시 2마리) 합체로 레벨업합니다.

### 공격력
```
실제 ATK = baseAtk × pow(2.0, level - 1) × 업그레이드 보정
```
- `BalanceConfig.unitAtkLevelBase = 2.0` — 레벨당 ATK 배율 베이스
- Lv1=1x, Lv2=2x, Lv3=4x, Lv4=8x, Lv5=16x

### 공격속도
```
실제 공속 = baseAtkSpeed × (1 + (level-1) × 0.1) × 업그레이드 보정
```
- `BalanceConfig.unitAtkSpeedPerLevel = 0.1` — 레벨당 +10%

### 사거리
```
실제 사거리 = range + (level-1) × 5.0 × 업그레이드 보정
```
- `BalanceConfig.unitRangePerLevel = 5.0` — 레벨당 +5px

### 최대 레벨
- `BalanceConfig.maxUnitLevel = 5` (무한 머지 유물 시 7)
- `BalanceConfig.mergeCount = 3` (합성의서 유물 시 2)

## 진화 유닛 8종

Lv5 유닛이 해당 진화석 유물을 보유하면 진화합니다.

| 기본 유닛 | 진화 ID | 진화 이름 | ATK 배율 | 필요 유물 | 특수 효과 |
|-----------|---------|----------|----------|-----------|-----------|
| Cat Archer | `stormArcher` | Storm Archer | 3.0x | `evolve_cat_archer` | 넓은 범위 화살비 |
| Dog Warrior | `flameKnight` | Flame Knight | 2.5x | `evolve_dog_warrior` | 근접 화상 DoT |
| Rabbit Mage | `archmage` | Archmage | 3.0x | `evolve_rabbit_mage` | 거대 범위 마법 폭발 |
| Bear Tanker | `ironGuardian` | Iron Guardian | 2.5x | `evolve_bear_tanker` | 강력한 둔화 + 약화 |
| Fox Assassin | `shadowFox` | Shadow Fox | 3.0x | `evolve_fox_assassin` | 독 DoT |
| Bird Scout | `stormHawk` | Storm Hawk | 2.5x | `evolve_bird_scout` | 넉백 + 전체 관통 |
| Turtle Healer | `ancientTurtle` | Ancient Turtle | 2.5x | `evolve_turtle_healer` | AoE 힐 펄스 |
| Owl Wizard | `cosmicOwl` | Cosmic Owl | 3.0x | `evolve_owl_wizard` | 메테오 샤워 |

### 진화 유닛 보정
- 공격속도: `× 1.2` (`BalanceConfig.unitEvolvedAtkSpeedMult`)
- 사거리: `× 1.2` (`BalanceConfig.unitEvolvedRangeMult`)

## 유닛별 특수 메카닉

### Fox Assassin 크리티컬
```dart
critChance = BalanceConfig.foxCritChance; // 0.20 (20%)
critMultiplier = BalanceConfig.foxCritMultiplier; // 2.0x
```

### Bear Tanker 둔화
```dart
slowIntensity = BalanceConfig.bearSlowIntensity; // 0.3 (30%)
slowDuration = BalanceConfig.bearSlowDuration; // 2.5초
```

### Turtle Healer 성벽 회복
```dart
healAmount = damage × BalanceConfig.turtleHealerHealFraction; // 0.5 (ATK의 50%)
```

## 유닛 행동 상수 (BalanceConfig)

| 상수 | 값 | 설명 |
|------|-----|------|
| `unitTargetSearchInterval` | 0.15s | 타겟 탐색 쓰로틀 간격 |
| `unitRecoilDuration` | 0.15s | 공격 반동 애니메이션 시간 |
| `unitBeamDuration` | 0.25s | 공격 빔 시각 표시 시간 |
| `unitWarCryAtkMult` | 1.5x | 전투의함성 스킬 ATK 배율 |

## 유닛 궤도 회전

유닛은 성벽 주위를 공전합니다.

```
orbitSpeed = 0.3 × (1 + wave × 0.02) × (1 + units × 0.05)
```

| 상수 | 값 | 설명 |
|------|-----|------|
| `orbitBaseSpeed` | 0.3 rad/s | 기본 공전 속도 (~20초/회전) |
| `orbitWaveScale` | 0.02 | 웨이브당 속도 증가 |
| `orbitUnitScale` | 0.05 | 유닛당 속도 증가 |

## 경제: 유닛 구매

```
unitCost = baseUnitCost × pow(unitCostScale, purchased) × unitCostDiscount
```

| 상수 | 값 | 설명 |
|------|-----|------|
| `baseUnitCost` | 10 | 첫 유닛 비용 |
| `unitCostScale` | 1.15 | 구매마다 비용 증가 |
| `sellRefundRate` | 0.5 | 판매 환불율 50% |
| `rerollCost` | 20 | 리롤 비용 |

## 영구 업그레이드 (유닛 관련)

| 업그레이드 ID | 이름 | 효과 | 최대 레벨 |
|--------------|------|------|-----------|
| `unitAtk` | 유닛 공격력 | ATK +3%/Lv | 30 |
| `unitAtkSpeed` | 유닛 공속 | 공속 +2%/Lv | 25 |
| `startUnits` | 초기 유닛 | 시작 시 무료 유닛 +1/Lv | 5 |
| `hybridBonus` | 하이브리드 강화 | 하이브리드 ATK +5%/Lv | 10 |
| `critChance` | 기본 크리티컬 | 크리 확률 +2%/Lv | 10 |
| `unitDiscount` | 유닛 할인 | 구매 비용 -2%/Lv | 20 |

## 투사체 비주얼 스케일링

레벨이 올라갈수록 투사체가 커지고 트레일이 길어집니다.

### 크기
```
scale = 1.2 + (level-1) × 0.3 + (evolved ? 0.5 : 0) + (hybrid ? 0.3 : 0)
```

### 트레일 길이
```
trailLength = clamp(10 + (level-1) × 2 + (evolved ? 4 : 0), 10, 24)
```

## 머즐 플래시

유닛 공격 시 파티클 이펙트:
- 기본: `2 + level × 2` 개 파티클
- 진화: 골드 색상
- 하이브리드: 보라 색상
- 8종 유닛별 고유 색상

## 새 유닛 추가 방법

1. `UnitType` enum에 새 타입 추가
2. `UnitDatabase.all`에 `UnitData` 추가
3. `UnitDatabase.evolutions`에 `EvolvedUnitData` 추가
4. `renderers/unit_renderer.dart`에 렌더링 케이스 추가
5. 하이브리드 조합 추가 시 `hybrid_unit_data.dart` 수정 (→ `hybrids.md` 참고)
6. 테스트 업데이트: `test/data/unit_data_test.dart`
