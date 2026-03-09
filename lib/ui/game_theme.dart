import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The Bichon's Run — 통합 게임 UI 테마 시스템
/// 픽셀 아트 + 레트로 게임 스타일 디자인 시스템
class GameTheme {
  GameTheme._();

  // ── 핵심 색상 팔레트 ──
  static const Color bgDeep = Color(0xFF0D0D1A);
  static const Color bgDark = Color(0xFF141428);
  static const Color bgPanel = Color(0xFF1C1C3A);
  static const Color bgCard = Color(0xFF222244);
  static const Color bgCardHover = Color(0xFF2A2A55);

  static const Color accent = Color(0xFF4FC3F7);
  static const Color accentGold = Color(0xFFFFD54F);
  static const Color accentPurple = Color(0xFFBA68C8);
  static const Color accentGreen = Color(0xFF66BB6A);
  static const Color accentRed = Color(0xFFEF5350);
  static const Color accentOrange = Color(0xFFFF9800);

  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0B0C0);
  static const Color textMuted = Color(0xFF6A6A80);
  static const Color textGold = Color(0xFFFFD54F);

  // ── 레어도 색상 ──
  static const Color rarityCommon = Color(0xFF9E9E9E);
  static const Color rarityRare = Color(0xFF42A5F5);
  static const Color rarityEpic = Color(0xFFAB47BC);
  static const Color rarityLegendary = Color(0xFFFFD600);

  // ── 픽셀 아트 전용 색상 ──
  static const Color pixelHighlight = Color(0xFF5A5A8A);
  static const Color pixelShadow = Color(0xFF050510);
  static const Color pixelBorder = Color(0xFF3A3A5C);

  // ── 그라디언트 ──
  static const LinearGradient gradientPrimary = LinearGradient(
    colors: [Color(0xFF4FC3F7), Color(0xFF2196F3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientGold = LinearGradient(
    colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientPurple = LinearGradient(
    colors: [Color(0xFFCE93D8), Color(0xFF7B1FA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientGreen = LinearGradient(
    colors: [Color(0xFF81C784), Color(0xFF388E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientRed = LinearGradient(
    colors: [Color(0xFFEF5350), Color(0xFFC62828)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientDark = LinearGradient(
    colors: [Color(0xFF1C1C3A), Color(0xFF0D0D1A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ══════════════════════════════════════════
  // ── 픽셀 폰트 시스템 ──
  // ══════════════════════════════════════════

  /// 픽셀 폰트 (영문/숫자 전용 - Press Start 2P)
  static TextStyle pixel({
    double fontSize = 10,
    Color color = textPrimary,
    FontWeight fontWeight = FontWeight.w400,
    double? letterSpacing,
    double? height,
    List<Shadow>? shadows,
  }) {
    return GoogleFonts.pressStart2p(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height ?? 1.4,
      shadows: shadows,
    );
  }

  /// 게임 UI 폰트 (Silkscreen - 더 읽기 쉬운 픽셀 폰트)
  static TextStyle gameFont({
    double fontSize = 12,
    Color color = textPrimary,
    FontWeight fontWeight = FontWeight.w400,
    double? letterSpacing,
    double? height,
    List<Shadow>? shadows,
  }) {
    return GoogleFonts.silkscreen(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height ?? 1.3,
      shadows: shadows,
    );
  }

  // ── 픽셀 텍스트 스타일 프리셋 ──
  static TextStyle get pixelTitleLarge => pixel(
        fontSize: 18,
        color: textPrimary,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
        height: 1.2,
      );

  static TextStyle get pixelTitleMedium => pixel(
        fontSize: 12,
        color: textPrimary,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      );

  static TextStyle get pixelTitleSmall => pixel(
        fontSize: 9,
        color: textPrimary,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get pixelLabel => pixel(
        fontSize: 7,
        color: textSecondary,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get pixelNumber => pixel(
        fontSize: 14,
        color: textGold,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      );

  // ── 한글 호환 텍스트 스타일 (기존 유지) ──
  static const TextStyle titleLarge = TextStyle(
    color: textPrimary,
    fontSize: 32,
    fontWeight: FontWeight.w900,
    letterSpacing: 2,
    height: 1.2,
  );

  static const TextStyle titleMedium = TextStyle(
    color: textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: 1,
  );

  static const TextStyle titleSmall = TextStyle(
    color: textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle bodyLarge = TextStyle(
    color: textSecondary,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle bodySmall = TextStyle(
    color: textMuted,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle labelBold = TextStyle(
    color: textPrimary,
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle numberLarge = TextStyle(
    color: textGold,
    fontSize: 28,
    fontWeight: FontWeight.w900,
    letterSpacing: 1,
  );

  // ══════════════════════════════════════════
  // ── 픽셀 아트 장식 ──
  // ══════════════════════════════════════════

  /// RPG 스타일 픽셀 패널 (3D 돌출 효과)
  static BoxDecoration pixelPanelDecoration({
    Color? fillColor,
    Color? borderColor,
    bool raised = true,
    bool glow = false,
    Color? glowColor,
  }) {
    final fill = fillColor ?? bgPanel;
    final highlight = raised
        ? Colors.white.withValues(alpha: 0.12)
        : pixelShadow;
    final shadow = raised
        ? pixelShadow
        : Colors.white.withValues(alpha: 0.08);

    return BoxDecoration(
      color: fill,
      border: Border(
        top: BorderSide(color: highlight, width: 2),
        left: BorderSide(color: highlight, width: 2),
        bottom: BorderSide(color: shadow, width: 3),
        right: BorderSide(color: shadow, width: 3),
      ),
      boxShadow: [
        if (glow)
          BoxShadow(
            color: (glowColor ?? accent).withValues(alpha: 0.3),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        BoxShadow(
          color: pixelShadow.withValues(alpha: 0.8),
          offset: const Offset(3, 3),
          blurRadius: 0,
        ),
      ],
    );
  }

  /// 픽셀 카드 장식
  static BoxDecoration pixelCardDecoration({
    Color? fillColor,
    Color? borderColor,
    bool selected = false,
    bool glow = false,
    Color? glowColor,
  }) {
    final fill = fillColor ?? bgCard;
    final border =
        borderColor ?? (selected ? accentGold : pixelBorder);

    return BoxDecoration(
      color: fill,
      border: Border.all(color: border, width: selected ? 2 : 1.5),
      boxShadow: [
        if (glow)
          BoxShadow(
            color: (glowColor ?? accent).withValues(alpha: 0.25),
            blurRadius: 8,
          ),
        BoxShadow(
          color: pixelShadow.withValues(alpha: 0.6),
          offset: const Offset(2, 2),
          blurRadius: 0,
        ),
      ],
    );
  }

  // ── 기존 장식 (하위 호환) ──
  static BoxDecoration panelDecoration({
    Color? color,
    Color? borderColor,
    double borderRadius = 16,
    double borderWidth = 1.5,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: color ?? bgPanel.withValues(alpha: 0.95),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? accent.withValues(alpha: 0.15),
        width: borderWidth,
      ),
      boxShadow: shadows ?? [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration cardDecoration({
    Color? color,
    Color? borderColor,
    double borderRadius = 12,
    bool glow = false,
    Color? glowColor,
  }) {
    return BoxDecoration(
      color: color ?? bgCard,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? Colors.white.withValues(alpha: 0.06),
        width: 1,
      ),
      boxShadow: glow
          ? [
              BoxShadow(
                color: (glowColor ?? accent).withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ]
          : null,
    );
  }

  static BoxDecoration glassDecoration({
    double opacity = 0.12,
    double borderRadius = 12,
  }) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withValues(alpha: opacity * 2),
        width: 0.5,
      ),
    );
  }

  // ══════════════════════════════════════════
  // ── 픽셀 아트 위젯 ──
  // ══════════════════════════════════════════

  /// 픽셀 아트 게임 버튼 (3D 돌출 + 눌림 효과)
  static Widget pixelButton({
    required String label,
    required VoidCallback? onTap,
    LinearGradient? gradient,
    Color? color,
    IconData? icon,
    double fontSize = 9,
    double verticalPad = 10,
    double horizontalPad = 20,
    bool enabled = true,
    bool usePixelFont = true,
  }) {
    final isEnabled = onTap != null && enabled;
    return _PixelButtonWidget(
      label: label,
      onTap: isEnabled ? onTap : null,
      gradient: isEnabled ? gradient : null,
      color: isEnabled ? (color ?? accent) : const Color(0xFF3A3A50),
      icon: icon,
      fontSize: fontSize,
      verticalPad: verticalPad,
      horizontalPad: horizontalPad,
      enabled: isEnabled,
      usePixelFont: usePixelFont,
    );
  }

  /// 픽셀 프로그레스 바
  static Widget pixelProgressBar({
    required double value,
    double height = 10,
    Color? fillColor,
    LinearGradient? fillGradient,
    Color bgColor = const Color(0xFF1A1A2E),
  }) {
    final clamped = value.clamp(0.0, 1.0);
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: pixelBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: pixelShadow.withValues(alpha: 0.5),
            offset: const Offset(1, 1),
            blurRadius: 0,
          ),
        ],
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: clamped,
          child: Container(
            decoration: BoxDecoration(
              gradient: fillGradient ??
                  LinearGradient(
                    colors: [
                      fillColor ?? accent,
                      (fillColor ?? accent).withValues(alpha: 0.8),
                    ],
                  ),
              boxShadow: [
                BoxShadow(
                  color: (fillColor ?? accent).withValues(alpha: 0.4),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 픽셀 스타일 정보 칩
  static Widget pixelChip({
    required String value,
    IconData? icon,
    Color color = textPrimary,
    double fontSize = 8,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: pixelCardDecoration(
        fillColor: bgDeep.withValues(alpha: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: fontSize + 6),
            const SizedBox(width: 5),
          ],
          Text(
            value,
            style: pixel(fontSize: fontSize, color: color),
          ),
        ],
      ),
    );
  }

  /// 픽셀 통화 표시
  static Widget pixelCurrency({
    required String value,
    bool isSoul = false,
    double fontSize = 9,
  }) {
    final color = isSoul ? accentPurple : accentGold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: pixelCardDecoration(
        fillColor: bgDeep.withValues(alpha: 0.7),
        borderColor: color.withValues(alpha: 0.3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSoul ? Icons.auto_awesome : Icons.monetization_on,
            color: color,
            size: fontSize + 6,
          ),
          const SizedBox(width: 5),
          Text(
            value,
            style: pixel(fontSize: fontSize, color: color),
          ),
        ],
      ),
    );
  }

  // ── 기존 위젯 (하위 호환) ──

  static Widget gameButton({
    required String label,
    required VoidCallback? onTap,
    LinearGradient? gradient,
    Color? color,
    IconData? icon,
    double fontSize = 16,
    double verticalPad = 14,
    double horizontalPad = 32,
    double borderRadius = 25,
    bool compact = false,
    bool enabled = true,
  }) {
    final isEnabled = onTap != null && enabled;
    final effectiveGradient = isEnabled ? gradient : null;
    final effectiveColor =
        isEnabled ? (color ?? accent) : const Color(0xFF3A3A50);

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 16 : horizontalPad,
          vertical: compact ? 8 : verticalPad,
        ),
        decoration: BoxDecoration(
          gradient: effectiveGradient,
          color: effectiveGradient == null ? effectiveColor : null,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: (effectiveGradient?.colors.first ?? effectiveColor)
                        .withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  color: isEnabled ? Colors.white : textMuted,
                  size: fontSize + 2),
              SizedBox(width: compact ? 4 : 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: isEnabled ? Colors.white : textMuted,
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget infoChip({
    required String value,
    IconData? icon,
    Color color = textPrimary,
    double fontSize = 14,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: glassDecoration(opacity: 0.15, borderRadius: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: fontSize + 2),
            const SizedBox(width: 6),
          ],
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  static Widget progressBar({
    required double value,
    double height = 6,
    Color? fillColor,
    LinearGradient? fillGradient,
    Color bgColor = const Color(0xFF2A2A40),
    double borderRadius = 3,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: fillGradient ??
                LinearGradient(
                  colors: [
                    fillColor ?? accent,
                    (fillColor ?? accent).withValues(alpha: 0.7),
                  ],
                ),
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: (fillColor ?? accent).withValues(alpha: 0.4),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget sectionHeader({
    required String title,
    Widget? trailing,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 18,
            decoration: BoxDecoration(
              color: color ?? accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: titleSmall.copyWith(color: color ?? accent),
          ),
          if (trailing != null) ...[
            const Spacer(),
            trailing,
          ],
        ],
      ),
    );
  }

  static Widget closeButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: pixelCardDecoration(
          fillColor: Colors.white.withValues(alpha: 0.08),
          borderColor: Colors.white.withValues(alpha: 0.15),
        ),
        child: const Icon(
          Icons.close,
          color: textSecondary,
          size: 18,
        ),
      ),
    );
  }

  static Widget currencyDisplay({
    required String value,
    bool isSoul = false,
    double fontSize = 18,
  }) {
    return pixelCurrency(
      value: value,
      isSoul: isSoul,
      fontSize: (fontSize * 0.5).clamp(8, 12).toDouble(),
    );
  }

  // ══════════════════════════════════════════
  // ── 유틸리티 ──
  // ══════════════════════════════════════════

  static String formatNumber(double n) {
    if (n >= 1e12) return '${(n / 1e12).toStringAsFixed(1)}T';
    if (n >= 1e9) return '${(n / 1e9).toStringAsFixed(1)}B';
    if (n >= 1e6) return '${(n / 1e6).toStringAsFixed(1)}M';
    if (n >= 1e3) return '${(n / 1e3).toStringAsFixed(1)}K';
    return n.toInt().toString();
  }

  static String formatInt(int n) => formatNumber(n.toDouble());

  static Color rarityToColor(String rarity) {
    switch (rarity) {
      case 'common':
        return rarityCommon;
      case 'rare':
        return rarityRare;
      case 'epic':
        return rarityEpic;
      case 'legendary':
        return rarityLegendary;
      default:
        return rarityCommon;
    }
  }
}

// ══════════════════════════════════════════
// ── 픽셀 버튼 위젯 (3D 눌림 효과) ──
// ══════════════════════════════════════════

class _PixelButtonWidget extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final LinearGradient? gradient;
  final Color color;
  final IconData? icon;
  final double fontSize;
  final double verticalPad;
  final double horizontalPad;
  final bool enabled;
  final bool usePixelFont;

  const _PixelButtonWidget({
    required this.label,
    this.onTap,
    this.gradient,
    required this.color,
    this.icon,
    required this.fontSize,
    required this.verticalPad,
    required this.horizontalPad,
    required this.enabled,
    required this.usePixelFont,
  });

  @override
  State<_PixelButtonWidget> createState() => _PixelButtonWidgetState();
}

class _PixelButtonWidgetState extends State<_PixelButtonWidget> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final highlight = _pressed
        ? GameTheme.pixelShadow
        : Colors.white.withValues(alpha: 0.25);
    final shadow = _pressed
        ? Colors.white.withValues(alpha: 0.15)
        : GameTheme.pixelShadow;

    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap?.call();
            }
          : null,
      onTapCancel:
          widget.enabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        transform: _pressed
            ? (Matrix4.identity()..translate(2.0, 2.0))
            : Matrix4.identity(),
        padding: EdgeInsets.symmetric(
          horizontal: widget.horizontalPad,
          vertical: widget.verticalPad,
        ),
        decoration: BoxDecoration(
          gradient: widget.enabled ? widget.gradient : null,
          color: widget.gradient == null ? widget.color : null,
          border: Border(
            top: BorderSide(color: highlight, width: 2),
            left: BorderSide(color: highlight, width: 2),
            bottom: BorderSide(color: shadow, width: 3),
            right: BorderSide(color: shadow, width: 3),
          ),
          boxShadow: _pressed
              ? null
              : [
                  BoxShadow(
                    color: GameTheme.pixelShadow.withValues(alpha: 0.7),
                    offset: const Offset(3, 3),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon,
                  color: widget.enabled ? Colors.white : GameTheme.textMuted,
                  size: widget.fontSize + 4),
              const SizedBox(width: 6),
            ],
            Text(
              widget.label,
              style: widget.usePixelFont
                  ? GameTheme.pixel(
                      fontSize: widget.fontSize,
                      color: widget.enabled
                          ? Colors.white
                          : GameTheme.textMuted,
                    )
                  : TextStyle(
                      color: widget.enabled
                          ? Colors.white
                          : GameTheme.textMuted,
                      fontSize: widget.fontSize + 4,
                      fontWeight: FontWeight.w700,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════
// ── 애니메이션 헬퍼 위젯 ──
// ══════════════════════════════════════════

/// 스태거드 리스트 아이템 애니메이션
class StaggeredEntry extends StatefulWidget {
  final int index;
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset slideFrom;

  const StaggeredEntry({
    super.key,
    required this.index,
    required this.child,
    this.delay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 300),
    this.slideFrom = const Offset(0, 20),
  });

  @override
  State<StaggeredEntry> createState() => _StaggeredEntryState();
}

class _StaggeredEntryState extends State<StaggeredEntry>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: widget.slideFrom,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(widget.delay * widget.index, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Transform.translate(
          offset: _slide.value,
          child: Opacity(
            opacity: _fade.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// 쉬머/글로우 펄스 이펙트
class ShimmerGlow extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double intensity;
  final Duration duration;

  const ShimmerGlow({
    super.key,
    required this.child,
    this.glowColor = GameTheme.accentGold,
    this.intensity = 0.3,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerGlow> createState() => _ShimmerGlowState();
}

class _ShimmerGlowState extends State<ShimmerGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(
                    alpha: widget.intensity * _controller.value),
                blurRadius: 12 + _controller.value * 8,
                spreadRadius: _controller.value * 3,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// 레트로 스캔라인 오버레이
class RetroScanlines extends StatelessWidget {
  final double opacity;
  final Widget child;

  const RetroScanlines({
    super.key,
    this.opacity = 0.03,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _ScanlinePainter(opacity: opacity),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  final double opacity;
  _ScanlinePainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;
    for (var y = 0.0; y < size.height; y += 3) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 픽셀 스타일 반짝임 효과 (보물/레어 아이템용)
class PixelSparkle extends StatefulWidget {
  final Widget child;
  final Color color;
  final int sparkleCount;

  const PixelSparkle({
    super.key,
    required this.child,
    this.color = GameTheme.accentGold,
    this.sparkleCount = 4,
  });

  @override
  State<PixelSparkle> createState() => _PixelSparkleState();
}

class _PixelSparkleState extends State<PixelSparkle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            widget.child,
            ...List.generate(widget.sparkleCount, (i) {
              final rng = Random(i * 17);
              final phase = (i / widget.sparkleCount);
              final t = (_controller.value + phase) % 1.0;
              final alpha = sin(t * pi).clamp(0.0, 1.0);
              final x = rng.nextDouble() * 40 - 5;
              final y = rng.nextDouble() * 40 - 5;
              return Positioned(
                left: x,
                top: y,
                child: Opacity(
                  opacity: alpha * 0.8,
                  child: Container(
                    width: 3,
                    height: 3,
                    color: widget.color,
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

/// 애니메이션 유틸리티
class GameAnimations {
  GameAnimations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration dramatic = Duration(milliseconds: 1000);

  static const Curve easeOutBack = Curves.easeOutBack;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;
}
