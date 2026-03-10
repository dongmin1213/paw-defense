# 코드 아키텍처

## 레이어 구조

```
UI (Flutter 위젯 오버레이)
    ↕ overlays.add/remove
Game (DefenseGame — FlameGame)
    ↕ world.add, .game 참조
Components (Wall, DefenseUnit, DefenseEnemy, Projectile)
    ↕ 데이터 참조
Data (unit_data, enemy_data, balance_config)
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
game.gameFeel.onEnemyKill();     // 쉐이크
game.gameFeel.onBossKill();      // 쉐이크 + 히트스탑 + 슬로모션 + 줌펀치
game.gameFeel.shake(intensity: 5, duration: 0.2);
```
- 히트스탑 중 update(dt) 스킵
- 슬로모션: dt * gameFeel.timeScale

### 텍스트 렌더링 주의
- Flame render(Canvas)에서는 `dart:ui`의 TextStyle만 사용
- ParagraphBuilder + ParagraphStyle 조합 (damage_number.dart 참고)

## 게임 라이프사이클

```
main.dart → DefenseGame.onLoad()
  → soundManager 초기화
  → overlays.add('DefenseMainMenu')
  → startGame()
    → wall/slots/waveManager 초기화
    → overlays.add('DefenseHud')
  → update(dt)
    → gameFeel 적용 (히트스탑/슬로모션)
    → camera shake/zoom
  → onWallDestroyed()
    → overlays.add('RunResult')
  → goToMainMenu()

9개 오버레이: DefenseMainMenu, DefenseHud, WaveReward,
StarShop, RunResult, Pause, RelicSelection, Tutorial, Settings
```

## 데이터 의존 관계

```
balance_config.dart ← wave_manager.dart, defense_game.dart, defense_unit.dart
enemy_data.dart     ← wave_manager.dart, defense_game.dart
unit_data.dart      ← defense_unit.dart
relic_manager.dart  ← defense_game.dart, relic_selection_screen.dart
sound_manager.dart  ← defense_game.dart, main.dart (앱 라이프사이클)
```

## 새 컨텐츠 추가 가이드

### 새 유닛
1. `data/unit_data.dart` → UnitType enum + UnitData
2. `renderers/unit_renderer.dart` → 렌더 case
3. `game/defense_game.dart` → `_unitIcons`, `_unitTypeIds`

### 새 적
1. `data/enemy_data.dart` → DefenseEnemyData (unlockWave 설정)
2. `renderers/defense_enemy_renderer.dart` → 렌더 case
3. (특수 행동) `components/defense_enemy.dart` → 로직 추가

### 새 유물
1. `systems/relic_manager.dart` → allRelicIds + 효과 getter
2. `ui/relic_selection_screen.dart` → _relicDatabase UI 정보

### 새 영구 업그레이드
1. `systems/defense_upgrade_manager.dart` → DefenseUpgradeId + getter
2. `ui/star_shop_screen.dart` → 자동 표시

### 밸런스 수치 변경
1. `data/balance_config.dart` → 해당 상수 수정
   다른 파일 수정 불필요
