import 'dart:math';
import 'package:flutter/material.dart';
// Fonts bundled locally: assets/fonts/PressStart2P, Silkscreen

/// Paw Defense — Professional Game UI Theme System
/// Unified design language with consistent hierarchy, spacing, and color.
class GameTheme {
  GameTheme._();

  // ══════════════════════════════════════════
  // ── Color Palette — Disciplined 4-color hierarchy ──
  // ══════════════════════════════════════════

  // Background layers (darkest → lightest)
  static const Color bgDeep = Color(0xFF080814);
  static const Color bgDark = Color(0xFF0E0E20);
  static const Color bgPanel = Color(0xFF161632);
  static const Color bgCard = Color(0xFF1E1E3C);
  static const Color bgCardHover = Color(0xFF262650);
  static const Color bgSurface = Color(0xFF2A2A52);

  // Primary accent — cool cyan
  static const Color accent = Color(0xFF4FC3F7);
  static const Color accentDark = Color(0xFF2196F3);

  // Semantic colors — warm, purposeful
  static const Color accentGold = Color(0xFFFFD54F);
  static const Color accentGoldDark = Color(0xFFFFA000);
  static const Color accentPurple = Color(0xFFCE93D8);
  static const Color accentPurpleDark = Color(0xFF9C27B0);
  static const Color accentGreen = Color(0xFF81C784);
  static const Color accentGreenDark = Color(0xFF388E3C);
  static const Color accentRed = Color(0xFFEF5350);
  static const Color accentRedDark = Color(0xFFC62828);
  static const Color accentOrange = Color(0xFFFFB74D);

  // Text hierarchy
  static const Color textPrimary = Color(0xFFF0F0F8);
  static const Color textSecondary = Color(0xFFA8A8C0);
  static const Color textMuted = Color(0xFF606078);
  static const Color textGold = Color(0xFFFFD54F);

  // Rarity tier colors
  static const Color rarityCommon = Color(0xFF8E8E9E);
  static const Color rarityRare = Color(0xFF42A5F5);
  static const Color rarityEpic = Color(0xFFCE93D8);
  static const Color rarityLegendary = Color(0xFFFFD54F);
  static const Color rarityMythic = Color(0xFFFF5252);

  // Pixel-art chrome
  static const Color pixelHighlight = Color(0xFF484870);
  static const Color pixelShadow = Color(0xFF040410);
  static const Color pixelBorder = Color(0xFF303058);

  // ══════════════════════════════════════════
  // ── Gradients ──
  // ══════════════════════════════════════════

  static const LinearGradient gradientPrimary = LinearGradient(
    colors: [Color(0xFF4FC3F7), Color(0xFF2196F3)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient gradientGold = LinearGradient(
    colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient gradientPurple = LinearGradient(
    colors: [Color(0xFFCE93D8), Color(0xFF7B1FA2)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient gradientGreen = LinearGradient(
    colors: [Color(0xFF81C784), Color(0xFF2E7D32)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient gradientRed = LinearGradient(
    colors: [Color(0xFFEF5350), Color(0xFFC62828)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient gradientDark = LinearGradient(
    colors: [Color(0xFF161632), Color(0xFF080814)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Subtle background vignette
  static const RadialGradient bgVignette = RadialGradient(
    center: Alignment.center,
    radius: 1.2,
    colors: [Color(0xFF12122A), Color(0xFF060612)],
  );

  // ══════════════════════════════════════════
  // ── Standard spacing ──
  // ══════════════════════════════════════════
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 12;
  static const double spacingLg = 16;
  static const double spacingXl = 24;
  static const double spacingXxl = 32;

  static const double radiusSm = 6;
  static const double radiusMd = 10;
  static const double radiusLg = 14;

  // ══════════════════════════════════════════
  // ── Typography ──
  // ══════════════════════════════════════════

  /// Pixel font for headings/numbers (Press Start 2P)
  static TextStyle pixel({
    double fontSize = 10,
    Color color = textPrimary,
    FontWeight fontWeight = FontWeight.w400,
    double? letterSpacing,
    double? height,
    List<Shadow>? shadows,
  }) {
    return TextStyle(
      fontFamily: 'PressStart2P',
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height ?? 1.4,
      shadows: shadows,
    );
  }

  /// Game UI font (Silkscreen — more readable pixel font)
  static TextStyle gameFont({
    double fontSize = 12,
    Color color = textPrimary,
    FontWeight fontWeight = FontWeight.w400,
    double? letterSpacing,
    double? height,
    List<Shadow>? shadows,
  }) {
    return TextStyle(
      fontFamily: 'Silkscreen',
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height ?? 1.3,
      shadows: shadows,
    );
  }

  // Presets
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

  // Korean-compatible text styles
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
  // ── Decorations ──
  // ══════════════════════════════════════════

  /// Professional panel with rounded corners + subtle depth
  static BoxDecoration pixelPanelDecoration({
    Color? fillColor,
    Color? borderColor,
    bool raised = true,
    bool glow = false,
    Color? glowColor,
  }) {
    final fill = fillColor ?? bgPanel;
    return BoxDecoration(
      color: fill,
      borderRadius: BorderRadius.circular(radiusMd),
      border: Border.all(
        color: borderColor ?? pixelBorder.withValues(alpha: 0.6),
        width: 1.5,
      ),
      boxShadow: [
        if (glow)
          BoxShadow(
            color: (glowColor ?? accent).withValues(alpha: 0.2),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4),
          offset: const Offset(0, 4),
          blurRadius: 12,
        ),
      ],
    );
  }

  /// Card with consistent rounded corners
  static BoxDecoration pixelCardDecoration({
    Color? fillColor,
    Color? borderColor,
    bool selected = false,
    bool glow = false,
    Color? glowColor,
  }) {
    final fill = fillColor ?? bgCard;
    final border =
        borderColor ?? (selected ? accentGold : pixelBorder.withValues(alpha: 0.4));

    return BoxDecoration(
      color: fill,
      borderRadius: BorderRadius.circular(radiusSm),
      border: Border.all(color: border, width: selected ? 2 : 1),
      boxShadow: [
        if (glow)
          BoxShadow(
            color: (glowColor ?? accent).withValues(alpha: 0.2),
            blurRadius: 10,
          ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          offset: const Offset(0, 2),
          blurRadius: 6,
        ),
      ],
    );
  }

  // Rounded panel for modern look
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
        color: borderColor ?? accent.withValues(alpha: 0.12),
        width: borderWidth,
      ),
      boxShadow: shadows ??
          [
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
        color: borderColor ?? Colors.white.withValues(alpha: 0.05),
        width: 1,
      ),
      boxShadow: glow
          ? [
              BoxShadow(
                color: (glowColor ?? accent).withValues(alpha: 0.25),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ]
          : null,
    );
  }

  static BoxDecoration glassDecoration({
    double opacity = 0.10,
    double borderRadius = 12,
  }) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withValues(alpha: opacity * 1.5),
        width: 0.5,
      ),
    );
  }

  // ══════════════════════════════════════════
  // ── Widgets ──
  // ══════════════════════════════════════════

  /// Professional game button with gradient + press effect
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
      color: isEnabled ? (color ?? accent) : const Color(0xFF2A2A40),
      icon: icon,
      fontSize: fontSize,
      verticalPad: verticalPad,
      horizontalPad: horizontalPad,
      enabled: isEnabled,
      usePixelFont: usePixelFont,
    );
  }

  /// Clean progress bar with rounded ends
  static Widget pixelProgressBar({
    required double value,
    double height = 10,
    Color? fillColor,
    LinearGradient? fillGradient,
    Color bgColor = const Color(0xFF0E0E20),
  }) {
    final clamped = value.clamp(0.0, 1.0);
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(
          color: pixelBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
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
                        (fillColor ?? accent).withValues(alpha: 0.7),
                      ],
                    ),
                borderRadius: BorderRadius.circular(height / 2),
                boxShadow: [
                  BoxShadow(
                    color: (fillColor ?? accent).withValues(alpha: 0.3),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Info chip badge
  static Widget pixelChip({
    required String value,
    IconData? icon,
    Color color = textPrimary,
    double fontSize = 8,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgDeep.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(radiusSm),
        border: Border.all(
          color: pixelBorder.withValues(alpha: 0.4),
          width: 1,
        ),
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

  /// Currency display with icon
  static Widget pixelCurrency({
    required String value,
    bool isSoul = false,
    double fontSize = 9,
  }) {
    final color = isSoul ? accentPurple : accentGold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgDeep.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(radiusSm),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSoul ? Icons.auto_awesome : Icons.monetization_on,
            color: color,
            size: fontSize + 5,
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

  // Legacy compatibility widgets

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
        isEnabled ? (color ?? accent) : const Color(0xFF2A2A40);

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
      decoration: glassDecoration(opacity: 0.12, borderRadius: 20),
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
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(radiusSm),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.10),
            width: 1,
          ),
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
  // ── Utility ──
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
      case 'mythic':
        return rarityMythic;
      default:
        return rarityCommon;
    }
  }
}

// ══════════════════════════════════════════
// ── Pixel Button Widget ──
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
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          padding: EdgeInsets.symmetric(
            horizontal: widget.horizontalPad,
            vertical: widget.verticalPad,
          ),
          decoration: BoxDecoration(
            gradient: widget.enabled ? widget.gradient : null,
            color: widget.gradient == null ? widget.color : null,
            borderRadius: BorderRadius.circular(GameTheme.radiusSm),
            border: Border.all(
              color: _pressed
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
            boxShadow: _pressed
                ? null
                : [
                    BoxShadow(
                      color: (widget.gradient?.colors.first ?? widget.color)
                          .withValues(alpha: widget.enabled ? 0.3 : 0.0),
                      offset: const Offset(0, 3),
                      blurRadius: 8,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
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
      ),
    );
  }
}

// ══════════════════════════════════════════
// ── Animation Helper Widgets ──
// ══════════════════════════════════════════

/// Staggered list item animation
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

/// Shimmer/glow pulse effect
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
            borderRadius: BorderRadius.circular(GameTheme.radiusSm),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(
                    alpha: widget.intensity * _controller.value),
                blurRadius: 12 + _controller.value * 8,
                spreadRadius: _controller.value * 2,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Retro scanline overlay
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

/// Pixel-style sparkle effect
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
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
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

/// Game tooltip — shown on long press with auto-positioning.
class GameTooltip extends StatefulWidget {
  final Widget child;
  final String title;
  final String description;
  final Color? accentColor;

  const GameTooltip({
    super.key,
    required this.child,
    required this.title,
    required this.description,
    this.accentColor,
  });

  @override
  State<GameTooltip> createState() => _GameTooltipState();
}

class _GameTooltipState extends State<GameTooltip> {
  OverlayEntry? _overlayEntry;

  void _showTooltip(BuildContext context) {
    _removeTooltip();
    final box = context.findRenderObject() as RenderBox;
    final position = box.localToGlobal(Offset.zero);
    final screenWidth = MediaQuery.of(context).size.width;
    final tooltipWidth = 200.0;

    // Auto-position: prefer below, shift left/right to stay on screen
    double left = position.dx + box.size.width / 2 - tooltipWidth / 2;
    left = left.clamp(8.0, screenWidth - tooltipWidth - 8);
    double top = position.dy + box.size.height + 8;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: left,
        top: top,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: _removeTooltip,
            child: Container(
              width: tooltipWidth,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: GameTheme.bgCard,
                borderRadius: BorderRadius.circular(GameTheme.radiusSm),
                border: Border.all(
                  color: (widget.accentColor ?? GameTheme.accent)
                      .withValues(alpha: 0.4),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    style: GameTheme.pixel(
                      fontSize: 8,
                      color: widget.accentColor ?? GameTheme.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.description,
                    style: GameTheme.pixel(
                      fontSize: 6,
                      color: GameTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), _removeTooltip);
  }

  void _removeTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeTooltip();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showTooltip(context),
      child: widget.child,
    );
  }
}

/// Animation utility constants
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
