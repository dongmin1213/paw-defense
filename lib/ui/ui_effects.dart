import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'game_theme.dart';

/// UI 이펙트 매니저 — 구매/레벨업/수집 시 시각적 피드백
/// Flutter 오버레이 레벨에서 동작하는 이펙트 시스템
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

  /// 플로팅 텍스트 (+코인, +소울, 데미지 등)
  void spawnFloatingText({
    required String text,
    required Offset position,
    Color color = GameTheme.accentGold,
    double fontSize = 12,
    double duration = 1.0,
    double riseSpeed = 40,
  }) {
    _addEffect(FloatingTextEffect(
      text: text,
      position: position,
      color: color,
      fontSize: fontSize,
      duration: duration,
      riseSpeed: riseSpeed,
    ));
  }

  /// 화면 플래시 (보스 처치, 초월 등)
  void screenFlash({
    Color color = Colors.white,
    double duration = 0.3,
    double maxAlpha = 0.6,
  }) {
    _addEffect(ScreenFlashEffect(
      color: color,
      duration: duration,
      maxAlpha: maxAlpha,
    ));
  }

  /// 코인 날아가기 (구매 후 코인 아이콘이 HUD로 날아감)
  void spawnCoinFly({
    required Offset from,
    required Offset to,
    int count = 5,
    Color color = GameTheme.accentGold,
  }) {
    final rng = Random();
    for (var i = 0; i < count; i++) {
      final delay = i * 0.05;
      final offset = Offset(
        rng.nextDouble() * 30 - 15,
        rng.nextDouble() * 30 - 15,
      );
      _addEffect(CoinFlyEffect(
        from: from + offset,
        to: to,
        delay: delay,
        color: color,
      ));
    }
  }

  /// 파티클 폭발 (구매 성공, 업적 달성 등)
  void spawnParticleBurst({
    required Offset position,
    Color color = GameTheme.accentGold,
    int count = 12,
    double spread = 60,
  }) {
    final rng = Random();
    for (var i = 0; i < count; i++) {
      final angle = (i / count) * 2 * pi;
      final speed = 30 + rng.nextDouble() * spread;
      _addEffect(UIParticleEffect(
        position: position,
        velocity: Offset(cos(angle) * speed, sin(angle) * speed),
        color: color,
        size: 3 + rng.nextDouble() * 3,
        duration: 0.5 + rng.nextDouble() * 0.3,
      ));
    }
  }

  /// 텍스트 펀치 (중앙 대형 텍스트 — BOSS KILL!, COMBO x10!)
  void spawnImpactText({
    required String text,
    Color color = GameTheme.accentGold,
    double fontSize = 24,
    double duration = 1.5,
  }) {
    _addEffect(ImpactTextEffect(
      text: text,
      color: color,
      fontSize: fontSize,
      duration: duration,
    ));
  }

  /// 글로우 링 (레벨업/장착 시)
  void spawnGlowRing({
    required Offset center,
    Color color = GameTheme.accentGold,
    double duration = 0.6,
  }) {
    _addEffect(GlowRingEffect(
      center: center,
      color: color,
      duration: duration,
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

  void update(double dt) {
    elapsed += dt;
  }

  Widget build(BuildContext context, Size screenSize);
}

// ══════════════════════════════════════
// 플로팅 텍스트
// ══════════════════════════════════════

class FloatingTextEffect extends UIEffect {
  final String text;
  final Offset position;
  final Color color;
  final double fontSize;
  @override
  final double duration;
  final double riseSpeed;

  FloatingTextEffect({
    required this.text,
    required this.position,
    required this.color,
    required this.fontSize,
    required this.duration,
    required this.riseSpeed,
  });

  @override
  Widget build(BuildContext context, Size screenSize) {
    final alpha = (1.0 - progress).clamp(0.0, 1.0);
    final scale = 1.0 + progress * 0.3;
    final yOffset = -riseSpeed * progress;

    return Positioned(
      left: position.dx - 40,
      top: position.dy + yOffset,
      child: IgnorePointer(
        child: Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: alpha,
            child: Text(
              text,
              style: GameTheme.pixel(
                fontSize: fontSize,
                color: color,
                shadows: [
                  Shadow(color: Colors.black.withValues(alpha: 0.8), blurRadius: 4),
                  Shadow(color: color.withValues(alpha: 0.5), blurRadius: 8),
                ],
              ),
            ),
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
  @override
  final double duration;
  final double maxAlpha;

  ScreenFlashEffect({
    required this.color,
    required this.duration,
    required this.maxAlpha,
  });

  @override
  Widget build(BuildContext context, Size screenSize) {
    // 빠르게 나타났다 사라짐
    final flash = progress < 0.3
        ? (progress / 0.3) * maxAlpha
        : maxAlpha * (1.0 - (progress - 0.3) / 0.7);

    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: color.withValues(alpha: flash.clamp(0.0, maxAlpha)),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════
// 코인 날아가기
// ══════════════════════════════════════

class CoinFlyEffect extends UIEffect {
  final Offset from;
  final Offset to;
  final double delay;
  final Color color;
  @override
  double get duration => 0.6 + delay;

  CoinFlyEffect({
    required this.from,
    required this.to,
    required this.delay,
    required this.color,
  });

  @override
  Widget build(BuildContext context, Size screenSize) {
    final adjustedProgress = ((elapsed - delay) / 0.6).clamp(0.0, 1.0);
    if (adjustedProgress <= 0) return const SizedBox.shrink();

    // 이징 곡선
    final t = Curves.easeInCubic.transform(adjustedProgress);
    final x = from.dx + (to.dx - from.dx) * t;
    final y = from.dy + (to.dy - from.dy) * t - sin(t * pi) * 30;
    final alpha = adjustedProgress < 0.8 ? 1.0 : (1.0 - (adjustedProgress - 0.8) / 0.2);
    final size = 6.0 * (1.0 - adjustedProgress * 0.3);

    return Positioned(
      left: x - size / 2,
      top: y - size / 2,
      child: IgnorePointer(
        child: Opacity(
          opacity: alpha,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 4),
              ],
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
  final Offset position;
  final Offset velocity;
  final Color color;
  final double size;
  @override
  final double duration;

  UIParticleEffect({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.duration,
  });

  @override
  Widget build(BuildContext context, Size screenSize) {
    final alpha = (1.0 - progress).clamp(0.0, 1.0);
    final x = position.dx + velocity.dx * progress;
    final y = position.dy + velocity.dy * progress + 30 * progress * progress;
    final s = size * (1.0 - progress * 0.5);

    return Positioned(
      left: x - s / 2,
      top: y - s / 2,
      child: IgnorePointer(
        child: Opacity(
          opacity: alpha,
          child: Container(
            width: s,
            height: s,
            color: color,
          ),
        ),
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
  @override
  final double duration;

  ImpactTextEffect({
    required this.text,
    required this.color,
    required this.fontSize,
    required this.duration,
  });

  @override
  Widget build(BuildContext context, Size screenSize) {
    // 빠르게 등장 → 유지 → 페이드아웃
    double alpha;
    double scale;
    if (progress < 0.15) {
      // 등장: 커지면서 나타남
      final t = progress / 0.15;
      alpha = t;
      scale = 0.5 + Curves.easeOutBack.transform(t) * 0.5;
    } else if (progress < 0.6) {
      alpha = 1.0;
      scale = 1.0;
    } else {
      // 페이드아웃
      final t = (progress - 0.6) / 0.4;
      alpha = 1.0 - t;
      scale = 1.0 + t * 0.2;
    }

    return Positioned(
      left: 0,
      right: 0,
      top: screenSize.height * 0.3,
      child: IgnorePointer(
        child: Center(
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: alpha.clamp(0.0, 1.0),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: GameTheme.pixel(
                  fontSize: fontSize,
                  color: color,
                  letterSpacing: 3,
                  shadows: [
                    Shadow(color: Colors.black, blurRadius: 8),
                    Shadow(color: color.withValues(alpha: 0.8), blurRadius: 16),
                    Shadow(color: color.withValues(alpha: 0.4), blurRadius: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════
// 글로우 링 (레벨업/장착)
// ══════════════════════════════════════

class GlowRingEffect extends UIEffect {
  final Offset center;
  final Color color;
  @override
  final double duration;

  GlowRingEffect({
    required this.center,
    required this.color,
    required this.duration,
  });

  @override
  Widget build(BuildContext context, Size screenSize) {
    final size = 20 + progress * 60;
    final alpha = (1.0 - progress).clamp(0.0, 0.6);
    final borderWidth = 3.0 * (1.0 - progress);

    return Positioned(
      left: center.dx - size / 2,
      top: center.dy - size / 2,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: alpha),
              width: borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: alpha * 0.5),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
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
