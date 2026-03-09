import 'dart:math';
import 'package:flutter/material.dart';
import '../game/runner_game.dart';
import 'game_theme.dart';
import 'ui_effects.dart';

class AscensionScreen extends StatefulWidget {
  final RunnerGame game;
  const AscensionScreen({super.key, required this.game});

  @override
  State<AscensionScreen> createState() => _AscensionScreenState();
}

class _AscensionScreenState extends State<AscensionScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _particleController;
  late AnimationController _pulseController;
  late Animation<double> _bgFade;
  late Animation<double> _contentScale;
  late Animation<double> _contentFade;
  late Animation<double> _soulCountUp;

  int _soulsEarned = 0;
  int _ascensionNumber = 0;
  bool _hasAscended = false;
  bool _showContinue = false;

  @override
  void initState() {
    super.initState();

    final game = widget.game;
    _soulsEarned =
        game.ascensionManager.calculateSoulReward(game.totalCoinsEarned);
    _ascensionNumber = game.ascensionManager.ascensionCount + 1;

    _entryController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _particleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _bgFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _entryController,
          curve: const Interval(0, 0.4, curve: Curves.easeIn)),
    );
    _contentScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
          parent: _entryController,
          curve: const Interval(0.2, 0.7, curve: Curves.elasticOut)),
    );
    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _entryController,
          curve: const Interval(0.2, 0.6, curve: Curves.easeOut)),
    );
    _soulCountUp = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _entryController,
          curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic)),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: Listenable.merge(
            [_entryController, _particleController, _pulseController]),
        builder: (context, _) {
          return RetroScanlines(
            opacity: _hasAscended ? 0.04 : 0.02,
            child: Stack(
              children: [
                Container(
                  color: _hasAscended
                      ? Color.lerp(
                          const Color(0xFF0D0D1A),
                          const Color(0xFF1A0A2E),
                          _bgFade.value,
                        )
                      : Color.lerp(
                          Colors.transparent,
                          const Color(0xFFF5F5F5),
                          _bgFade.value * 0.95,
                        ),
                ),
                if (_hasAscended) ..._buildAscensionParticles(),
                Center(
                  child: Opacity(
                    opacity: _contentFade.value,
                    child: Transform.scale(
                      scale: _contentScale.value,
                      child: _hasAscended
                          ? _buildPostAscension()
                          : _buildPreAscension(),
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

  Widget _buildPreAscension() {
    final pulseVal = _pulseController.value;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: GameTheme.accentPurple
                    .withValues(alpha: 0.3 + pulseVal * 0.2),
                blurRadius: 30 + pulseVal * 10,
                spreadRadius: pulseVal * 5,
              ),
            ],
          ),
          child: Icon(
            Icons.auto_awesome,
            size: 64,
            color: Color.lerp(
              GameTheme.accentPurple,
              GameTheme.accentGold,
              (_entryController.value * 2).clamp(0, 1).toDouble(),
            ),
          ),
        ),
        const SizedBox(height: 20),

        Text(
          'ASCENSION #$_ascensionNumber',
          style: GameTheme.pixel(
            fontSize: 16,
            color: _hasAscended
                ? GameTheme.textPrimary
                : const Color(0xFF1A1A1A),
            letterSpacing: 2,
            shadows: [
              Shadow(
                  color: GameTheme.accentPurple.withValues(alpha: 0.5),
                  blurRadius: 12),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 소울 보상 카드
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          decoration: GameTheme.pixelPanelDecoration(
            fillColor: GameTheme.accentPurple.withValues(alpha: 0.1),
            glow: true,
            glowColor: GameTheme.accentPurple,
          ),
          child: Column(
            children: [
              Text('SOUL REWARD',
                  style: GameTheme.pixel(
                      fontSize: 8, color: GameTheme.accentPurple)),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome,
                      color: GameTheme.accentPurple, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    '+${(_soulsEarned * _soulCountUp.value).toInt()}',
                    style: GameTheme.pixel(
                      fontSize: 22,
                      color: GameTheme.accentPurple,
                      shadows: [
                        Shadow(
                            color: GameTheme.accentPurple
                                .withValues(alpha: 0.5),
                            blurRadius: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        Text(
          '일반 업그레이드와 코인이 초기화됩니다',
          style: TextStyle(
            color: Colors.black.withValues(alpha: 0.4),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 32),

        ShimmerGlow(
          glowColor: GameTheme.accentPurple,
          intensity: 0.3,
          child: GameTheme.pixelButton(
            label: 'ASCEND',
            icon: Icons.auto_awesome,
            onTap: _performAscension,
            gradient: GameTheme.gradientPurple,
            fontSize: 12,
            horizontalPad: 36,
            verticalPad: 14,
          ),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: () => widget.game.closeAscensionScreen(),
          child: Text(
            'BACK',
            style: GameTheme.pixel(
              fontSize: 7,
              color: const Color(0xFF888888),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPostAscension() {
    return AnimatedOpacity(
      opacity: _showContinue ? 1 : 0,
      duration: const Duration(milliseconds: 800),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PixelSparkle(
            color: GameTheme.accentGold,
            sparkleCount: 6,
            child: Icon(Icons.auto_awesome,
                color: GameTheme.accentGold, size: 72),
          ),
          const SizedBox(height: 20),
          ShaderMask(
            shaderCallback: (bounds) =>
                GameTheme.gradientGold.createShader(bounds),
            child: Text(
              'ASCENDED',
              style: GameTheme.pixel(
                fontSize: 20,
                color: Colors.white,
                letterSpacing: 3,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '+$_soulsEarned SOULS',
            style: GameTheme.pixel(
              fontSize: 12,
              color: GameTheme.accentPurple,
              shadows: [
                Shadow(
                    color: GameTheme.accentPurple.withValues(alpha: 0.5),
                    blurRadius: 8),
              ],
            ),
          ),
          const SizedBox(height: 40),
          GameTheme.pixelButton(
            label: 'CONTINUE',
            icon: Icons.arrow_forward_rounded,
            onTap: () => widget.game.closeAscensionScreen(),
            gradient: GameTheme.gradientGold,
            fontSize: 10,
            horizontalPad: 32,
            verticalPad: 12,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAscensionParticles() {
    final rng = Random(42);
    return List.generate(20, (i) {
      final angle = rng.nextDouble() * 2 * pi;
      final radius = 50 + rng.nextDouble() * 250;
      final speed = 0.5 + rng.nextDouble() * 1.5;
      final t = (_particleController.value * speed + i * 0.05) % 1.0;
      final size = 2 + rng.nextDouble() * 3;

      final x = 400 + cos(angle + t * 2 * pi) * radius * t;
      final y = 300 + sin(angle + t * 2 * pi) * radius * t;
      final alpha = (1 - t).clamp(0.0, 0.6);

      // 픽셀 스타일 사각형 파티클
      return Positioned(
        left: x - size / 2,
        top: y - size / 2,
        child: Container(
          width: size,
          height: size,
          color: Color.lerp(
            GameTheme.accentPurple,
            GameTheme.accentGold,
            rng.nextDouble(),
          )!
              .withValues(alpha: alpha),
        ),
      );
    });
  }

  void _performAscension() {
    widget.game.executeAscension();
    setState(() {
      _hasAscended = true;
    });

    _entryController.reset();
    _entryController.forward().then((_) {
      if (mounted) {
        setState(() => _showContinue = true);
      }
    });
  }
}
