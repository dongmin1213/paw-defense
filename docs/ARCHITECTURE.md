# Code Architecture

## 기술 스택
- Flutter 3.27.4 / Dart 3.6.2
- Flame 1.14.0 (flame_audio 2.1.0)
- shared_preferences 2.2.0
- Android landscape, 800x600 FixedResolutionViewport

---

## 디렉토리 구조

```
lib/                              # ~11000줄, 49파일
├── main.dart                     # 앱 진입점 — GameWidget + 9개 오버레이 등록
├── game/
│   └── runner_game.dart          # FlameGame 메인 (466줄)
│                                 #   게임 상태, 카메라, 입력(TapCallbacks)
│                                 #   코인/콤보, 방치/적극 모드, 특수 이벤트
│                                 #   모든 매니저 보유 (upgrade/ascension/companion/weather/ad/save)
├── components/                   # Flame PositionComponent 엔티티
│   ├── runner_player.dart        # 비숏 — 자동 달리기, 중력/점프, 자동 공격, 충돌 핸들링
│   ├── ground_segment.dart       # 400px 바닥 블록, 무한 재배치, 픽셀아트 돌담+풀잎 폴백
│   ├── enemy.dart                # 몬스터 — 바닥/공중, HP, 피격 플래시, 코인 스폰, 황금
│   ├── coin.dart                 # 코인 — 호버 애니, 수집 "+N" 팝업 (ParagraphBuilder)
│   ├── obstacle.dart             # 바위 — 적극 플레이 시만, 충돌→2초 속도 50%
│   ├── parallax_layer.dart       # 3레이어 픽셀아트 패럴랙스 (구름/산/풀잎/나무)
│   ├── companion_pickup.dart     # 필드 동료 — 희귀도 글로우, 수집 팝업
│   ├── boss.dart                 # 보스 — HP바/타이머바, 자동+탭 공격, 10초 제한
│   ├── treasure_box.dart         # 보물상자 — 3등급(일반/레어/에픽), 코인 폭발, 픽셀아트
│   ├── weather_effect.dart       # 날씨 파티클 + 시간대 오버레이 (priority 50)
│   └── particle_effect.dart      # FX 사각 픽셀 파티클 — 5종 이펙트 (priority 60)
├── data/                         # ★ 데이터 정의 — 컨텐츠 추가 = 여기만 수정
│   ├── balance_config.dart       # ★ 밸런스 수치 전부 한 곳
│   ├── enemy_data.dart           # 적 20종 (EnemyData + EnemyDatabase)
│   ├── region_data.dart          # 5개 지역 (RegionData)
│   ├── upgrade_data.dart         # 일반 업그레이드 7종 (UpgradeData)
│   ├── soul_upgrade_data.dart    # 영구 업그레이드 13종 (SoulUpgradeData)
│   ├── companion_data.dart       # 동료 10종 (CompanionData)
│   └── achievement_data.dart     # 업적 46종 (AchievementData + AchievementDatabase)
├── renderers/                    # ★ 픽셀아트 렌더링 — 스프라이트 교체 = 여기만 수정
│   ├── player_renderer.dart      # 비숏 픽셀아트 5프레임 (PixelArt 기반)
│   ├── enemy_renderer.dart       # 적 20종 픽셀아트 + 황금/피격 팔레트 변환
│   ├── coin_renderer.dart        # 코인 12x12 픽셀아트 2프레임
│   ├── companion_renderer.dart   # 동료 10종 픽셀아트 2프레임
│   └── boss_renderer.dart        # 보스 5종 픽셀아트 2프레임
├── systems/                      # 게임 시스템 매니저
│   ├── level_generator.dart      # 절차적 배치 — 적/코인/장애물/동료/보스
│   ├── upgrade_manager.dart      # 일반 업글 — 레벨/비용/배율 getter
│   ├── ascension_manager.dart    # 초월 — 소울/영구업글/지역해금
│   ├── companion_manager.dart    # 동료 — 수집/장착/레벨업/버프
│   ├── weather_manager.dart      # 날씨(5종)/시간대(4종) — 배율 getter
│   ├── game_feel.dart            # ★ 게임필 시스템 — 쉐이크/히트스탑/슬로모션/줌펀치/자동업글
│   ├── achievement_manager.dart  # 업적 추적 — 15+ 카운터, checkAll(), 이벤트 메서드
│   ├── daily_bonus_manager.dart  # 일일 보너스 — 7일 주기, 스트릭 배율
│   ├── bonus_stage_manager.dart  # 보너스 스테이지 — ~800m마다, 8초 코인 러시
│   ├── ad_manager.dart           # 광고 스텁 (SDK 미연동)
│   ├── offline_reward.dart       # CpS 기반 오프라인 보상 계산
│   └── save_manager.dart         # SharedPreferences 저장/로드
└── ui/                           # Flutter 위젯 오버레이 9개
    ├── game_theme.dart           # ★ 통합 디자인 시스템 — 색상/타이포/버튼/패널/그라디언트
    ├── runner_hud.dart           # HUD — 숫자롤링/콤보등급/보스HP/보너스배너/업적버튼
    ├── upgrade_shop.dart         # 일반 업그레이드 — 카드형+x1/x10/MAX 벌크구매
    ├── soul_shop.dart            # 영구 업그레이드 — 트리형 스킬트리 (4섹션 노드 그래프)
    ├── ascension_screen.dart     # 초월 — 파티클 폭발+글로우 펄스+소울 카운트업
    ├── companion_screen.dart     # 동료 — 리스트+상세패널 분할/레어도 뱃지/글로우
    ├── offline_popup.dart        # 오프라인 복귀 — 코인 카운트업 롤링
    ├── achievement_screen.dart   # 업적 — 5카테고리 탭+완료율+카드형 목록
    ├── daily_bonus_popup.dart    # 일일 보너스 — 7일 캘린더+보상+수령
    └── main_menu.dart            # 타이틀 — ShaderMask 그라디언트+파티클 배경
└── utils/
    ├── constants.dart            # 월드(800x600), 물리(중력1100, 점프-520, 속도180)
    ├── pixel_art.dart            # ★ 픽셀아트 유틸 — 문자맵 스프라이트 블록 렌더링
    └── sprite_loader.dart        # 이미지 로드 (폴백 → 픽셀아트 렌더러 사용)
```

---

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

### 2. 픽셀아트 렌더러 분리
게임 오브젝트의 렌더링을 별도 static 클래스로 분리.
`PixelArt` 유틸을 사용한 **문자맵 기반 픽셀아트 스프라이트** 렌더링.

```dart
// 스프라이트는 문자열 배열로 정의 ('.' = 투명)
static const _sprite = [
  '..OOO..',
  '.OOEOO.',
  '.OOOOO.',
];
static const _palette = {
  'O': Color(0xFF4CAF50),
  'E': Color(0xFF1A1A1A),
};

// 렌더링: PixelArt.drawCentered()
class EnemyRenderer {
  static void render(Canvas canvas, Size size, EnemyData data, {...}) {
    PixelArt.drawCentered(canvas, sprite, palette, size, pixelSize: px);
  }
}
```
- 스프라이트 추가 = 문자열 배열 + 팔레트 맵만 정의
- 황금 적/피격 시 팔레트를 자동 변환하는 헬퍼 내장

### 3. 밸런스 중앙 관리
`balance_config.dart`에 모든 게임 수치 집중. 밸런스 조정 = 이 파일만 수정.

```dart
class BalanceConfig {
  static const double upgradeCostMultiplier = 1.15;
  static const double airEnemyCoinMultiplier = 3.0;
  static const double comboMultiplierPerStack = 0.05;
  static const double offlineEfficiency = 0.3;
  static double ascensionThreshold(int count) => 10000 * pow(3, count);
}
```

---

## 클래스 관계도

```
RunnerGame (FlameGame with HasCollisionDetection, TapCallbacks)
│
├── [World]
│   ├── RunnerPlayer (PositionComponent + CollisionCallbacks)
│   │   ├── 자동 이동 (position.x += speed * dt)
│   │   ├── 중력/점프/더블점프 (velocity.y, groundY)
│   │   └── 충돌: Enemy → onHit(), Coin → collect(), Obstacle → applySlowdown()
│   │         CompanionPickup → game.companionManager.addCompanion()
│   │
│   ├── GroundSegment[] (PositionComponent)
│   │   └── 카메라 뒤 → 앞으로 재배치 (무한 스크롤)
│   │
│   ├── ParallaxLayer[3] (PositionComponent) — 배경 패럴랙스 (priority -10~-8)
│   │
│   ├── Enemy[] (PositionComponent + CollisionCallbacks)
│   │   ├── EnemyData 참조 (data/enemy_data.dart에서)
│   │   ├── HP, hitFlash, isGolden
│   │   ├── 바닥적: 플레이어 접촉 → 자동 피격
│   │   └── 공중적: 점프 접촉 → 피격 (x3 코인)
│   │
│   ├── Coin[] (PositionComponent + CollisionCallbacks)
│   │   └── 수집 → game.addCoins() + "+N" 팝업 + 파티클
│   │
│   ├── Obstacle[] (PositionComponent + CollisionCallbacks)
│   │   └── 충돌 → player.applySlowdown() (2초, 속도 50%)
│   │
│   ├── Boss (PositionComponent + CollisionCallbacks) — 500m마다
│   │   ├── HP바 + 타이머바 (10초 제한)
│   │   ├── 자동공격 (0.5초 간격 / attackMultiplier)
│   │   ├── 탭공격 (x2 DPS)
│   │   └── 처치 → 코인 8~12개 폭발 + 콤보+5 + 파티클
│   │
│   ├── CompanionPickup[] (PositionComponent + CollisionCallbacks)
│   │   └── 수집 → companionManager.addCompanion() + 팝업
│   │
│   ├── TreasureBox[] (PositionComponent + CollisionCallbacks)
│   │   └── 3등급(일반/레어/에픽), 충돌 → 코인 폭발 + 파티클
│   │
│   ├── WeatherEffect (PositionComponent) — 날씨 파티클 + 시간대 오버레이 (priority 50)
│   ├── ParticleEffect (PositionComponent) — FX 파티클 (priority 60)
│   ├── GameFeelSystem (Component) — 스크린쉐이크/히트스탑/슬로모션/줌펀치
│   ├── BonusStageManager (Component) — ~800m마다, 8초 코인 러시
│   └── LevelGenerator (Component) — 절차적 레벨 생성
│
├── [매니저 (non-component)]
│   ├── UpgradeManager — 일반 업글 7종, 코인 비용, 배율 getter
│   ├── AscensionManager — 초월 조건/실행, 소울, 영구 업글 13종
│   ├── CompanionManager — 동료 수집/장착(1~4슬롯)/레벨업/버프 계산
│   ├── WeatherManager — 시간대(4종) + 날씨(5종, 3~5분 주기), 배율
│   ├── AchievementManager — 업적 46종, 15+ 카운터 추적
│   ├── DailyBonusManager — 7일 보상 주기, 스트릭 배율
│   ├── AdManager — 광고 스텁 (실제 SDK 없음)
│   └── SaveManager — SharedPreferences 저장/로드
│
└── [Flutter 오버레이 (GameWidget overlayBuilderMap)]
    ├── MainMenu — 타이틀 + ShaderMask + 파티클 + 통계
    ├── RunnerHud — HUD (숫자롤링/콤보등급/보스/보너스배너/업적버튼)
    ├── UpgradeShop — 일반 업글 상점 (x1/x10/MAX 벌크구매)
    ├── SoulShop — 영구 업글 트리형 스킬트리 (4섹션)
    ├── AscensionScreen — 초월 연출 (파티클/글로우/카운트업)
    ├── CompanionScreen — 동료 관리/도감 (분할뷰)
    ├── OfflinePopup — 오프라인 복귀 팝업
    ├── AchievementScreen — 업적 (5카테고리 탭)
    └── DailyBonusPopup — 일일 보너스 (7일 캘린더)
```

---

## 카메라 시스템

```dart
// runner_game.dart onLoad()
camera.viewport = FixedResolutionViewport(resolution: Vector2(800, 600));
camera.viewfinder.anchor = Anchor.topLeft;

// update()
camera.viewfinder.position = Vector2(player.position.x - 150, 0);
```

---

## 무한 레벨 생성 (level_generator.dart)

```
generationCursor < cameraX + 1200 이면:
  → 300px 세그먼트 생성
  → 바닥 세그먼트 + 적 1~3마리 + 코인 패턴 + 장애물(적극 모드만)
  → 보스 체크 (500m마다)
  → 동료 스폰 체크 (평균 2분, 적극 시만)
  → generationCursor += 300

cameraX - 200보다 왼쪽 컴포넌트 → removeFromParent()
```

### 모드별 생성 차이
- **적극 모드** (5초 내 탭 입력): 공중 적 + 장애물 + 동료 스폰
- **방치 모드** (5초 무입력): 바닥 적만 + 장애물/동료 미생성

### 특수 이벤트 영향
- **골든 아워**: 적 100% 황금 (isGolden = true)
- **동료 집회**: 동료 스폰 타이머 5배 빠르게
- **폭풍 날씨**: 장애물 x2

---

## 입력 처리

```dart
class RunnerGame extends FlameGame with HasCollisionDetection, TapCallbacks {
  void onTapDown(TapDownEvent event) {
    _lastTapTime = _elapsed;  // 적극 모드 감지용

    if (currentBoss != null && !currentBoss!.isDead) {
      currentBoss!.onTapAttack();  // 보스 추가 공격
    }

    player.jump();
  }

  bool get isActiveMode => (_elapsed - _lastTapTime) < 5.0;
}
```

---

## 코인 경제 (runner_game.dart addCoins)

```dart
void addCoins(double amount) {
  final total = amount
    * comboMultiplier          // 1 + combo * 0.05
    * regionMultiplier         // 지역별 (x1 ~ x100)
    * activeBonus              // 적극 플레이 x1.5
    * upgradeMultiplier        // 코인 업글 (lv25 = x3.0)
    * soulCoinMultiplier       // 영구 코인배율 (+25%/lv)
    * companionMultiplier      // 동료 버프
    * weatherCoinMultiplier    // 날씨 (비+30%, 폭풍x2)
    * timeCoinMultiplier       // 시간대 (저녁+20%)
    * goldenHourMultiplier     // 골든아워 이벤트 x5
    * rainbowMultiplier;       // 무지개 날씨 x2
  coins += total;
}
```

### 오프라인 보상 (offline_reward.dart)
```dart
cps = baseEnemies/s(2.0) × baseCoin(1.0) × regionMult × coinMult
    × soulMult × companionMult × offlineEfficiency(0.3) × (1 + offlineBonus);
totalCoins = cps × clamp(elapsed, 0, 86400);
```

---

## 저장 시스템 (save_manager.dart)

### SharedPreferences 키
```
coins, distance, highScore, totalCoinsEarned
ascensionCount, souls, currentRegion, lastOnlineTime
upgrade_{speedLv/coinLv/attackLv/jumpLv/doubleJump/magnetLv/comboRetainLv}
soul_upgrade_{id}_level  (13종)
companions (JSON string: {id: {owned, level, equipped}})
achievements_data (JSON string: {unlocked: [...], counters: {...}})
daily_bonus_data (JSON string: {streak, lastClaimDate, ...})
```

### 저장 타이밍
- 업그레이드 구매 시
- 30초 자동 저장
- `AppLifecycleState.paused` 시
- 초월 실행 시

### 초월 시 리셋 범위
- **리셋**: coins, distance, 일반 업그레이드 레벨
- **유지**: souls, 영구 업그레이드, 동료, ascensionCount

---

## 오버레이 시스템

```dart
// main.dart — 9개 오버레이 등록
GameWidget(
  overlayBuilderMap: {
    'MainMenu':           (ctx, g) => MainMenu(game: g),
    'RunnerHud':          (ctx, g) => RunnerHud(game: g),
    'UpgradeShop':        (ctx, g) => UpgradeShop(game: g),
    'SoulShop':           (ctx, g) => SoulShop(game: g),
    'AscensionScreen':    (ctx, g) => AscensionScreen(game: g),
    'CompanionScreen':    (ctx, g) => CompanionScreen(game: g),
    'OfflinePopup':       (ctx, g) => OfflinePopup(game: g, reward: g.pendingOfflineReward!),
    'AchievementScreen':  (ctx, g) => AchievementScreen(game: g),
    'DailyBonus':         (ctx, g) => DailyBonusPopup(game: g),
  },
  initialActiveOverlays: ['MainMenu'],
);
```

### 오버레이 전환 흐름
```
MainMenu → [시작] → RunnerHud (게임 시작)
  RunnerHud → [상점] → UpgradeShop (pauseEngine)
  RunnerHud → [소울] → SoulShop
  RunnerHud → [초월] → AscensionScreen → MainMenu
  RunnerHud → [동료] → CompanionScreen
  RunnerHud → [업적] → AchievementScreen
  시작 시 오프라인 보상 → OfflinePopup → RunnerHud
  시작 시 일일 보너스 → DailyBonus → RunnerHud
```

---

## 기술적 결정 & 주의사항

### dart:ui vs flutter 혼용 금지
- Flame Component의 `render(Canvas)` 안에서는 `dart:ui` API만 사용
- flutter `TextStyle`과 dart:ui `TextStyle`은 **다른 클래스**
- 텍스트 렌더링: `ParagraphBuilder` + `ParagraphStyle` + dart:ui `TextStyle` 조합 (coin.dart 참고)

### Color API
- `Color.withValues(alpha: 0.5)` 사용 (withOpacity deprecated 대체)

### Flame 버전 API
- `HasGameRef` → `HasGameReference<RunnerGame>` (`.gameRef` → `.game`)
- `FixedResolutionViewport`는 `package:flame/camera.dart`에서 import
- `camera.viewfinder.position`으로 카메라 위치 제어 (anchor = topLeft)
- `CollisionCallbacks` mixin + `add(RectangleHitbox())` 패턴

### 렌더링 priority 순서
```
-10 ~ -8 : ParallaxLayer (배경)
     0   : GroundSegment, Enemy, Coin, Obstacle, CompanionPickup
     5   : Boss
    10   : RunnerPlayer
    50   : WeatherEffect
    60   : ParticleEffect
```

### 알려진 기술 부채
- HUD 100ms Timer 폴링 → 상태 관리 패턴으로 개선 필요
- 광고는 스텁 — 실제 google_mobile_ads SDK 연동 필요
- 장비 효과 일부 미구현 — 활(자동 공중 처치)/망토(대시) — 장갑(x1.3 코인)은 구현 완료
- 사운드 미구현 (flame_audio 의존성만 있음)
- 업적 보상 자동 수령 미구현 (추적만)
- 빌드 검증은 CI(GitHub Actions)로만 가능 (로컬 flutter 없음)

---

## 새 컨텐츠 추가 가이드

### 새 적 추가
1. `data/enemy_data.dart`에 `EnemyData` 추가 (id, name, type, hp, coinDrop, size, color, spawnWeight)
2. `renderers/enemy_renderer.dart`에 렌더링 case 추가 (id 매칭)
3. `data/region_data.dart`에서 해당 지역 몬스터 풀에 포함

### 새 지역 추가
1. `data/region_data.dart`에 `RegionData` 추가 (배경색, 배율, 해금 비용)
2. `data/enemy_data.dart`에 해당 지역 적 추가 (바닥2 + 공중2)
3. `data/soul_upgrade_data.dart`에 지역 해금 소울 업글 추가
4. `renderers/boss_renderer.dart`에 보스 렌더 추가
5. `components/boss.dart` — _regionHpMultiplier(), coinReward, soulReward에 case 추가

### 새 업그레이드 추가
1. `data/upgrade_data.dart`에 `UpgradeId` enum 값 + `UpgradeData` 추가
2. `systems/upgrade_manager.dart`에 getter/효과 로직 추가
3. UI에 자동 표시 (데이터 기반 리스트)

### 새 동료 추가
1. `data/companion_data.dart`에 `CompanionData` 추가 (id, name, rarity, spawnWeight, buffType, baseValue)
2. `renderers/companion_renderer.dart`에 렌더 case 추가
3. `systems/companion_manager.dart` — 버프 타입이 기존과 다르면 버프 로직 추가

### 새 영구 업그레이드 추가
1. `data/soul_upgrade_data.dart`에 `SoulUpgradeData` 추가
2. `systems/ascension_manager.dart`에 효과 getter 추가
3. `save_manager.dart`에 저장/로드 키 추가
