# 스킬 & 콤보 시스템 (Skills & Combo)

> 이 문서만 읽으면 스킬/콤보 관련 작업을 독립적으로 수행할 수 있습니다.

## 소스 파일

| 파일 | 역할 |
|------|------|
| `lib/systems/skill_manager.dart` | 8종 액티브 스킬 정의, 게이지 충전, 발동 |
| `lib/systems/combo_manager.dart` | 콤보 시스템 (6단계 티어) |
| `lib/components/skill_effect_overlay.dart` | 스킬별 풀스크린 시각 이펙트 |
| `lib/data/balance_config.dart` | 스킬/콤보 관련 밸런스 상수 |

## 액티브 스킬 시스템

### 게이지 충전
- 적 처치 시 게이지 +1
- 게이지가 차면 자동 발동
- 지배적 유닛 타입에 따라 스킬이 결정됨

### 기본 상수

| 상수 | 값 | 설명 |
|------|-----|------|
| `skillDefaultMaxCharge` | 20 | 기본 최대 게이지 |
| `skillEffectDuration` | 5.0s | 스킬 지속 시간 |
| `skillCooldown` | 1.0s | 스킬 쿨다운 |
| `skillMaxParticles` | 60 | 스킬 이펙트 최대 파티클 |

### 스킬 8종

| 유닛 타입 | 스킬 ID | 이름 | 최대 게이지 | 효과 |
|-----------|---------|------|------------|------|
| Cat Archer | `arrow_rain` | 화살비 | 20 | 넓은 범위 화살비 공격 |
| Dog Warrior | `war_cry` | 전투의 함성 | 25 | 전체 유닛 ATK x1.5 |
| Rabbit Mage | `meteor` | 메테오 | 30 | 강력한 광역 데미지 |
| Bear Tanker | `ice_wall` | 얼음벽 | 25 | 전체 적 속도 30%로 감소 |
| Fox Assassin | `assassin_mark` | 암살 표식 | 30 | 가장 강한 적에게 집중 공격 |
| Bird Scout | `storm_call` | 폭풍 소환 | 35 | 번개 광역 공격 |
| Turtle Healer | `wall_heal` | 성벽 회복 | 40 | 성벽 회복 + 무적 |
| Owl Wizard | `mana_burst` | 마력 폭발 | 35 | 전체 화면 마법 폭발 |

### 스킬별 시각 이펙트

`skill_effect_overlay.dart`에서 8종 스킬별 풀스크린 오버레이 구현:
- 화살비: 하늘에서 떨어지는 화살 파티클
- 메테오: 불꽃 파티클 + 폭발
- 얼음벽: 서리/눈 파티클
- 폭풍 소환: 번개 파티클
- 기타: 각 스킬 테마에 맞는 고유 이펙트

### 스킬 발동 Game Feel

| 상수 | 값 |
|------|-----|
| `feelSkillHitStop` | 0.08s |
| `feelSkillSlowScale` | 0.3x |
| `feelSkillSlowDuration` | 0.5s |
| `feelSkillZoom` | 1.04x |
| `feelSkillZoomDuration` | 0.3s |

### War Cry 특수 효과
```
unitWarCryAtkMult = 1.5  // 전투의 함성 중 전체 유닛 ATK 1.5배
```

### Ice Wall 특수 효과
```
iceWallSpeedMult = 0.3  // 얼음벽 중 전체 적 속도 30%
```

---

## 콤보 시스템

### 기본 메카닉
- 연속 처치 시 콤보 카운트 증가
- 시간 내 다음 처치가 없으면 콤보 리셋

### 콤보 상수

| 상수 | 값 | 설명 |
|------|-----|------|
| `comboWindowBase` | 2.0s | 콤보 유지 시간 (기본) |
| `comboGoldBonusInterval` | 10 | N콤보마다 골드 보너스 |
| `comboGoldPerInterval` | 5 | 간격당 보너스 골드 (step × 5) |
| `comboTierChangeDisplayTime` | 1.5s | 티어 변경 표시 시간 |

### 콤보 6단계 티어

| 티어 | 필요 콤보 | 이펙트 크기 배율 |
|------|----------|-----------------|
| NONE | 0 | 1.0x |
| NICE | 5+ | 1.2x |
| GREAT | 10+ | 1.5x |
| AMAZING | 25+ | 2.0x |
| UNSTOPPABLE | 50+ | 2.5x |
| GODLIKE | 100+ | 3.0x |

### 콤보 골드 보너스
```
10콤보: 5 골드
20콤보: 10 골드
30콤보: 15 골드
...
```

### 콤보 티어 변경 Game Feel

| 상수 | 값 |
|------|-----|
| `feelComboTierHitStop` | 0.06s |
| `feelComboTierFlashDuration` | 0.3s |
| 화면 전체 플래시 | 티어별 색상, 0.5s 페이드 |

### 영구 업그레이드: 콤보 지속

| ID | 이름 | 효과 | 최대 Lv |
|----|------|------|---------|
| `comboDuration` | 콤보 지속 | +0.3s/Lv | 10 |

## 시너지 시스템

(→ `systems/synergy_manager.dart`)

- **종족 시너지**: 같은 종류 유닛이 일정 수 이상이면 보너스
- **다양성 시너지**: 서로 다른 종류가 많을수록 보너스
- 하이브리드 유닛은 양쪽 부모 종족으로 카운팅
