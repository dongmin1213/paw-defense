# 적 시스템 (Enemies)

> 이 문서만 읽으면 적 관련 작업을 독립적으로 수행할 수 있습니다.

## 소스 파일

| 파일 | 역할 |
|------|------|
| `lib/data/enemy_data.dart` | 16종 적 스탯 + 해금 웨이브 정의 |
| `lib/components/defense_enemy.dart` | 적 컴포넌트 (이동, 공격, DoT, 사망) |
| `lib/renderers/defense_enemy_renderer.dart` | 적 픽셀아트 렌더링 |
| `lib/data/balance_config.dart` | 적 스케일링/행동 상수 |

## 적 16종

| ID | 이름 | 해금 | HP | 속도 | DMG | 공속 | 골드 | 비행 | 특수 |
|----|------|------|-----|------|-----|------|------|------|------|
| `slime` | 슬라임 | W1 | 20 | 40 | 3 | 1.0 | 2 | - | 기본 적 |
| `goblin` | 고블린 | W4 | 35 | 60 | 5 | 1.2 | 4 | - | 빠른 이동 |
| `skeleton` | 스켈레톤 | W6 | 30 | 55 | 6 | 1.3 | 5 | - | 빠른 공속 |
| `bat` | 박쥐 | W7 | 15 | 70 | 3 | 1.5 | 3 | O | 비행 + 최고속 공속 |
| `orc` | 오크 | W10 | 80 | 30 | 10 | 0.6 | 8 | - | 고 HP + 강 공격 |
| `mushroom` | 독버섯 | W12 | 25 | 35 | 8 | 0.7 | 7 | - | 독 공격 |
| `shielded` | 방패병 | W15 | 120 | 25 | 7 | 0.8 | 10 | - | 정면 피해 -50% |
| `wraith` | 레이스 | W16 | 45 | 65 | 9 | 1.1 | 9 | O | 비행 + 빠른 이동 |
| `bomber` | 폭탄병 | W18 | 40 | 50 | 15 | 0.5 | 12 | - | 자폭 데미지 x2 |
| `healer` | 힐러 | W20 | 50 | 35 | 4 | 1.0 | 6 | - | 주변 적 회복 |
| `golem` | 골렘 | W22 | 150 | 18 | 12 | 0.4 | 15 | - | 최고 HP + 느린 이동 |
| `necromancer` | 네크로맨서 | W25 | 60 | 30 | 6 | 0.8 | 14 | - | 소환/부활 계열 |
| `shadow` | 그림자 암살자 | W28 | 35 | 80 | 12 | 1.4 | 11 | - | 최고 이동속도 |
| `ice_mage` | 얼음 마법사 | W30 | 55 | 35 | 8 | 0.6 | 13 | - | 둔화 마법 |
| `dragon_whelp` | 용 새끼 | W35 | 100 | 50 | 14 | 0.9 | 18 | O | 비행 + 고 스탯 |
| `lich` | 리치 | W40 | 200 | 20 | 20 | 0.5 | 25 | - | 최강 지상 적 |

## 보스

10웨이브마다 보스가 등장합니다. (`BalanceConfig.bossInterval = 10`)

| 상수 | 값 |
|------|-----|
| `bossBaseHp` | 200 |
| `bossSpeed` | 20 |
| `bossDamage` | 20 |
| `bossAtkSpeed` | 0.5 |
| `bossGoldDrop` | 50 |
| `bossSizeMultiplier` | 1.5x |

보스 HP는 일반 적과 동일한 웨이브 스케일링이 적용됩니다.

## HP 스케일링

```
scaledHp = baseHp × pow(1.08, wave) × (1 + unitCount × 0.12) × swarmHpMult(0.30)
```

| 상수 | 값 | 설명 |
|------|-----|------|
| `enemyHpWaveScale` | 1.08 | 웨이브당 HP 배율 |
| `enemyHpUnitScale` | 0.12 | 유닛당 HP 보정 |
| `swarmHpMultiplier` | 0.30 | 스웜 밀도 보정 (적 수 2배, HP 0.3배) |
| `enemyHpSoftCapWave` | 40 | HP 소프트캡 시작 웨이브 |
| `enemyHpSoftCapMultiplier` | 0.70 | 소프트캡 이후 성장률 감소 |

## 속도 스케일링

```
scaledSpeed = baseSpeed × (1 + unitCount × 0.02) × lateWaveBonus
lateWaveBonus = 1 + max(0, wave-30) × 0.005  (capped at 3.0x)
```

| 상수 | 값 | 설명 |
|------|-----|------|
| `enemySpeedUnitScale` | 0.02 | 유닛당 속도 증가 |
| `enemySpeedLateWaveScale` | 0.005 | W30 이후 웨이브당 속도 증가 |
| `enemySpeedLateWaveStart` | 30 | 후반 속도 스케일링 시작 |
| `enemySpeedMaxMultiplier` | 3.0 | 최대 속도 배율 |

## 적 행동 상수

| 상수 | 값 | 설명 |
|------|-----|------|
| `enemyWallProximity` | 35px | 성벽 도달 판정 거리 |
| `enemyHitFlashDuration` | 0.1s | 피격 플래시 |
| `enemyDeathAnimDuration` | 0.3s | 사망 애니메이션 |
| `enemyKnockbackDistance` | 3px | 피격 넉백 거리 |
| `bigHitThreshold` | 0.15 | 대형 타격 판정 (최대 HP의 15%) |

### 특수 적: 방패병 (Shielded)
```
shieldedDamageReduction = 0.5  // 정면 피해 50% 감소
```

### 특수 적: 폭탄병 (Bomber)
```
bomberExplosionMultiplier = 2.0  // 자폭 시 데미지 2배
```

### 특수 적: 힐러 (Healer)
| 상수 | 값 | 설명 |
|------|-----|------|
| `healerRadius` | 50px | 치유 범위 |
| `healerHealPercent` | 0.10 | 아군 최대 HP의 10% 회복/틱 |
| `healerInterval` | 3.0s | 치유 간격 |

## DoT (지속 피해) 시스템

| 상수 | 값 | 설명 |
|------|-----|------|
| `dotTickInterval` | 0.5s | DoT 틱 간격 |

### 원소 효과 (원소 폭풍 유물)
| 원소 | DoT/효과 | 지속시간 |
|------|----------|----------|
| 불 🔥 | 30% DoT/s | 3.0s |
| 얼음 ❄️ | 40% 슬로우 | 2.0s |
| 독 🟢 | 15% DoT/s | 5.0s |

### 얼음벽 스킬
```
iceWallSpeedMult = 0.3  // 적 이동속도 30%로 감소
```

## 적 사망 이펙트

| 적 타입 | 파티클 색상 | 수량 |
|---------|------------|------|
| 슬라임 | 초록 | 25 |
| 스켈레톤 | 흰 | 25 |
| 폭탄병 | 주황 + 추가 파티클 | 40 |
| 보스 | 폭발 이펙트 | 60 |
| 기본 | 타입별 고유 색상 | 25 |

## 스웜 시스템

적 수를 2배로 늘려 화면을 가득 채우고, 개별 HP를 0.30배로 낮춰 총 웨이브 HP를 유지합니다.
적 속도에 ±15% 편차를 부여하여 무리 느낌을 줍니다.

## New Game+ (Ascension)

| 상수 | 값 | 설명 |
|------|-----|------|
| `ascensionEnemyHpScale` | 1.25 | 승급당 적 HP 배율 |
| `ascensionBonusGold` | 20 | 승급당 보너스 시작 골드 |
| `ascensionStarMultiplier` | 0.15 | 승급당 스타 보너스 |

## 새 적 추가 방법

1. `DefenseEnemyDatabase.all`에 `DefenseEnemyData` 추가
2. `renderers/defense_enemy_renderer.dart`에 렌더링 케이스 추가
3. 특수 행동 → `components/defense_enemy.dart`에 로직 추가
4. 사망 이펙트 색상 → `components/defense_particle.dart`
5. 테스트: `test/data/enemy_data_test.dart` 업데이트
