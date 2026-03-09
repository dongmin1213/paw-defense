import 'package:flutter/material.dart';

/// The Bichon's Run — 통합 게임 UI 테마 시스템
/// Idle Slayer / 소닉 / 마리오 급 품질의 일관된 디자인 시스템
class GameTheme {
  GameTheme._();

  // ── 핵심 색상 팔레트 ──
  static const Color bgDeep = Color(0xFF0D0D1A);
  static const Color bgDark = Color(0xFF141428);
  static const Color bgPanel = Color(0xFF1C1C3A);
  static const Color bgCard = Color(0xFF222244);
  static const Color bgCardHover = Color(0xFF2A2A55);

  static const Color accent = Color(0xFF4FC3F7); // 메인 액센트 (시원한 블루)
  static const Color accentGold = Color(0xFFFFD54F); // 골드
  static const Color accentPurple = Color(0xFFBA68C8); // 소울/초월
  static const Color accentGreen = Color(0xFF66BB6A); // 성공/구매
  static const Color accentRed = Color(0xFFEF5350); // 위험/HP
  static const Color accentOrange = Color(0xFFFF9800); // 동료/경고

  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0B0C0);
  static const Color textMuted = Color(0xFF6A6A80);
  static const Color textGold = Color(0xFFFFD54F);

  // ── 레어도 색상 ──
  static const Color rarityCommon = Color(0xFF9E9E9E);
  static const Color rarityRare = Color(0xFF42A5F5);
  static const Color rarityEpic = Color(0xFFAB47BC);
  static const Color rarityLegendary = Color(0xFFFFD600);

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

  // ── 텍스트 스타일 ──
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

  // ── 장식 ──
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
      boxShadow: glow ? [
        BoxShadow(
          color: (glowColor ?? accent).withValues(alpha: 0.3),
          blurRadius: 12,
          spreadRadius: 1,
        ),
      ] : null,
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

  // ── 공통 위젯 빌더 ──

  /// 게임 스타일 버튼
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
    final effectiveColor = isEnabled
        ? (color ?? accent)
        : const Color(0xFF3A3A50);

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
          boxShadow: isEnabled ? [
            BoxShadow(
              color: (effectiveGradient?.colors.first ?? effectiveColor).withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: isEnabled ? Colors.white : textMuted, size: fontSize + 2),
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

  /// 글래스모피즘 정보 칩
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

  /// 프로그레스 바
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
            gradient: fillGradient ?? LinearGradient(
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

  /// 섹션 헤더
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

  /// 닫기 버튼 (X 스타일)
  static Widget closeButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: const Icon(
          Icons.close,
          color: textSecondary,
          size: 18,
        ),
      ),
    );
  }

  /// 통화 표시 위젯 (코인/소울)
  static Widget currencyDisplay({
    required String value,
    bool isSoul = false,
    double fontSize = 18,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: glassDecoration(opacity: 0.1, borderRadius: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSoul ? Icons.auto_awesome : Icons.monetization_on,
            color: isSoul ? accentPurple : accentGold,
            size: fontSize + 2,
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              color: isSoul ? accentPurple : accentGold,
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ── 유틸리티 ──

  /// 숫자 포맷팅 (1K, 1.2M, 1.5B ...)
  static String formatNumber(double n) {
    if (n >= 1e12) return '${(n / 1e12).toStringAsFixed(1)}T';
    if (n >= 1e9) return '${(n / 1e9).toStringAsFixed(1)}B';
    if (n >= 1e6) return '${(n / 1e6).toStringAsFixed(1)}M';
    if (n >= 1e3) return '${(n / 1e3).toStringAsFixed(1)}K';
    return n.toInt().toString();
  }

  /// 정수 포맷팅
  static String formatInt(int n) => formatNumber(n.toDouble());

  /// 레어도 색상
  static Color rarityToColor(String rarity) {
    switch (rarity) {
      case 'common': return rarityCommon;
      case 'rare': return rarityRare;
      case 'epic': return rarityEpic;
      case 'legendary': return rarityLegendary;
      default: return rarityCommon;
    }
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
