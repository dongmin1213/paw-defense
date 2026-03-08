# The Bichon's Run — 반방치 오토러너

## 한 줄 요약
Idle Slayer 스타일 반방치 오토러너. 비숏(Bichon Frise)이 자동으로 달리며 적을 처치하고 코인을 모은다. 탭(점프)하면 효율적이지만 방치해도 코인이 모이는 구조.

## Tech Stack
- **Framework**: Flutter 3.27.4 / Dart 3.6.2
- **Game Engine**: Flame 1.14.0 (flame_audio 2.1.0)
- **저장**: shared_preferences 2.2.0
- **Target**: Android (landscape, immersive mode)
- **CI/CD**: GitHub Actions → APK 빌드 (`.github/workflows/build-apk.yml`)
- **로컬 빌드**: flutter SDK 미설치 — CI로만 빌드 검증

## 빌드
```bash
flutter pub get
flutter build apk --release
```

---

## 프로젝트 구조 (40개 파일, ~7000줄)

```
lib/
├── main.dart                     # 앱 진입점, 7개 오버레이 등록
├── game/
│   └── runner_game.dart          # FlameGame 메인 (466줄) — 게임 상태, 카메라, 입력, 이벤트
├── components/                   # 게임 엔티티 (Flame PositionComponent)
│   ├── runner_player.dart        # 비숏 — 자동 달리기, 점프, 자동 공격, 충돌
│   ├── ground_segment.dart       # 무한 반복 바닥 블록 (400px 단위)
│   ├── enemy.dart                # 몬스터 — 바닥/공중, HP, 코인 드랍, 황금 적
│   ├── coin.dart                 # 코인 — 호버 애니, 수집 팝업 "+N"
│   ├── obstacle.dart             # 바위 장애물 — 충돌 시 2초간 속도 50%
│   ├── parallax_layer.dart       # 3레이어 프로시저럴 패럴랙스 배경
│   ├── companion_pickup.dart     # 필드 동료 픽업 — 희귀도 글로우, 수집 팝업
│   ├── boss.dart                 # 보스 — 500m마다, HP바, 자동+탭 공격, 10초 제한
│   ├── weather_effect.dart       # 날씨 파티클 — 비/눈/폭풍/무지개 + 시간대 오버레이
│   └── particle_effect.dart      # FX 파티클 — 코인수집/적처치/보스폭발/먼지
├── data/                         # ★ 데이터 정의 — 컨텐츠 추가 시 여기만 수정
│   ├── balance_config.dart       # ★ 모든 밸런스 수치 한 곳 (비용공식, 드랍률, 속도커브)
│   ├── enemy_data.dart           # 적 20종 (5지역 x 바닥2+공중2)
│   ├── region_data.dart          # 5개 지역 (초원/숲/사막/설산/화산)
│   ├── upgrade_data.dart         # 일반 업그레이드 7종
│   ├── soul_upgrade_data.dart    # 영구 업그레이드 13종
│   └── companion_data.dart       # 동료 10종 (일반3/레어3/에픽2/전설2)
├── renderers/                    # ★ 렌더링 분리 — 스프라이트 교체 시 여기만 수정
│   ├── player_renderer.dart      # 비숏 Canvas 드로잉
│   ├── enemy_renderer.dart       # 적 20종 + 황금 적 Canvas 드로잉
│   ├── coin_renderer.dart        # 코인 Canvas 드로잉
│   ├── companion_renderer.dart   # 동료 10종 Canvas 드로잉
│   └── boss_renderer.dart        # 보스 5종 Canvas 드로잉
├── systems/                      # 게임 시스템 (매니저 패턴)
│   ├── level_generator.dart      # 절차적 레벨 생성 — 적/코인/장애물/동료/보스 배치
│   ├── upgrade_manager.dart      # 일반 업글 — 레벨/구매/비용계산/배율 getter
│   ├── ascension_manager.dart    # 초월 — 소울 계산, 영구 업글, 지역/장비 해금
│   ├── companion_manager.dart    # 동료 — 수집/장착(1~4슬롯)/레벨업/버프 계산
│   ├── weather_manager.dart      # 날씨(5종) + 시간대(4종) — 3~5분 주기 + 보너스
│   ├── ad_manager.dart           # 광고 스텁 — 실제 SDK 없이 API만 준비
│   ├── offline_reward.dart       # 오프라인 보상 — CpS 기반, 최소60초~최대24시간
│   └── save_manager.dart         # SharedPreferences 저장/로드 (동료는 JSON)
├── ui/                           # Flutter 위젯 오버레이 (GameWidget overlayBuilderMap)
│   ├── runner_hud.dart           # HUD — 거리, 코인, 콤보, 보스HP, 날씨, 이벤트, 버튼
│   ├── upgrade_shop.dart         # 일반 업그레이드 상점 (pauseEngine)
│   ├── soul_shop.dart            # 영구 업그레이드 상점 — 3탭(강화/지역/장비)
│   ├── ascension_screen.dart     # 초월 연출 — 화이트아웃 + 소울 보상
│   ├── companion_screen.dart     # 동료 관리 — 장착/도감/레벨업
│   ├── offline_popup.dart        # 오프라인 복귀 팝업 — 수령/x2 광고
│   └── main_menu.dart            # 타이틀 화면 — 시작, 통계, 소울상점
└── utils/
    └── constants.dart            # 월드크기(800x600), 물리(중력980, 점프-420)
```

---

## 핵심 게임 루프

```
달리기 → 적 처치 → 코인 획득 → 업그레이드 구매 → 더 빠르게/강하게
    ↓ (누적코인 달성)
  초월 → 소울 획득 → 영구 업그레이드 → 지역/장비 해금 → 재성장
    ↓ (동료는 유지)
  반복 (∞)
```

---

## 코인 배율 스택 (addCoins)

```dart
total = amount
  * (1 + combo * 0.05)     // 콤보 (20콤보 = x2.0)
  * regionMultiplier        // 지역 (초원x1 ~ 화산x100)
  * activeBonus             // 적극 플레이 x1.5
  * upgradeMultiplier       // 코인 업글 (lv25 = x3.0)
  * soulCoinMultiplier      // 영구 코인배율 (+25%/lv)
  * companionMultiplier     // 동료 버프
  * weatherCoinMultiplier   // 날씨 (비+30%, 폭풍x2)
  * timeCoinMultiplier      // 시간대 (저녁+20%)
  * goldenHourMultiplier    // 골든아워 이벤트 x5
  * rainbowMultiplier       // 무지개 날씨 x2
```

---

## 주요 상수 (balance_config.dart + constants.dart)

| 상수 | 값 | 설명 |
|------|-----|------|
| 월드 크기 | 800x600 | FixedResolutionViewport |
| 바닥 Y | 500 | 지면 높이 |
| 기본 속도 | 120px/s | 플레이어 이동 속도 |
| 중력 | 980 | 낙하 가속도 |
| 점프력 | -420 | 점프 초기 속도 |
| 업글 비용배율 | 1.15^lv | 레벨당 15% 증가 |
| 공중적 코인 | x3 | 점프 처치 보너스 |
| 콤보 리셋 | 3초 | 미처치 시 리셋 |
| 방치 판정 | 5초 | 무입력 시 방치 모드 |
| 적극 코인 | x1.5 | 적극 플레이 보너스 |
| 황금적 확률 | 2% | 황금 적 스폰 확률 |
| 초월 임계값 | 10000 * 3^n | n번째 초월 필요 코인 |

---

## 현재 구현 상태 (Phase 1~6 완료)

| Phase | 내용 | 상태 |
|-------|------|------|
| 1 | 핵심 달리기 + 적 + 코인 + 콤보 + 장애물 | ✅ |
| 2 | 업그레이드 7종 + SharedPreferences 저장 + 상점 | ✅ |
| 3 | 초월 + 소울 + 영구업글 13종 + 5지역 적 20종 + 패럴랙스 | ✅ |
| 4 | 동료 10종 + 보스 5종 + 황금 적 + 동료 장착/도감 | ✅ |
| 5 | 날씨/시간(4시간대+5날씨) + 광고 스텁 | ✅ |
| 6 | 오프라인 보상 + 파티클 FX + 특수 이벤트 3종 | ✅ |

## 미구현 (TODO)

- **장비 효과**: 활(자동 공중 처치)/장갑(추가 코인)/망토(대시) — 해금 구조만 있고 실제 효과 없음
- **사운드**: flame_audio 의존성은 있으나 사용 안 함
- **실제 광고**: google_mobile_ads SDK 미연동 (스텁만)
- **온보딩**: 말풍선 튜토리얼 없음
- **업적/퀘스트**: 미구현
- **보물상자/코인 러시**: 미니이벤트 미구현
- **자동 공중적 처치/자동 업글**: 소울 해금은 있지만 실제 로직 미구현

---

## 코드 패턴 & 컨벤션

### Component 패턴
```dart
class Enemy extends PositionComponent
    with HasGameReference<RunnerGame>, CollisionCallbacks {
  // .game 으로 RunnerGame 접근
  // CollisionCallbacks + add(RectangleHitbox()) 로 충돌
  // 카메라 뒤 → removeFromParent()
}
```

### Renderer 패턴
```dart
class EnemyRenderer {
  static void render(Canvas canvas, Size size, EnemyData data, {
    required double animTimer, required bool isHit, required bool isGolden,
  }) { /* Canvas API 프로시저럴 드로잉 */ }
}
```
- 모든 렌더러는 **static 메서드**만. 인스턴스 없음.
- 스프라이트 교체 시 렌더러 파일만 수정.

### Data 패턴
```dart
class EnemyData {
  final String id, name;
  final int hp;
  const EnemyData({...});
}
class EnemyDatabase {
  static const List<EnemyData> _all = [...];
  static List<EnemyData> getGroundEnemies(String regionId) => ...;
}
```
- `const` 생성자 + `static const List`
- `XxxDatabase.getXxx()` static 조회

### 텍스트 렌더링 주의
- Flame `render(Canvas)` 안에서는 **`dart:ui`의 TextStyle**만 사용 가능
- flutter의 TextStyle과 **다른 클래스**
- `ParagraphBuilder` + `ParagraphStyle` + `dart:ui TextStyle` 조합 사용 (coin.dart 참고)

### 동료 저장
- `CompanionManager.toMap()` → `jsonEncode()` → `SharedPreferences.setString()`
- 초월해도 동료 데이터 리셋 안 됨

---

## 새 컨텐츠 추가 가이드

### 새 적 추가
1. `data/enemy_data.dart` — `EnemyData` 항목 추가
2. `renderers/enemy_renderer.dart` — 렌더 case 추가
3. `data/region_data.dart` — 해당 지역 몬스터풀에 포함

### 새 업그레이드 추가
1. `data/upgrade_data.dart` — `UpgradeId` enum + `UpgradeData` 추가
2. `systems/upgrade_manager.dart` — getter/효과 로직 추가
3. UI에 자동 표시 (데이터 기반)

### 새 동료 추가
1. `data/companion_data.dart` — `CompanionData` 추가
2. `renderers/companion_renderer.dart` — 렌더 case 추가
3. `systems/companion_manager.dart` — 버프 로직 추가

### 새 지역 추가
1. `data/region_data.dart` — `RegionData` 추가
2. `data/enemy_data.dart` — 해당 지역 적 추가
3. `data/soul_upgrade_data.dart` — 지역 해금 소울 업글 추가
4. `renderers/boss_renderer.dart` — 보스 렌더 추가

---

## 설계 문서
- `docs/GAME_DESIGN.md` — 전체 게임 설계 (시스템, 밸런스, 경제, 수익화)
- `docs/PROGRESS.md` — Phase별 구현 진행 체크리스트
- `docs/ARCHITECTURE.md` — 코드 아키텍처, 클래스 관계, 데이터 흐름, 확장 가이드
