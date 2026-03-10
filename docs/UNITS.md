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

## 레벨 스케일링

| 스탯 | 공식 | Lv1 | Lv2 | Lv3 | Lv4 | Lv5 |
|------|------|-----|-----|-----|-----|-----|
| ATK | base * 2^(lv-1) | x1 | x2 | x4 | x8 | x16 |
| 공속 | base * (1 + (lv-1)*0.1) | x1 | x1.1 | x1.2 | x1.3 | x1.4 |
| 사거리 | base + (lv-1)*5 | +0 | +5 | +10 | +15 | +20 |

## 머지 시스템
- **동일 타입 + 동일 레벨 3개** → 레벨+1 유닛 1개
- Lv5 도달 시 자동 진화 (isEvolved = true)
- 진화 시 투사체에 관통 속성 추가

## 유닛 추가 방법
1. `data/unit_data.dart` → UnitType enum + UnitData 추가
2. `renderers/unit_renderer.dart` → 렌더 case 추가
3. `game/defense_game.dart` → `_unitIcons`, `_unitTypeIds`에 추가
