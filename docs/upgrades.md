# 업그레이드 & 경제 시스템 (Upgrades & Economy)

> 이 문서만 읽으면 업그레이드/경제 관련 작업을 독립적으로 수행할 수 있습니다.

## 소스 파일

| 파일 | 역할 |
|------|------|
| `lib/systems/defense_upgrade_manager.dart` | 16종 영구 업그레이드 정의 + 멀티플라이어 |
| `lib/data/balance_config.dart` | 업그레이드 스케일링 상수 |
| `lib/systems/defense_save_manager.dart` | 세이브/로드 (업그레이드 영속) |

## 영구 업그레이드 16종

별(Star)로 구매. 런 사이에 영속됩니다.

### 비용 공식
```
cost = baseCost × pow(1.12, currentLevel)  // 반올림
```
- `BalanceConfig.upgradeCostScale = 1.12`

### 성벽 카테고리 (3종)

| ID | 이름 | 아이콘 | 기본 비용 | 최대 Lv | 효과/Lv | 상수 |
|----|------|--------|----------|---------|---------|------|
| `wallHp` | 성벽 강화 | 🏰 | 10 | 30 | 최대 HP +5% | `upgradeWallHpPerLevel = 0.05` |
| `wallRegen` | 성벽 재생 | 💚 | 15 | 20 | HP 재생 +0.5/s | `upgradeWallRegenPerLevel = 0.5` |
| `wallDefense` | 성벽 방어 | 🛡️ | 20 | 20 | 피해 -2% (최소 40%) | `upgradeWallDefensePerLevel = 0.02`, `min = 0.4` |

### 유닛 카테고리 (5종)

| ID | 이름 | 아이콘 | 기본 비용 | 최대 Lv | 효과/Lv | 상수 |
|----|------|--------|----------|---------|---------|------|
| `unitAtk` | 유닛 공격력 | ⚔️ | 12 | 30 | ATK +3% | `upgradeUnitAtkPerLevel = 0.03` |
| `unitAtkSpeed` | 유닛 공속 | ⚡ | 15 | 25 | 공속 +2% | `upgradeUnitAtkSpeedPerLevel = 0.02` |
| `startUnits` | 초기 유닛 | 🐾 | 50 | 5 | 시작 시 무료 유닛 +1 | - |
| `hybridBonus` | 하이브리드 강화 | 🧬 | 35 | 10 | 하이브리드 ATK +5% | `upgradeHybridBonusPerLevel = 0.05` |
| `critChance` | 기본 크리티컬 | 💥 | 25 | 10 | 크리 확률 +2% | `upgradeCritChancePerLevel = 0.02` |

### 경제 카테고리 (4종)

| ID | 이름 | 아이콘 | 기본 비용 | 최대 Lv | 효과/Lv | 상수 |
|----|------|--------|----------|---------|---------|------|
| `goldGain` | 골드 획득 | 💰 | 10 | 30 | 골드 +5% | `upgradeGoldGainPerLevel = 0.05` |
| `unitDiscount` | 유닛 할인 | 🏷️ | 18 | 20 | 비용 -2% (최소 40%) | `upgradeUnitDiscountPerLevel = 0.02`, `min = 0.4` |
| `starBonus` | 스타 보너스 | ⭐ | 25 | 20 | 별 +5% | `upgradeStarBonusPerLevel = 0.05` |
| `startGold` | 초기 자금 | 🪙 | 15 | 10 | 시작 골드 +20 | `upgradeStartGoldPerLevel = 20` |

### 특수 카테고리 (4종)

| ID | 이름 | 아이콘 | 기본 비용 | 최대 Lv | 효과/Lv | 상수 |
|----|------|--------|----------|---------|---------|------|
| `slotExpansion` | 배치 확장 | 📦 | 60 | 8 | 슬롯 +1 (기본 8) | `upgradeBaseSlots = 8` |
| `relicChance` | 유물 행운 | 🍀 | 30 | 10 | 추가 선택지 +5% | `upgradeRelicChancePerLevel = 0.05` |
| `relicQuality` | 유물 품질 | 🔮 | 40 | 10 | 높은 등급 +3% | `upgradeRelicQualityPerLevel = 0.03` |
| `comboDuration` | 콤보 지속 | 🔥 | 20 | 10 | 콤보 유지 +0.3s | `upgradeComboDurationPerLevel = 0.3` |

## 인게임 경제

### 유닛 구매
```
cost = baseUnitCost(10) × pow(unitCostScale(1.15), purchased) × unitCostDiscount(업그레이드)
```

### 판매
```
refund = purchaseCost × sellRefundRate(0.5)
// 재활용 유물 시 0.8
```

### 리롤
```
rerollCost = 20
```

### 골드 획득 보정
```
finalGold = baseGold × goldGainMultiplier(업그레이드) × relicBonus × comboBonus
```

### 캐치업 골드
진행이 기대치보다 5웨이브 뒤처지면 골드 ×1.5:
```
catchUpGoldMultiplier = 1.5
catchUpWaveThreshold = 5
```

### 퍼펙트 웨이브 보너스
```
bonusGold = perfectStreak × perfectWaveGoldPerStreak(5)
```

## 별(Star) 보상

```
stars = waveReached × baseStarMultiplier(1.0) × starBonusMultiplier(업그레이드) × ascensionBonus
```

## 성벽

| 상수 | 값 | 설명 |
|------|-----|------|
| `wallBaseHp` | 100 | 성벽 기본 HP |
| `wallHpPerLevel` | 30 | 인게임 레벨당 HP 증가 |

### 성벽 인게임 업그레이드
```
maxHp = 100 + (level-1) × 30  // wallHpPerLevel
```

### 불사조 부활
```
wallPhoenixRevivePercent = 0.5  // HP 50%로 부활
```

## 세이브/로드

`defense_save_manager.dart`에서 관리:
- **영구 저장**: 업그레이드 레벨, 별, 해금 시스템, 업적, 도감
- **중간 저장**: 골드, 킬수, 웨이브, 유물, 슬롯, 벽 HP (앱 백그라운드 시 자동)
- **이어하기**: 저장된 런 상태에서 현재 웨이브 재시작

### 점진적 시스템 해금
플레이 진행에 따라 순차 해금:
1. 머지 힌트
2. 보상 카드
3. 유물
4. 하이브리드
5. 콤보
6. 진화
7. 업적
