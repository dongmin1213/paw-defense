# 코드 아키텍처

## 레이어 구조

```
UI (Flutter 위젯 오버레이)
    ↕ overlays.add/remove
Game (DefenseGame — FlameGame)
    ↕ world.add, .game 참조
Components (Wall, DefenseUnit, DefenseEnemy, Projectile)
    ↕ 데이터 참조
Data (unit_data, hybrid_unit_data, relic_data, enemy_data, balance_config)
    ↕ 렌더링 위임
Renderers (static 메서드, PixelArt 기반)
```

## 주요 패턴

### Component 패턴
```dart
class DefenseEnemy extends PositionComponent
    with HasGameReference<DefenseGame>, CollisionCallbacks {
  // .game으로 DefenseGame 접근
  // CollisionCallbacks + add(RectangleHitbox())로 충돌 처리
}
```

### Renderer 패턴 (static only)
```dart
class UnitRenderer {
  static void render(Canvas canvas, Size size, {
    required String unitTypeId, ...
  }) { /* PixelArt.drawCentered() */ }
}
```

### Data 패턴
```dart
class DefenseEnemyData {
  final String id;
  final double baseHp;
  const DefenseEnemyData({...});
}
class DefenseEnemyDatabase {
  static const List<DefenseEnemyData> all = [...];
  static DefenseEnemyData? get(String id) => ...;
}
```

### PixelArt 스프라이트
```dart
static const _sprite = ['..OOO..', '.OOOOO.'];
static const _palette = { 'O': Color(0xFF4CAF50) };
PixelArt.drawCentered(canvas, _sprite, _palette, size, pixelSize: px);
```

### UI 디자인 시스템 (GameTheme static)

#### 색상 체계
```dart
// 배경 레이어 (어두운 → 밝은)
GameTheme.bgDeep / bgDark / bgPanel / bgCard / bgCardHover / bgSurface

// 시맨틱 액센트
GameTheme.accent (시안) / accentGold / accentPurple / accentGreen / accentRed

// 텍스트 계층
GameTheme.textPrimary / textSecondary / textMuted

// 희귀도 티어
GameTheme.rarityCommon / rarityRare / rarityEpic / rarityLegendary / rarityMythic
```

#### 타이포그래피
```dart
GameTheme.pixel(fontSize: 10)       // Press Start 2P (제목/숫자)
GameTheme.gameFont(fontSize: 12)    // Silkscreen (게임 UI)
GameTheme.pixelTitleLarge / pixelTitleMedium / pixelTitleSmall / pixelLabel / pixelNumber
GameTheme.titleLarge / bodyLarge / bodyMedium / caption  // 한글 호환
```

#### 간격/라운딩 상수
```dart
GameTheme.spacingXs(4) / spacingSm(8) / spacingMd(12) / spacingLg(16) / spacingXl(24) / spacingXxl(32)
GameTheme.radiusSm(6) / radiusMd(10) / radiusLg(14)
```

#### 공통 위젯
```dart
GameTheme.pixelButton(label: '시작', onTap: () {});   // AnimatedScale 눌림 효과
GameTheme.pixelProgressBar(value: 0.7);                // ClipRRect 둥근 끝
GameTheme.panelBox(child: widget);                     // bgCard 패널
GameTheme.badgeChip(label: 'Lv.5');                    // 라운드 뱃지
GameTheme.sectionTitle(title: '공격');                  // 액센트 좌측바 제목
GameTheme.formatInt(12345);                            // '12.3K'
GameTheme.rarityColor(RelicRarity.epic);               // 희귀도별 색상
```

#### 그라데이션
```dart
GameTheme.gradientPrimary / gradientGold / gradientPurple / gradientGreen / gradientRed / gradientDark
GameTheme.bgVignette  // RadialGradient 배경 비네팅
```

### 사운드 (SoundManager)
```dart
game.soundManager.playSfx('hit');        // 효과음 재생
game.soundManager.playBgm('battle');     // BGM 재생
game.soundManager.onAppPaused();         // 앱 백그라운드 시 일시정지
game.soundManager.onAppResumed();        // 앱 복귀 시 재개
```
- `main.dart`의 `WidgetsBindingObserver`에서 앱 라이프사이클 연동
- Settings 오버레이에서 사운드 on/off 제어

### 게임필 (DefenseGameFeel)
```dart
game.gameFeel.onEnemyKill();     // 히트스탑
game.gameFeel.onBossKill();      // 히트스탑 + 슬로모션 + 줌펀치 + 스크린플래시
game.gameFeel.onWallHit();       // 벽 피격 반응 (heavy 시 플래시)
game.gameFeel.onEvolve();        // 히트스탑 + 플래시(골드)
```
- 히트스탑 중 update(dt) 스킵
- 슬로모션: dt * gameFeel.timeScale
- 스크린 플래시: 7종 (보스처치/벽위기/진화/하이브리드/퍼펙트웨이브/스킬/콤보티어)
- 스크린 쉐이크: 완전 제거됨 (배터리/발열 최적화)

### 텍스트 렌더링 주의
- Flame render(Canvas)에서는 `dart:ui`의 TextStyle만 사용
- ParagraphBuilder + ParagraphStyle 조합 (damage_number.dart 참고)

## 게임 라이프사이클

```
main.dart → DefenseGame.onLoad()
  → soundManager 초기화
  → comboManager 초기화 (add to world)
  → achievementManager 초기화
  → overlays.add('DefenseMainMenu')
  → startGame()
    → wall/slots/waveManager 초기화
    → relicManager.reset(), comboManager.resetAll()
    → _clearAllUnits/Enemies/Projectiles/DamageNumbers/Particles()
    → gold = 50 + startUnits * 10 + startGoldBonus
    → saveManager.clearRunState()
    → overlays.add('DefenseHud')
  → resumeRun() (이어하기)
    → 저장된 상태 복원 (gold, relics, slots, wave, wall HP)
    → _clearAllProjectiles/DamageNumbers/Particles() 잔여 오브젝트 정리
    → waveManager.resumeAtWave(savedWave)
  → update(dt)
    → gameFeel 적용 (히트스탑/슬로모션)
    → camera zoom punch
    → livingEnemies dirty-flag 캐싱 (매 프레임 lazy rebuild)
    → livingWall/wallTurret DPS (유물, 3프레임 쓰로틀링)
  → onEnemyKilled()
    → comboManager.onEnemyKilled()
    → 유물 효과 (bonus gold, kill heal, chain lightning, boss gold, convert)
    → particle effects (scaled by combo tier)
    → achievement 업데이트 (kills, combos)
  → onWaveStart()
    → 유물 효과 (wave gold, blessing rain, rift, time warp, chaos)
  → onWallDestroyed()
    → achievement 업데이트 (waves, gold, relics)
    → saveManager.clearRunState()
    → overlays.add('RunResult')
  → goToMainMenu()

앱 라이프사이클:
  → paused/inactive → saveRunState() + saveGame()
  → resumed → soundManager.onAppResumed()

12개 오버레이: DefenseMainMenu, DefenseHud, WaveReward,
StarShop, RunResult, Pause, RelicSelection, Tutorial, Settings, Achievement, Daily, Codex
```

## 데이터 의존 관계

```
balance_config.dart     ← wave_manager, defense_game, defense_unit, relic_manager
enemy_data.dart         ← wave_manager, defense_game
unit_data.dart          ← defense_unit
hybrid_unit_data.dart   ← defense_unit, merge_manager, defense_game, unit_renderer
relic_data.dart         ← relic_manager, relic_selection_screen, defense_hud, defense_game
relic_manager.dart      ← defense_game, defense_unit, defense_enemy, wave_manager, wall
combo_manager.dart      ← defense_game, defense_hud
upgrade_manager.dart    ← defense_game, defense_unit, combo_manager, relic_manager, star_shop_screen
save_manager.dart       ← defense_game, main.dart (앱 라이프사이클), defense_main_menu
sound_manager.dart      ← defense_game, main.dart (앱 라이프사이클)
achievement_manager.dart ← defense_game, achievement_screen, settings_screen
skill_manager.dart      ← defense_game, defense_hud (스킬 게이지/발동)
reactive_background.dart ← defense_game (강도 연동, 펄스 트리거)
skill_effect_overlay.dart ← defense_game (스킬 발동 시 activate())
wave_modifier.dart      ← wave_manager, defense_hud (변형 배너)
synergy_manager.dart    ← defense_game, defense_unit
codex_manager.dart      ← defense_game, codex_screen
daily_manager.dart      ← defense_game, daily_screen, defense_main_menu
```

## 핵심 시스템 구조

### 유물 시스템
```
relic_data.dart (데이터 정의)
  → RelicRarity enum (5단계 가중치)
  → RelicDef class (id, name, icon, description, rarity, category)
  → RelicDatabase (50개 유물 등록, allIds, byRarity, get())

relic_manager.dart (런타임 로직)
  → 소유 관리 (addRelic, removeRelic, reset)
  → 가중 드롭 (generateRelicChoices with qualityBonus)
  → 스탯 쿼리 (atkMultiplier, rangeMultiplier, critChanceBonus 등 30+개)
  → 이벤트 (onEnemyKilled, onWallFatalDamage, onWaveStart, onWaveStartHeal)
  → 상태 쿼리 (hasBerserker, hasMidas, hasChainLightning 등)
```

### 이종 머지 시스템
```
hybrid_unit_data.dart (데이터)
  → HybridRecipe (parentA, parentB, hybridId)
  → HybridUnitData (id, name, stats, specialAbility)
  → HybridDatabase (12 recipes, findRecipe(), isHybrid())

merge_manager.dart (로직)
  → findCrossBreedMerges() — 보드에서 가능한 이종 머지 탐색
  → performCrossBreed() — 실제 이종 머지 수행
  → CrossBreedMerge class — 머지 결과 데이터

defense_unit.dart (통합)
  → isHybrid getter
  → 7개 static lookup (_lookupAtk 등) — 일반/하이브리드 통합 스탯 조회
  → 크리/힐/슬로우 분기에서 하이브리드 유닛 지원
```

### 콤보 시스템
```
combo_manager.dart (Component with HasGameReference)
  → ComboTier enum (5단계, threshold, effectScale)
  → onEnemyKilled() → 콤보 증가 + 티어 갱신 + 골드 보너스
  → update(dt) → 콤보 타이머 관리
  → comboWindow getter → 2.0 + upgradeManager.comboDurationBonus
  → effectSizeMultiplier → 파티클 크기에 전달
```

### 중간 저장/복원 시스템
```
defense_save_manager.dart
  → saveRunState(Map) — JSON 직렬화 → SharedPreferences
  → loadRunState() → Map? — 복원
  → clearRunState() — 런 종료/시작 시 삭제
  → hasRunState getter — 메인 메뉴 "이어하기" 표시 여부

defense_game.dart
  → buildRunState() — 현재 런 상태 스냅샷 (gold, wave, relics, slots, wall HP 등)
  → saveRunState() — isPlaying일 때만 저장
  → resumeRun() — 저장된 상태 복원 + waveManager.resumeAtWave()

main.dart
  → didChangeAppLifecycleState(paused) → saveRunState() + saveGame()
```

### 업적 시스템
```
achievement_manager.dart
  → AchievementDef (id, name, icon, target, type, starReward)
  → AchievementDatabase (25+개 업적, 8가지 타입)
  → updateProgress(type, value) → 새로 달성된 업적 ID 리스트 반환
  → SharedPreferences 기반 영구 저장

defense_game.dart
  → _updateAchievement(type, value) → 달성 시 별 보상 + 알림 큐
  → popAchievementNotification() → HUD에서 폴링
  → 머지/킬/웨이브/콤보/보스/하이브리드/골드/유물 추적
```

### 액티브 스킬 시스템
```
skill_manager.dart (Component with HasGameReference)
  → SkillDef (8종: 유닛별 1개씩)
  → 킬 기반 게이지 충전 (killsRequired per skill)
  → dominantUnitType — 보드 위 가장 많은 유닛 타입 자동 판별
  → activateSkill() → 쿨다운 + 효과 지속시간
  → update(dt) → 쿨다운/효과 타이머 관리
```

### 웨이브 변형 시스템
```
wave_modifier.dart
  → WaveModifier enum (10종)
  → 웨이브 10부터 5웨이브마다 랜덤 선택 (보스 웨이브 제외)
  → 적 수/HP/속도/골드/사거리 배율 수정
  → wave_manager.dart에서 연동
```

### 도감 시스템
```
codex_manager.dart
  → discoverUnit/Enemy/Relic/Hybrid() — 발견 기록
  → isDiscovered(category, id) — 발견 여부
  → completionRate(category) — 완성도 %
  → SharedPreferences 기반 영구 저장

codex_screen.dart
  → 4탭: 유닛(기본/진화/하이브리드) / 적 / 유물(희귀도별) / 통계
  → 미발견 → "???" 실루엣
```

### 일일 시스템
```
daily_manager.dart
  → 로그인 스트릭 (7일 사이클, SharedPreferences)
  → 일일 챌린지: 날짜 해시 기반 목표 웨이브
  → hasUnclaimedReward — 메인 메뉴 알림 뱃지

daily_screen.dart
  → 7일 스트릭 표시 + 보상 수령 + 챌린지 상태
```

### 시너지 시스템
```
synergy_manager.dart
  → 종족 시너지 (같은 종 3/5/7 마리 → ATK/DEF 보너스)
  → 다양성 시너지 (다른 종 N개 → 전체 ATK 보너스)
  → 하이브리드 유닛의 양쪽 부모 종 카운팅
```

## 성능 최적화 패턴

### livingEnemies Dirty-Flag 캐싱
```dart
bool _livingEnemiesDirty = true;
List<DefenseEnemy> _livingEnemiesCache = [];
List<DefenseEnemy> get livingEnemies {
  if (_livingEnemiesDirty) {
    _livingEnemiesCache = world.children.whereType<DefenseEnemy>()
        .where((e) => !e.isDead).toList();
    _livingEnemiesDirty = false;
  }
  return _livingEnemiesCache;
}
// update()에서 _livingEnemiesDirty = true로 매 프레임 마킹
// 같은 프레임 내 다중 접근 시 캐시 재사용
```

### 유물 효과 쓰로틀링
```dart
int _relicEffectFrame = 0;
// livingWall AoE, wallTurret 등 비싼 유물 효과를 3프레임마다 실행
if (_relicEffectFrame % 3 == 0) {
  final compensatedDt = effectiveDt * 3; // DPS 보정
  // 유물 효과 적용
}
_relicEffectFrame++;
```

### 파티클 최적화
- 파티클 캡: 600개 (초과 시 자동 제거)
- 알파 < 0.05 파티클 렌더 스킵
- `clear()` 메서드로 게임 시작/재시작 시 일괄 정리
- 호밍 파티클: 수명 50% 이후 400px/s² 가속으로 타겟 수렴

### 시각적 스펙터클 시스템 (6 Phase)
```
Phase 1: 유닛 궤도 회전 (unit_slot.dart, defense_unit.dart)
  → orbitAngle += orbitSpeed * dt (defense_game.dart)
  → orbitSpeed = base × (1 + wave × waveScale) × (1 + unitCount × unitScale)
  → 슬롯/유닛 각각 sin/cos 궤도 계산 + 스프라이트 좌우반전

Phase 2: 투사체 트레일 + 타입별 모양 (projectile.dart)
  → 8프레임 링버퍼 (trailX, trailY) → 알파/크기 감쇠 렌더
  → _ProjProfile: 8종 유닛별 고유 색상+트레일 프로필
  → _renderShape(): 8종 픽셀 모양 (화살/검기/마법구/바위/수리검/깃털/힐볼트/아케인)

Phase 3: 적 스웜 밀도 (balance_config.dart, wave_manager.dart)
  → baseEnemyCount 2배 + swarmHpMultiplier 0.55 (총 웨이브 HP 동일)
  → ±15% 속도 편차 (_scaledSpeed에 0.85~1.15 랜덤)

Phase 4: 사망이펙트 + 골드비산 (defense_particle.dart)
  → 15~40파티클 사망 (콤보 스케일링)
  → spawnShockwaveRing: 24개 방사형 확산
  → spawnGoldScatter: 호밍 파티클 (비산→성벽 수렴)

Phase 5: 반응형 배경 (reactive_background.dart)
  → intensity = enemyCount/50 × 0.4 + comboScale × 0.3 + wave/50 × 0.3
  → 색상: 네이비(0xFF1A1A2E) → 크림슨(0xFF2E1A1A)
  → 40개 별 파티클 (사전 할당, GC 없음)
  → pulse(Color, duration): 방사형 그라디언트 펄스

Phase 6: 스킬 시각 이펙트 (skill_effect_overlay.dart)
  → 8종 스킬별 풀스크린 오버레이 (SkillEffectOverlay.activate())
  → 독립 파티클 풀 (최대 60개), 자동 리스폰 (arrow_rain, storm_call)
  → 엣지 틴트 + 특수 오버레이 (서리 테두리, 메테오 글로우, 번개 플래시 등)
```

## 새 컨텐츠 추가 가이드

### 새 유닛
1. `data/unit_data.dart` → UnitType enum + UnitData
2. `renderers/unit_renderer.dart` → 렌더 case
3. `game/defense_game.dart` → `_unitIcons`, `_unitTypeIds`

### 새 하이브리드 유닛
1. `data/hybrid_unit_data.dart` → HybridRecipe + HybridUnitData
2. `renderers/unit_renderer.dart` → 렌더 case (hybrid_ 접두사)
3. `game/defense_game.dart` → `_unitIcons`에 이모지 추가
4. (특수능력) `components/defense_unit.dart` → 크리/힐/슬로우 분기 추가

### 새 적
1. `data/enemy_data.dart` → DefenseEnemyData (unlockWave 설정)
2. `renderers/defense_enemy_renderer.dart` → 렌더 case
3. (특수 행동) `components/defense_enemy.dart` → 로직 추가

### 새 유물
1. `data/relic_data.dart` → RelicDef 추가 (id, name, icon, description, rarity, category)
2. `systems/relic_manager.dart` → 효과 getter/이벤트 핸들러 추가
3. (게임 로직) `game/defense_game.dart` → 효과 적용 포인트 추가

### 새 영구 업그레이드
1. `systems/defense_upgrade_manager.dart` → DefenseUpgradeId enum + DefenseUpgradeData + getter
2. `ui/star_shop_screen.dart` → 자동 표시

### 밸런스 수치 변경
1. `data/balance_config.dart` → 해당 상수 수정
   다른 파일 수정 불필요
