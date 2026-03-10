# 밸런스 수치 총정리

> 모든 수치는 `lib/data/balance_config.dart`에 정의되어 있습니다.
> 밸런스 조절 시 이 파일 하나만 수정하면 됩니다.

## 경제

| 항목 | 값 | 설명 |
|------|-----|------|
| 기본 유닛 비용 | 10골드 | `baseUnitCost` |
| 비용 증가율 | 1.15^n | `unitCostScale` |
| 판매 환불 | 50% | `sellRefundRate` |
| 리롤 비용 | 20골드 | `rerollCost` |
| 퍼펙트 웨이브 보너스 | 5 * 연속횟수 | `perfectWaveGoldPerStreak` |

## 유닛 스케일링

| 항목 | 값 | 설명 |
|------|-----|------|
| ATK 배율 | 2.0^(lv-1) | `unitAtkLevelBase` |
| 공속 보너스/레벨 | +0.1 | `unitAtkSpeedPerLevel` |
| 사거리 보너스/레벨 | +5px | `unitRangePerLevel` |
| 최대 레벨 | 5 | `maxUnitLevel` |
| 머지 필요 수 | 3개 | `mergeCount` |

## 적 스케일링

| 항목 | 값 | 설명 |
|------|-----|------|
| HP 웨이브 배율 | 1.08^wave | `enemyHpWaveScale` |
| HP 유닛 수 배율 | +12%/유닛 | `enemyHpUnitScale` |
| 속도 유닛 수 배율 | +2%/유닛 | `enemySpeedUnitScale` |
| 속도 후반 배율 | +0.5%/wave(30+) | `enemySpeedLateWaveScale` |

## 웨이브 시스템

| 항목 | 값 | 설명 |
|------|-----|------|
| 웨이브 지속시간 | 20초 | `waveDuration` |
| 웨이브 간 휴식 | 3초 | `betweenWavePause` |
| 보스 등장 주기 | 10웨이브 | `bossInterval` |
| 보상 선택 주기 | 5웨이브 | `rewardInterval` |
| 최소 스폰 간격 | 0.15초 | `minSpawnInterval` |

## 보스

| 항목 | 값 | 설명 |
|------|-----|------|
| 기본 HP | 200 | `bossBaseHp` |
| 속도 | 20 | `bossSpeed` |
| 공격력 | 20 | `bossDamage` |
| 공속 | 0.5 | `bossAtkSpeed` |
| 골드 | 50 | `bossGoldDrop` |

## 성벽

| 항목 | 값 | 설명 |
|------|-----|------|
| 기본 HP | 100 | `wallBaseHp` |
| 레벨당 HP | +30 | `wallHpPerLevel` |

## 유물 보너스 (relic_manager.dart)

| 유물 | 효과 |
|------|------|
| ATK 부스트 | +15% |
| 공속 부스트 | +15% |
| 골드 부스트 | +30% |
| 성벽 방어 | -20% 피해 |
| 크리 확률 | +10% |
| 흡혈 | 2% 데미지 → 성벽 회복 |
| 스타 보너스 | +20% |

## 웨이브 보상 카드 (wave_reward_screen.dart)

| 등급 | 확률 | 예시 효과 |
|------|------|----------|
| 일반 | 60% | ATK +10%, 성벽 회복 10%, 골드 +15% |
| 레어 | 25% | 유닛 비용 -20%, 성벽 방어 +20% |
| 에픽 | 12% | ATK +25%, 성벽 자동회복, 비용 -30% |
| 전설 | 3% | 성벽 완전회복, 전체 강화 +15% |

## 여우 암살자

| 항목 | 값 |
|------|-----|
| 크리 확률 | 20% |
| 크리 배율 | 2x |
