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

### UI 테마 (GameTheme static)
```dart
GameTheme.pixelButton(label: '시작', onTap: () {});
GameTheme.pixelProgressBar(value: 0.7);
GameTheme.formatInt(12345); // '12.3K'
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
game.gameFeel.onBossKill();      // 히트스탑 + 슬로모션 + 줌펀치
game.gameFeel.onWallHit();       // 벽 피격 반응
```
- 히트스탑 중 update(dt) 스킵
- 슬로모션: dt * gameFeel.timeScale
- 스크린 쉐이크: 제거됨 (defense_game_feel.dart에서 삭제)

### 텍스트 렌더링 주의
- Flame render(Canvas)에서는 `dart:ui`의 TextStyle만 사용
- ParagraphBuilder + ParagraphStyle 조합 (damage_number.dart 참고)

## 게임 라이프사이클

```
main.dart → DefenseGame.onLoad()
  → soundManager 초기화
  → comboManager 초기화 (add to world)
  → overlays.add('DefenseMainMenu')
  → startGame()
    → wall/slots/waveManager 초기화
    → relicManager.reset(), comboManager.resetAll()
    → gold = 50 + startUnits * 10 + startGoldBonus
    → overlays.add('DefenseHud')
  → update(dt)
    → gameFeel 적용 (히트스탑/슬로모션)
    → camera shake/zoom
    → livingWall/wallTurret DPS (유물)
  → onEnemyKilled()
    → comboManager.onEnemyKilled()
    → 유물 효과 (bonus gold, kill heal, chain lightning, boss gold)
    → particle effects (scaled by combo tier)
  → onWaveStart()
    → 유물 효과 (wave gold, blessing rain, rift, time warp)
  → onWallDestroyed()
    → overlays.add('RunResult')
  → goToMainMenu()

9개 오버레이: DefenseMainMenu, DefenseHud, WaveReward,
StarShop, RunResult, Pause, RelicSelection, Tutorial, Settings
```

## 데이터 의존 관계

```
balance_config.dart     ← wave_manager, defense_game, defense_unit, relic_manager
enemy_data.dart         ← wave_manager, defense_game
unit_data.dart          ← defense_unit
hybrid_unit_data.dart   ← defense_unit, merge_manager, defense_game, unit_renderer
relic_data.dart         ← relic_manager, relic_selection_screen, defense_hud
relic_manager.dart      ← defense_game, defense_unit, defense_enemy, wave_manager, wall
combo_manager.dart      ← defense_game, defense_hud
upgrade_manager.dart    ← defense_game, defense_unit, combo_manager, relic_manager
sound_manager.dart      ← defense_game, main.dart (앱 라이프사이클)
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
