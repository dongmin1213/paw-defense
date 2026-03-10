# 적 가이드

## 적 10종 (data/enemy_data.dart)

| ID | 이름 | HP | 속도 | 공격력 | 공속 | 골드 | 비행 | 해금 웨이브 |
|-----|------|-----|------|--------|------|------|------|-----------|
| slime | 슬라임 | 20 | 40 | 3 | 1.0 | 2 | - | 1 |
| goblin | 고블린 | 35 | 60 | 5 | 1.2 | 4 | - | 4 |
| skeleton | 스켈레톤 | 30 | 55 | 6 | 1.3 | 5 | - | 6 |
| bat | 박쥐 | 15 | 70 | 3 | 1.5 | 3 | O | 7 |
| orc | 오크 | 80 | 30 | 10 | 0.6 | 8 | - | 10 |
| mushroom | 독버섯 | 25 | 35 | 8 | 0.7 | 7 | - | 12 |
| shielded | 방패병 | 120 | 25 | 7 | 0.8 | 10 | - | 15 |
| bomber | 폭탄병 | 40 | 50 | 15 | 0.5 | 12 | - | 18 |
| healer | 힐러 | 50 | 35 | 4 | 1.0 | 6 | - | 20 |
| golem | 골렘 | 150 | 18 | 12 | 0.4 | 15 | - | 22 |

## 특수 행동 (defense_enemy.dart)

| 타입 | 행동 |
|------|------|
| **shielded** | 전방에서 오는 공격 데미지 50% 감소 (dot product 판정) |
| **bomber** | 성벽 도달 시 2x 데미지 폭발 후 즉사. 일반 공격 안 함 |
| **healer** | 3초마다 주변 50px 아군 HP 10% 회복 |
| **boss** | 1.5x 크기, 빨간 글로우, 공속 0.5 고정, 유물 드랍 |
| **bat** | 사인파 이동. 대공(canHitAir) 유닛만 공격 가능 |

## 보스

| 상수 | 값 | 설명 |
|------|-----|------|
| 등장 주기 | 10웨이브마다 | BalanceConfig.bossInterval |
| 기본 HP | 200 | BalanceConfig.bossBaseHp |
| HP 스케일링 | 200 * 1.08^wave * (1 + units*0.12) | 웨이브+유닛 수 비례 |
| 속도 | 20 | 느림 |
| 골드 | 50 | 높음 |
| 드랍 | 유물 선택 (2~3택) | 최대 3개/런 |

## 난이도 스케일링 (balance_config.dart)

```
HP = baseHp * 1.08^wave * (1 + units * 0.12)
Speed = baseSpeed * (1 + units * 0.02) * (1 + max(0, wave-30) * 0.005)
Count = (baseTier + wave * 0.8) * (1 + units * 0.04)
```

## 적 추가 방법
1. `data/enemy_data.dart` → DefenseEnemyData 추가 (unlockWave 지정)
2. `renderers/defense_enemy_renderer.dart` → 렌더 case 추가
3. (특수 행동 시) `components/defense_enemy.dart` → 행동 로직 추가
