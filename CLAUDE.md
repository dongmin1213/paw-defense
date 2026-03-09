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

## 프로젝트 구조 (49개 파일, ~11000줄)

```
lib/
├── main.dart                     # 앱 진입점, 9개 오버레이 등록
├── game/
│   └── runner_game.dart          # FlameGame 메인 — 게임 상태, 카메라, 입력, 이벤트, 게임필/업적/일일보너스 통합
├── components/                   # 게임 엔티티 (Flame PositionComponent)
│   ├── runner_player.dart        # 비숏 — 자동 달리기, 점프, 자동 공격, 충돌
│   ├── ground_segment.dart       # 무한 반복 바닥 블록 (400px 단위)
│   ├── enemy.dart                # 몬스터 — 바닥/공중, HP, 코인 드랍, 황금 적, 업적 추적
│   ├── coin.dart                 # 코인 — 호버 애니, 수집 팝업 "+N"
│   ├── obstacle.dart             # 바위 장애물 — 충돌 시 2초간 속도 50%
│   ├── parallax_layer.dart       # 3레이어 프로시저럴 패럴랙스 배경
│   ├── companion_pickup.dart     # 필드 동료 픽업 — 희귀도 글로우, 수집 팝업
│   ├── boss.dart                 # 보스 — 500m마다, HP바, 자동+탭 공격, 10초 제한, 업적 추적
│   ├── treasure_box.dart         # ★ 보물상자 — 3등급(일반/레어/에픽), 코인 폭발, 필드 스폰
│   ├── weather_effect.dart       # 날씨 파티클 — 비/눈/폭풍/무지개 + 시간대 오버레이
│   └── particle_effect.dart      # FX 파티클 — 코인수집/적처치/보스폭발/먼지
├── data/                         # ★ 데이터 정의 — 컨텐츠 추가 시 여기만 수정
│   ├── balance_config.dart       # ★ 모든 밸런스 수치 한 곳 (비용공식, 드랍률, 속도커브)
│   ├── enemy_data.dart           # 적 20종 (5지역 x 바닥2+공중2)
│   ├── region_data.dart          # 5개 지역 (초원/숲/사막/설산/화산)
│   ├── upgrade_data.dart         # 일반 업그레이드 7종
│   ├── soul_upgrade_data.dart    # 영구 업그레이드 13종
│   ├── companion_data.dart       # 동료 10종 (일반3/레어3/에픽2/전설2)
│   └── achievement_data.dart     # ★ 업적 46종 (전투/경제/진행/수집/특수 5카테고리)
├── renderers/                    # ★ 렌더링 분리 — 픽셀아트 스프라이트 교체 시 여기만 수정
│   ├── player_renderer.dart      # 비숏 픽셀아트 스프라이트 (idle/run/jump/attack)
│   ├── enemy_renderer.dart       # 적 20종 + 황금 적 픽셀아트 스프라이트
│   ├── coin_renderer.dart        # 코인 픽셀아트 (12x12, 외곽선+하이라이트)
│   ├── companion_renderer.dart   # 동료 10종 픽셀아트 스프라이트
│   └── boss_renderer.dart        # 보스 5종 픽셀아트 스프라이트
├── systems/                      # 게임 시스템 (매니저 패턴)
│   ├── level_generator.dart      # 절차적 레벨 생성 — 적/코인/장애물/동료/보스/보물상자 배치
│   ├── upgrade_manager.dart      # 일반 업글 — 레벨/구매/비용계산/배율 getter + upgradeIdFromName
│   ├── ascension_manager.dart    # 초월 — 소울 계산, 영구 업글, 지역/장비 해금
│   ├── companion_manager.dart    # 동료 — 수집/장착(1~4슬롯)/레벨업/버프 계산
│   ├── weather_manager.dart      # 날씨(5종) + 시간대(4종) — 3~5분 주기 + 보너스
│   ├── game_feel.dart            # ★ 게임필 — 스크린쉐이크/히트스탑/슬로모션/줌펀치/자동시스템
│   ├── achievement_manager.dart  # ★ 업적 — 46종 마일스톤 추적, 보상 지급
│   ├── daily_bonus_manager.dart  # ★ 일일 보너스 — 7일 주기 출석, 연속 배율
│   ├── bonus_stage_manager.dart  # ★ 보너스 스테이지 — 코인 러시 구간 (8초)
│   ├── ad_manager.dart           # 광고 스텁 — 실제 SDK 없이 API만 준비
│   ├── offline_reward.dart       # 오프라인 보상 — CpS 기반, 최소60초~최대24시간
│   └── save_manager.dart         # SharedPreferences 저장/로드 (동료/업적/일일보너스 JSON)
├── ui/                           # ★ Flutter 위젯 오버레이 — GameTheme 기반 통합 디자인 시스템
│   ├── game_theme.dart           # ★ 통합 디자인 시스템 — 색상/타이포/버튼/패널/그라디언트/유틸
│   ├── runner_hud.dart           # HUD — 숫자롤링, 콤보미터, 보스HP, 보너스스테이지 배너, 업적버튼
│   ├── upgrade_shop.dart         # ★ 상점 — x1/x10/MAX 벌크 구매, 카드+아이콘+진행바
│   ├── soul_shop.dart            # ★ 스킬 트리 — 노드 기반 트리 레이아웃, 상세패널, 지역바
│   ├── ascension_screen.dart     # 초월 — 파티클 폭발+글로우 펄스+소울 카운트업+시네마틱 전환
│   ├── companion_screen.dart     # 동료 — 리스트+상세패널 분할뷰/레어도 뱃지/글로우 아바타
│   ├── offline_popup.dart        # 복귀 — 코인 카운트업 롤링+그라디언트 버튼+진입 애니메이션
│   ├── achievement_screen.dart   # ★ 업적 — 5카테고리 탭, 진행률, 보상 표시
│   ├── daily_bonus_popup.dart    # ★ 일일 보너스 — 7일 캘린더, 연속 보상, 카운트업
│   └── main_menu.dart            # 타이틀 — ShaderMask 그라디언트+멀티컬러 파티클+업적 진행률
└── utils/
    ├── constants.dart            # 월드크기(800x600), 물리(중력1100, 점프-520, 속도180)
    └── pixel_art.dart            # ★ 픽셀아트 유틸 — 문자맵 기반 스프라이트 렌더링
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
  * gauntletMultiplier      // 장갑 장비 효과 x1.3
```

---

## 주요 상수 (balance_config.dart + constants.dart)

| 상수 | 값 | 설명 |
|------|-----|------|
| 월드 크기 | 800x600 | FixedResolutionViewport |
| 바닥 Y | 500 | 지면 높이 |
| 기본 속도 | 180px/s | 플레이어 이동 속도 |
| 중력 | 1100 | 낙하 가속도 |
| 점프력 | -520 | 점프 초기 속도 |
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
| 7 | 픽셀아트 비주얼 전환 + 게임필 개선 | ✅ |
| 8 | UI/UX 전면 리빌드 + 게임필 시스템 + 장비효과 + 자동시스템 | ✅ |
| 9 | 업적 + 일일보너스 + 보물상자 + 보너스스테이지 + 벌크구매 + 스킬트리 | ✅ |

## Phase 9 상세 (Idle Slayer급 기능 확장)

### 새 파일
- `data/achievement_data.dart` — 업적 46종 정의 (5카테고리: 전투/경제/진행/수집/특수)
- `systems/achievement_manager.dart` — 마일스톤 추적 + 보상 지급 + 저장/로드
- `systems/daily_bonus_manager.dart` — 7일 주기 출석, 연속 배율(Day7=x4), 소울 보상
- `systems/bonus_stage_manager.dart` — 800m 간격 코인 러시 구간 (8초, 대량 코인 스폰)
- `components/treasure_box.dart` — 필드 보물상자 (3등급: 일반/레어/에픽, 코인 폭발)
- `ui/achievement_screen.dart` — 5카테고리 탭, 진행률 바, 보상 표시
- `ui/daily_bonus_popup.dart` — 7일 캘린더, 연속 출석 배율, 소울 보상

### 기존 파일 수정
- **upgrade_shop.dart**: x1/x10/MAX 벌크 구매 버튼 추가
- **soul_shop.dart**: 트리형 노드 기반 스킬 트리로 전면 리빌드 (4섹션: 코어/장비/자동화/지역)
- **runner_hud.dart**: 보너스 스테이지 배너, 업적 버튼 추가
- **main_menu.dart**: 업적 진행률 표시, 멀티컬러 파티클 배경
- **runner_game.dart**: 업적/일일보너스/보너스스테이지 매니저 연동
- **save_manager.dart**: 업적/일일보너스 JSON 저장/로드
- **level_generator.dart**: 보물상자 스폰 (5% 확률, 3등급 가중치)
- **enemy.dart / boss.dart**: 업적 추적 호출 추가

## Phase 8 상세 (UI/UX/시스템 리빌드)

### 새 파일
- `ui/game_theme.dart` — 통합 디자인 시스템 (색상 팔레트, 타이포그래피, 버튼, 패널, 유틸)
- `systems/game_feel.dart` — 스크린 쉐이크, 히트스탑, 슬로모션, 줌 펀치, 자동 업그레이드

### UI 리빌드 (7개 전면 교체)
- **MainMenu**: ShaderMask 그라디언트 타이틀, 파티클 배경, 펄스 글로우 버튼, 진입 애니메이션
- **RunnerHud**: 부드러운 숫자 롤링, 콤보 등급(NICE/GREAT/EPIC/INSANE), 타이머 바, 글래스모피즘
- **UpgradeShop**: 카드 레이아웃, 업그레이드별 아이콘+색상, 진행 바, 슬라이드업 진입 애니
- **SoulShop**: 세그먼트 탭, 지역 색상 미리보기 카드, 아이콘 매핑, 퍼플 그라디언트 버튼
- **CompanionScreen**: 리스트+상세패널 분할 뷰, 레어도 뱃지, 글로우 아바타, 장착 인디케이터
- **AscensionScreen**: 초월 파티클 폭발, 글로우 펄스, 소울 카운트업, 시네마틱 전환
- **OfflinePopup**: 코인 카운트업 롤링, 그라디언트 버튼, 스케일+페이드 진입 애니메이션

### 게임필 시스템 (GameFeelSystem)
- **스크린 쉐이크**: 적 처치(약), 보스 피격(중), 보스 처치(강), 장애물(강), 초월(극강)
- **히트스탑**: 황금 적 처치 60ms, 보스 피격 30ms, 보스 처치 150ms 프레임 프리즈
- **슬로모션**: 보스 처치 0.3x 0.8초, 초월 0.2x 1.5초
- **줌 펀치**: 보스 처치/콤보 마일스톤(10단위)에서 미세 줌인+탄성 복귀
- **콤보 마일스톤 피드백**: 10콤보 단위마다 쉐이크+줌펀치

### 자동 시스템 (구현 완료)
- **자동 업그레이드**: 소울 해금 시 2초마다 구매 가능한 업그레이드 자동 구매 (우선순위 기반)
- **자동 공중 처치**: 소울 해금 시 방치 모드에서 1초마다 가장 가까운 공중 적 자동 처치
- **장갑 효과**: 장갑 해금 시 모든 코인 획득에 x1.3 배율 적용
- **망토 효과**: 망토 해금 시 이동속도 +20% 보너스
- **보스 소울 보상**: 보스 처치 시 지역별 소울 드랍 (초원0, 숲0.5, 사막1, 설산2, 화산5)

### 디자인 시스템 (GameTheme)
- 색상: bgDeep→bgDark→bgPanel→bgCard 4단계 + accent 6색 + rarity 4색
- 타이포: titleLarge/Medium/Small, bodyLarge/Small, labelBold, numberLarge
- 위젯: gameButton(), infoChip(), progressBar(), sectionHeader(), closeButton(), currencyDisplay()
- 장식: panelDecoration(), cardDecoration(), glassDecoration()
- 그라디언트: Primary/Gold/Purple/Green/Red/Dark 6종

## 미구현 (TODO)

- **사운드**: flame_audio 의존성은 있으나 사용 안 함
- **실제 광고**: google_mobile_ads SDK 미연동 (스텁만)
- **온보딩**: 말풍선 튜토리얼 없음
- **업적 보상 수령**: 업적 달성 시 보상 자동 지급 미구현 (추적만 됨)
- **미니게임**: Idle Slayer의 Chest Hunt / Ascending Heights 같은 미니게임 미구현

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

### Renderer 패턴 (픽셀아트)
```dart
class EnemyRenderer {
  static void render(Canvas canvas, Size size, EnemyData data, {
    required double animTimer, required bool isHit, required bool isGolden,
  }) { /* PixelArt.drawCentered() 기반 스프라이트 렌더링 */ }
}
```
- 모든 렌더러는 **static 메서드**만. 인스턴스 없음.
- 스프라이트는 **문자열 배열 + 색상 팔레트 맵** 방식으로 정의.
- `PixelArt.drawCentered()` 호출로 렌더링.
- 새 스프라이트 추가 시 문자열 배열 + 팔레트만 정의하면 됨.

### PixelArt 유틸리티 패턴
```dart
// 스프라이트 정의 (문자 = 팔레트 키, '.' = 투명)
static const _sprite = [
  '..OOO..',
  '.OOOOO.',
  '.OOEOO.',
  '.OOOOO.',
  '..OOO..',
];
static const _palette = {
  'O': Color(0xFF4CAF50),
  'E': Color(0xFF1A1A1A),
};

// 렌더링
PixelArt.drawCentered(canvas, _sprite, _palette, size, pixelSize: px);
```

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

### UI 테마 패턴 (GameTheme)
```dart
// 모든 UI에서 GameTheme 정적 멤버 사용
GameTheme.gameButton(label: '시작', onTap: () {}, gradient: GameTheme.gradientPrimary);
GameTheme.progressBar(value: 0.7, fillColor: GameTheme.accentGold);
GameTheme.currencyDisplay(value: '1.2K', isSoul: true);
GameTheme.formatNumber(12345.0); // '12.3K'
```
- 모든 색상, 스타일, 위젯은 `GameTheme` 정적 멤버로 통일
- 새 UI 추가 시 `game_theme.dart`의 패턴을 따를 것

### 게임필 패턴 (GameFeelSystem)
```dart
// runner_game.dart에서 gameFeel 인스턴스로 접근
game.gameFeel.onEnemyKill(isGolden: true);
game.gameFeel.onBossKill();
game.gameFeel.shake(intensity: 5, duration: 0.2);
```
- `GameFeelSystem`은 Flame `Component`로 world에 추가
- 히트스탑 중에는 `update(dt)`가 스킵됨
- 슬로모션은 `dt * gameFeel.timeScale`로 적용

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
