# 동물 성벽 지키기 — 반방치 로그라이트 타워디펜스

## 한 줄 요약
귀여운 동물 유닛을 배치·머지하여 성벽을 지키는 반방치 로그라이트 타워디펜스. 뱀서류의 자동전투 쾌감 + 머지 전략 + 영구 성장.

## Tech Stack
- **Framework**: Flutter 3.27.4 / Dart 3.6.2
- **Game Engine**: Flame 1.14.0 (flame_audio 2.1.0)
- **저장**: shared_preferences 2.2.0
- **Target**: Android (portrait, immersive mode)
- **CI/CD**: GitHub Actions → APK 빌드 (`.github/workflows/build-apk.yml`)
- **로컬 빌드**: flutter SDK 미설치 — CI로만 빌드 검증

## 빌드
```bash
flutter pub get
flutter build apk --release
```

---

## 프로젝트 구조 (28개 파일)

```
lib/
├── main.dart                          # 앱 진입점, 9개 오버레이 등록
├── game/
│   └── defense_game.dart              # FlameGame 메인 — 게임 상태, 스폰, 머지, 오버레이, 라이프사이클
├── components/                        # 게임 엔티티 (Flame PositionComponent)
│   ├── wall.dart                      # 성벽 — HP, 데미지, 힐, 레벨업
│   ├── unit_slot.dart                 # 유닛 슬롯 위치 컴포넌트 (성벽 주변 원형 배치)
│   ├── defense_unit.dart              # 유닛 — 자동 공격, 타입별 스탯, 근거리/원거리, 크리/스플래시
│   ├── defense_enemy.dart             # 적 — 이동/공격, 특수행동(힐러/폭탄/방패/보스)
│   ├── defense_particle.dart          # 파티클 FX — 적처치/보스폭발/머지 이펙트
│   ├── projectile.dart                # 투사체 — 관통/스플래시 지원
│   └── damage_number.dart             # 플로팅 데미지/골드 숫자 팝업
├── data/
│   └── unit_data.dart                 # 유닛 6종 정의 (UnitType enum, UnitData, UnitDatabase)
├── renderers/                         # 렌더링 분리 — 픽셀아트 스프라이트
│   ├── wall_renderer.dart             # 성벽 픽셀아트
│   ├── unit_renderer.dart             # 유닛 6종 픽셀아트
│   └── defense_enemy_renderer.dart    # 적 픽셀아트
├── systems/                           # 게임 시스템 (매니저 패턴)
│   ├── wave_manager.dart              # 웨이브 관리 — 적 스폰, 보스, 난이도 스케일링
│   ├── merge_manager.dart             # 머지 로직 — 3동일 → 레벨+1, 최대 Lv5
│   ├── relic_manager.dart             # 유물 — 최대 3개/런, 15종, 패시브 효과
│   ├── defense_game_feel.dart         # 게임필 — 스크린쉐이크/히트스탑/슬로모션/줌펀치/자동시스템
│   ├── defense_upgrade_manager.dart   # 영구 업그레이드 — 11종 (스타로 구매)
│   └── defense_save_manager.dart      # SharedPreferences 저장/로드
├── ui/                                # Flutter 위젯 오버레이
│   ├── game_theme.dart                # 통합 디자인 시스템 — 색상/타이포/버튼/패널/유틸
│   ├── defense_main_menu.dart         # 메인 메뉴 — 성 애니메이션, 시작/상점 버튼
│   ├── defense_hud.dart               # HUD — 유닛슬롯/골드/HP/웨이브바/유물바/판매/리롤
│   ├── defense_pause_screen.dart      # 일시정지 — 스탯 요약, 재개/설정/종료
│   ├── wave_reward_screen.dart        # 웨이브 보상 — 3택 카드 선택
│   ├── star_shop_screen.dart          # 스타 상점 — 영구 업그레이드 구매
│   ├── run_result_screen.dart         # 런 결과 — 웨이브/킬/골드/스타 요약
│   └── relic_selection_screen.dart    # 유물 선택 — 보스 처치 후 2~3택
└── utils/
    └── pixel_art.dart                 # 픽셀아트 유틸 — 문자맵 기반 스프라이트 렌더링
```

---

## 핵심 게임 루프

```
런 시작 → 웨이브 방어 → 골드 획득 → 유닛 구매/머지 → 더 강한 웨이브
    ↓ (성벽 파괴 = 런 종료)
  스타 획득 → 영구 업그레이드 → 다음 런 더 강하게
    ↓
  반복 (∞)
```

---

## 주요 상수

| 상수 | 값 | 설명 |
|------|-----|------|
| 뷰포트 | 400x700 | FixedResolution, 세로모드 |
| 기본 유닛 비용 | 10골드 | 1.15^n 스케일링 |
| 머지 조건 | 동일 타입+레벨 3개 | → 레벨+1 (최대 Lv5) |
| 유물 최대 | 3개/런 | 보스 처치 시 선택 |
| 영구 업글 | 11종 | 스타로 구매 |
| 판매 환불 | 50% | 현재 유닛 비용 기준 |
| 리롤 비용 | 20골드 | 전체 유닛 교체 |
| 보스 등장 | 10웨이브마다 | HP/골드 스케일링 |

---

## 유닛 6종 (unit_data.dart)

| ID | 이름 | 타입 | 특수 능력 |
|-----|------|------|----------|
| cat_archer 🐱 | 고양이 궁수 | 원거리 | 기본 원거리 딜러 |
| dog_warrior 🐶 | 강아지 전사 | 근거리 | 높은 공격력, 범위 공격 |
| rabbit_mage 🐰 | 토끼 마법사 | 원거리+스플래시 | 광역 데미지 |
| bear_tanker 🐻 | 곰 탱커 | 근거리 | 고체력, 느린 공속 |
| fox_assassin 🦊 | 여우 암살자 | 근거리+관통 | 20% 크리티컬 (2x) |
| bird_scout 🐦 | 새 정찰병 | 원거리+대공 | 비행 적 공격 가능 |

---

## 적 특수 타입

| 타입 | 행동 |
|------|------|
| slime | 기본 — 성벽으로 이동, 주기적 공격 |
| bat | 비행 — 사인파 이동, 대공 유닛만 공격 가능 |
| goblin | 빠른 이동, 약한 공격 |
| orc | 느린 이동, 강한 공격 |
| shielded | 전방 데미지 50% 감소 |
| bomber | 성벽 도달 시 3x 데미지 폭발 후 즉사 |
| healer | 3초마다 주변 50px 아군 HP 10% 회복 |
| boss | 1.5x 크기, 빨간 글로우, 유물 드랍 |

---

## 게임필 시스템 (DefenseGameFeel)

| 이벤트 | 쉐이크 | 히트스탑 | 슬로모션 | 줌펀치 |
|--------|--------|---------|---------|--------|
| 적 처치 | 2px, 0.1s | - | - | - |
| 보스 피격 | 4px, 0.12s | 40ms | - | - |
| 보스 처치 | 15px, 0.6s | 250ms | 0.2x 1.0s | 1.08x |
| 성벽 피격 | 6px, 0.2s | - | - | - |
| 머지 | 2+lv px | - | - | 1.02+lv% |
| 진화 | 10px, 0.4s | 150ms | 0.3x 0.8s | 1.06x |

---

## 유물 15종 (relic_manager.dart)

**진화 유물 (5종)**: evolve_knight/archer/mage/healer/assassin
**패시브 유물 (10종)**: ATK+15%, 공속+15%, 골드+30%, 성벽방어+20%, 크리+10%, 스플래시, 슬로우오라, 흡혈2%, 머지2개, 스타+20%

---

## 코드 패턴 & 컨벤션

### Component 패턴
```dart
class DefenseEnemy extends PositionComponent
    with HasGameReference<DefenseGame>, CollisionCallbacks {
  // .game 으로 DefenseGame 접근
  // CollisionCallbacks + add(RectangleHitbox()) 로 충돌
}
```

### Renderer 패턴 (픽셀아트)
```dart
class UnitRenderer {
  static void render(Canvas canvas, Size size, {
    required String unitTypeId, required int level, ...
  }) { /* PixelArt.drawCentered() 기반 */ }
}
```
- 모든 렌더러는 **static 메서드**만. 인스턴스 없음.
- 스프라이트는 **문자열 배열 + 색상 팔레트 맵** 방식.

### PixelArt 유틸리티
```dart
static const _sprite = ['..OOO..', '.OOOOO.', '.OOEOO.'];
static const _palette = { 'O': Color(0xFF4CAF50), 'E': Color(0xFF1A1A1A) };
PixelArt.drawCentered(canvas, _sprite, _palette, size, pixelSize: px);
```

### 텍스트 렌더링 주의
- Flame `render(Canvas)` 안에서는 **`dart:ui`의 TextStyle**만 사용 가능
- `ParagraphBuilder` + `ParagraphStyle` + `dart:ui TextStyle` 조합 (damage_number.dart 참고)

### UI 테마 패턴 (GameTheme)
```dart
GameTheme.pixelButton(label: '시작', onTap: () {});
GameTheme.pixelProgressBar(value: 0.7, fillColor: GameTheme.accentGold);
GameTheme.pixelCurrency(value: '1.2K', icon: '⭐');
GameTheme.formatInt(12345); // '12.3K'
```

### 게임필 패턴
```dart
game.gameFeel.onEnemyKill();
game.gameFeel.onBossKill();
game.gameFeel.shake(intensity: 5, duration: 0.2);
```
- `DefenseGameFeel`은 Flame `Component`로 world에 추가
- 히트스탑 중에는 `update(dt)`가 스킵됨
- 슬로모션은 `dt * gameFeel.timeScale`로 적용

---

## 새 컨텐츠 추가 가이드

### 새 유닛 추가
1. `data/unit_data.dart` — `UnitType` enum + `UnitData` 추가
2. `renderers/unit_renderer.dart` — 렌더 case 추가
3. `game/defense_game.dart` — `_unitIcons`, `_unitTypeIds` 에 추가

### 새 적 추가
1. `game/defense_game.dart` — `spawnEnemy()` switch case 추가
2. `renderers/defense_enemy_renderer.dart` — 렌더 case 추가
3. `systems/wave_manager.dart` — 웨이브 스폰 로직에 포함

### 새 유물 추가
1. `systems/relic_manager.dart` — `allRelicIds` + 효과 getter 추가
2. `ui/relic_selection_screen.dart` — `_relicDatabase` 에 UI 정보 추가

### 새 영구 업그레이드 추가
1. `systems/defense_upgrade_manager.dart` — `DefenseUpgradeId` enum + 효과 getter
2. `ui/star_shop_screen.dart` — 상점 UI에 자동 표시

---

## 설계 문서
- `docs/GDD_CASTLE_DEFENSE.md` — 전체 게임 설계 (시스템, 밸런스, 경제, 수익화)
