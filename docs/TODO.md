# Project TODO & Roadmap

## 현재 상태
- [x] 프로젝트 기본 구조
- [x] 플레이어 메카닉 (이동, 점프, 대시, 사격, 필살기)
- [x] 보스 시스템 프레임워크 (BossBase, BossFactory)
- [x] Boss 1: Stone Guardian (3 페이즈)
- [x] HUD (HP, 게이지, 보스HP)
- [x] 터치 조작 UI
- [x] 메인 메뉴 (보스 선택)
- [x] 게임오버/승리 화면
- [x] GitHub Actions APK 빌드
- [x] 빌드 에러 수정 (FixedResolutionViewport, HasGameReference)

## 미구현 보스
- [ ] Boss 2: Shadow Dasher - 고속 이동, 텔레포트
- [ ] Boss 3: Bullet Witch - 탄막 패턴
- [ ] Boss 4: Iron Colossus - 거대, 중장갑, 느린 강공
- [ ] Boss 5: Mirror Trickster - 분신, 속임수
- [ ] Boss 6: Hive Queen - 소환, 미니언 관리
- [ ] Boss 7: Storm Elemental - 원소 공격, 환경 변화
- [ ] Boss 8: The Overlord - 최종보스, 복합 패턴

## 개선 사항
- [ ] resetGame() 리팩토링 (onLoad 직접 호출 제거)
- [ ] 사운드/BGM 추가 (flame_audio 연동)
- [ ] 스프라이트/애니메이션 교체 (현재 프로시저럴 드로잉)
- [ ] 보스 잠금 해제 시스템 (순차 해금)
- [ ] 난이도 밸런싱
- [ ] 화면 흔들림 효과 (피격, 슬램 등)
- [ ] 파티클 이펙트 (폭발, 대시 트레일 등)
- [ ] 세이브/로드 (진행도 저장)
- [ ] 보스 처치 기록/타임어택

## 알려진 이슈
- world.removeAll(world.children)에서 concurrent modification 가능성
- HUD 업데이트가 100ms 폴링 방식 (비효율적, 리스너 패턴으로 변경 권장)
