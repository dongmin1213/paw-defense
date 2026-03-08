# Code Architecture

## 기술 스택
- Flutter 3.27.4 / Dart 3.6.2
- Flame 1.14.0+ (game engine)
- Android landscape, 800x600 FixedResolutionViewport

## 디렉토리 구조
```
lib/
├── main.dart                     # 앱 진입점
├── game/
│   └── runner_game.dart          # FlameGame 메인 (게임 상태, 카메라, 입력)
├── components/
│   ├── runner_player.dart        # 자동 달리기 비숏
│   ├── ground_segment.dart       # 무한 스크롤 바닥
│   ├── enemy.dart                # 몬스터 (바닥/공중, HP 시스템)
│   ├── coin.dart                 # 코인 드랍 + 팝업
│   └── obstacle.dart             # 장애물 (적극 플레이 시만)
├── data/                         # ★ 데이터 정의 (컨텐츠 = 여기만 수정)
│   ├── enemy_data.dart           # 적 스탯/드랍/출현율
│   ├── region_data.dart          # 지역별 배경/배율
│   └── balance_config.dart       # ★ 밸런스 수치 전부
├── renderers/                    # ★ 렌더링 분리 (에셋 교체 = 여기만)
│   ├── player_renderer.dart      # 비숏 렌더링
│   ├── enemy_renderer.dart       # 적 렌더링
│   └── coin_renderer.dart        # 코인 렌더링
├── systems/
│   └── level_generator.dart      # 절차적 레벨 배치
├── ui/
│   └── runner_hud.dart           # HUD 오버레이
└── utils/
    └── constants.dart            # 물리/월드 상수
```

## 핵심 설계 원칙

### 1. 데이터 주도(Data-Driven)
모든 컨텐츠(적, 업글, 동료, 지역)를 `lib/data/`에 데이터 클래스로 정의.
새 컨텐츠 추가 = 데이터 한 줄 추가, 코드 변경 최소화.

```dart
// data/enemy_data.dart — 새 적 추가 예시
EnemyData(
  id: 'goblin', name: '고블린', type: EnemyType.ground,
  hp: 3, coinDrop: 5, size: Vector2(28, 28),
  color: Color(0xFF4CAF50), accentColor: Color(0xFF388E3C),
  spawnWeight: 10,
),
```

### 2. 렌더러 분리
게임 오브젝트의 렌더링을 별도 static 클래스로 분리.
현재는 Canvas API 프로시저럴 렌더링, 나중에 스프라이트로 교체 가능.

```dart
// 현재: 프로시저럴
PlayerRenderer.render(canvas, size, isRunning: true, ...);

// 나중에: 스프라이트로 교체 시 렌더러만 수정
class PlayerRenderer {
  static late SpriteSheet _sheet;
  static void render(Canvas canvas, Size size, ...) {
    // sprite rendering instead of canvas drawing
  }
}
```

### 3. 밸런스 중앙 관리
`balance_config.dart`에 모든 게임 수치 집중. 밸런스 조정 = 이 파일만 수정.

```dart
class BalanceConfig {
  static const double upgradeCostMultiplier = 1.15;
  static const double airEnemyCoinMultiplier = 3.0;
  static const double comboMultiplierPerStack = 0.05;
  static double ascensionThreshold(int count) => 10000 * pow(3, count);
  // ...
}
```

## 클래스 관계도

```
RunnerGame (FlameGame)
├── RunnerPlayer (PositionComponent)
│   ├── 자동 이동 (position.x += speed * dt)
│   ├── 중력/점프 (velocity.y, groundY)
│   └── 충돌: Enemy → triggerAttack(), Coin → collect(), Obstacle → slowdown()
├── GroundSegment[] (PositionComponent)
│   └── 카메라 뒤 → 앞으로 재배치 (무한 스크롤)
├── Enemy[] (PositionComponent)
│   ├── HP, hitFlash, EnemyData 참조
│   ├── 바닥적: 플레이어 접촉 → 자동 피격
│   └── 공중적: 점프 접촉 → 피격 (x3 코인)
├── Coin[] (PositionComponent)
│   └── 수집 → game.addCoins() + "+N" 팝업
├── Obstacle[] (PositionComponent)
│   └── 충돌 → player.applySlowdown()
└── LevelGenerator (Component)
    └── 카메라 앞 300px 세그먼트 생성, 뒤 컴포넌트 제거
```

## 카메라 시스템
```dart
camera.viewport = FixedResolutionViewport(resolution: Vector2(800, 600));
// update():
camera.viewfinder.position = Vector2(player.position.x - 150, 0);
```

## 무한 레벨 생성
```
generationCursor < cameraX + 1200 이면:
  → 300px 세그먼트 생성
  → 바닥 세그먼트 + 적 1~3마리 + 코인 패턴 + 장애물(적극 모드만)
  → generationCursor += 300

cameraX - 200보다 왼쪽 컴포넌트 → removeFromParent()
```

## 입력 처리
```dart
class RunnerGame extends FlameGame with TapCallbacks {
  void onTapDown(TapDownEvent event) {
    player.jump();
    _lastTapTime = _elapsed;  // 적극 모드 감지용
  }
  bool get isActiveMode => (_elapsed - _lastTapTime) < 5.0;
}
```

## 코인 경제
```dart
void addCoins(double base, {bool isAirKill = false}) {
  final multiplier = currentRegion.coinMultiplier
    * comboMultiplier          // 1 + combo * 0.05
    * (isActiveMode ? 1.5 : 1.0)
    * (isAirKill ? 3.0 : 1.0);
  coins += (base * multiplier).round();
}
```

## 새 컨텐츠 추가 가이드

### 새 적 추가
1. `data/enemy_data.dart`에 `EnemyData` 추가
2. `renderers/enemy_renderer.dart`에 렌더링 메서드 추가
3. `data/region_data.dart`에서 해당 지역 몬스터 풀에 포함

### 새 지역 추가
1. `data/region_data.dart`에 `RegionData` 추가 (배경색, 배율, 해금 비용)
2. 해당 지역 적 데이터를 `enemy_data.dart`에 추가
3. 영구 업그레이드에 지역 해금 항목 추가

### 새 업그레이드 추가
1. `data/upgrade_data.dart`에 업그레이드 정의 추가
2. `systems/upgrade_manager.dart`에서 효과 적용 로직
3. `ui/upgrade_shop.dart`에 자동 표시 (데이터 기반)

### 새 동료 추가
1. `data/companion_data.dart`에 동료 정의
2. `renderers/companion_renderer.dart`에 렌더링
3. `systems/companion_manager.dart`에서 버프 로직
