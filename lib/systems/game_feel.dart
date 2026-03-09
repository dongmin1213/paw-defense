import 'dart:math';
import 'package:flame/components.dart';
import '../game/runner_game.dart';
import '../components/enemy.dart';
import '../data/enemy_data.dart';

/// 게임필 시스템 — 스크린쉐이크, 히트스탑, 슬로모션, 줌 펀치
/// Idle Slayer / Skul 수준의 타격감과 피드백
class GameFeelSystem extends Component with HasGameReference<RunnerGame> {
  // ── 스크린 쉐이크 ──
  double _shakeTimer = 0;
  double _shakeIntensity = 0;
  double _shakeFrequency = 40;
  Vector2 shakeOffset = Vector2.zero();

  // ── 히트스탑 (프레임 프리즈) ──
  double _hitStopTimer = 0;
  bool get isHitStopped => _hitStopTimer > 0;

  // ── 슬로모션 ──
  double _slowMotionTimer = 0;
  double _slowMotionScale = 1.0;
  double get timeScale => _slowMotionTimer > 0 ? _slowMotionScale : 1.0;

  // ── 줌 펀치 ──
  double _zoomPunchTimer = 0;
  double _zoomPunchTarget = 1.0;
  double currentZoom = 1.0;

  // ── 콤보 마일스톤 ──
  int _lastComboMilestone = 0;

  // ── 자동 시스템 ──
  double _autoUpgradeTimer = 0;
  double _autoAirKillTimer = 0;

  final Random _rng = Random();

  @override
  void update(double dt) {
    _updateShake(dt);
    _updateHitStop(dt);
    _updateSlowMotion(dt);
    _updateZoomPunch(dt);
    _updateComboFeedback();
    _updateAutoSystems(dt);
  }

  // ══════════════════════════════════════
  // 스크린 쉐이크
  // ══════════════════════════════════════

  /// 스크린 쉐이크 트리거
  /// [intensity]: 흔들림 강도 (px), [duration]: 지속 시간 (초)
  void shake({double intensity = 4.0, double duration = 0.2, double frequency = 40}) {
    if (intensity > _shakeIntensity) {
      _shakeIntensity = intensity;
      _shakeTimer = duration;
      _shakeFrequency = frequency;
    }
  }

  /// 적 처치 시 — 콤보에 비례하여 쉐이크 증폭
  void onEnemyKill({bool isGolden = false, bool isAir = false}) {
    final comboScale = 1.0 + game.combo * 0.03; // 콤보 30 = 1.9x
    if (isGolden) {
      shake(intensity: 7 * comboScale, duration: 0.3);
      hitStop(duration: 0.08);
      zoomPunch(targetZoom: 1.03, duration: 0.2);
    } else if (isAir) {
      shake(intensity: 3.5 * comboScale, duration: 0.15);
      hitStop(duration: 0.03);
    } else {
      shake(intensity: 2 * comboScale, duration: 0.1);
    }
  }

  /// 보스 피격
  void onBossHit() {
    shake(intensity: 4, duration: 0.12);
    hitStop(duration: 0.04);
  }

  /// 보스 처치 — 극적 연출
  void onBossKill() {
    shake(intensity: 15, duration: 0.6, frequency: 25);
    hitStop(duration: 0.25);
    slowMotion(scale: 0.2, duration: 1.0);
    zoomPunch(targetZoom: 1.08, duration: 0.5);
  }

  /// 착지 임팩트
  void onLanding() {
    shake(intensity: 1.5, duration: 0.06);
  }

  /// 장애물 충돌
  void onObstacleHit() {
    shake(intensity: 8, duration: 0.3, frequency: 35);
  }

  /// 초월
  void onAscension() {
    shake(intensity: 15, duration: 1.0, frequency: 25);
    slowMotion(scale: 0.2, duration: 1.5);
  }

  void _updateShake(double dt) {
    if (_shakeTimer > 0) {
      _shakeTimer -= dt;
      final progress = (_shakeTimer).clamp(0.0, 1.0);
      final decay = progress; // 선형 감쇠
      final angle = _shakeTimer * _shakeFrequency * 2 * pi;
      shakeOffset = Vector2(
        sin(angle) * _shakeIntensity * decay,
        cos(angle * 1.3) * _shakeIntensity * decay * 0.7,
      );
      if (_shakeTimer <= 0) {
        shakeOffset = Vector2.zero();
        _shakeIntensity = 0;
      }
    }
  }

  // ══════════════════════════════════════
  // 히트스탑
  // ══════════════════════════════════════

  void hitStop({double duration = 0.05}) {
    _hitStopTimer = duration;
  }

  void _updateHitStop(double dt) {
    if (_hitStopTimer > 0) {
      _hitStopTimer -= dt;
    }
  }

  // ══════════════════════════════════════
  // 슬로모션
  // ══════════════════════════════════════

  void slowMotion({double scale = 0.5, double duration = 0.5}) {
    _slowMotionScale = scale;
    _slowMotionTimer = duration;
  }

  void _updateSlowMotion(double dt) {
    if (_slowMotionTimer > 0) {
      _slowMotionTimer -= dt;
    }
  }

  // ══════════════════════════════════════
  // 줌 펀치
  // ══════════════════════════════════════

  void zoomPunch({double targetZoom = 1.05, double duration = 0.3}) {
    _zoomPunchTarget = targetZoom;
    _zoomPunchTimer = duration;
  }

  void _updateZoomPunch(double dt) {
    if (_zoomPunchTimer > 0) {
      _zoomPunchTimer -= dt;
      final t = (_zoomPunchTimer / 0.3).clamp(0.0, 1.0);
      currentZoom = 1.0 + (_zoomPunchTarget - 1.0) * _easeOutElastic(1.0 - t);
      if (_zoomPunchTimer <= 0) {
        currentZoom = 1.0;
      }
    }
  }

  double _easeOutElastic(double t) {
    if (t == 0 || t == 1) return t;
    return pow(2, -10 * t) * sin((t - 0.1) * 5 * pi) + 1;
  }

  // ══════════════════════════════════════
  // 콤보 피드백
  // ══════════════════════════════════════

  void _updateComboFeedback() {
    final combo = game.combo;
    final milestone = (combo ~/ 10) * 10;
    if (milestone > 0 && milestone > _lastComboMilestone) {
      _lastComboMilestone = milestone;
      // 마일스톤이 높을수록 더 강한 피드백
      final tier = (milestone / 10).clamp(1, 5).toDouble();
      shake(intensity: 4 + tier * 2, duration: 0.15 + tier * 0.03);
      zoomPunch(targetZoom: 1.02 + tier * 0.01, duration: 0.25);
      if (milestone >= 30) {
        hitStop(duration: 0.06);
        slowMotion(scale: 0.7, duration: 0.3);
      }
    }
    if (combo == 0) {
      _lastComboMilestone = 0;
    }
  }

  // ══════════════════════════════════════
  // 자동 시스템 (소울 업그레이드 효과)
  // ══════════════════════════════════════

  void _updateAutoSystems(double dt) {
    // 자동 업그레이드 — 소울 업그레이드 해금 시 작동
    if (game.ascensionManager.hasAutoUpgrade) {
      _autoUpgradeTimer += dt;
      if (_autoUpgradeTimer >= 2.0) {
        _autoUpgradeTimer = 0;
        _tryAutoUpgrade();
      }
    }

    // 자동 공중 처치 — 방치 모드에서 공중 적 자동 처치
    if (game.ascensionManager.hasAutoAirKill && !game.isActiveMode) {
      _autoAirKillTimer += dt;
      if (_autoAirKillTimer >= 1.0) {
        _autoAirKillTimer = 0;
        _tryAutoAirKill();
      }
    }
  }

  void _tryAutoAirKill() {
    // 화면 내 공중 적 중 가장 가까운 하나를 자동 처치
    final cameraX = game.camera.viewfinder.position.x;
    final screenRight = cameraX + 800;

    Enemy? closest;
    double closestDist = double.infinity;

    for (final child in game.world.children) {
      if (child is Enemy &&
          child.data.type == EnemyType.air &&
          child.position.x > cameraX &&
          child.position.x < screenRight) {
        final dist = (child.position.x - game.player.position.x).abs();
        if (dist < closestDist) {
          closestDist = dist;
          closest = child;
        }
      }
    }

    if (closest != null) {
      closest.onHit(game.player);
    }
  }

  void _tryAutoUpgrade() {
    final manager = game.upgradeManager;
    final upgrades = [
      // 우선순위: 코인 > 공격 > 속도 > 점프 > 자석 > 콤보 > 더블점프
      'coinGain', 'attackPower', 'moveSpeed', 'jumpPower',
      'coinMagnet', 'comboRetain', 'doubleJump',
    ];

    for (final name in upgrades) {
      final id = manager.upgradeIdFromName(name);
      if (id != null && !manager.isMaxed(id) && manager.canAfford(id, game.coins)) {
        final cost = manager.buy(id, game.coins);
        if (cost > 0) {
          game.coins -= cost;
          game.applyUpgrades();
          break; // 한 번에 하나씩만
        }
      }
    }
  }
}
