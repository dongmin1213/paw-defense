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
├── main.dart                     # 앱 진입점 (7개 오버레이 등록)
├── game/
│   └── runner_game.dart          # FlameGame 메인 (카메라, 입력, 게임 상태, 이벤트)
├── components/
│   ├── runner_player.dart        # 자동 달리기 비숏 (점프, 공격, 충돌)
│   ├── ground_segment.dart       # 무한 반복 바닥
│   ├── enemy.dart                # 몬스터 (바닥/공중, HP, 코인 드랍, 황금 적)
│   ├── coin.dart                 # 수집 코인 (호버, 팝업)
│   ├── obstacle.dart             # 장애물 (속도 감소)
│   ├── parallax_layer.dart       # 3레이어 패럴랙스 배경
│   ├── companion_pickup.dart     # 필드 동료 픽업 (희귀도 글로우)
│   ├── boss.dart                 # 500m마다 보스 (HP바, 시간제한)
│   ├── weather_effect.dart       # 날씨 파티클 (비/눈/폭풍/무지개) + 시간대 오버레이
│   └── particle_effect.dart      # 파티클 FX (코인수집/적처치/보스폭발/먼지)
├── data/                         # ★ 데이터 정의 (컨텐츠 추가 = 여기만 수정)
│   ├── balance_config.dart       # 밸런스 수치 전부
│   ├── enemy_data.dart           # 적 스탯/드랍/출현율 (5지역 20종)
│   ├── region_data.dart          # 지역별 배경/몬스터풀/배율
│   ├── upgrade_data.dart         # 일반 업그레이드 정의
│   ├── soul_upgrade_data.dart    # 영구 업그레이드 정의 (소울)
│   └── companion_data.dart       # 동료 10종 (희귀도/출현율/버프)
├── renderers/                    # ★ 렌더링 분리 (에셋 교체 = 여기만)
│   ├── player_renderer.dart      # 비숏 프로시저럴 렌더링
│   ├── enemy_renderer.dart       # 적 프로시저럴 렌더링 (20종 + 황금)
│   ├── coin_renderer.dart        # 코인 프로시저럴 렌더링
│   ├── companion_renderer.dart   # 동료 10종 프로시저럴 렌더링
│   └── boss_renderer.dart        # 보스 5종 프로시저럴 렌더링
├── systems/
│   ├── level_generator.dart      # 절차적 적/코인/장애물/동료/보스 배치
│   ├── upgrade_manager.dart      # 일반 업글 레벨/구매/효과
│   ├── ascension_manager.dart    # 초월 + 소울 + 영구 업글
│   ├── companion_manager.dart    # 동료 수집/장착/레벨업/버프
│   ├── weather_manager.dart      # 날씨(5종) + 시간대(4종) 관리
│   ├── ad_manager.dart           # 광고 스텁 (보상형/인터스티셜)
│   ├── offline_reward.dart       # CpS 기반 오프라인 보상 계산
│   └── save_manager.dart         # SharedPreferences 저장/로드 (동료 JSON)
├── ui/
│   ├── runner_hud.dart           # HUD (거리, 코인, 콤보, 보스HP, 날씨, 이벤트, 버튼들)
│   ├── upgrade_shop.dart         # 일반 업그레이드 상점
│   ├── soul_shop.dart            # 영구 업그레이드 상점 (소울)
│   ├── ascension_screen.dart     # 초월 연출 화면
│   ├── companion_screen.dart     # 동료 장착/도감/레벨업
│   ├── offline_popup.dart        # 오프라인 보상 팝업 (수령/x2)
│   └── main_menu.dart            # 타이틀 화면 + 시작
└── utils/
    └── constants.dart            # 월드 크기, 물리 상수
```

## Key Architecture
- **Data-Driven**: 적/업글/지역/동료 등 모든 컨텐츠가 `data/` 디렉토리에 데이터로 정의. 새 컨텐츠 = 데이터 추가만.
- **Renderer 분리**: `renderers/`에서 렌더링 전담. 프로시저럴 → 스프라이트 교체 시 여기만 수정.
- **밸런스 집중**: `balance_config.dart`에 모든 수치 (비용, 드랍률, 속도 커브 등).
- **카메라**: `FixedResolutionViewport(800x600)`, 플레이어 X 추적.
- **입력**: 화면 탭 = 점프 + 보스 공격. TapCallbacks mixin.
- **충돌**: Flame `CollisionCallbacks` + `RectangleHitbox`/`CircleHitbox`.
- **방치/적극 모드**: 5초 무입력 시 방치 모드 (장애물 미생성, 공중 적 미생성, 동료 미출현).

## Build & CI
```bash
flutter pub get
flutter build apk --release
```
GitHub Actions: `.github/workflows/build-apk.yml`

## Current State
- **Phase 1 완료**: 핵심 달리기 + 몬스터 + 코인 + 장애물 + 콤보 + HUD
- **Phase 2 완료**: 업그레이드 7종 + SharedPreferences 저장 + 상점 UI + 메인 메뉴
- **Phase 3 완료**: 초월 + 소울 + 영구 업글 13종 + 5개 지역 적 20종 + 패럴랙스 배경
- **Phase 4 완료**: 동료 10종 + 보스 5종 + 황금 적 + 동료 장착/도감
- **Phase 5 완료**: 날씨/시간(4시간대+5날씨) + 광고 스텁
- **Phase 6 완료**: 오프라인 보상 + 파티클 FX + 특수 이벤트 3종
- **다음**: 장비 효과(활/장갑/망토), 사운드, 실제 광고 SDK 연동

## 전체 로드맵
- Phase 1: ✅ 핵심 달리기
- Phase 2: ✅ 업그레이드 + 저장 (SharedPreferences)
- Phase 3: ✅ 초월 + 영구 업글 + 지역
- Phase 4: ✅ 동료 + 보스 + 황금 적
- Phase 5: ✅ 날씨/시간 + 광고 스텁
- Phase 6: ✅ 오프라인 + 파티클 + 특수 이벤트

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

### 동료 저장 패턴
- 동료 데이터는 JSON으로 직렬화 → SharedPreferences에 문자열 저장
- `CompanionManager.toMap()` → `jsonEncode()` → `_prefs.setString()`
- 초월해도 동료는 리셋되지 않음 (장기 수집 동기)

## 기술적 결정사항

### 왜 이렇게 했는가
1. **프로시저럴 렌더링**: 에셋 없이 빠르게 프로토타이핑. `renderers/` 분리로 나중에 스프라이트 교체 용이
2. **FixedResolutionViewport(800x600)**: 모든 기기에서 동일한 게임 경험. 카메라가 player.x - 150 추적
3. **방치/적극 모드 분리**: 방치 시 장애물·공중적 미생성으로 패널티 없는 방치 보장. `_lastTapTime` 기반 5초 판정
4. **LevelGenerator가 Component**: `update(dt)`에서 카메라 위치 기반 자동 생성. `generationCursor`로 중복 방지
5. **HUD는 Flutter 위젯 오버레이**: GameWidget의 overlayBuilder로 구현. 100ms Timer 폴링
6. **enemy HP 시스템**: 공격력 업그레이드가 의미 있으려면 적에게 HP 필요
7. **보스 자동공격+탭공격**: 방치해도 보스 진행 가능, 탭하면 2x DPS로 효율적

### 알려진 한계/이슈
- 로컬에 flutter SDK 없음 → CI(GitHub Actions)로만 빌드 검증
- HUD 100ms 폴링 비효율 → 상태 관리 도입 시 개선 가능
- 장비 효과(활/장갑/망토) 미구현 → 별도 세션에서
- 보물상자/코인 러시 미니이벤트 미구현 → 별도 세션에서
- 광고는 스텁(placeholder) — 실제 google_mobile_ads SDK는 AndroidManifest 설정 필요
- 사운드 미구현 → 별도 세션에서 flame_audio 추가

## 날씨/시간 시스템 가이드

- `WeatherManager`는 `runner_game.dart`에서 `update(dt)`로 갱신
- 시간대: 기기 시간 기반 (6~18 낮, 18~22 저녁, 22~4 밤, 4~6 새벽)
- 날씨: 3~5분 주기 랜덤 (맑음50%/비20%/눈15%/폭풍10%/무지개5%)
- `addCoins()`에서 `weatherCoinMultiplier * timeCoinMultiplier * goldenMult * rainbowMult` 적용
- `WeatherEffect`가 시각적 파티클 + 시간대 오버레이 렌더링

## 특수 이벤트 가이드

- 평균 10분마다 랜덤 발생 (5분 쿨다운)
- 골든 아워(20초): 모든 적 황금, 코인x5
- 유성우(30초): 하늘에서 코인 비
- 동료 집회(60초): 동료 출현율 5배

## Important Notes
- `HasGameRef` deprecated → `HasGameReference` 사용 (`.game`으로 접근)
- `FixedResolutionViewport`는 `package:flame/camera.dart`에서 import
- assets 폴더(images/, audio/)는 비어있음 — 프로시저럴 렌더링
- 모든 밸런스 수치는 `balance_config.dart`에서 관리
- 새 적 추가: `enemy_data.dart`에 데이터 추가 + `enemy_renderer.dart`에 렌더 함수 추가
- 새 동료 추가: `companion_data.dart`에 데이터 추가 + `companion_renderer.dart`에 case 추가 + `companion_manager.dart` 버프 로직 추가
- 새 보스 추가: `boss_renderer.dart`에 지역별 렌더 추가
