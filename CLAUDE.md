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
- `docs/GDD_CASTLE_DEFENSE.md` — 게임 설계 문서
- `docs/UNITS.md` — 유닛 6종 스탯/특성
- `docs/ENEMIES.md` — 적 7종 + 보스 스탯/특수행동
- `docs/BALANCE.md` — 밸런스 수치 총정리 (balance_config.dart 기반)
- `docs/ARCHITECTURE.md` — 코드 구조, 패턴, 확장 가이드

## 프로젝트 구조 (33개 파일)

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
│   ├── enemy_data.dart                # 적 10종
│   └── balance_config.dart            # 모든 밸런스 수치
├── renderers/                         # 픽셀아트 렌더러 (static only)
│   ├── wall_renderer.dart, unit_renderer.dart
│   └── defense_enemy_renderer.dart
├── systems/                           # 게임 시스템
│   ├── wave_manager.dart, merge_manager.dart
│   ├── relic_manager.dart, defense_game_feel.dart
│   ├── defense_upgrade_manager.dart, defense_save_manager.dart
│   └── sound_manager.dart             # BGM/SFX 재생, 앱 pause/resume
├── ui/                                # Flutter 오버레이
│   ├── game_theme.dart, defense_main_menu.dart, defense_hud.dart
│   ├── defense_pause_screen.dart, wave_reward_screen.dart
│   ├── star_shop_screen.dart, run_result_screen.dart
│   ├── relic_selection_screen.dart
│   ├── settings_screen.dart           # 설정 (사운드, 진동 등)
│   └── tutorial_screen.dart           # 게임 튜토리얼
└── utils/pixel_art.dart               # 문자맵 스프라이트 유틸
```

## 핵심 규칙
1. **밸런스 수치** → `data/balance_config.dart` 한 곳에서 관리
2. **새 적/유닛 추가** → `data/` 파일만 수정 (상세: `docs/ARCHITECTURE.md`)
3. **렌더러** → static 메서드만, PixelArt.drawCentered() 패턴
4. **UI** → GameTheme 정적 멤버 사용 (pixelButton, pixelProgressBar 등)
5. **텍스트 렌더링** → Flame render()에서는 dart:ui TextStyle만 사용
