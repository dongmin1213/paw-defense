# Implementation Progress

> 39개 Dart 파일, ~6900줄. Phase 1~6 모두 완료. 아래는 파일별 구현 상세 체크리스트.

---

## Phase 1: 핵심 달리기 ✅

Core auto-runner: 자동 달리기, 적 처치, 코인 수집, 콤보, 장애물.

- [x] `utils/constants.dart` — 월드(800x600), 물리(중력980, 점프-420), 바닥Y(500), 디스폰 거리
- [x] `data/balance_config.dart` — 공중적 코인x3, 콤보 0.05/스택, 리셋3초, 적극x1.5, 속도 커브
- [x] `data/enemy_data.dart` — EnemyData 클래스 + 초원 적 4종 (슬라임/버섯/새/나비)
- [x] `data/region_data.dart` — 5개 지역 정의 (초원x1 ~ 화산x100 배율)
- [x] `renderers/player_renderer.dart` — 비숏 Canvas 드로잉 (달리기/점프 애니)
- [x] `renderers/enemy_renderer.dart` — 적 Canvas 드로잉 (4종 기본)
- [x] `renderers/coin_renderer.dart` — 코인 Canvas 드로잉 (회전 애니)
- [x] `game/runner_game.dart` — FlameGame, FixedResolutionViewport(800x600), 카메라 추적, TapCallbacks, 방치/적극 모드 감지 (5초), addCoins(), addCombo()
- [x] `components/runner_player.dart` — 자동 이동, 중력/점프, 더블점프, 자동공격 (적 충돌 시), 장애물 속도감소
- [x] `components/ground_segment.dart` — 400px 바닥 블록, 카메라 뒤 → 앞 재배치 (무한 스크롤)
- [x] `components/enemy.dart` — 바닥적(자동처치)/공중적(점프처치), HP 시스템, 코인 스폰, 피격 플래시
- [x] `components/coin.dart` — 호버 애니, 수집 시 "+N" 팝업 (ParagraphBuilder), 자동 디스폰
- [x] `components/obstacle.dart` — 바위 (적극 플레이 시만 생성), 충돌 → 2초간 속도 50%
- [x] `systems/level_generator.dart` — 카메라+1200px까지 300px 세그먼트 생성, 적/코인/장애물 배치
- [x] `ui/runner_hud.dart` — 거리(m), 코인, 콤보, 방치/적극 모드 표시
- [x] `main.dart` — GameWidget + HUD 오버레이 등록

## Phase 2: 업그레이드 + 저장 ✅

코인 → 업그레이드 → 성장 체감. SharedPreferences 영속성.

- [x] `pubspec.yaml` — shared_preferences 2.2.0 추가
- [x] `data/upgrade_data.dart` — 7종: 이동속도(25lv)/코인획득(25lv)/공격력(20lv)/점프력(15lv)/더블점프(1lv)/자석(10lv)/콤보유지(5lv)
- [x] `systems/upgrade_manager.dart` — 레벨 관리, `baseCost * 1.15^lv` 비용, 배율 getter (coinMultiplier, speedMultiplier, attackMultiplier 등)
- [x] `systems/save_manager.dart` — coins/distance/upgrades/stats 저장·로드, 자동저장 30초, AppLifecycleState.paused 저장
- [x] `ui/upgrade_shop.dart` — 오버레이 상점 (pauseEngine), 업글 목록, 구매 버튼, MAX 표시
- [x] `ui/main_menu.dart` — 타이틀 "The Bichon's Run", 시작 버튼, 최고거리/코인 통계
- [x] runner_game.dart — 업글 연동 (코인배율, 콤보유지, 상점 토글, 자동저장)
- [x] runner_player.dart — 속도/점프력/더블점프/자석 업글 적용
- [x] enemy.dart — 공격력 업글 적용 (`attackMultiplier.ceil()` 데미지)

## Phase 3: 초월 + 영구 업글 + 지역 ✅

전체 성장 루프: 코인 → 업글 → 초월 → 소울 → 영구업글 → 재성장.

- [x] `data/soul_upgrade_data.dart` — 영구 13종: 코인배율(∞lv)/시작속도(10)/오프라인(10)/지역해금(4)/장비해금(3)/자동(2)/콤보(5)
- [x] `systems/ascension_manager.dart` — 초월 조건(`10000*3^n`), 소울 계산(`max(1,log10-3)`), 리셋, 영구 업글 구매/효과
- [x] `ui/soul_shop.dart` — 3탭(강화/지역/장비), 소울 표시, 지역 변경
- [x] `ui/ascension_screen.dart` — 화이트아웃 애니, "초월 N회차", 소울 보상 표시, 탭하여 계속
- [x] `components/parallax_layer.dart` — 3레이어 프로시저럴 패럴랙스 (지역별 색상)
- [x] `data/enemy_data.dart` — 5지역 적 20종 추가 (숲4/사막4/설산4/화산4)
- [x] `renderers/enemy_renderer.dart` — 20종 적 렌더링 메서드 추가
- [x] runner_game.dart — 초월/소울 연동, 지역변경, 패럴랙스, 소울 코인배율
- [x] save_manager.dart — 소울/초월횟수/영구업글레벨/지역 저장·로드
- [x] main.dart — SoulShop, AscensionScreen 오버레이 등록 (총 5개)
- [x] runner_hud.dart — 초월 버튼(조건충족 시 표시), 소울상점 버튼(1회 이상 초월 후)

## Phase 4: 동료 + 보스 + 미니이벤트 ✅

수집 메카닉, 마일스톤 보스, 황금 적.

- [x] `data/companion_data.dart` — 동료 10종 (일반3/레어3/에픽2/전설2), 희귀도/레벨업 비용/버프 타입
- [x] `systems/companion_manager.dart` — 수집/장착(1~4슬롯, 소울로 확장)/레벨업/7종 버프 계산
- [x] `renderers/companion_renderer.dart` — 10종 동료 Canvas 드로잉
- [x] `components/companion_pickup.dart` — 필드 동료 (적극 플레이 시만, 평균 2분 주기), 희귀도별 글로우, 수집 팝업
- [x] `components/boss.dart` — 500m마다 등장, HP 바 + 타이머 바, 자동공격(0.5초) + 탭 추가공격(x2 DPS), 10초 제한, 코인 폭발(8~12개), 지역별 HP/보상 스케일링
- [x] `renderers/boss_renderer.dart` — 5지역 보스 렌더링 (킹슬라임/트렌트/스핑크스/이무기/드래곤)
- [x] `ui/companion_screen.dart` — 장착/해제 + 도감 그리드 + 레벨업
- [x] enemy.dart — isGolden 플래그, x10 보상, 금색 글로우 이펙트
- [x] level_generator.dart — 동료 스폰(2분 평균, 적극 시만), 보스 스폰(500m마다), 황금 적(2%)
- [x] runner_game.dart — CompanionManager 연동, 보스 탭공격 전달, 동료 버프 addCoins() 반영
- [x] runner_player.dart — CompanionPickup 충돌, 동료 속도 버프, 장애물 무시 확률
- [x] save_manager.dart — 동료 데이터 JSON 직렬화 (초월 시 유지)
- [x] main.dart — CompanionScreen 오버레이 등록 (총 6개)

## Phase 5: 날씨/시간 + 광고 ✅

분위기 변화 + 수익화 인프라.

- [x] `systems/weather_manager.dart` — DateTime 기반 시간대(4종) + 랜덤 날씨(5종, 3~5분 주기), 배율 getter
- [x] `components/weather_effect.dart` — 비(빗방울)/눈(눈송이)/폭풍(번개)/무지개(반짝) 파티클 + 시간대별 색상 오버레이
- [x] 시간대 보너스: 저녁 코인+20%, 밤 소울+50%+희귀적↑, 새벽 전설동료 2x
- [x] 날씨 보너스: 비 코인+30%, 눈 희귀적+50%, 폭풍 전체x2+장애물x2, 무지개 전부x2
- [x] `systems/ad_manager.dart` — 스텁 구현 (showRewardedAd → 즉시 onReward 콜백), 일일 제한 카운터
- [x] 광고 연동 구조: 오프라인x2, 보상형/인터스티셜 API 준비

## Phase 6: 오프라인 + 폴리시 ✅

오프라인 보상, 파티클 FX, 특수 이벤트.

- [x] `systems/offline_reward.dart` — CpS 계산 (적출현율 × 코인 × 모든배율 × 0.3), 최소60초, 최대24시간
- [x] `ui/offline_popup.dart` — 복귀 팝업 (경과시간/코인 표시, "수령" / "x2 수령" 버튼)
- [x] `components/particle_effect.dart` — 5종 파티클: 코인수집(금색)/적처치(적 색상)/보스폭발(다색)/먼지(갈색)/콤보(황금)
- [x] 특수 이벤트 3종: 골든 아워(20초, 적 100%황금), 유성우(30초, 하늘 코인), 동료 집회(60초, 출현5x)
- [x] runner_game.dart — 날씨/파티클/이벤트/오프라인 전체 통합, 이벤트 ~10분 평균 + 5분 쿨다운
- [x] level_generator.dart — 골든아워(적 100% 황금), 동료집회(스폰 5x), 폭풍(장애물 x2)
- [x] runner_hud.dart — 날씨/시간 좌하단 표시, 이벤트 배너(이름+카운트다운)
- [x] main.dart — OfflinePopup 오버레이 등록 (총 7개 오버레이)

---

## 미구현 기능 (TODO)

### 높은 우선순위
- [ ] **장비 효과 구현** — 활(점프 중 자동 화살 → 공중적 자동 처치), 장갑(처치 시 추가 코인), 망토(2단 대시 + 무적) — 소울 해금 구조는 있으나 실제 효과 미구현
- [ ] **자동 공중적 처치** — 소울 해금은 있지만 실제 방치 중 공중적 자동 처치 로직 없음
- [ ] **자동 업글 구매** — 소울 해금은 있지만 실제 자동 구매 로직 없음

### 중간 우선순위
- [ ] **실제 광고 SDK** — google_mobile_ads 연동 (AndroidManifest AdMob ID 필요)
- [ ] **온보딩 튜토리얼** — 말풍선 안내 ("탭하여 점프!", "점프하여 처치!" 등)
- [ ] **사운드** — flame_audio 의존성은 있으나 미사용 (점프/코인/처치/보스/초월 SFX)
- [ ] **보물상자** — 랜덤 등장, 터치 → 코인/소울/동료 중 랜덤 보상
- [ ] **코인 러시** — 30초 코인 대량 출현 구간

### 낮은 우선순위
- [ ] **업적/퀘스트 시스템** — 방향성 제시 + 장기 목표
- [ ] **달리기/공격 애니메이션 개선** — 현재 2프레임 토글, 더 부드러운 애니 필요
- [ ] **적 진화** (3단계, 처치 수 기반)
- [ ] **업글 티어** (만렙 → 다음 티어 해금)
- [ ] **울트라 초월** (초월 10회 → 소울까지 리셋 + 디바인 포인트)
- [ ] **미니언 시스템** (자동 수입원)
- [ ] **크래프팅** (재료 드랍 → 아이템 제작)
- [ ] **추가 지역/차원**
- [ ] **캐릭터 스킨/코스튬**

---

## 커밋 히스토리

| 커밋 | 내용 |
|------|------|
| `10463db` | docs: MD 파일 초기 작성 |
| `dea9793` | feat: Phase 2 — 업그레이드, 저장, 상점, 메뉴 |
| `3863d54` | feat: Phase 3 — 초월, 소울, 5지역, 패럴랙스 |
| `b937464` | feat: Phase 4 — 동료, 보스, 황금 적 |
| `0a3fffe` | feat: Phase 5+6 — 날씨/시간, 오프라인, 파티클, 이벤트 |
