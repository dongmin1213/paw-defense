import 'dart:math';
import 'package:flutter/material.dart';
import '../game/runner_game.dart';
import 'game_theme.dart';

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
        animation:
            Listenable.merge([_entryController, _particleController, _pulseController]),
        builder: (context, _) {
          return Stack(
            children: [
              // 배경 — 화이트아웃 → 딥 퍼플
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

              // 파티클 이펙트
              if (_hasAscended) ..._buildAscensionParticles(),

              // 메인 콘텐츠
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
        // 아이콘 — 그라데이션 글로우
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: GameTheme.accentPurple.withValues(alpha: 0.3 + pulseVal * 0.2),
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
          '초월 $_ascensionNumber회차',
          style: TextStyle(
            color: _hasAscended
                ? GameTheme.textPrimary
                : const Color(0xFF1A1A1A),
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 24),

        // 소울 보상 카드
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
          decoration: BoxDecoration(
            color: GameTheme.accentPurple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: GameTheme.accentPurple.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                  color: GameTheme.accentPurple.withValues(alpha: 0.1),
                  blurRadius: 16),
            ],
          ),
          child: Column(
            children: [
              Text('획득 소울',
                  style: GameTheme.bodyLarge.copyWith(
                      color: GameTheme.accentPurple)),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome,
                      color: GameTheme.accentPurple, size: 32),
                  const SizedBox(width: 10),
                  Text(
                    '+${(_soulsEarned * _soulCountUp.value).toInt()}',
                    style: TextStyle(
                      color: GameTheme.accentPurple,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
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
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 32),

        // 초월 버튼
        GameTheme.gameButton(
          label: '초월하기',
          icon: Icons.auto_awesome,
          onTap: _performAscension,
          gradient: GameTheme.gradientPurple,
          fontSize: 20,
          horizontalPad: 44,
          verticalPad: 16,
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: () => widget.game.closeAscensionScreen(),
          child: Text(
            '돌아가기',
            style: GameTheme.bodySmall.copyWith(
              color: const Color(0xFF888888),
              fontSize: 14,
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
          Icon(Icons.auto_awesome,
              color: GameTheme.accentGold, size: 72),
          const SizedBox(height: 20),
          ShaderMask(
            shaderCallback: (bounds) => GameTheme.gradientGold.createShader(bounds),
            child: Text(
              '초월 완료',
              style: GameTheme.titleLarge.copyWith(
                  fontSize: 36, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '+$_soulsEarned 소울 획득',
            style: TextStyle(
              color: GameTheme.accentPurple,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 40),
          GameTheme.gameButton(
            label: '계속하기',
            icon: Icons.arrow_forward_rounded,
            onTap: () => widget.game.closeAscensionScreen(),
            gradient: GameTheme.gradientGold,
            fontSize: 18,
            horizontalPad: 40,
            verticalPad: 14,
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
      final size = 2 + rng.nextDouble() * 4;

      final x = 400 + cos(angle + t * 2 * pi) * radius * t;
      final y = 300 + sin(angle + t * 2 * pi) * radius * t;
      final alpha = (1 - t).clamp(0.0, 0.6);

      return Positioned(
        left: x - size / 2,
        top: y - size / 2,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Color.lerp(
              GameTheme.accentPurple,
              GameTheme.accentGold,
              rng.nextDouble(),
            )!
                .withValues(alpha: alpha),
            shape: BoxShape.circle,
          ),
        ),
      );
    });
  }

  void _performAscension() {
    widget.game.executeAscension();
    setState(() {
      _hasAscended = true;
    });

    // 새 진입 애니메이션
    _entryController.reset();
    _entryController.forward().then((_) {
      if (mounted) {
        setState(() => _showContinue = true);
      }
    });
  }
}
