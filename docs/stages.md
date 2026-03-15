# 스테이지/웨이브 시스템 (Stages & Waves)

> 이 문서만 읽으면 웨이브/스테이지 관련 작업을 독립적으로 수행할 수 있습니다.

## 소스 파일

| 파일 | 역할 |
|------|------|
| `lib/systems/wave_manager.dart` | 웨이브 생성, 적 스폰, 보스 웨이브 |
| `lib/systems/wave_modifier.dart` | 10종 웨이브 변형 시스템 |
| `lib/data/enemy_data.dart` | 적 해금 웨이브 정의 |
| `lib/data/balance_config.dart` | 모든 웨이브 관련 수치 |

## 웨이브 기본 구조

| 상수 | 값 | 설명 |
|------|-----|------|
| `waveDuration` | 20.0s | 웨이브 지속 시간 |
| `betweenWavePause` | 3.0s | 웨이브 사이 휴식 |
| `minSpawnInterval` | 0.03s | 최소 스폰 간격 (최대 스폰 속도) |
| `maxSpawnInterval` | 1.5s | 최대 스폰 간격 (최소 스폰 속도) |

## 적 수 계산

```
baseCount = tierCount(wave)  // 아래 티어 테이블 참조
scaledCount = baseCount + wave × 1.2
finalCount = scaledCount × (1 + unitCount × 0.04)
clampedCount = min(finalCount, 300)
```

### 적 수 티어 테이블

| 최대 웨이브 | 기본 적 수 |
|------------|-----------|
| ~3 | 40 |
| ~5 | 55 |
| ~10 | 70 |
| ~20 | 90 |
| ~30 | 120 |
| 31+ | 150 |

| 상수 | 값 |
|------|-----|
| `enemyCountWaveScale` | 1.2 |
| `enemyCountUnitScale` | 0.04 |
| `maxEnemiesPerWave` | 300 |

## 적 해금 프로그레션

```
W1:  슬라임
W4:  고블린
W6:  스켈레톤
W7:  박쥐(비행)
W10: 오크 + 보스
W12: 독버섯
W15: 방패병
W16: 레이스(비행)
W18: 폭탄병
W20: 힐러 + 보스
W22: 골렘
W25: 네크로맨서
W28: 그림자 암살자
W30: 얼음 마법사 + 보스
W35: 용 새끼(비행)
W40: 리치 + 보스
```

## 보스 웨이브

매 10웨이브마다 보스가 등장합니다.

| 상수 | 값 |
|------|-----|
| `bossInterval` | 10 |
| `bossBaseHp` | 200 |
| `bossSpeed` | 20 |
| `bossDamage` | 20 |
| `bossAtkSpeed` | 0.5 |
| `bossGoldDrop` | 50 |
| `bossSizeMultiplier` | 1.5x |

보스 HP도 일반 웨이브 스케일링이 적용됩니다.

## 보상 시스템

매 5웨이브마다 보상 선택지가 제공됩니다 (`rewardInterval = 5`).

### 보상 카드 수치

| 등급 | 보상 | 값 | 상수 |
|------|------|-----|------|
| Common | ATK 보너스 | +10% | `rewardAtkBonus` |
| Common | 성벽 회복 | 10% | `rewardWallHealPercent` |
| Common | 골드 보너스 | +15% | `rewardGoldBonus` |
| Common | 공속 보너스 | +10% | `rewardAtkSpeedBonus` |
| Common | 사거리 보너스 | +15% | `rewardRangeBonus` |
| Rare | 유닛 할인 | -20% | `rewardUnitCostDiscount` |
| Rare | 성벽 방어 | +20% | `rewardWallDefenseBonus` |
| Epic | 대형 ATK | +25% | `rewardAtkBonusLarge` |
| Epic | 자동 재생 | 1 HP/s | `rewardWallAutoRegen` |
| Epic | 대형 유닛 할인 | -30% | `rewardUnitCostDiscountLarge` |

보상 버프는 런 전체 지속 (`rewardBuffDurationWaves = 999`).

## 퍼펙트 웨이브

성벽 피해 없이 웨이브를 클리어하면 퍼펙트 웨이브 보너스:
```
bonusGold = streak × 5  // perfectWaveGoldPerStreak
```

| Game Feel | 값 |
|-----------|-----|
| 줌 펀치 | 1.03x, 0.3s |
| 플래시 | 초록 `0xFF4CAF50`, 0.2s |

## 웨이브 변형 시스템 (10종)

웨이브 10부터 (`waveModifierStartWave = 10`), 5웨이브마다 랜덤 적용. 보스 웨이브 제외.

| ID | 이름 | 효과 | 상수 |
|----|------|------|------|
| `sky_threat` | 하늘의 위협 | 비행 적만 등장 | - |
| `speed_run` | 스피드런 | 적 속도 x2, 골드 x1.5 | `modifierSpeedRunSpeedMult=2.0`, `modifierSpeedRunGoldMult=1.5` |
| `iron_march` | 철벽 행군 | 느리지만 HP 높은 적 | - |
| `elite` | 엘리트 | 적 수 x0.5, HP x3 | `modifierEliteCountMult=0.5`, `modifierEliteHpMult=3.0` |
| `swarm` | 물량공세 | 적 수 x3, HP x0.5 | `modifierSwarmCountMult=3.0`, `modifierSwarmHpMult=0.5` |
| `burning` | 불타는 땅 | 성벽 DoT | - |
| `golden` | 황금 웨이브 | 골드 x3 | `modifierGoldenGoldMult=3.0` |
| `lightning` | 번개 웨이브 | 랜덤 번개 데미지 | - |
| `fog` | 안개 | 유닛 사거리 x0.6 | `modifierFogRangeMult=0.6` |
| `chaos` | 카오스 | 여러 변형 동시 적용 | - |

## 스토리 마일스톤

| 상수 | 값 |
|------|-----|
| `storyMilestoneWaves` | [5, 10, 15, 20, 30, 40, 50] |

## 후반 밸런스 조정

### HP 소프트캡
웨이브 40 이후 HP 성장률이 70%로 감소:
```
if (wave > 40) hpScale *= pow(0.7, wave - 40)
```

### 캐치업 시스템
| 상수 | 값 | 설명 |
|------|-----|------|
| `catchUpGoldMultiplier` | 1.5 | 캐치업 골드 보너스 |
| `catchUpWaveThreshold` | 5 | 기대 진행도보다 5웨이브 뒤처지면 발동 |

## 배속 조절

1x ↔ 2x 토글 (`defense_game.dart`: `gameSpeed`, `toggleGameSpeed()`).

## 런 결과 랭크

| 랭크 | 기준 (웨이브) |
|------|-------------|
| F | ~5 |
| D | ~10 |
| C | ~15 |
| B | ~20 |
| A | ~30 |
| S | ~40 |
| SS | 50+ |

별 보상: `wave × baseStarMultiplier(1.0) × starBonusMultiplier(업그레이드)`

## New Game+ (Ascension)

| 상수 | 값 | 설명 |
|------|-----|------|
| `ascensionEnemyHpScale` | 1.25x | 승급당 적 HP |
| `ascensionBonusGold` | +20 | 승급당 시작 골드 |
| `ascensionStarMultiplier` | +15% | 승급당 스타 보너스 |
