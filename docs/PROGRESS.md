# Implementation Progress

## Phase 1: 핵심 달리기 ✅
Core auto-runner with enemies, coins, combo, and obstacles.

- [x] `utils/constants.dart` — 월드(800x600), 물리(중력, 점프력)
- [x] `data/balance_config.dart` — 밸런스 수치 집중 관리
- [x] `data/enemy_data.dart` — 초원 적 데이터 (슬라임, 버섯, 새, 나비)
- [x] `data/region_data.dart` — 5개 지역 데이터
- [x] `renderers/player_renderer.dart` — 비숏 프로시저럴 렌더링
- [x] `renderers/enemy_renderer.dart` — 적 프로시저럴 렌더링 (4종)
- [x] `renderers/coin_renderer.dart` — 코인 프로시저럴 렌더링
- [x] `game/runner_game.dart` — FlameGame 메인 클래스
- [x] `components/runner_player.dart` — 자동 이동 + 중력/점프 + 자동 공격
- [x] `components/ground_segment.dart` — 무한 스크롤 바닥
- [x] `components/enemy.dart` — 바닥/공중 적 + HP + 코인 스폰
- [x] `components/coin.dart` — 코인 수집 + "+N" 팝업
- [x] `components/obstacle.dart` — 바위 장애물 (적극 플레이 시만)
- [x] `systems/level_generator.dart` — 절차적 레벨 생성
- [x] `ui/runner_hud.dart` — 거리/코인/콤보/모드 HUD
- [x] `main.dart` — 앱 진입점
- [x] `CLAUDE.md` — 프로젝트 문서 업데이트
- [x] `docs/GAME_DESIGN.md` — 게임 설계 문서
- [x] `docs/PROGRESS.md` — 진행 상황 트래커
- [x] `docs/ARCHITECTURE.md` — 코드 아키텍처 문서

## Phase 2: 업그레이드 + 저장 ⬜
Coin → upgrade → growth loop with persistent save.

- [ ] `pubspec.yaml` — shared_preferences 추가
- [ ] `systems/save_manager.dart` — SharedPreferences 저장/로드
- [ ] `systems/upgrade_manager.dart` — 일반 업글 데이터 + 비용 + 효과
- [ ] `data/upgrade_data.dart` — 업그레이드 정의
- [ ] `ui/upgrade_shop.dart` — 업글 상점 UI
- [ ] `ui/main_menu.dart` — 타이틀 + 시작 + 통계
- [ ] runner_player에 업그레이드 효과 연동

## Phase 3: 초월 + 영구 업글 + 지역 ⬜
Full growth loop: coins → upgrades → ascension → souls → permanent upgrades.

- [ ] `systems/ascension_manager.dart` — 초월 조건/실행/소울 계산
- [ ] `ui/soul_shop.dart` — 영구 업글 UI
- [ ] 초월 연출 (화이트아웃 + "초월 N회차")
- [ ] `components/parallax_layer.dart` — 지역별 3레이어 배경
- [ ] 지역별 몬스터 풀 + 코인 배율 적용
- [ ] 장비 시스템 (검 기본 + 활/장갑/망토)

## Phase 4: 동료 + 보스 + 미니이벤트 ⬜
Collection mechanics, milestone bosses, variety events.

- [ ] `systems/companion_manager.dart` — 동료 수집/장착/버프
- [ ] `data/companion_data.dart` — 동료 데이터
- [ ] `components/companion_pickup.dart` — 필드 동료 등장
- [ ] `renderers/companion_renderer.dart` — 동료 렌더링
- [ ] `ui/companion_screen.dart` — 장착/도감 UI
- [ ] `components/boss.dart` — 500m 보스
- [ ] `renderers/boss_renderer.dart` — 보스 렌더링
- [ ] 미니이벤트 (보물상자, 코인 러시, 황금 적)

## Phase 5: 날씨/시간 + 광고 ⬜
Atmosphere and monetization.

- [ ] `systems/weather_manager.dart` — 날씨/시간 관리
- [ ] `components/weather_effect.dart` — 비/눈/폭풍 파티클
- [ ] 시간대별 배경색 변화 + 보너스
- [ ] `systems/ad_manager.dart` — google_mobile_ads
- [ ] 광고 연동 (오프라인 x2, 코인 부스트, 보스 보상, 초월)
- [ ] `pubspec.yaml` — google_mobile_ads 추가

## Phase 6: 오프라인 + 폴리시 ⬜
Offline rewards, particles, sound, polish.

- [ ] `systems/offline_reward.dart` — CpS 기반 오프라인 보상
- [ ] `ui/offline_popup.dart` — 복귀 팝업
- [ ] `components/particle_effect.dart` — 파티클 이펙트
- [ ] 달리기/공격 애니메이션 개선
- [ ] 특수 이벤트 (유성우, 골든 아워, 동료 집회)
- [ ] 사운드 (flame_audio)

---

## 다음 세션에서 할 일
- Phase 2 구현 시작: upgrade_data → upgrade_manager → save_manager → upgrade_shop → main_menu
