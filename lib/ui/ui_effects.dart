import 'dart:math';
import 'package:flutter/material.dart';
import 'game_theme.dart';

/// UI 이펙트 매니저 — 구매/레벨업/수집 시 시각적 피드백
/// 모든 좌표는 화면 비율 (0.0~1.0) 기반으로 동작
class UIEffectManager {
  UIEffectManager._();
  static final instance = UIEffectManager._();

  final List<UIEffect> _effects = [];
  VoidCallback? _onUpdate;

  void setUpdateCallback(VoidCallback cb) => _onUpdate = cb;

  List<UIEffect> get effects => _effects;

  void _addEffect(UIEffect effect) {
    _effects.add(effect);
    _onUpdate?.call();
  }

  void update(double dt) {
    for (final e in _effects) {
      e.update(dt);
    }
    _effects.removeWhere((e) => e.isDone);
  }

  // ══════════════════════════════════════
  // 이펙트 생성 API
  // ══════════════════════════════════════

  /// 플로팅 텍스트 — [relX/relY]는 화면 비율 (0.0~1.0)
  void spawnFloatingText({
    required String text,
    Color color = GameTheme.accentGold,
    double fontSize = 12,
    double duration = 1.0,
    double riseSpeed = 40,
    double relX = 0.5,
    double relY = 0.4,
    Offset? position, // 레거시 호환 (무시됨)
  }) {
    _addEffect(FloatingTextEffect(
      text: text, relX: relX, relY: relY,
      color: color, fontSize: fontSize,
      duration: duration, riseSpeed: riseSpeed,
    ));
  }

  /// 화면 플래시
  void screenFlash({
    Color color = Colors.white,
    double duration = 0.3,
    double maxAlpha = 0.6,
  }) {
    _addEffect(ScreenFlashEffect(
      color: color, duration: duration, maxAlpha: maxAlpha,
    ));
  }

  /// 코인 날아가기 — 비율 좌표
  void spawnCoinFly({
    double fromRelX = 0.5,
    double fromRelY = 0.5,
    double toRelX = 0.85,
    double toRelY = 0.03,
    int count = 5,
    Color color = GameTheme.accentGold,
  }) {
    final rng = Random();
    for (var i = 0; i < count; i++) {
      _addEffect(CoinFlyEffect(
        fromRelX: fromRelX + (rng.nextDouble() - 0.5) * 0.04,
        fromRelY: fromRelY + (rng.nextDouble() - 0.5) * 0.04,
        toRelX: toRelX, toRelY: toRelY,
        delay: i * 0.05, color: color,
      ));
    }
  }

  /// 파티클 폭발 — 비율 좌표
  void spawnParticleBurst({
    Color color = GameTheme.accentGold,
    int count = 12,
    double spread = 60,
    double relX = 0.5,
    double relY = 0.5,
    Offset? position, // 레거시 호환 (무시됨)
  }) {
    final rng = Random();
    for (var i = 0; i < count; i++) {
      final angle = (i / count) * 2 * pi;
      final speed = 30 + rng.nextDouble() * spread;
      _addEffect(UIParticleEffect(
        relX: relX, relY: relY,
        velocity: Offset(cos(angle) * speed, sin(angle) * speed),
        color: color, size: 3 + rng.nextDouble() * 3,
        duration: 0.5 + rng.nextDouble() * 0.3,
      ));
    }
  }

  /// 임팩트 텍스트 (화면 중앙 대형)
  void spawnImpactText({
    required String text,
    Color color = GameTheme.accentGold,
    double fontSize = 24,
    double duration = 1.5,
  }) {
    _addEffect(ImpactTextEffect(
      text: text, color: color,
      fontSize: fontSize, duration: duration,
    ));
  }

  /// 글로우 링 — 비율 좌표
  void spawnGlowRing({
    Color color = GameTheme.accentGold,
    double duration = 0.6,
    double relX = 0.5,
    double relY = 0.5,
    Offset? center, // 레거시 호환 (무시됨)
  }) {
    _addEffect(GlowRingEffect(
      relX: relX, relY: relY,
      color: color, duration: duration,
    ));
  }

  /// 업적 달성 토스트
  void showAchievementToast({
    required String name,
    required String description,
    double coinReward = 0,
    int soulReward = 0,
  }) {
    _addEffect(AchievementToastEffect(
      name: name, description: description,
      coinReward: coinReward, soulReward: soulReward,
    ));
  }
}

// ══════════════════════════════════════
// 이펙트 기본 클래스
// ══════════════════════════════════════

abstract class UIEffect {
  double elapsed = 0;
  double get duration;
  bool get isDone => elapsed >= duration;
  double get progress => (elapsed / duration).clamp(0.0, 1.0);

  void update(double dt) => elapsed += dt;

  Widget build(BuildContext context, Size screenSize);
}

// ══════════════════════════════════════
// 플로팅 텍스트
// ══════════════════════════════════════

class FloatingTextEffect extends UIEffect {
  final String text;
  final double relX, relY;
  final Color color;
  final double fontSize;
  @override final double duration;
  final double riseSpeed;

  FloatingTextEffect({
    required this.text, required this.relX, required this.relY,
    required this.color, required this.fontSize,
    required this.duration, required this.riseSpeed,
  });

  @override
  Widget build(BuildContext context, Size s) {
    final alpha = (1.0 - progress).clamp(0.0, 1.0);
    final scale = 1.0 + progress * 0.3;

    return Positioned(
      left: s.width * relX - 40,
      top: s.height * relY - riseSpeed * progress,
      child: IgnorePointer(
        child: Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: alpha,
            child: Text(text, style: GameTheme.pixel(
              fontSize: fontSize, color: color,
              shadows: [
                Shadow(color: Colors.black.withValues(alpha: 0.8), blurRadius: 4),
                Shadow(color: color.withValues(alpha: 0.5), blurRadius: 8),
              ],
            )),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════
// 화면 플래시
// ══════════════════════════════════════

class ScreenFlashEffect extends UIEffect {
  final Color color;
  @override final double duration;
  final double maxAlpha;

  ScreenFlashEffect({required this.color, required this.duration, required this.maxAlpha});

  @override
  Widget build(BuildContext context, Size s) {
    final flash = progress < 0.3
        ? (progress / 0.3) * maxAlpha
        : maxAlpha * (1.0 - (progress - 0.3) / 0.7);
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(color: color.withValues(alpha: flash.clamp(0.0, maxAlpha))),
      ),
    );
  }
}

// ══════════════════════════════════════
// 코인 날아가기
// ══════════════════════════════════════

class CoinFlyEffect extends UIEffect {
  final double fromRelX, fromRelY, toRelX, toRelY;
  final double delay;
  final Color color;
  @override double get duration => 0.6 + delay;

  CoinFlyEffect({
    required this.fromRelX, required this.fromRelY,
    required this.toRelX, required this.toRelY,
    required this.delay, required this.color,
  });

  @override
  Widget build(BuildContext context, Size s) {
    final p = ((elapsed - delay) / 0.6).clamp(0.0, 1.0);
    if (p <= 0) return const SizedBox.shrink();

    final t = Curves.easeInCubic.transform(p);
    final x = s.width * (fromRelX + (toRelX - fromRelX) * t);
    final y = s.height * (fromRelY + (toRelY - fromRelY) * t) - sin(t * pi) * 30;
    final alpha = p < 0.8 ? 1.0 : (1.0 - (p - 0.8) / 0.2);
    final sz = 6.0 * (1.0 - p * 0.3);

    return Positioned(
      left: x - sz / 2, top: y - sz / 2,
      child: IgnorePointer(
        child: Opacity(
          opacity: alpha,
          child: Container(
            width: sz, height: sz,
            decoration: BoxDecoration(
              color: color,
              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 4)],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════
// UI 파티클
// ══════════════════════════════════════

class UIParticleEffect extends UIEffect {
  final double relX, relY;
  final Offset velocity;
  final Color color;
  final double size;
  @override final double duration;

  UIParticleEffect({
    required this.relX, required this.relY,
    required this.velocity, required this.color,
    required this.size, required this.duration,
  });

  @override
  Widget build(BuildContext context, Size s) {
    final alpha = (1.0 - progress).clamp(0.0, 1.0);
    final x = s.width * relX + velocity.dx * progress;
    final y = s.height * relY + velocity.dy * progress + 30 * progress * progress;
    final sz = size * (1.0 - progress * 0.5);

    return Positioned(
      left: x - sz / 2, top: y - sz / 2,
      child: IgnorePointer(
        child: Opacity(opacity: alpha, child: Container(width: sz, height: sz, color: color)),
      ),
    );
  }
}

// ══════════════════════════════════════
// 임팩트 텍스트 (화면 중앙 대형)
// ══════════════════════════════════════

class ImpactTextEffect extends UIEffect {
  final String text;
  final Color color;
  final double fontSize;
  @override final double duration;

  ImpactTextEffect({
    required this.text, required this.color,
    required this.fontSize, required this.duration,
  });

  @override
  Widget build(BuildContext context, Size s) {
    double alpha, scale;
    if (progress < 0.15) {
      final t = progress / 0.15;
      alpha = t;
      scale = 0.5 + Curves.easeOutBack.transform(t) * 0.5;
    } else if (progress < 0.6) {
      alpha = 1.0;
      scale = 1.0;
    } else {
      final t = (progress - 0.6) / 0.4;
      alpha = 1.0 - t;
      scale = 1.0 + t * 0.2;
    }

    return Positioned(
      left: 0, right: 0, top: s.height * 0.3,
      child: IgnorePointer(
        child: Center(
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: alpha.clamp(0.0, 1.0),
              child: Text(text, textAlign: TextAlign.center, style: GameTheme.pixel(
                fontSize: fontSize, color: color, letterSpacing: 3,
                shadows: [
                  Shadow(color: Colors.black, blurRadius: 8),
                  Shadow(color: color.withValues(alpha: 0.8), blurRadius: 16),
                  Shadow(color: color.withValues(alpha: 0.4), blurRadius: 32),
                ],
              )),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════
// 글로우 링
// ══════════════════════════════════════

class GlowRingEffect extends UIEffect {
  final double relX, relY;
  final Color color;
  @override final double duration;

  GlowRingEffect({
    required this.relX, required this.relY,
    required this.color, required this.duration,
  });

  @override
  Widget build(BuildContext context, Size s) {
    final size = 20 + progress * 60;
    final alpha = (1.0 - progress).clamp(0.0, 0.6);
    final bw = 3.0 * (1.0 - progress);
    final cx = s.width * relX;
    final cy = s.height * relY;

    return Positioned(
      left: cx - size / 2, top: cy - size / 2,
      child: IgnorePointer(
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: alpha), width: bw),
            boxShadow: [BoxShadow(color: color.withValues(alpha: alpha * 0.5), blurRadius: 12, spreadRadius: 2)],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════
// 업적 달성 토스트 (상단 슬라이드인)
// ══════════════════════════════════════

class AchievementToastEffect extends UIEffect {
  final String name, description;
  final double coinReward;
  final int soulReward;

  @override double get duration => 3.5;

  AchievementToastEffect({
    required this.name, required this.description,
    this.coinReward = 0, this.soulReward = 0,
  });

  @override
  Widget build(BuildContext context, Size s) {
    double slideY, alpha;
    if (progress < 0.1) {
      final t = Curves.easeOutCubic.transform(progress / 0.1);
      slideY = -60 + 60 * t;
      alpha = t;
    } else if (progress < 0.8) {
      slideY = 0;
      alpha = 1.0;
    } else {
      final t = (progress - 0.8) / 0.2;
      slideY = -60 * Curves.easeInCubic.transform(t);
      alpha = 1.0 - t;
    }

    return Positioned(
      top: 50 + slideY,
      left: s.width * 0.2, right: s.width * 0.2,
      child: IgnorePointer(
        child: Opacity(
          opacity: alpha.clamp(0.0, 1.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: GameTheme.bgPanel,
              border: Border.all(color: GameTheme.accentGold.withValues(alpha: 0.6), width: 2),
              boxShadow: [
                BoxShadow(color: GameTheme.accentGold.withValues(alpha: 0.3), blurRadius: 16, spreadRadius: 2),
                BoxShadow(color: GameTheme.pixelShadow.withValues(alpha: 0.8), offset: const Offset(3, 3), blurRadius: 0),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: GameTheme.accentGold.withValues(alpha: 0.2),
                    border: Border.all(color: GameTheme.accentGold.withValues(alpha: 0.5), width: 1.5),
                  ),
                  child: const Icon(Icons.emoji_events, color: GameTheme.accentGold, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('ACHIEVEMENT!', style: GameTheme.pixel(fontSize: 6, color: GameTheme.accentGold, letterSpacing: 1)),
                      const SizedBox(height: 2),
                      Text(name, style: const TextStyle(color: GameTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                if (coinReward > 0) ...[
                  const Icon(Icons.monetization_on, color: GameTheme.accentGold, size: 14),
                  const SizedBox(width: 3),
                  Text(GameTheme.formatNumber(coinReward), style: GameTheme.pixel(fontSize: 7, color: GameTheme.accentGold)),
                ],
                if (soulReward > 0) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.auto_awesome, color: GameTheme.accentPurple, size: 14),
                  const SizedBox(width: 3),
                  Text('$soulReward', style: GameTheme.pixel(fontSize: 7, color: GameTheme.accentPurple)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════
// UI 이펙트 오버레이 위젯
// ══════════════════════════════════════

class UIEffectOverlay extends StatefulWidget {
  final Widget child;
  const UIEffectOverlay({super.key, required this.child});

  @override
  State<UIEffectOverlay> createState() => _UIEffectOverlayState();
}

class _UIEffectOverlayState extends State<UIEffectOverlay>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _ticker.start();
    UIEffectManager.instance.setUpdateCallback(() {
      if (mounted) setState(() {});
    });
  }

  void _onTick(Duration elapsed) {
    final dt = (_lastTick == Duration.zero)
        ? 0.016
        : (elapsed - _lastTick).inMicroseconds / 1000000.0;
    _lastTick = elapsed;

    final manager = UIEffectManager.instance;
    if (manager.effects.isNotEmpty) {
      manager.update(dt);
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effects = UIEffectManager.instance.effects;
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        widget.child,
        if (effects.isNotEmpty)
          ...effects.map((e) => e.build(context, screenSize)),
      ],
    );
  }
}
