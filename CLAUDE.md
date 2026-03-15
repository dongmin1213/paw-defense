# 동물 성벽 지키기 — 반방치 로그라이트 타워디펜스

## 한 줄 요약
귀여운 동물 유닛을 배치·머지하여 성벽을 지키는 반방치 로그라이트 타워디펜스.

## Tech Stack
- **Framework**: Flutter 3.27.4 / Dart 3.6.2
- **Game Engine**: Flame 1.14.0 (flame_audio 2.1.0)
- **저장**: shared_preferences 2.2.0
- **폰트**: 로컬 번들 (PressStart2P, Silkscreen — assets/fonts/)
- **Target**: Android (portrait 400x700, immersive mode)
- **테스트**: `flutter test` (16개 파일, 274+ 케이스)
- **빌드**: `flutter pub get && flutter build apk --release` (CI로만 검증)

## 문서 구조 (주제별 독립 문서)

각 문서는 **자기 완결적** — 해당 문서만 읽으면 그 영역의 작업을 독립적으로 수행할 수 있습니다.

- `CLAUDE.md` — 프로젝트 개요 (이 파일)
- `docs/units.md` — 유닛 8종 + 진화 8종 (스탯, 스케일링, 특수 메카닉)
- `docs/hybrids.md` — 하이브리드 28종 (레시피, 스탯, 특수 능력)
- `docs/enemies.md` — 적 16종 (스탯, 해금, 스케일링, 특수 행동)
- `docs/relics.md` — 유물 58개 (5티어 희귀도, 효과, 드롭 가중치)
- `docs/stages.md` — 웨이브/스테이지 (적 수, 보스, 변형 10종, 보상)
- `docs/skills.md` — 액티브 스킬 8종 + 콤보 6단계 + 시너지
- `docs/upgrades.md` — 영구 업그레이드 16종 + 경제 시스템
- `docs/systems.md` — 게임필/파티클/업적/일일/도감/사운드
- `docs/architecture.md` — 코드 구조, 패턴, 콘텐츠 추가 가이드

## 프로젝트 구조

```
lib/
├── main.dart                          # 앱 진입점, 12개 오버레이
├── game/defense_game.dart             # FlameGame 메인
├── components/                        # Flame 컴포넌트
│   ├── wall.dart, unit_slot.dart, defense_unit.dart
│   ├── defense_enemy.dart, projectile.dart
│   ├── defense_particle.dart, damage_number.dart
│   ├── reactive_background.dart          # 강도 반응형 동적 배경
│   ├── skill_effect_overlay.dart         # 스킬별 풀스크린 시각 이펙트
├── data/                              # 데이터 정의 (수치 변경은 여기만)
│   ├── unit_data.dart                 # 유닛 8종 + 진화 8종
│   ├── hybrid_unit_data.dart          # 하이브리드 유닛 28종 (이종 머지)
│   ├── relic_data.dart                # 유물 50개 (5단계 희귀도)
│   ├── enemy_data.dart                # 적 10종
│   └── balance_config.dart            # 모든 밸런스 수치
├── renderers/                         # 픽셀아트 렌더러 (static only)
│   ├── wall_renderer.dart, unit_renderer.dart
│   └── defense_enemy_renderer.dart
├── systems/                           # 게임 시스템
│   ├── wave_manager.dart              # 웨이브 생성, 후반 스케일링
│   ├── wave_modifier.dart             # 웨이브 변형 10종 (속도/비행/엘리트 등)
│   ├── merge_manager.dart             # 동종 머지 + 이종 크로스브리드
│   ├── relic_manager.dart             # 50개 유물 효과, 가중 드롭
│   ├── combo_manager.dart             # 콤보 5단계 티어, 골드 보너스
│   ├── skill_manager.dart             # 액티브 스킬 8종 (킬 기반 게이지)
│   ├── synergy_manager.dart           # 종족/다양성 시너지
│   ├── defense_game_feel.dart         # 히트스탑, 슬로모션, 줌펀치, 스크린플래시
│   ├── defense_upgrade_manager.dart   # 영구 업그레이드 16종
│   ├── defense_save_manager.dart      # 세이브/로드 (영구 + 중간저장 + 해금)
│   ├── codex_manager.dart             # 도감 발견 상태 관리
│   ├── daily_manager.dart             # 일일 챌린지/출석 보상
│   ├── achievement_manager.dart       # 업적 시스템 (처치/웨이브/머지/유물)
│   └── sound_manager.dart             # BGM/SFX 재생, 앱 pause/resume
├── ui/                                # Flutter 오버레이
│   ├── game_theme.dart                # 통합 디자인 시스템 (색상/간격/타이포/위젯)
│   ├── defense_main_menu.dart, defense_hud.dart
│   ├── defense_pause_screen.dart, wave_reward_screen.dart
│   ├── star_shop_screen.dart, run_result_screen.dart
│   ├── relic_selection_screen.dart
│   ├── achievement_screen.dart        # 업적 화면
│   ├── codex_screen.dart              # 도감 4탭 (유닛/적/유물/통계)
│   ├── daily_screen.dart              # 일일 보상/챌린지
│   ├── settings_screen.dart           # 설정 (사운드, 데이터 초기화)
│   └── tutorial_screen.dart           # 게임 튜토리얼 (8단계)
└── utils/pixel_art.dart               # 문자맵 스프라이트 유틸

test/
├── data/                              # 데이터 레이어 검증
│   ├── balance_config_test.dart       # 밸런스 상수 범위/정합성
│   ├── unit_data_test.dart            # 8종 유닛 + 8종 진화 데이터
│   ├── enemy_data_test.dart           # 10종 적, availableAt() 필터
│   ├── hybrid_unit_data_test.dart     # 28종 레시피, 양방향 매칭
│   └── relic_data_test.dart           # 58개 유물 ID/희귀도 분포
├── systems/                           # 시스템 로직 검증
│   ├── merge_manager_test.dart        # 동종 머지/진화/이종 크로스브리드
│   ├── relic_manager_test.dart        # 인벤토리, 멀티플라이어, 이벤트
│   ├── synergy_manager_test.dart      # 종족/다양성 시너지, 하이브리드 카운팅
│   ├── upgrade_manager_test.dart      # 비용 스케일링, 멀티플라이어, 저장/로드
│   ├── achievement_manager_test.dart  # 진행도 추적, 보상 누적
│   ├── game_feel_test.dart            # 플래시/히트스탑/줌펀치 프리셋 검증
│   ├── combo_manager_test.dart        # 콤보 5단계 티어, 골드 보너스
│   ├── skill_manager_test.dart        # 액티브 스킬 게이지/발동
│   ├── sound_manager_test.dart        # BGM/SFX 재생/일시정지
│   ├── codex_manager_test.dart        # 도감 발견/완성도
│   └── wave_modifier_test.dart        # 웨이브 변형 10종 멀티플라이어
```

## UI 디자인 시스템 (GameTheme)

### 색상 팔레트
- **배경 6단계**: bgDeep → bgDark → bgPanel → bgCard → bgCardHover → bgSurface
- **주 액센트**: accent(시안), accentDark
- **시맨틱 6색**: Gold, Purple, Green, Red, Orange + Dark 변형
- **텍스트 3단계**: textPrimary(밝음), textSecondary(중간), textMuted(어두움)
- **희귀도 5티어**: rarityCommon → rarityRare → rarityEpic → rarityLegendary → rarityMythic
- **픽셀 크롬**: pixelHighlight, pixelShadow, pixelBorder

### 그라데이션
- 6종 LinearGradient (Primary/Gold/Purple/Green/Red/Dark)
- bgVignette RadialGradient (배경 비네팅)

### 타이포그래피
- **pixel()**: Press Start 2P (제목/숫자) — `GameTheme.pixelTitleLarge/Medium/Small/Label/Number`
- **gameFont()**: Silkscreen (가독성 높은 게임 UI 텍스트)
- **Korean TextStyle**: titleLarge/bodyLarge/bodyMedium/caption (한글 호환)

### 표준 간격/라운딩
- **간격**: spacingXs(4) / Sm(8) / Md(12) / Lg(16) / Xl(24) / Xxl(32)
- **라운딩**: radiusSm(6) / radiusMd(10) / radiusLg(14)

### 공통 위젯 (static 메서드)
- `pixelButton()` — AnimatedScale(0.95) 눌림 효과, 그라데이션 배경
- `pixelProgressBar()` — ClipRRect 둥근 끝 처리
- `panelBox()` — bgCard + pixelBorder 테두리 패널
- `badgeChip()` — 작은 라운드 뱃지
- `sectionTitle()` — 액센트 좌측바 + 제목
- `formatInt()` — 숫자 포맷 (12345 → '12.3K')
- `rarityColor()` — 희귀도별 색상 반환

### 12개 오버레이
DefenseMainMenu, DefenseHud, WaveReward, StarShop, RunResult,
Pause, RelicSelection, Tutorial, Settings, Achievement, Daily, Codex

## 핵심 시스템

### 유물 시스템 (50개, 5단계 희귀도)
- **등급**: 일반(40%) / 레어(30%) / 에픽(20%) / 전설(8%) / 신화(2%)
- **최대 소지**: 5개 (무한의 돌 유물 시 7개)
- **카테고리**: 공격 / 방어 / 경제 / 머지 / 규칙변경
- **구성**: 진화석 8 + 일반 15 + 레어 15 + 에픽 12 + 전설 6 + 신화 2 = 58개
- 데이터: `data/relic_data.dart` / 로직: `systems/relic_manager.dart`

### 이종 머지 (하이브리드 유닛 28종)
- **다른 종 2마리** (둘 다 Lv3+) = 하이브리드 유닛 탄생
- 8종 기본 유닛에서 C(8,2) = 28종 전체 조합 구현
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

### 중간 저장 시스템 (Mid-run Save/Load)
- 앱이 백그라운드로 가면 자동 저장 (`didChangeAppLifecycleState`)
- `buildRunState()`: 골드, 킬수, 웨이브, 유물, 슬롯, 벽 HP, 보상 배율 직렬화
- `resumeRun()`: 저장 상태 복원 + 현재 웨이브 재시작
- 메인 메뉴에 "이어하기" 버튼 표시 (저장된 런이 있을 때)
- 런 종료 시 자동 삭제 (`clearRunState`)

### 업적 시스템
- 카테고리: 처치(kills), 웨이브(waves), 머지(merges), 유물(relics)
- HUD 상단에 업적 달성 알림 배너 (2.5초 표시)
- `achievement_manager.dart` + `defense_game.dart` 큐 기반 알림

### 원소 & DoT 시스템
- 분열탄 유물: 피격 시 ±45° 자식 투사체 2개 (데미지 50%)
- 원소 폭풍 유물: 피격 시 랜덤 원소 적용 (불/얼음/독)
  - 불: 30% DoT 3초 / 얼음: 40% 슬로우 2초 / 독: 15% DoT 5초
- DoT 틱 간격: 0.5초 (`defense_enemy.dart`)

### HUD 피드백
- 머지 힌트: 동종 3개(합성의서 2개) 시 초록 글로우
- 하이브리드 힌트: 이종 머지 가능 시 보라 글로우 + 🧬 표시
- 콤보 티어 변경 시 화면 전체 플래시 (티어별 색상, 0.5초 페이드)
- 유물 탭 툴팁: HUD 유물바에서 탭 → 이름/희귀도/설명 표시
- AnimatedSize 래핑: HUD 조건부 위젯 9개 부드러운 전환

### 액티브 스킬 시스템 (8종)
- 킬 기반 게이지 충전 → 지배적 유닛 타입의 스킬 자동 판별
- 화살비/전투의함성/메테오/얼음벽/암살표식/폭풍소환/성벽회복/마력폭발
- 스킬별 풀스크린 시각 이펙트 오버레이 (`skill_effect_overlay.dart`)
- `systems/skill_manager.dart`

### 시각적 스펙터클 시스템 (6 Phase)
- **유닛 궤도 회전**: 성벽 주위 공전, 웨이브/유닛수에 따라 가속, 스프라이트 좌우반전
- **투사체 트레일+타입별 모양**: 8종 유닛별 고유 픽셀 모양+색상, 8프레임 잔상 링버퍼
- **적 스웜 밀도**: 적 수 2배 + HP 0.55배 (총 웨이브 HP 유지), ±15% 속도 편차
- **사망이펙트+골드비산**: 15~40파티클 사망, 충격파 링(24개), 호밍 골드 파티클
- **반응형 배경**: 전투 강도 연동 색상 시프트 (네이비→크림슨), 40개 별 파티클, 방사형 펄스
- **스킬 시각 이펙트**: 8종 스킬별 화면 가득 오버레이 (화살비/메테오/서리/번개 등)
- 관련 파일: `balance_config.dart` (궤도/스웜 파라미터), `reactive_background.dart`, `skill_effect_overlay.dart`

### 시각적 성장 피드백 시스템 (5 Phase)
- **투사체 레벨 스케일링**: 크기 Lv1=1.0x→Lv5=1.6x→진화=1.9x, 트레일 6→12프레임, 진화 골드 글로우+밝은 색상
- **하이브리드 투사체 이중 색상**: 부모A+B 색상 블렌딩, 보라색 코어, 진화 골드 트레일
- **머지 이펙트 레벨 스케일링**: 파티클 수 Lv2=15→Lv5=30개, 크기/속도/범위 비례 증가, Lv5 골드 폭발
- **적 타입별 사망 이펙트**: 10종 적별 고유 사망 색상 (슬라임=초록, 스켈레톤=흰, 폭탄병=주황+추가 파티클 등)
- **머즐 플래시**: 8종 유닛별 고유 색상, 레벨 비례 파티클(Lv1=2→Lv5=6), 진화=골드, 하이브리드=보라
- 관련 파일: `projectile.dart` (투사체 스케일링), `defense_particle.dart` (머지/사망/머즐), `defense_unit.dart` (머즐 색상)

### 웨이브 변형 시스템 (10종)
- 웨이브 10부터 5웨이브마다 랜덤 적용 (보스 웨이브 제외)
- 하늘의위협/스피드런/철벽행군/엘리트/물량공세/불타는땅/황금웨이브/번개웨이브/안개/카오스
- `systems/wave_modifier.dart`

### 일일 챌린지 & 출석 보상
- 7일 사이클 출석 보상 (50~500 별)
- 날짜 해시 기반 일일 챌린지 (목표 웨이브 15~30)
- `systems/daily_manager.dart` + `ui/daily_screen.dart`

### 도감 시스템 (4탭)
- 유닛/적/유물/통계 탭, 미발견 아이템 "???" 실루엣 표시
- `systems/codex_manager.dart` + `ui/codex_screen.dart`

### 시너지 시스템
- 종족 시너지 + 다양성 시너지, 하이브리드 카운팅
- `systems/synergy_manager.dart`

### 점진적 시스템 해금
- 플레이 진행에 따라 시스템 순차 해금 (머지힌트 → 보상카드 → 유물 → 하이브리드 → 콤보 → 진화 → 업적)
- `defense_save_manager.dart` (`unlockedSystems`)

### 배속 조절
- 1x ↔ 2x 토글, HUD 상단바에서 조작
- `defense_game.dart` (`gameSpeed`, `toggleGameSpeed()`)

### 런 결과 랭크 시스템
- F → D → C → B → A → S → SS (웨이브 기반)
- 신기록 표시, DPS 통계, 광고 x2 보상 슬롯
- `ui/run_result_screen.dart`

### 튜토리얼 (8단계)
1. 성벽을 지켜라! → 2. 유닛 배치 → 3. 합체! → 4. 보상과 유물
5. 하이브리드 유닛 → 6. 콤보 시스템 → 7. 진화 & 업그레이드 → 8. 판매 & 리롤

## 핵심 규칙
1. **밸런스 수치** → `data/balance_config.dart` 한 곳에서 관리
2. **새 적/유닛 추가** → `data/` 파일만 수정 (상세: `docs/ARCHITECTURE.md`)
3. **렌더러** → static 메서드만, PixelArt.drawCentered() 패턴
4. **UI** → GameTheme 정적 멤버 사용 (색상: bgCard/accent/textPrimary, 간격: spacingMd, 위젯: pixelButton/panelBox/badgeChip 등)
5. **텍스트 렌더링** → Flame render()에서는 dart:ui TextStyle만 사용
6. **유물 추가** → `data/relic_data.dart` 데이터 + `systems/relic_manager.dart` 효과 로직
7. **하이브리드 추가** → `data/hybrid_unit_data.dart` 레시피+데이터 + `renderers/unit_renderer.dart` 렌더
8. **테스트** → `flutter test` 실행, 데이터 변경 시 `test/data/` 테스트도 업데이트
9. **유닛 ID** → 게임 내부에서 snake_case 사용 (`cat_archer`, `dog_warrior` 등)
