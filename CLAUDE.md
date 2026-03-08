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
│   └── region_data.dart          # 지역별 배경/몬스터풀/배율
├── renderers/                    # ★ 렌더링 분리 (에셋 교체 = 여기만)
│   ├── player_renderer.dart      # 비숏 프로시저럴 렌더링
│   ├── enemy_renderer.dart       # 적 프로시저럴 렌더링
│   └── coin_renderer.dart        # 코인 프로시저럴 렌더링
├── systems/
│   └── level_generator.dart      # 절차적 적/코인/장애물 배치
├── ui/
│   └── runner_hud.dart           # HUD (거리, 코인, 콤보)
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
- **다음**: Phase 2 (업그레이드 + 저장)

## 전체 로드맵
- Phase 1: ✅ 핵심 달리기
- Phase 2: 업그레이드 + 저장 (SharedPreferences)
- Phase 3: 초월 + 영구 업글 + 지역
- Phase 4: 동료 + 보스 + 미니이벤트
- Phase 5: 날씨/시간 + 광고 (google_mobile_ads)
- Phase 6: 오프라인 + 폴리시

## 설계 문서
- `docs/GAME_DESIGN.md` — 전체 게임 설계 (시스템, 밸런스, 경제)
- `docs/PROGRESS.md` — 구현 진행 상황
- `docs/ARCHITECTURE.md` — 코드 아키텍처, 확장 가이드

## Important Notes
- `HasGameRef` deprecated → `HasGameReference` 사용 (`.game`으로 접근)
- `FixedResolutionViewport`는 `package:flame/camera.dart`에서 import
- assets 폴더(images/, audio/)는 비어있음 — 프로시저럴 렌더링
- 모든 밸런스 수치는 `balance_config.dart`에서 관리
- 새 적 추가: `enemy_data.dart`에 데이터 추가 + `enemy_renderer.dart`에 렌더 함수 추가
- 새 지역 추가: `region_data.dart`에 데이터 추가
