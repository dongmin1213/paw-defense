# 게임 시스템 (Game Systems)

> 이 문서만 읽으면 게임 시스템(파티클, 게임필, 시너지, 업적, 일일) 관련 작업을 독립적으로 수행할 수 있습니다.

## 소스 파일

| 파일 | 역할 |
|------|------|
| `lib/systems/defense_game_feel.dart` | 히트스탑, 슬로모션, 줌펀치, 스크린플래시 |
| `lib/components/defense_particle.dart` | 파티클 이펙트 시스템 |
| `lib/components/reactive_background.dart` | 전투 강도 반응형 배경 |
| `lib/components/skill_effect_overlay.dart` | 스킬 풀스크린 이펙트 |
| `lib/components/damage_number.dart` | 데미지/골드 숫자 팝업 |
| `lib/components/field_drop.dart` | 필드 골드 드롭 물리 |
| `lib/systems/synergy_manager.dart` | 종족/다양성 시너지 |
| `lib/systems/achievement_manager.dart` | 업적 시스템 |
| `lib/systems/daily_manager.dart` | 일일 챌린지/출석 보상 |
| `lib/systems/codex_manager.dart` | 도감 시스템 |
| `lib/systems/sound_manager.dart` | BGM/SFX 관리 |
| `lib/data/balance_config.dart` | 모든 시스템 수치 |

---

## 1. Game Feel 시스템

`defense_game_feel.dart`에서 4가지 피드백 효과를 관리합니다:

### 효과 종류
- **히트스탑 (Hit Stop)**: 잠시 게임 멈춤 → 충격감
- **슬로모션 (Slow Motion)**: 게임 속도 감소 → 드라마틱
- **줌 펀치 (Zoom Punch)**: 카메라 줌 인/아웃 → 임팩트
- **스크린 플래시 (Screen Flash)**: 화면 전체 색상 → 하이라이트

### 프리셋 목록

| 이벤트 | 히트스탑 | 슬로모 | 줌펀치 | 플래시 |
|--------|---------|--------|--------|--------|
| 적 처치 | 0.015s | - | - | 3콤보 이상: 흰 0.08s |
| 보스 피격 | 0.04s | - | - | - |
| 보스 처치 | 0.25s | 0.2x/1.0s | 1.08x/0.5s | 금 0.3s |
| 성벽 피격(강) | - | - | - | 빨강 0.2s |
| 성벽 위기 | - | - | - | 빨강(진) 0.4s |
| 머지 | - | - | 1.02+Lv×0.01/0.2s | - |
| 진화 | 0.15s | 0.3x/0.8s | 1.06x/0.4s | 금 0.3s |
| 하이브리드 | 0.1s | 0.4x/0.6s | 1.05x/0.3s | 보라 0.25s |
| 승급 | - | 0.2x/1.5s | - | 흰 0.5s |
| 퍼펙트 웨이브 | - | - | 1.03x/0.3s | 초록 0.2s |
| 스킬 발동 | 0.08s | 0.3x/0.5s | 1.04x/0.3s | - |
| 콤보 티어 변경 | 0.06s | - | - | 0.3s |
| 유물 획득 | - | - | 1.03x/0.2s | 보라 0.2s |

### BalanceConfig 상수 (~45개)

모든 Game Feel 타이밍은 `feel` 접두어로 `balance_config.dart`에 정의:
```
feelEnemyKillHitStop, feelBossHitHitStop, feelBossKillHitStop,
feelBossKillSlowScale, feelBossKillSlowDuration, feelBossKillZoom, ...
feelEvolveHitStop, feelEvolveSlowScale, feelEvolveSlowDuration, ...
feelHybridHitStop, feelHybridSlowScale, feelHybridSlowDuration, ...
feelSkillHitStop, feelSkillSlowScale, feelSkillSlowDuration, ...
feelComboTierHitStop, feelComboTierFlashDuration, ...
feelRelicZoom, feelRelicZoomDuration, feelRelicFlashColor, ...
```

---

## 2. 파티클 시스템

`defense_particle.dart`에서 모든 파티클 이펙트를 관리합니다.

### 하드 캡
```
particleHardCap = 2000        // 전체 파티클 상한
groundMarkCap = 150           // 지면 마크 상한
groundMarkKeep = 120          // 트림 후 유지 수
```

### 파티클 수량 테이블

| 이벤트 | 상수 | 수량 |
|--------|------|------|
| 적 사망 | `particleEnemyDeath` | 25 |
| 폭탄병 사망 | `particleBomberDeath` | 40 |
| 사망 코어 플래시 | `particleDeathCoreFlash` | 2 |
| 보스 폭발 | `particleBossExplosion` | 60 |
| 머지 기본 | `particleMergeBase` | 10 |
| 머지/레벨 | `particleMergePerLevel` | +5 |
| 머지 진화 | `particleMergeEvolution` | 12 |
| 성벽 피격 | `particleWallHit` | 6 |
| 웨이브 시작 | `particleWaveStart` | 12 |
| 크리티컬 히트 | `particleCriticalHit` | 12 |
| 체인 킬 | `particleChainKill` | 8 |
| 하이브리드 머지 | `particleHybridMerge` | 25 |
| 콤보 플래시 | `particleComboFlash` | 80 |
| 투사체 피격 | `particleProjectileHit` | 8 |
| 스킬 발동 | `particleSkillActivation` | 70 |
| 힐 이펙트 | `particleHealEffect` | 10 |
| 성벽 데미지 | `particleWallDamage` | 10 |
| 진화 | `particleEvolution` | 30 |
| 스킬 링 | `particleSkillRing` | 40 |
| 스케일드 사망 기본 | `particleScaledDeathBase` | 25 |
| 스케일드 사망 (최소/최대) | | 12~80 |
| 충격파 링 | `particleShockwaveRing` | 48 |
| 머즐 플래시 기본 | `particleMuzzleFlashBase` | 2 |
| 머즐 플래시/레벨 | `particleMuzzleFlashPerLevel` | +2 |
| 골드 수집 | `particleGoldCollect` | 8 |
| 골드 흩뿌림 | `particleGoldScatterMin/Max` | 5~20 |
| 배경 별 | `backgroundStarCount` | 120 |

---

## 3. 데미지 숫자 팝업

`damage_number.dart`

| 타입 | 색상 | 크기 배율 | 접두/접미 |
|------|------|-----------|-----------|
| `normal` | 흰 | 1.3x | - |
| `critical` | 빨강/주황 | 2.0x | "!" |
| `heal` | 초록 | 1.4x | "+" |
| `dot` | 주황/보라 | 0.9x | - |
| `gold` | 금 | 1.3x | "+" |
| `shield` | 회색 | 1.0x | - |

| 상수 | 값 |
|------|-----|
| `damageNumberLifetime` | 1.2s |
| `damageNumberFloatSpeed` | 50 px/s |
| `damageNumberPopDuration` | 0.15s |

최적화: 알파 버킷 양자화 (10단계) → 매 프레임 ParagraphBuilder 재생성 방지

---

## 4. 필드 드롭 물리

`field_drop.dart` — 적 사망 시 골드가 떨어져 성벽으로 호밍

| 상수 | 값 | 설명 |
|------|-----|------|
| `fieldDropGravity` | 120 | 중력 가속도 |
| `fieldDropGroundDelay` | 0.8s | 착지 후 호밍까지 대기 |
| `fieldDropHomeAccel` | 800 | 호밍 가속도 |
| `fieldDropHomeMaxSpeed` | 500 | 호밍 최대 속도 |
| `fieldDropMaxDrops` | 150 | 최대 활성 드롭 수 |
| `fieldDropPickupRadius` | 10px | 흡수 반경 |

---

## 5. 반응형 배경

`reactive_background.dart`

- 전투 강도에 따라 배경색이 네이비→크림슨으로 시프트
- 120개 별 파티클이 배경에 반짝임 (`backgroundStarCount = 120`)
- 강한 전투 시 방사형 펄스 이펙트

---

## 6. 시너지 시스템

`synergy_manager.dart`

- **종족 시너지**: 같은 유닛 타입이 일정 수 이상이면 보너스
- **다양성 시너지**: 서로 다른 유닛 타입 수에 따른 보너스
- 하이브리드 유닛은 양쪽 부모 종족으로 카운팅

---

## 7. 업적 시스템

`achievement_manager.dart`

### 카테고리
- **처치 (kills)**: 총 적 처치 수 기반
- **웨이브 (waves)**: 도달 웨이브 기반
- **머지 (merges)**: 총 머지 횟수 기반
- **유물 (relics)**: 유물 수집 기반

### 보상
- 업적 달성 시 별(Star) 보상
- HUD 상단에 알림 배너 (2.5초 표시)
- 큐 기반 순차 알림 (`defense_game.dart`)

### UI
- `ui/achievement_screen.dart` — 업적 목록/진행도 표시

---

## 8. 일일 시스템

`daily_manager.dart`

### 출석 보상 (7일 사이클)
- 7일 사이클로 별 보상 (50~500)
- 28일 스트릭 마일스톤 보너스

### 일일 챌린지
- 날짜 해시 기반으로 매일 다른 챌린지 생성
- 목표 웨이브: 15~30
- 클리어 시 별 보상

### UI
- `ui/daily_screen.dart` — 출석/챌린지 화면

---

## 9. 도감 시스템

`codex_manager.dart`

### 4개 탭
1. **유닛**: 기본 8 + 진화 8 + 하이브리드 28
2. **적**: 16종
3. **유물**: 58개
4. **통계**: 누적 플레이 통계

- 미발견 아이템은 "???" 실루엣 표시
- 발견 시 자동 등록

### UI
- `ui/codex_screen.dart` — 도감 4탭

---

## 10. 사운드 시스템

`sound_manager.dart`

- BGM 재생/일시정지
- SFX 효과음 재생
- 앱 pause/resume 시 자동 일시정지/재개
- `ui/settings_screen.dart`에서 음량 조절
