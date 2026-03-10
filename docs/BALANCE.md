# 밸런스 수치 총정리

> 모든 수치는 `lib/data/balance_config.dart`에 정의되어 있습니다.
> 밸런스 조절 시 이 파일 하나만 수정하면 됩니다.

## 경제

| 항목 | 값 | 설명 |
|------|-----|------|
| 기본 유닛 비용 | 10골드 | `baseUnitCost` |
| 비용 증가율 | 1.15^n | `unitCostScale` |
| 판매 환불 | 50% | `sellRefundRate` (재활용 유물 시 80%) |
| 리롤 비용 | 20골드 | `rerollCost` |
| 퍼펙트 웨이브 보너스 | 5 * 연속횟수 | `perfectWaveGoldPerStreak` |
| 스타 보상 배율 | wave * 1.0 | `baseStarMultiplier` |

## 유닛 스케일링

| 항목 | 값 | 설명 |
|------|-----|------|
| ATK 배율 | 2.0^(lv-1) | `unitAtkLevelBase` |
| 공속 보너스/레벨 | +0.1 | `unitAtkSpeedPerLevel` |
| 사거리 보너스/레벨 | +5px | `unitRangePerLevel` |
| 최대 레벨 | 5 | `maxUnitLevel` (무한머지 유물 시 7) |
| 머지 필요 수 | 3개 | `mergeCount` (합성의 서 유물 시 2개) |

## 적 스케일링

| 항목 | 값 | 설명 |
|------|-----|------|
| HP 웨이브 배율 | 1.08^wave | `enemyHpWaveScale` |
| HP 유닛 수 배율 | +12%/유닛 | `enemyHpUnitScale` |
| 속도 유닛 수 배율 | +2%/유닛 | `enemySpeedUnitScale` |
| 속도 후반 배율 | +0.5%/wave(30+) | `enemySpeedLateWaveScale` |
| 후반 배율 시작 웨이브 | 30 | `enemySpeedLateWaveStart` |

## 웨이브 시스템

| 항목 | 값 | 설명 |
|------|-----|------|
| 웨이브 지속시간 | 20초 | `waveDuration` (시간의 모래 유물 시 10초) |
| 웨이브 간 휴식 | 3초 | `betweenWavePause` |
| 보스 등장 주기 | 10웨이브 | `bossInterval` |
| 보상 선택 주기 | 5웨이브 | `rewardInterval` |
| 최소 스폰 간격 | 0.15초 | `minSpawnInterval` |
| 최대 스폰 간격 | 3.0초 | `maxSpawnInterval` |

## 후반 웨이브 적 수 스케일링 (wave_manager.dart)

| 웨이브 | 기본 적 수 | 설명 |
|--------|-----------|------|
| 1~14 | 5~15 | 기존과 동일 |
| 15~19 | 20 | 중반 진입 |
| 20~23 | 30 | 후반 진입 |
| 24~29 | 40 | 대량 스폰 |
| 30+ | 60 | 최대 스폰 |

## 웨이브 적 수

| 항목 | 값 | 설명 |
|------|-----|------|
| 기본 적 수 티어 | [5,5] [10,7] [20,10] [30,13] | `baseEnemyCountTiers` |
| 기본값 (30+) | 16 | `baseEnemyCountDefault` |
| 웨이브 스케일 | +0.8/wave | `enemyCountWaveScale` |
| 유닛 수 스케일 | +4%/유닛 | `enemyCountUnitScale` |
| 최대 적 수/웨이브 | 200 | `maxEnemiesPerWave` |

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

## 유닛별 특수 수치

### 여우 암살자

| 항목 | 값 |
|------|-----|
| 크리 확률 | 20% (`foxCritChance`) |
| 크리 배율 | 2x (유물 crit_dmg 시 2.5x) |

### 거북 힐러

| 항목 | 값 |
|------|-----|
| 성벽 회복 비율 | 공격 데미지의 50% (`turtleHealerHealFraction`) |

### 곰 탱커

| 항목 | 값 |
|------|-----|
| 슬로우 강도 | 30% (`bearSlowIntensity`) |
| 슬로우 지속 | 2.5초 (`bearSlowDuration`) |

## 유물 시스템 (relic_data.dart + relic_manager.dart)

### 희귀도별 드롭 가중치

| 등급 | 가중치 | 드롭 확률 (근사) |
|------|--------|-----------------|
| 일반 | 40 | ~40% |
| 레어 | 30 | ~30% |
| 에픽 | 20 | ~20% |
| 전설 | 8 | ~8% |
| 신화 | 2 | ~2% |

> `relicQualityBonus` 영구 업그레이드로 고등급 확률 증가 (+3%/Lv, 최대 10Lv)

### 유물 최대 소지: 5개 (`maxRelics`, 무한의 돌 시 +2)

### 주요 유물 효과 수치

| 유물 | 효과 |
|------|------|
| ATK 부스트 | +15% (`relicAtkBonus`) |
| 공속 부스트 | +15% (`relicAtkSpeedBonus`) |
| 골드 부스트 | +30% (`relicGoldBonus`) |
| 성벽 방어 | -20% 피해 (`relicWallDefenseBonus`) |
| 크리 확률 | +10% (`relicCritBonus`) |
| 크리 데미지 | 기본 2x → 2.5x |
| 흡혈 | 2% 데미지 → 성벽 회복 (`relicLifestealPercent`) |
| 흡혈 강화 | 5% |
| 스타 보너스 | +20% (`relicStarBonus`) |
| 슬로우 오라 | 성벽 주변, 20% 감속 |
| 사거리 | +20% |
| 투사체 속도 | +30% |
| 광전사 | HP <30% → ATK x2 |
| 역전의 법칙 | 1%HP → ATK x5 (신화) |
| 전쟁의 신 | ATK x3, 성벽 HP -50% (전설) |
| 마이다스 | ATK=0, 처치당 골드 +5 (전설) |
| 시간의 모래 | 웨이브 10초, 적 속도 -30% (전설) |
| 가시 갑옷 | 성벽 피격 시 반사 데미지 10 |
| 처치 회복 | 적 처치 시 성벽 HP +1 |
| 웨이브 골드 | 웨이브 시작 시 +10 골드 |
| 보스 골드 | +50% |
| 보물 사냥꾼 | 보스 골드 x3 |
| 쌍둥이 | 유닛 구매 시 30% 확률 2마리 |
| 도박사 | 50% 무료 / 50% 비용 x2 |
| 재활용 | 판매 환불 50% → 80% |
| 근성 | 1회 성벽 HP=1 생존 |
| 불사조 | 1회 부활 + HP 50% |
| 살아있는 성벽 | 초당 15 데미지 |
| 성벽 포탑 | 초당 20 데미지 |
| 폭발 머지 | 머지 시 범위 30 데미지 |
| 축복의 비 | 3웨이브마다 HP 15% 회복 |
| 차원 균열 | 웨이브 시작 무료 유닛 1개 |
| 시간 왜곡 | 5웨이브마다 3초 슬로모션 |
| 무한 머지 | 최대 레벨 5 → 7 |
| 무한의 돌 | 유물 슬롯 +2 |

## 콤보 시스템 (combo_manager.dart)

| 항목 | 값 | 설명 |
|------|-----|------|
| 콤보 윈도우 | 2.0초 + comboDurationBonus | 연속 처치 유지 시간 |
| 골드 보너스 간격 | 10콤보마다 | `goldBonusInterval` |
| 골드 보너스 공식 | (comboCount / 10) * 5 | 10콤보=5G, 20콤보=10G |

### 콤보 티어

| 티어 | 임계값 | 이펙트 크기 |
|------|--------|-----------|
| NICE | 5+ | x1.2 |
| GREAT | 10+ | x1.5 |
| AMAZING | 25+ | x2.0 |
| UNSTOPPABLE | 50+ | x2.5 |
| GODLIKE | 100+ | x3.0 |

## 영구 업그레이드 (defense_upgrade_manager.dart)

### 기본 업그레이드 11종

| ID | 이름 | 효과/Lv | 최대Lv | 기본비용 |
|----|------|---------|--------|---------|
| wallHp | 성벽 강화 | HP +5% | 30 | 10 |
| wallRegen | 성벽 재생 | +0.5 HP/초 | 20 | 15 |
| wallDefense | 성벽 방어 | 피해 -2% | 20 | 20 |
| unitAtk | 유닛 공격력 | ATK +3% | 30 | 12 |
| unitAtkSpeed | 유닛 공속 | 공속 +2% | 25 | 15 |
| startUnits | 초기 유닛 | 무료 유닛 +1 | 5 | 50 |
| goldGain | 골드 획득 | 골드 +5% | 30 | 10 |
| unitDiscount | 유닛 할인 | 비용 -2% | 20 | 18 |
| starBonus | 스타 보너스 | 스타 +5% | 20 | 25 |
| slotExpansion | 배치 확장 | 슬롯 +1 (기본8) | 8 | 60 |
| relicChance | 유물 행운 | 선택지 확률 +5% | 10 | 30 |

### Phase 4 신규 업그레이드 5종

| ID | 이름 | 효과/Lv | 최대Lv | 기본비용 |
|----|------|---------|--------|---------|
| startGold | 초기 자금 | 시작 골드 +20 | 10 | 15 |
| relicQuality | 유물 품질 | 고등급 유물 확률 +3% | 10 | 40 |
| comboDuration | 콤보 지속 | 콤보 유지 +0.3초 | 10 | 20 |
| hybridBonus | 하이브리드 강화 | 하이브리드 ATK +5% | 10 | 35 |
| critChance | 기본 크리티컬 | 기본 크리 확률 +2% | 10 | 25 |

### 비용 공식
```
upgradeCost(lv) = baseCost * 1.12^lv
```

## 웨이브 보상 카드 (wave_reward_screen.dart)

| 등급 | 확률 | 예시 효과 |
|------|------|----------|
| 일반 | 60% | ATK +10%, 성벽 회복 10%, 골드 +15%, 공속 +10%, 사거리 +15% |
| 레어 | 25% | 유닛 비용 -20%, 성벽 방어 +20% |
| 에픽 | 12% | ATK +25%, 성벽 자동회복 1/s, 비용 -30% |
| 전설 | 3% | 성벽 완전회복, 전체 강화 +15% |

## 투사체 / 뷰포트

| 항목 | 값 | 설명 |
|------|-----|------|
| 투사체 속도 | 200 | `projectileSpeed` (유물 +30%) |
| 스플래시 반경 | 40px | `splashRadius` |
| 게임 너비 | 400px | `gameWidth` |
| 게임 높이 | 700px | `gameHeight` |

## 폭탄병

| 항목 | 값 | 설명 |
|------|-----|------|
| 폭발 배율 | 2.0x | `bomberExplosionMultiplier` |
