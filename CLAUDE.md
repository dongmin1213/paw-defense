# Boss Rush - Flutter/Flame Side-Scrolling Action Game

## Project Overview
2D 횡스크롤 보스러시 액션 게임. Flutter + Flame 엔진 기반. Android APK 빌드.

## Tech Stack
- **Framework**: Flutter 3.27.4 / Dart 3.6.2
- **Game Engine**: Flame 1.30.1 (flame_audio 2.11.8)
- **Target**: Android (landscape, immersive mode)
- **CI/CD**: GitHub Actions → APK 빌드 및 artifact 업로드

## Project Structure
```
lib/
├── main.dart                  # 앱 진입점, GameScreen, GameOver/Victory 화면
├── game/
│   └── boss_rush_game.dart    # FlameGame 메인 클래스 (HP, 게이지, 게임상태 관리)
├── components/
│   ├── player.dart            # 플레이어 (이동, 점프, 대시, 사격, 무적)
│   ├── bullet.dart            # 플레이어 탄환 (일반/필살기)
│   ├── enemy_bullet.dart      # 적 탄환 (straight, sine, aimed, falling 패턴)
│   └── ground.dart            # 지면 렌더링
├── bosses/
│   ├── boss_base.dart         # 보스 추상 클래스 (HP, 페이즈, 피격, 충돌)
│   ├── boss1_guardian.dart     # 1번 보스: Stone Guardian (3페이즈)
│   └── boss_factory.dart      # 보스 팩토리 (8개 슬롯, 현재 1개 구현)
├── ui/
│   ├── game_overlay.dart      # HUD (HP 하트, 게이지바, 보스HP) + 조작 버튼
│   └── main_menu.dart         # 메인 메뉴 (보스 선택 그리드)
└── utils/
    └── constants.dart         # 게임 상수 (물리, 밸런스, 색상)
```

## Key Architecture
- **렌더링**: 스프라이트 없이 Canvas API로 프로시저럴 드로잉
- **카메라**: `FixedResolutionViewport(800x600)` 고정 해상도
- **입력**: Flutter 위젯 오버레이 버튼 → Player 플래그 설정
- **보스 시스템**: `BossBase` 추상 클래스 → 각 보스가 페이즈별 행동 구현
- **충돌**: Flame `CollisionCallbacks` + `RectangleHitbox`
- **Mixin**: `HasGameReference<BossRushGame>` (`.game`으로 접근)

## Build & CI
```bash
flutter pub get
flutter build apk --release
```
GitHub Actions: `.github/workflows/build-apk.yml` → push시 자동 빌드

## Important Notes
- `HasGameRef` deprecated → `HasGameReference` 사용 (`.gameRef` → `.game`)
- `FixedResolutionViewport`는 `package:flame/camera.dart`에서 import
- assets 폴더(images/, audio/)는 비어있음 - 현재 프로시저럴 렌더링만 사용
- `resetGame()`에서 `onLoad()` 직접 호출 중 - 향후 리팩토링 고려
