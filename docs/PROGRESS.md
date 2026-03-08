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

## Phase 2: 업그레이드 + 저장 ✅
Coin → upgrade → growth loop with persistent save.

- [x] `pubspec.yaml` — shared_preferences 추가
- [x] `data/upgrade_data.dart` — 7종 업그레이드 정의 (이동속도/코인/공격력/점프력/더블점프/자석/콤보유지)
- [x] `systems/upgrade_manager.dart` — 업글 레벨/구매/비용계산/효과 멀티플라이어
- [x] `systems/save_manager.dart` — SharedPreferences 저장/로드 (코인/업글/통계/자동저장)
- [x] `ui/upgrade_shop.dart` — 업글 상점 오버레이 (구매/MAX 표시)
- [x] `ui/main_menu.dart` — 타이틀 화면 + 통계 + 시작 버튼
- [x] `ui/runner_hud.dart` — 상점 버튼 추가
- [x] `main.dart` — SaveManager 초기화, 3개 오버레이 등록, 앱 라이프사이클 저장
- [x] `runner_game.dart` — 업글 연동 (코인배율, 콤보유지, 자동저장 30초, 상점 토글)
- [x] `runner_player.dart` — 속도/점프력 업글 적용
- [x] `enemy.dart` — 공격력 업글 적용 (데미지 = attackMultiplier.ceil())

## Phase 3: 초월 + 영구 업글 + 지역 ✅
Full growth loop: coins → upgrades → ascension → souls → permanent upgrades.

- [x] `data/soul_upgrade_data.dart` — 영구 업그레이드 13종 (코인배율/시작속도/오프라인/지역해금4/장비해금3/자동/콤보)
- [x] `systems/ascension_manager.dart` — 초월 조건/실행/소울 계산/영구 업글 관리
- [x] `ui/soul_shop.dart` — 3탭(강화/지역/장비) 소울 상점 + 지역 변경
- [x] `ui/ascension_screen.dart` — 초월 연출 (화이트아웃 애니메이션 + 소울 보상 표시)
- [x] `components/parallax_layer.dart` — 3레이어 프로시저럴 패럴랙스 (산/언덕/수풀)
- [x] `data/enemy_data.dart` — 5개 지역 적 20종 (초원4/숲4/사막4/설산4/화산4)
- [x] `renderers/enemy_renderer.dart` — 20종 적 프로시저럴 렌더링 추가
- [x] `runner_game.dart` — 초월/소울 연동, 지역변경, 패럴랙스, 소울 코인배율
- [x] `save_manager.dart` — 소울/초월/영구업글/지역 저장·로드
- [x] `main.dart` — SoulShop, AscensionScreen 오버레이 등록
- [x] `runner_hud.dart` — 초월 버튼(조건 충족 시) + 소울 상점 버튼(초월 후)
- [x] `main_menu.dart` — 영구 업그레이드 버튼(초월 후)
- [ ] 장비 시스템 실제 효과 구현 (활/장갑/망토 — Phase 5+에서 구현)

## Phase 4: 동료 + 보스 + 미니이벤트 ✅
Collection mechanics, milestone bosses, golden enemies.

- [x] `data/companion_data.dart` — 동료 10종 (일반3/레어3/에픽2/전설2) + 희귀도/레벨업 비용
- [x] `systems/companion_manager.dart` — 수집/장착(1~4슬롯)/레벨업/버프(코인/속도/점프/공격/소울/콤보/장애물무시)
- [x] `renderers/companion_renderer.dart` — 10종 동료 프로시저럴 렌더링
- [x] `components/companion_pickup.dart` — 필드 동료 등장 + 수집 팝업 + 희귀도 글로우
- [x] `components/boss.dart` — 500m마다 보스 (HP바, 자동공격, 탭 추가공격, 10초 제한, 코인 폭발)
- [x] `renderers/boss_renderer.dart` — 5개 지역별 보스 렌더링 (킹슬라임/트렌트/스핑크스/이무기/드래곤)
- [x] `ui/companion_screen.dart` — 장착/해제 + 도감 그리드 + 레벨업
- [x] `enemy.dart` — isGolden 플래그 + x10 보상 + 금색 글로우
- [x] `renderers/enemy_renderer.dart` — isGolden 파라미터 (금색 팔레트)
- [x] `level_generator.dart` — 동료 스폰(2분 평균, 적극 시만), 보스 스폰(500m마다), 황금 적(2%)
- [x] `runner_game.dart` — CompanionManager 추가, 보스 연동, 동료 코인/콤보 버프
- [x] `runner_player.dart` — CompanionPickup 충돌, 동료 속도 버프, 장애물 무시
- [x] `save_manager.dart` — 동료 JSON 저장/로드 (초월해도 유지)
- [x] `main.dart` — CompanionScreen 오버레이 등록
- [x] `runner_hud.dart` — 동료 버튼 + 보스 HP/타이머 바

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
- [ ] 장비 효과 구현 (활/장갑/망토)

---

## 다음 세션에서 할 일
- Phase 5 구현 시작: weather_manager → weather_effect → 시간대별 배경 → ad_manager
