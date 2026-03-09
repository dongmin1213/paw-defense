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

    _titleSlide = Tween<double>(begin: -40, end: 0).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0, 0.5, curve: Curves.easeOutCubic)),
    );
    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0, 0.4, curve: Curves.easeOut)),
    );
    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0.3, 0.7, curve: Curves.easeOut)),
    );
    _buttonScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0.5, 1.0, curve: Curves.easeOutBack)),
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
        animation: Listenable.merge([_entryController, _bgController, _pulseController]),
        builder: (context, _) {
          return Container(
            decoration: const BoxDecoration(gradient: GameTheme.gradientDark),
            child: Stack(
              children: [
                ..._buildBgParticles(),
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
                        const SizedBox(height: 32),
                        if (hasProgress)
                          Opacity(
                            opacity: _contentFade.value,
                            child: _buildStatsCard(game, hasAscended),
                          ),
                        SizedBox(height: hasProgress ? 32 : 0),
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
                              '화면을 탭하면 점프합니다',
                              style: GameTheme.bodySmall.copyWith(
                                color: GameTheme.textMuted.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF4FC3F7), Color(0xFFFFD54F), Color(0xFF4FC3F7)],
            stops: [0.0, 0.5, 1.0],
          ).createShader(bounds),
          child: Text(
            "THE BICHON'S RUN",
            style: GameTheme.titleLarge.copyWith(
              fontSize: 34,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: GameTheme.accent.withValues(alpha: 0.6),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
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
      width: 300,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: GameTheme.cardDecoration(
        borderColor: GameTheme.accent.withValues(alpha: 0.1),
      ),
      child: Column(
        children: [
          _statRow(Icons.straighten, '최고 거리',
              '${(game.saveManager.highScore / 10).toStringAsFixed(0)}m'),
          const SizedBox(height: 8),
          _statRow(Icons.monetization_on, '보유 코인',
              GameTheme.formatNumber(game.saveManager.coins),
              valueColor: GameTheme.accentGold),
          if (hasAscended) ...[
            const SizedBox(height: 8),
            _statRow(Icons.loop, '초월 횟수',
                '${game.saveManager.ascensionCount}회',
                valueColor: GameTheme.accentPurple),
            const SizedBox(height: 8),
            _statRow(Icons.auto_awesome, '보유 소울',
                '${game.saveManager.souls}',
                valueColor: GameTheme.accentPurple),
          ],
        ],
      ),
    );
  }

  Widget _statRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, color: GameTheme.textMuted, size: 16),
        const SizedBox(width: 8),
        Text(label, style: GameTheme.bodySmall),
        const Spacer(),
        Text(
          value,
          style: GameTheme.labelBold.copyWith(
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
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: GameTheme.accent.withValues(alpha: 0.2 + pulseValue * 0.2),
                blurRadius: 16 + pulseValue * 8,
                spreadRadius: pulseValue * 2,
              ),
            ],
          ),
          child: GameTheme.gameButton(
            label: '시작하기',
            icon: Icons.play_arrow_rounded,
            onTap: () => game.startGame(),
            gradient: GameTheme.gradientPrimary,
            fontSize: 20,
            horizontalPad: 48,
            verticalPad: 16,
          ),
        ),
        if (hasAscended) ...[
          const SizedBox(height: 14),
          GameTheme.gameButton(
            label: '영구 업그레이드',
            icon: Icons.auto_awesome,
            onTap: () => game.openSoulShop(),
            color: GameTheme.accentPurple.withValues(alpha: 0.8),
            fontSize: 14,
            compact: true,
          ),
        ],
      ],
    );
  }

  List<Widget> _buildBgParticles() {
    final rng = Random(42);
    return List.generate(15, (i) {
      final x = rng.nextDouble();
      final y = rng.nextDouble();
      final size = 2.0 + rng.nextDouble() * 3;
      final speed = 0.3 + rng.nextDouble() * 0.7;
      final offset = _bgController.value * speed;

      return Positioned(
        left: (x * 800) % 800,
        top: ((y + offset) % 1.0) * 600,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: GameTheme.accent.withValues(alpha: 0.1 + rng.nextDouble() * 0.15),
            shape: BoxShape.circle,
          ),
        ),
      );
    });
  }
}
