# 유닛 가이드

## 유닛 8종 (data/unit_data.dart)

| ID | 이름 | 아이콘 | 타입 | ATK | 공속 | 사거리 | 특수 |
|-----|------|--------|------|-----|------|--------|------|
| catArcher | 고양이 궁수 | 🐱 | 원거리 | 10 | 1.5 | 120 | 대공 가능, 단일 타겟 |
| dogWarrior | 강아지 전사 | 🐶 | 근거리+스플래시 | 15 | 0.8 | 40 | 광역 근접 공격 |
| rabbitMage | 토끼 마법사 | 🐰 | 원거리+스플래시 | 20 | 0.5 | 100 | 느리지만 강력한 광역 |
| bearTanker | 곰 탱커 | 🐻 | 근거리 | 8 | 0.6 | 35 | 적 슬로우 (30%, 2.5초) |
| foxAssassin | 여우 암살자 | 🦊 | 원거리 | 25 | 0.7 | 90 | 20% 크리 (2x) |
| birdScout | 새 정찰병 | 🐦 | 원거리+관통+대공 | 12 | 1.0 | 110 | 관통탄, 비행적 공격 |
| turtleHealer | 거북 힐러 | 🐢 | 근거리 | 5 | 0.4 | 60 | 공격 데미지의 50% 성벽 회복 |
| owlWizard | 부엉이 마법사 | 🦉 | 원거리+스플래시+대공 | 18 | 0.6 | 130 | 장거리 광역, 대공 가능 |

## 진화 유닛 8종 (unit_data.dart → EvolvedUnitData)

| 기본 유닛 | 진화 이름 | ATK 배율 | 특수 효과 | 필요 유물 |
|-----------|----------|----------|----------|----------|
| 🐱 Cat Archer | Storm Archer | 3.0x | 넓은 범위에 화살 비 | evolve_cat_archer |
| 🐶 Dog Warrior | Flame Knight | 2.5x | 근접 적 화상 도트 데미지 | evolve_dog_warrior |
| 🐰 Rabbit Mage | Archmage | 3.0x | 거대 범위 마법 폭발 | evolve_rabbit_mage |
| 🐻 Bear Tanker | Iron Guardian | 2.5x | 강력한 슬로우 + 약화 | evolve_bear_tanker |
| 🦊 Fox Assassin | Shadow Fox | 3.0x | 독 도트 데미지 | evolve_fox_assassin |
| 🐦 Bird Scout | Storm Hawk | 2.5x | 바람 넉백 + 전체 관통 | evolve_bird_scout |
| 🐢 Turtle Healer | Ancient Turtle | 2.5x | 범위 힐 + 성벽 수리 + 버프 | evolve_turtle_healer |
| 🦉 Owl Wizard | Cosmic Owl | 3.0x | 대규모 메테오 공격 | evolve_owl_wizard |

## 하이브리드 유닛 12종 (data/hybrid_unit_data.dart)

> **이종 머지**: 다른 종류의 유닛 2마리 (둘 다 Lv3+)를 합성하면 하이브리드 유닛 탄생

| 조합 | ID | 이름 | 이모지 | ATK | 공속 | 사거리 | 특수 능력 |
|------|-----|------|--------|-----|------|--------|----------|
| 🐱+🦊 | hybrid_flame_hunter | 불꽃 사냥꾼 | 🔥 | 35 | 1.2 | 120 | 크리 20% + 관통 + 대공 |
| 🐶+🐻 | hybrid_iron_warrior | 철벽 전사 | 🛡️ | 22 | 0.7 | 45 | 근접 광역 + 슬로우 |
| 🐰+🦉 | hybrid_archmage | 대마법사 | 🌟 | 40 | 0.4 | 140 | 초대형 스플래시 + 장거리 + 대공 |
| 🐢+🐻 | hybrid_mountain_guard | 산악 수호자 | 🏔️ | 12 | 0.5 | 50 | 성벽 회복 + 슬로우 40% |
| 🐱+🐦 | hybrid_storm_archer | 폭풍 궁수 | 🌪️ | 12 | 2.0 | 115 | 3연발 + 대공 + 관통 |
| 🦊+🐦 | hybrid_wind_thief | 바람 도적 | 💨 | 28 | 1.0 | 100 | 30% 회피 + 이동 사격 + 대공 |
| 🐶+🐢 | hybrid_holy_knight | 수호 기사 | ⚜️ | 15 | 0.7 | 40 | 근접 광역 + 타격당 성벽 회복 |
| 🐰+🐢 | hybrid_mystic_sage | 신비술사 | 🔮 | 18 | 0.5 | 80 | 범위 공격 + 성벽 HP 3% 회복 |
| 🐻+🦉 | hybrid_wise_bear | 현자곰 | 📚 | 16 | 0.5 | 110 | 장거리 광역 + 둔화 40% + 대공 |
| 🦊+🦉 | hybrid_shadow_sage | 그림자 현자 | 🌑 | 30 | 0.6 | 120 | 크리 30% + 광역 + 대공 |
| 🐶+🦊 | hybrid_wolf_blade | 늑대 전사 | 🐺 | 22 | 1.2 | 50 | 빠른 근접 연타 + 크리 25% |
| 🐱+🐰 | hybrid_spell_sniper | 스펠 스나이퍼 | 🎯 | 32 | 0.8 | 150 | 초장거리 저격 + 대공 |

### 하이브리드 고유 능력 상세

- **크리 유닛** (flame_hunter 20%, shadow_sage 30%, wolf_blade 25%): 유물 critDamageMultiplier 적용
- **힐러 유닛** (holy_knight, mystic_sage 3%, mountain_guard): 공격 시 성벽 자동 회복
- **슬로우 유닛** (iron_warrior, mountain_guard, wise_bear 40%): 피격 적 이동속도 감소
- **하이브리드 ATK 보너스**: 영구 업그레이드 `hybridBonus`로 하이브리드 전용 ATK 증가

## 레벨 스케일링

| 스탯 | 공식 | Lv1 | Lv2 | Lv3 | Lv4 | Lv5 |
|------|------|-----|-----|-----|-----|-----|
| ATK | base * 2^(lv-1) | x1 | x2 | x4 | x8 | x16 |
| 공속 | base * (1 + (lv-1)*0.1) | x1 | x1.1 | x1.2 | x1.3 | x1.4 |
| 사거리 | base + (lv-1)*5 | +0 | +5 | +10 | +15 | +20 |

## ATK 최종 공식

```dart
finalAtk = baseAtk * 2^(lv-1)
  * rewardAtkMultiplier       // 웨이브 보상 카드
  * relicManager.atkMultiplier // 유물 (ATK부스트, 속사포, 전쟁의신, 마이다스)
  * upgradeManager.unitAtkMultiplier  // 영구 업그레이드 +3%/Lv
  * (isHybrid ? upgradeManager.hybridAtkMultiplier : 1.0) // 하이브리드 보너스
  * relicManager.berserkerMultiplier(wallHp%) // 광전사 (HP<30%→x2)
  * relicManager.reverseMultiplier(wallHp%)   // 역전법칙 (1%HP→x5)
```

## 크리티컬 공식

```dart
critChance = baseCritChance         // 여우 20%, 하이브리드별 다름
  + relicManager.critChanceBonus    // 유물 +10%
  + upgradeManager.baseCritChance   // 영구 업그레이드 +2%/Lv
critDamage = relicManager.critDamageMultiplier // 기본 2x, 유물 +50%
```

## 머지 시스템

### 동종 머지
- **같은 타입 + 같은 레벨** → 레벨+1 유닛 1개
- Lv5 도달 시 자동 진화 (isEvolved = true)
- 진화 시 투사체에 관통 속성 추가
- 최대 레벨: 5 (무한머지 유물 시 7)

### 이종 머지 (크로스브리드)
- **다른 타입 2마리** + 둘 다 **Lv3 이상** → 하이브리드 유닛 1마리
- 12종의 레시피 정의됨 (HybridDatabase.recipes)
- 하이브리드 유닛은 양쪽 부모의 특성을 결합

## 유닛 추가 방법
1. `data/unit_data.dart` → UnitType enum + UnitData 추가
2. `renderers/unit_renderer.dart` → 렌더 case 추가
3. `game/defense_game.dart` → `_unitIcons`, `_unitTypeIds`에 추가

## 하이브리드 유닛 추가 방법
1. `data/hybrid_unit_data.dart` → HybridRecipe + HybridUnitData 추가
2. `renderers/unit_renderer.dart` → 렌더 case 추가
3. `game/defense_game.dart` → `_unitIcons`에 하이브리드 이모지 추가
4. (특수능력 시) `components/defense_unit.dart` → 크리/힐/슬로우 분기 추가
