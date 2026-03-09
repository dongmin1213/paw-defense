import 'dart:math';
import 'package:flutter/material.dart';
import '../game/runner_game.dart';
import 'game_theme.dart';

class MainMenu extends StatefulWidget {
  final RunnerGame game;
  const MainMenu({super.key, required this.game});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _entryController;
  late AnimationController _pulseController;
  late AnimationController _titleFlicker;
  late Animation<double> _titleSlide;
  late Animation<double> _titleFade;
  late Animation<double> _contentFade;
  late Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _entryController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _titleFlicker = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _titleSlide = Tween<double>(begin: -40, end: 0).animate(
      CurvedAnimation(
          parent: _entryController,
          curve: const Interval(0, 0.5, curve: Curves.easeOutCubic)),
    );
    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _entryController,
          curve: const Interval(0, 0.4, curve: Curves.easeOut)),
    );
    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _entryController,
          curve: const Interval(0.3, 0.7, curve: Curves.easeOut)),
    );
    _buttonScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
          parent: _entryController,
          curve: const Interval(0.5, 1.0, curve: Curves.easeOutBack)),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _entryController.forward();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _entryController.dispose();
    _pulseController.dispose();
    _titleFlicker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final hasProgress = game.saveManager.highScore > 0;
    final hasAscended = game.saveManager.ascensionCount > 0;

    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: Listenable.merge(
            [_entryController, _bgController, _pulseController, _titleFlicker]),
        builder: (context, _) {
          return RetroScanlines(
            opacity: 0.025,
            child: Container(
              decoration: const BoxDecoration(gradient: GameTheme.gradientDark),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final h = constraints.maxHeight;
                  return Stack(
                    children: [
                      ..._buildBgParticles(w, h),
                      // 스타필드 효과
                      ..._buildStarfield(w, h),
                      SafeArea(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(flex: 2),
                          Transform.translate(
                            offset: Offset(0, _titleSlide.value),
                            child: Opacity(
                              opacity: _titleFade.value,
                              child: _buildTitle(),
                            ),
                          ),
                          const SizedBox(height: 28),
                          if (hasProgress)
                            Opacity(
                              opacity: _contentFade.value,
                              child: _buildStatsCard(game, hasAscended),
                            ),
                          SizedBox(height: hasProgress ? 28 : 0),
                          Transform.scale(
                            scale: _buttonScale.value,
                            child: Opacity(
                              opacity: _contentFade.value,
                              child: _buildButtons(game, hasAscended),
                            ),
                          ),
                          const Spacer(flex: 3),
                          Opacity(
                            opacity: _contentFade.value * 0.6,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: Text(
                                'TAP TO JUMP',
                                style: GameTheme.pixel(
                                  fontSize: 7,
                                  color: GameTheme.textMuted
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ],
                );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitle() {
    // 레트로 깜빡임 효과
    final flicker = sin(_titleFlicker.value * pi * 4);
    final flickerAlpha = 0.9 + flicker * 0.1;

    return Column(
      children: [
        Opacity(
          opacity: flickerAlpha.clamp(0.85, 1.0),
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Color(0xFF4FC3F7),
                Color(0xFFFFD54F),
                Color(0xFF4FC3F7)
              ],
              stops: [0.0, 0.5, 1.0],
            ).createShader(bounds),
            child: Text(
              "THE BICHON'S RUN",
              style: GameTheme.pixel(
                fontSize: 18,
                color: Colors.white,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                    color: GameTheme.accent.withValues(alpha: 0.8),
                    blurRadius: 20,
                  ),
                  Shadow(
                    color: GameTheme.accentGold.withValues(alpha: 0.4),
                    blurRadius: 40,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '비숑의 달리기',
          style: GameTheme.bodyLarge.copyWith(
            color: GameTheme.textSecondary.withValues(alpha: 0.7),
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(RunnerGame game, bool hasAscended) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: GameTheme.pixelPanelDecoration(),
      child: Column(
        children: [
          _statRow(Icons.straighten, '최고 거리',
              '${(game.saveManager.highScore / 10).toStringAsFixed(0)}m'),
          const SizedBox(height: 6),
          _statRow(Icons.monetization_on, '보유 코인',
              GameTheme.formatNumber(game.saveManager.coins),
              valueColor: GameTheme.accentGold),
          if (hasAscended) ...[
            const SizedBox(height: 6),
            _statRow(Icons.loop, '초월 횟수',
                '${game.saveManager.ascensionCount}',
                valueColor: GameTheme.accentPurple),
            const SizedBox(height: 6),
            _statRow(Icons.auto_awesome, '보유 소울',
                '${game.saveManager.souls}',
                valueColor: GameTheme.accentPurple),
          ],
          const SizedBox(height: 6),
          _statRow(
              Icons.emoji_events,
              '업적',
              '${game.achievementManager.completedCount}/${game.achievementManager.totalCount}',
              valueColor: GameTheme.accentGold),
        ],
      ),
    );
  }

  Widget _statRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, color: GameTheme.textMuted, size: 14),
        const SizedBox(width: 8),
        Text(label, style: GameTheme.bodySmall.copyWith(fontSize: 11)),
        const Spacer(),
        Text(
          value,
          style: GameTheme.pixel(
            fontSize: 8,
            color: valueColor ?? GameTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(RunnerGame game, bool hasAscended) {
    final pulseValue = _pulseController.value;
    return Column(
      children: [
        ShimmerGlow(
          glowColor: GameTheme.accent,
          intensity: 0.2 + pulseValue * 0.15,
          child: GameTheme.pixelButton(
            label: 'START',
            icon: Icons.play_arrow_rounded,
            onTap: () => game.startGame(),
            gradient: GameTheme.gradientPrimary,
            fontSize: 12,
            horizontalPad: 36,
            verticalPad: 14,
          ),
        ),
        if (hasAscended) ...[
          const SizedBox(height: 14),
          GameTheme.pixelButton(
            label: 'SOUL SHOP',
            icon: Icons.auto_awesome,
            onTap: () => game.openSoulShop(),
            color: GameTheme.accentPurple.withValues(alpha: 0.8),
            fontSize: 8,
            horizontalPad: 16,
            verticalPad: 8,
          ),
        ],
      ],
    );
  }

  // 스타필드 배경 효과
  List<Widget> _buildStarfield(double w, double h) {
    final rng = Random(99);
    return List.generate(15, (i) {
      final x = rng.nextDouble() * w;
      final y = rng.nextDouble() * h;
      final size = 1.0 + rng.nextDouble() * 2;
      final phase = rng.nextDouble() * 2 * pi;
      final twinkle =
          (sin(_bgController.value * 2 * pi + phase) + 1) / 2;

      return Positioned(
        left: x,
        top: y,
        child: Container(
          width: size,
          height: size,
          color: Colors.white.withValues(alpha: 0.1 + twinkle * 0.15),
        ),
      );
    });
  }

  List<Widget> _buildBgParticles(double w, double h) {
    final rng = Random(42);
    final colors = [
      GameTheme.accent,
      GameTheme.accentGold,
      GameTheme.accentPurple,
      GameTheme.accentGreen,
    ];
    return List.generate(25, (i) {
      final x = rng.nextDouble();
      final y = rng.nextDouble();
      final size = 1.5 + rng.nextDouble() * 4;
      final speed = 0.2 + rng.nextDouble() * 0.8;
      final offset = _bgController.value * speed;
      final color = colors[i % colors.length];
      final drift = sin((x + _bgController.value) * 3.14159 * 2) * 10;

      return Positioned(
        left: (x * w + drift) % w,
        top: ((y + offset) % 1.0) * h,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08 + rng.nextDouble() * 0.12),
            shape: BoxShape.circle,
            boxShadow: size > 3
                ? [
                    BoxShadow(
                        color: color.withValues(alpha: 0.15), blurRadius: 4)
                  ]
                : null,
          ),
        ),
      );
    });
  }
}
