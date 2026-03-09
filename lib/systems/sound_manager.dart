import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import '../game/runner_game.dart';

/// 사운드 매니저 — 프로시저럴 사운드 (에셋 없이 AudioPool 기반)
/// 실제 사운드 에셋이 없으므로 음소거 상태로 API만 준비
/// 에셋 추가 시 _play 호출부만 활성화하면 됨
class SoundManager extends Component with HasGameReference<RunnerGame> {
  bool _initialized = false;
  bool muted = false;
  double sfxVolume = 0.8;
  double bgmVolume = 0.5;

  // 사운드 쿨다운 (같은 효과 연속 재생 방지)
  final Map<String, double> _cooldowns = {};
  static const double _minInterval = 0.05;

  Future<void> init() async {
    // 에셋이 추가되면 여기서 AudioPool 초기화
    // await FlameAudio.audioCache.loadAll([...]);
    _initialized = true;
  }

  @override
  void update(double dt) {
    // 쿨다운 업데이트
    final keys = _cooldowns.keys.toList();
    for (final key in keys) {
      _cooldowns[key] = _cooldowns[key]! - dt;
      if (_cooldowns[key]! <= 0) _cooldowns.remove(key);
    }
  }

  bool _canPlay(String id) {
    if (muted || !_initialized) return false;
    if (_cooldowns.containsKey(id)) return false;
    _cooldowns[id] = _minInterval;
    return true;
  }

  // ══════════════════════════════════════
  // 사운드 이벤트 API
  // ══════════════════════════════════════

  /// 점프
  void playJump() {
    if (!_canPlay('jump')) return;
    // FlameAudio.play('jump.wav', volume: sfxVolume);
  }

  /// 코인 수집
  void playCoinCollect({bool isBig = false}) {
    if (!_canPlay('coin')) return;
    // FlameAudio.play(isBig ? 'coin_big.wav' : 'coin.wav', volume: sfxVolume);
  }

  /// 적 처치
  void playEnemyKill({bool isGolden = false}) {
    if (!_canPlay('enemy_kill')) return;
    // FlameAudio.play(isGolden ? 'enemy_gold.wav' : 'enemy_kill.wav', volume: sfxVolume);
  }

  /// 보스 피격
  void playBossHit() {
    if (!_canPlay('boss_hit')) return;
    // FlameAudio.play('boss_hit.wav', volume: sfxVolume);
  }

  /// 보스 처치
  void playBossKill() {
    if (!_canPlay('boss_kill')) return;
    // FlameAudio.play('boss_kill.wav', volume: sfxVolume);
  }

  /// 장애물 충돌
  void playObstacleHit() {
    if (!_canPlay('obstacle')) return;
    // FlameAudio.play('obstacle.wav', volume: sfxVolume);
  }

  /// 구매 성공
  void playPurchase() {
    if (!_canPlay('purchase')) return;
    // FlameAudio.play('purchase.wav', volume: sfxVolume);
  }

  /// 레벨업
  void playLevelUp() {
    if (!_canPlay('levelup')) return;
    // FlameAudio.play('levelup.wav', volume: sfxVolume);
  }

  /// 업적 달성
  void playAchievement() {
    if (!_canPlay('achievement')) return;
    // FlameAudio.play('achievement.wav', volume: sfxVolume);
  }

  /// 초월
  void playAscension() {
    if (!_canPlay('ascension')) return;
    // FlameAudio.play('ascension.wav', volume: sfxVolume);
  }

  /// 콤보 마일스톤
  void playComboMilestone(int combo) {
    if (!_canPlay('combo')) return;
    // 콤보 높을수록 피치 업
    // FlameAudio.play('combo.wav', volume: sfxVolume);
  }

  /// 보너스 스테이지 시작
  void playBonusStageStart() {
    if (!_canPlay('bonus')) return;
    // FlameAudio.play('bonus_start.wav', volume: sfxVolume);
  }

  /// 보물상자 오픈
  void playTreasureOpen() {
    if (!_canPlay('treasure')) return;
    // FlameAudio.play('treasure.wav', volume: sfxVolume);
  }

  /// UI 탭 (버튼 클릭)
  void playUITap() {
    if (!_canPlay('ui_tap')) return;
    // FlameAudio.play('ui_tap.wav', volume: sfxVolume * 0.5);
  }

  /// 동료 획득
  void playCompanionGet() {
    if (!_canPlay('companion')) return;
    // FlameAudio.play('companion_get.wav', volume: sfxVolume);
  }

  /// 일일 보너스 수령
  void playDailyClaim() {
    if (!_canPlay('daily')) return;
    // FlameAudio.play('daily_claim.wav', volume: sfxVolume);
  }

  /// 장착/해제
  void playEquip() {
    if (!_canPlay('equip')) return;
    // FlameAudio.play('equip.wav', volume: sfxVolume * 0.7);
  }
}
