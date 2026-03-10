# 동물 성벽 지키기 — 반방치 로그라이트 타워디펜스

## 한 줄 요약
귀여운 동물 유닛을 배치·머지하여 성벽을 지키는 반방치 로그라이트 타워디펜스.

## Tech Stack
- **Framework**: Flutter 3.27.4 / Dart 3.6.2
- **Game Engine**: Flame 1.14.0 (flame_audio 2.1.0)
- **저장**: shared_preferences 2.2.0
- **Target**: Android (portrait 400x700, immersive mode)
- **빌드**: `flutter pub get && flutter build apk --release` (CI로만 검증)

## 문서 구조
- `CLAUDE.md` — 프로젝트 개요 (이 파일)
- `PLAN.md` — 차별화 개선 4단계 계획 (✅ 전체 완료)
- `docs/GDD_CASTLE_DEFENSE.md` — 게임 설계 문서
- `docs/UNITS.md` — 유닛 8종 + 진화 8종 + 하이브리드 12종
- `docs/ENEMIES.md` — 적 10종 + 보스 스탯/특수행동
- `docs/BALANCE.md` — 밸런스 수치 총정리 (balance_config.dart 기반)
- `docs/ARCHITECTURE.md` — 코드 구조, 패턴, 확장 가이드

## 프로젝트 구조

```
lib/
├── main.dart                          # 앱 진입점, 9개 오버레이
├── game/defense_game.dart             # FlameGame 메인
├── components/                        # Flame 컴포넌트
│   ├── wall.dart, unit_slot.dart, defense_unit.dart
│   ├── defense_enemy.dart, projectile.dart
│   ├── defense_particle.dart, damage_number.dart
├── data/                              # 데이터 정의 (수치 변경은 여기만)
│   ├── unit_data.dart                 # 유닛 8종 + 진화 8종
│   ├── hybrid_unit_data.dart          # 하이브리드 유닛 12종 (이종 머지)
│   ├── relic_data.dart                # 유물 50개 (5단계 희귀도)
│   ├── enemy_data.dart                # 적 10종
│   └── balance_config.dart            # 모든 밸런스 수치
├── renderers/                         # 픽셀아트 렌더러 (static only)
│   ├── wall_renderer.dart, unit_renderer.dart
│   └── defense_enemy_renderer.dart
├── systems/                           # 게임 시스템
│   ├── wave_manager.dart              # 웨이브 생성, 후반 스케일링
│   ├── merge_manager.dart             # 동종 머지 + 이종 크로스브리드
│   ├── relic_manager.dart             # 50개 유물 효과, 가중 드롭
│   ├── combo_manager.dart             # 콤보 5단계 티어, 골드 보너스
│   ├── defense_game_feel.dart         # 히트스탑, 슬로모션, 줌펀치
│   ├── defense_upgrade_manager.dart   # 영구 업그레이드 16종
│   ├── defense_save_manager.dart      # 세이브/로드
│   ├── achievement_manager.dart       # 업적 시스템
│   └── sound_manager.dart             # BGM/SFX 재생, 앱 pause/resume
├── ui/                                # Flutter 오버레이
│   ├── game_theme.dart, defense_main_menu.dart, defense_hud.dart
│   ├── defense_pause_screen.dart, wave_reward_screen.dart
│   ├── star_shop_screen.dart, run_result_screen.dart
│   ├── relic_selection_screen.dart
│   ├── achievement_screen.dart        # 업적 화면
│   ├── settings_screen.dart           # 설정 (사운드, 진동 등)
│   └── tutorial_screen.dart           # 게임 튜토리얼
└── utils/pixel_art.dart               # 문자맵 스프라이트 유틸
```

## 핵심 시스템

### 유물 시스템 (50개, 5단계 희귀도)
- **등급**: 일반(40%) / 레어(30%) / 에픽(20%) / 전설(8%) / 신화(2%)
- **최대 소지**: 5개 (무한의 돌 유물 시 7개)
- **카테고리**: 공격 / 방어 / 경제 / 머지 / 규칙변경
- **구성**: 진화석 8 + 일반 15 + 레어 15 + 에픽 12 + 전설 6 + 신화 2 = 58개
- 데이터: `data/relic_data.dart` / 로직: `systems/relic_manager.dart`

### 이종 머지 (하이브리드 유닛 12종)
- **다른 종 2마리** (둘 다 Lv3+) = 하이브리드 유닛 탄생
- 8종 기본 유닛에서 12종 핵심 조합 구현
- 하이브리드 유닛은 양쪽 부모의 능력을 결합한 고유 특수 능력 보유
- 데이터: `data/hybrid_unit_data.dart` / 머지: `systems/merge_manager.dart`

### 콤보 시스템 (5단계 티어)
- 2초 내 연속 처치 → 콤보 카운트 증가
- 5단계: NICE(5+) → GREAT(10+) → AMAZING(25+) → UNSTOPPABLE(50+) → GODLIKE(100+)
- 10콤보마다 골드 보너스, 이펙트 크기 1.2x~3.0x 증폭
- `systems/combo_manager.dart`

### 영구 업그레이드 (16종)
- 기본 11종: 성벽(HP/재생/방어), 유닛(ATK/공속/초기유닛), 경제(골드/할인/스타), 특수(슬롯/유물확률)
- 신규 5종: 초기자금, 유물품질, 콤보지속, 하이브리드강화, 기본크리티컬
- `systems/defense_upgrade_manager.dart`

## 핵심 규칙
1. **밸런스 수치** → `data/balance_config.dart` 한 곳에서 관리
2. **새 적/유닛 추가** → `data/` 파일만 수정 (상세: `docs/ARCHITECTURE.md`)
3. **렌더러** → static 메서드만, PixelArt.drawCentered() 패턴
4. **UI** → GameTheme 정적 멤버 사용 (pixelButton, pixelProgressBar 등)
5. **텍스트 렌더링** → Flame render()에서는 dart:ui TextStyle만 사용
6. **유물 추가** → `data/relic_data.dart` 데이터 + `systems/relic_manager.dart` 효과 로직
7. **하이브리드 추가** → `data/hybrid_unit_data.dart` 레시피+데이터 + `renderers/unit_renderer.dart` 렌더
