# 코드 아키텍처 (Architecture)

> 이 문서만 읽으면 코드 구조를 파악하고 새 기능을 추가할 수 있습니다.

## Tech Stack

| 항목 | 버전/도구 |
|------|----------|
| Framework | Flutter 3.27.4 / Dart 3.6.2 |
| Game Engine | Flame 1.14.0 (flame_audio 2.1.0) |
| 저장 | shared_preferences 2.2.0 |
| 폰트 | PressStart2P, Silkscreen (assets/fonts/) |
| Target | Android (portrait 400x700, immersive mode) |
| 테스트 | `flutter test` (16개 파일, 274+ 케이스) |
| 빌드 | `flutter pub get && flutter build apk --release` |

## 프로젝트 구조

```
lib/
├── main.dart                          # 앱 진입점, 12개 오버레이 등록
├── game/defense_game.dart             # FlameGame 메인 (게임 루프)
├── components/                        # Flame 컴포넌트 (렌더+로직)
│   ├── wall.dart                      # 성벽 (HP, 피격, 업그레이드)
│   ├── unit_slot.dart                 # 유닛 배치 슬롯
│   ├── defense_unit.dart              # 유닛 (타겟팅, 공격, 궤도)
│   ├── defense_enemy.dart             # 적 (이동, 공격, DoT, 사망)
│   ├── projectile.dart                # 투사체 (트레일, 분열, 원소)
│   ├── defense_particle.dart          # 파티클 이펙트 (전체)
│   ├── damage_number.dart             # 데미지/골드 숫자 팝업
│   ├── field_drop.dart                # 필드 골드 드롭
│   ├── reactive_background.dart       # 강도 반응형 동적 배경
│   └── skill_effect_overlay.dart      # 스킬별 풀스크린 이펙트
├── data/                              # 데이터 정의 (수치 변경은 여기만)
│   ├── unit_data.dart                 # 유닛 8종 + 진화 8종
│   ├── hybrid_unit_data.dart          # 하이브리드 28종
│   ├── enemy_data.dart                # 적 16종
│   ├── relic_data.dart                # 유물 58개
│   └── balance_config.dart            # 모든 밸런스 수치 (180+ 상수)
├── renderers/                         # 픽셀아트 렌더러 (static only)
│   ├── wall_renderer.dart
│   ├── unit_renderer.dart
│   └── defense_enemy_renderer.dart
├── systems/                           # 게임 시스템
│   ├── wave_manager.dart              # 웨이브 생성/스폰
│   ├── wave_modifier.dart             # 웨이브 변형 10종
│   ├── merge_manager.dart             # 동종 머지 + 이종 크로스브리드
│   ├── relic_manager.dart             # 유물 효과/인벤토리
│   ├── combo_manager.dart             # 콤보 6단계
│   ├── skill_manager.dart             # 액티브 스킬 8종
│   ├── synergy_manager.dart           # 종족/다양성 시너지
│   ├── defense_game_feel.dart         # 히트스탑/슬로모/줌/플래시
│   ├── defense_upgrade_manager.dart   # 영구 업그레이드 16종
│   ├── defense_save_manager.dart      # 세이브/로드
│   ├── codex_manager.dart             # 도감
│   ├── daily_manager.dart             # 일일 챌린지/출석
│   ├── achievement_manager.dart       # 업적
│   └── sound_manager.dart             # BGM/SFX
├── ui/                                # Flutter 오버레이 (12개)
│   ├── game_theme.dart                # 통합 디자인 시스템
│   ├── defense_main_menu.dart
│   ├── defense_hud.dart
│   ├── defense_pause_screen.dart
│   ├── wave_reward_screen.dart
│   ├── star_shop_screen.dart
│   ├── run_result_screen.dart
│   ├── relic_selection_screen.dart
│   ├── achievement_screen.dart
│   ├── codex_screen.dart
│   ├── daily_screen.dart
│   ├── settings_screen.dart
│   └── tutorial_screen.dart
└── utils/pixel_art.dart               # 문자맵 스프라이트 유틸

test/                                  # 테스트 (16파일, 274+ 케이스)
├── data/                              # 데이터 검증
│   ├── balance_config_test.dart
│   ├── unit_data_test.dart
│   ├── enemy_data_test.dart
│   ├── hybrid_unit_data_test.dart
│   └── relic_data_test.dart
└── systems/                           # 시스템 로직 검증
    ├── merge_manager_test.dart
    ├── relic_manager_test.dart
    ├── synergy_manager_test.dart
    ├── upgrade_manager_test.dart
    ├── achievement_manager_test.dart
    ├── game_feel_test.dart
    ├── combo_manager_test.dart
    ├── skill_manager_test.dart
    ├── sound_manager_test.dart
    ├── codex_manager_test.dart
    └── wave_modifier_test.dart
```

## 핵심 패턴

### 1. 데이터/로직 분리
- **데이터**: `data/` 디렉토리 — 수치 변경은 여기만
- **로직**: `systems/` + `components/` — 데이터를 참조하여 동작
- **렌더링**: `renderers/` — static 메서드, `PixelArt.drawCentered()` 패턴

### 2. BalanceConfig 중앙화
모든 튜닝 가능한 수치는 `data/balance_config.dart`에 `static const`로 정의.
180+ 상수를 30+ 섹션으로 구분. 다른 파일에서는 `BalanceConfig.xxx` 형식으로 참조.

### 3. 텍스트 렌더링
- Flame `render()` 안에서는 **dart:ui TextStyle만** 사용 (Flutter TextStyle 아님)
- Flutter 오버레이(`ui/`)에서는 일반 Flutter 위젯 사용

### 4. UI 디자인 시스템 (GameTheme)
`ui/game_theme.dart`에 모든 UI 상수를 정의:

#### 색상
```dart
GameTheme.bgDeep / bgDark / bgPanel / bgCard / bgSurface  // 배경 6단계
GameTheme.accent / accentDark                              // 주 액센트 (시안)
GameTheme.gold / purple / green / red / orange             // 시맨틱 6색
GameTheme.textPrimary / textSecondary / textMuted          // 텍스트 3단계
GameTheme.rarityCommon ~ rarityMythic                      // 희귀도 5티어
```

#### 타이포그래피
```dart
GameTheme.pixel()        // Press Start 2P (제목/숫자)
GameTheme.gameFont()     // Silkscreen (게임 UI)
// 한글: titleLarge / bodyLarge / bodyMedium / caption
```

#### 간격/라운딩
```dart
GameTheme.spacingXs(4) / Sm(8) / Md(12) / Lg(16) / Xl(24) / Xxl(32)
GameTheme.radiusSm(6) / radiusMd(10) / radiusLg(14)
```

#### 공통 위젯 (static 메서드)
```dart
GameTheme.pixelButton()       // 눌림 효과 버튼
GameTheme.pixelProgressBar()  // 둥근 끝 프로그레스바
GameTheme.panelBox()          // 카드형 패널
GameTheme.badgeChip()         // 작은 뱃지
GameTheme.sectionTitle()      // 섹션 제목
GameTheme.formatInt()         // 숫자 포맷 (12345 → '12.3K')
GameTheme.rarityColor()       // 희귀도별 색상
```

### 5. 12개 오버레이
```
DefenseMainMenu, DefenseHud, WaveReward, StarShop, RunResult,
Pause, RelicSelection, Tutorial, Settings, Achievement, Daily, Codex
```

## 성능 최적화

| 기법 | 적용 위치 |
|------|----------|
| 알파 버킷 양자화 | `damage_number.dart` (10단계, ParagraphBuilder 캐시) |
| 파티클 하드 캡 | 2000 (전체), 150 (지면 마크) |
| 타겟 탐색 쓰로틀 | `defense_unit.dart` (0.15초 간격) |
| Static Paint 캐시 | 렌더러 전체 |
| 킬 쓰로틀링 | 프레임당 처리 제한 |
| 오토머지/오토플레이스 간격 | 1.5s / 3.0s |

## 콘텐츠 추가 가이드

### 새 유닛 추가
→ `docs/units.md` "새 유닛 추가 방법" 참조

### 새 적 추가
→ `docs/enemies.md` "새 적 추가 방법" 참조

### 새 유물 추가
→ `docs/relics.md` "새 유물 추가 방법" 참조

### 새 하이브리드 추가
→ `docs/hybrids.md` "새 하이브리드 추가 방법" 참조

### 밸런스 수치 변경
1. `data/balance_config.dart`에서 해당 상수 수정
2. 관련 테스트 실행: `flutter test`

### 새 시스템 추가
1. `systems/` 디렉토리에 새 매니저 클래스 생성
2. `game/defense_game.dart`에서 인스턴스 생성 및 연결
3. 필요 시 `balance_config.dart`에 상수 추가
4. `test/systems/`에 테스트 추가

### 새 UI 화면 추가
1. `ui/` 디렉토리에 새 오버레이 위젯 생성
2. `GameTheme` 정적 멤버 사용
3. `main.dart`에 오버레이 등록
4. `defense_game.dart`에서 오버레이 표시/숨김 로직 추가

## 문서 구조

| 문서 | 내용 |
|------|------|
| `docs/units.md` | 유닛 8종 + 진화 8종 |
| `docs/hybrids.md` | 하이브리드 28종 |
| `docs/enemies.md` | 적 16종 |
| `docs/relics.md` | 유물 58개 |
| `docs/stages.md` | 웨이브/변형/보스 |
| `docs/skills.md` | 스킬 8종 + 콤보 |
| `docs/upgrades.md` | 업그레이드 16종 + 경제 |
| `docs/systems.md` | 게임필/파티클/시너지/업적/일일 |
| `docs/architecture.md` | 이 문서 — 코드 구조 |
| `CLAUDE.md` | 프로젝트 개요 (루트) |
