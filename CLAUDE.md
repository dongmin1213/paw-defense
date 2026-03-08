# The Bichon's Run — 반방치 오토러너

## Project Overview
Idle Slayer 스타일 반방치 오토러너 게임. 비숏(Bichon Frisé)이 끝없이 달리며 몬스터를 처치하고 코인을 모은다. 직접 플레이(탭=점프)하면 효율적이지만 방치해도 코인이 모이는 구조. 동료 시스템 + 날씨/시간 시스템으로 차별화.

## Tech Stack
- **Framework**: Flutter 3.27.4 / Dart 3.6.2
- **Game Engine**: Flame 1.14.0+ (flame_audio 2.1.0)
- **Target**: Android (landscape, immersive mode)
- **CI/CD**: GitHub Actions → APK 빌드 및 artifact 업로드

## Project Structure
```
lib/
├── main.dart                     # 앱 진입점
├── game/
│   └── runner_game.dart          # FlameGame 메인 (카메라, 입력, 게임 상태)
├── components/
│   ├── runner_player.dart        # 자동 달리기 비숏 (점프, 공격, 충돌)
│   ├── ground_segment.dart       # 무한 반복 바닥
│   ├── enemy.dart                # 몬스터 (바닥/공중, HP, 코인 드랍)
│   ├── coin.dart                 # 수집 코인 (호버, 팝업)
│   └── obstacle.dart             # 장애물 (속도 감소)
├── data/                         # ★ 데이터 정의 (컨텐츠 추가 = 여기만 수정)
│   ├── balance_config.dart       # 밸런스 수치 전부
│   ├── enemy_data.dart           # 적 스탯/드랍/출현율
│   ├── region_data.dart          # 지역별 배경/몬스터풀/배율
│   └── upgrade_data.dart         # 업그레이드 정의 (비용/효과/최대레벨)
├── renderers/                    # ★ 렌더링 분리 (에셋 교체 = 여기만)
│   ├── player_renderer.dart      # 비숏 프로시저럴 렌더링
│   ├── enemy_renderer.dart       # 적 프로시저럴 렌더링
│   └── coin_renderer.dart        # 코인 프로시저럴 렌더링
├── systems/
│   ├── level_generator.dart      # 절차적 적/코인/장애물 배치
│   ├── upgrade_manager.dart      # 업글 레벨/구매/효과 계산
│   └── save_manager.dart         # SharedPreferences 저장/로드
├── ui/
│   ├── runner_hud.dart           # HUD (거리, 코인, 콤보, 상점버튼)
│   ├── upgrade_shop.dart         # 업그레이드 상점 오버레이
│   └── main_menu.dart            # 타이틀 화면 + 시작
└── utils/
    └── constants.dart            # 월드 크기, 물리 상수
```

## Key Architecture
- **Data-Driven**: 적/업글/지역 등 모든 컨텐츠가 `data/` 디렉토리에 데이터로 정의. 새 컨텐츠 = 데이터 추가만.
- **Renderer 분리**: `renderers/`에서 렌더링 전담. 프로시저럴 → 스프라이트 교체 시 여기만 수정.
- **밸런스 집중**: `balance_config.dart`에 모든 수치 (비용, 드랍률, 속도 커브 등).
- **카메라**: `FixedResolutionViewport(800x600)`, 플레이어 X 추적.
- **입력**: 화면 탭 = 점프. TapCallbacks mixin.
- **충돌**: Flame `CollisionCallbacks` + `RectangleHitbox`/`CircleHitbox`.
- **방치/적극 모드**: 5초 무입력 시 방치 모드 (장애물 미생성, 공중 적 미생성).

## Build & CI
```bash
flutter pub get
flutter build apk --release
```
GitHub Actions: `.github/workflows/build-apk.yml`

## Current State
- **Phase 1 완료**: 핵심 달리기 + 몬스터 + 코인 + 장애물 + 콤보 + HUD
- **Phase 2 완료**: 업그레이드 7종 + SharedPreferences 저장 + 상점 UI + 메인 메뉴
- **다음**: Phase 3 (초월 + 영구 업글 + 지역)

## 전체 로드맵
- Phase 1: ✅ 핵심 달리기
- Phase 2: ✅ 업그레이드 + 저장 (SharedPreferences)
- Phase 3: 초월 + 영구 업글 + 지역
- Phase 4: 동료 + 보스 + 미니이벤트
- Phase 5: 날씨/시간 + 광고 (google_mobile_ads)
- Phase 6: 오프라인 + 폴리시

## 설계 문서
- `docs/GAME_DESIGN.md` — 전체 게임 설계 (시스템, 밸런스, 경제)
- `docs/PROGRESS.md` — 구현 진행 상황
- `docs/ARCHITECTURE.md` — 코드 아키텍처, 확장 가이드

## 코드 컨벤션 & 패턴

### Component 패턴
- 모든 게임 컴포넌트는 `PositionComponent` + `HasGameReference<RunnerGame>` mixin
- `.game`으로 RunnerGame 접근 (`.gameRef` deprecated)
- 충돌: `CollisionCallbacks` mixin + `RectangleHitbox` 또는 `CircleHitbox`
- 카메라 뒤 컴포넌트 자동 정리: `if (position.x < game.camera.viewfinder.position.x - 200) removeFromParent()`

### 렌더러 패턴
- `renderers/` 내 모든 클래스는 **static 메서드**만 가짐 (인스턴스 없음)
- `render(Canvas canvas, Size size, ...)` 시그니처 통일
- 현재 전부 Canvas API 프로시저럴 드로잉, 나중에 스프라이트 교체 시 렌더러만 수정

### 데이터 패턴
- `data/` 내 클래스는 `const` 생성자 + `static const List` 로 정의
- `XxxDatabase` 클래스에 `static` 조회 메서드 제공
- 새 컨텐츠 추가 = 리스트에 항목 추가 + 렌더러에 case 추가

### 텍스트 렌더링 주의
- coin.dart의 "+N" 팝업: `dart:ui`의 `ParagraphBuilder` + `ParagraphStyle` + `TextStyle` 사용
- **flutter의 TextStyle과 dart:ui의 TextStyle은 다른 클래스** — Flame Component의 render()에서는 dart:ui만 사용 가능
- `textStyle.getTextStyle()` 같은 혼용은 에러남

## 기술적 결정사항

### 왜 이렇게 했는가
1. **프로시저럴 렌더링**: 에셋 없이 빠르게 프로토타이핑. `renderers/` 분리로 나중에 스프라이트 교체 용이
2. **FixedResolutionViewport(800x600)**: 모든 기기에서 동일한 게임 경험. 카메라가 player.x - 150 추적
3. **방치/적극 모드 분리**: 방치 시 장애물·공중적 미생성으로 패널티 없는 방치 보장. `_lastTapTime` 기반 5초 판정
4. **LevelGenerator가 Component**: `update(dt)`에서 카메라 위치 기반 자동 생성. `generationCursor`로 중복 방지
5. **HUD는 Flutter 위젯 오버레이**: GameWidget의 overlayBuilder로 구현. 100ms Timer 폴링 (리스너 패턴으로 개선 가능)
6. **enemy HP 시스템**: 공격력 업그레이드가 의미 있으려면 적에게 HP 필요. `onHit()` → HP 감소 → 0이면 `_die()`

### 알려진 한계/이슈
- 로컬에 flutter SDK 없음 → CI(GitHub Actions)로만 빌드 검증
- HUD 100ms 폴링 비효율 → Phase 2에서 상태 관리 도입 시 개선 가능
- RunnerGame.resetGame() 미구현 → 메인 메뉴 추가 시 필요
- enemy_data.dart에 초원(meadow) 적만 정의됨 → Phase 3에서 지역별 적 추가

## Phase 3 시작 가이드

Phase 3 구현 순서:
1. `systems/ascension_manager.dart` — 초월 조건 체크, 실행, 소울 계산, 리셋 처리
2. `ui/soul_shop.dart` — 영구 업글 UI (소울 소비, 지역/장비 해금)
3. 초월 연출 (화면 화이트아웃 → "초월 N회차" → 메인 메뉴)
4. `components/parallax_layer.dart` — 지역별 3레이어 프로시저럴 배경
5. 지역별 몬스터 풀 확장 (enemy_data.dart에 숲/사막/설산/화산 적 추가)
6. 장비 시스템 기본 (data/equipment_data.dart + 검 기본 + 활/장갑/망토)

핵심 연결 포인트:
- `RunnerGame`에 `AscensionManager ascensionManager` 필드 추가
- 초월 시 `upgradeManager.resetAll()` + `saveManager.resetForAscension()` 호출
- 소울 업글은 별도 데이터 구조 (soul_upgrade_data.dart)
- 지역 변경: `game.currentRegionId` 변경 → 배경색/몬스터풀 자동 전환
- SaveManager에 소울/초월 횟수/영구업글 저장 추가

## Important Notes
- `HasGameRef` deprecated → `HasGameReference` 사용 (`.game`으로 접근)
- `FixedResolutionViewport`는 `package:flame/camera.dart`에서 import
- assets 폴더(images/, audio/)는 비어있음 — 프로시저럴 렌더링
- 모든 밸런스 수치는 `balance_config.dart`에서 관리
- 새 적 추가: `enemy_data.dart`에 데이터 추가 + `enemy_renderer.dart`에 렌더 함수 추가
- 새 지역 추가: `region_data.dart`에 데이터 추가
