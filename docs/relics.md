# 유물 시스템 (Relics)

> 이 문서만 읽으면 유물 관련 작업을 독립적으로 수행할 수 있습니다.

## 소스 파일

| 파일 | 역할 |
|------|------|
| `lib/data/relic_data.dart` | 58개 유물 정의 (ID, 이름, 희귀도, 카테고리) |
| `lib/systems/relic_manager.dart` | 유물 효과 로직, 인벤토리, 가중 드롭 |
| `lib/data/balance_config.dart` | 유물 관련 밸런스 상수 |

## 희귀도 등급 (5티어)

| 등급 | 가중치 | 한글 | 색상 키 |
|------|--------|------|---------|
| Common | 40 | 일반 | `rarityCommon` |
| Rare | 30 | 레어 | `rarityRare` |
| Epic | 20 | 에픽 | `rarityEpic` |
| Legendary | 8 | 전설 | `rarityLegendary` |
| Mythic | 2 | 신화 | `rarityMythic` |

## 기본 규칙

- **최대 소지**: 5개 (`BalanceConfig.maxRelics`), 무한의 돌 유물 시 7개
- **드롭 시점**: 5웨이브마다 보상 선택 (`BalanceConfig.rewardInterval = 5`)
- **카테고리**: attack / defense / economy / merge / rule

## 천장 시스템 (Pity)

| 상수 | 값 | 설명 |
|------|-----|------|
| `pityEpicThreshold` | 5 | 연속 5회 비에픽 → 에픽+ 보장 |
| `pityLegendaryThreshold` | 10 | 연속 10회 비전설 → 전설+ 보장 |

## 전체 유물 목록

### 진화석 (8개, Rare)

| ID | 이름 | 설명 | 카테고리 |
|----|------|------|----------|
| `evolve_cat_archer` | 궁수 진화석 🏹 | 고양이 궁수를 진화시킵니다 | attack |
| `evolve_dog_warrior` | 기사 진화석 🗡️ | 강아지 전사를 진화시킵니다 | attack |
| `evolve_rabbit_mage` | 마법사 진화석 🔮 | 토끼 마법사를 진화시킵니다 | attack |
| `evolve_bear_tanker` | 수호자 진화석 🛡️ | 곰 탱커를 진화시킵니다 | defense |
| `evolve_fox_assassin` | 암살자 진화석 🗡️ | 여우 암살자를 진화시킵니다 | attack |
| `evolve_bird_scout` | 정찰대 진화석 🦅 | 새 정찰대를 진화시킵니다 | attack |
| `evolve_turtle_healer` | 힐러 진화석 💚 | 거북이 힐러를 진화시킵니다 | defense |
| `evolve_owl_wizard` | 마도사 진화석 🌙 | 부엉이 마도사를 진화시킵니다 | attack |

### Common (15개) — 숫자 버프

| ID | 이름 | 아이콘 | 설명 | 카테고리 | BalanceConfig 상수 |
|----|------|--------|------|----------|-------------------|
| `relic_atk_boost` | 분노의 부적 | ⚔️ | 전체 유닛 공격력 +15% | attack | `relicAtkBonus = 0.15` |
| `relic_speed_boost` | 신속의 부적 | ⚡ | 전체 유닛 공격속도 +15% | attack | `relicAtkSpeedBonus = 0.15` |
| `relic_gold_boost` | 황금 나침반 | 💰 | 골드 획득량 +30% | economy | `relicGoldBonus = 0.30` |
| `relic_wall_shield` | 수호의 방패 | 🛡️ | 성벽 피해 -20% | defense | `relicWallDefenseBonus = 0.20` |
| `relic_crit_chance` | 치명의 반지 | 💥 | 치명타 확률 +10% | attack | `relicCritBonus = 0.10` |
| `relic_star_magnet` | 별의 나침반 | ⭐ | 런 종료 시 별 +20% | economy | `relicStarBonus = 0.20` |
| `relic_range_boost` | 매의 눈 | 👁️ | 전체 유닛 사거리 +20% | attack | - |
| `relic_proj_speed` | 질풍의 화살 | 🏃 | 투사체 속도 +30% | attack | - |
| `relic_kill_heal` | 생명의 수확 | 🌿 | 적 처치 시 성벽 HP +1 | defense | - |
| `relic_wave_gold` | 전쟁 자금 | 🪙 | 웨이브 시작 시 골드 +10 | economy | - |
| `relic_crit_dmg` | 파멸의 반지 | 💎 | 치명타 데미지 +50% | attack | - |
| `relic_slow_aura` | 빙결의 오라 | ❄️ | 성벽 근처 적 둔화 -20% | defense | `relicSlowAuraIntensity = 0.2`, `relicSlowAuraRadius = 80px` |
| `relic_lifesteal` | 흡혈의 보석 | 🩸 | 유닛 데미지의 2% 성벽 회복 | defense | `relicLifestealPercent = 0.02` |
| `relic_thorns` | 가시 갑옷 | 🌹 | 성벽 피격 시 반사 데미지 10 | defense | - |
| `relic_boss_gold` | 보스 사냥꾼 | 👑 | 보스 골드 +50% | economy | - |

### Rare (15개) — 메카닉 변형

| ID | 이름 | 아이콘 | 설명 | 카테고리 |
|----|------|--------|------|----------|
| `relic_split_shot` | 분열탄 | 🔱 | 투사체 충돌 시 2개로 분열 (±45°, 데미지 50%) | attack |
| `relic_chain_lightning` | 연쇄 번개 | ⛈️ | 적 처치 시 주변 적 1마리에 50% 데미지 | attack |
| `relic_splash` | 폭발의 룬 | 💫 | 원거리 유닛 범위 공격 획득 | attack |
| `relic_lifesteal_up` | 강화 흡혈 | 🧛 | 라이프스틸 2% → 5% | defense |
| `relic_gold_rush` | 골드 러시 | 🏆 | 10콤보마다 골드 x2 | economy |
| `relic_berserker` | 광전사 | 🔥 | HP 30% 이하 시 전체 ATK x2 | attack |
| `relic_rapid_fire` | 속사포 | 🔫 | 공속 +30% 대신 ATK -15% | attack |
| `relic_pierce_all` | 관통 강화 | 🎯 | 모든 원거리 유닛 관통탄 | attack |
| `relic_gambler` | 도박사 | 🎰 | 유닛 뽑기 50% 무료 / 50% 비용x2 | economy |
| `relic_recycle` | 재활용 | ♻️ | 판매 환불 50% → 80% | economy |
| `relic_last_stand` | 근성 | 💪 | 성벽 HP 1로 1회 생존 | defense |
| `relic_twin` | 쌍둥이 | 👯 | 유닛 구매 시 30% 확률 2마리 | merge |
| `relic_giant` | 거인 | 🗿 | 유닛 크기 +50%, 사거리 +30% | attack |
| `relic_tiny` | 소형화 | 🔬 | 유닛 크기 -30%, 공속 +40% | attack |
| `relic_double_merge` | 합성의 서 | 📖 | 2마리만으로 합성 가능 | merge |

### Epic (12개) — 게임 규칙 변경

| ID | 이름 | 아이콘 | 설명 | 카테고리 |
|----|------|--------|------|----------|
| `relic_living_wall` | 살아있는 성벽 | 🏰 | 성벽이 직접 공격 (초당 15 데미지) | rule |
| `relic_convert` | 적 전향 | 🔄 | 적 처치 시 5% 확률 아군으로 변환 | rule |
| `relic_time_warp` | 시간 왜곡 | ⏳ | 매 5웨이브 시작 시 3초 슬로모션 | rule |
| `relic_infinite_merge` | 무한 머지 | ♾️ | 최대 레벨 5 → 7 | merge |
| `relic_merge_bomb` | 폭발 머지 | 💣 | 머지 시 주변 적에게 범위 데미지 | merge |
| `relic_ghost_unit` | 유령 유닛 | 👻 | 모든 유닛 공격력 +20% | attack |
| `relic_blessing_rain` | 축복의 비 | 🌧️ | 3웨이브마다 전체 HP 15% 회복 | defense |
| `relic_doppelganger` | 도플갱어 | 🪞 | 유닛 구매 시 가장 많은 유닛과 같은 종류 | merge |
| `relic_elemental` | 원소 폭풍 | 🌀 | 투사체에 랜덤 원소 효과 (불/얼음/독) | attack |
| `relic_treasure_hunter` | 보물 사냥꾼 | 🗺️ | 보스 보상 골드 x3 | economy |
| `relic_auto_evolve` | 자동 진화 | 🧬 | Lv5 유닛 자동 진화 (진화유물 불필요) | merge |
| `relic_wall_turret` | 성벽 포탑 | 🔫 | 성벽에 자동 포탑 추가 (초당 20 데미지) | rule |

### Legendary (6개) — 런 정의 변경

| ID | 이름 | 아이콘 | 설명 | 카테고리 |
|----|------|--------|------|----------|
| `relic_phoenix` | 불사조 | 🔥 | 성벽 파괴 시 1회 부활 + HP 50% 회복 | rule |
| `relic_rift` | 차원 균열 | 🌀 | 매 웨이브 시작 랜덤 유닛 1개 무료 소환 | rule |
| `relic_midas` | 마이다스 | ✋ | 모든 데미지를 골드로 변환, ATK=0 | rule |
| `relic_war_god` | 전쟁의 신 | ⚔️ | ATK x3 대신 성벽 HP -50% | rule |
| `relic_infinity` | 무한의 돌 | 💠 | 유물 슬롯 +2 (5→7) | rule |
| `relic_time_sand` | 시간의 모래 | ⌛ | 웨이브 시간 20초→10초, 적 속도 -30% | rule |

### Mythic (2개) — 런 자체를 바꿈

| ID | 이름 | 아이콘 | 설명 | 카테고리 |
|----|------|--------|------|----------|
| `relic_chaos` | 카오스 | 🌪️ | 매 웨이브마다 보유 유물 효과 랜덤 변경 | rule |
| `relic_reverse` | 역전의 법칙 | ☯️ | 성벽 HP가 낮을수록 전체 ATK 폭증 | rule |

## 유물 수량 요약

| 등급 | 수량 |
|------|------|
| 진화석 (Rare) | 8 |
| Common | 15 |
| Rare | 15 (진화석 포함 23) |
| Epic | 12 |
| Legendary | 6 |
| Mythic | 2 |
| **총합** | **58** |

## 분열탄/원소 상세 스탯

### 분열탄 (`relic_split_shot`)
```
splitShotSpeedMult = 0.7   // 자식 투사체 속도 70%
splitShotDamageMult = 0.5   // 자식 투사체 데미지 50%
```

### 원소 폭풍 (`relic_elemental`)
| 원소 | 효과 | 수치 | 지속 |
|------|------|------|------|
| 불 | DoT | 30%/s | 3.0s |
| 얼음 | 슬로우 | 40% | 2.0s |
| 독 | DoT | 15%/s | 5.0s |

## 유물 획득 시 Game Feel

| 상수 | 값 |
|------|-----|
| `feelRelicZoom` | 1.03x |
| `feelRelicZoomDuration` | 0.2s |
| `feelRelicFlashColor` | `0xFFE040FB` (보라) |
| `feelRelicFlashDuration` | 0.2s |

## 새 유물 추가 방법

1. `RelicDatabase.all`에 `RelicDef` 추가 (`relic_data.dart`)
2. `relic_manager.dart`에 효과 로직 구현
3. 테스트: `test/data/relic_data_test.dart` 업데이트
4. 도감 자동 등록 (codex_manager가 자동 인식)
