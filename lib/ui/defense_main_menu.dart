import 'package:flutter/material.dart';
import 'game_theme.dart';
import '../game/defense_game.dart';

/// Castle defense main menu overlay.
class DefenseMainMenu extends StatefulWidget {
  final DefenseGame game;
  const DefenseMainMenu({super.key, required this.game});

  @override
  State<DefenseMainMenu> createState() => _DefenseMainMenuState();
}

class _DefenseMainMenuState extends State<DefenseMainMenu>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _scaleFade;
  late AnimationController _pulseController;
  late Animation<double> _pulse;
  late AnimationController _castleController;
  late Animation<double> _castleBob;

  @override
  void initState() {
    super.initState();

    // Entry animation: scale + fade
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleFade = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutBack,
    );
    _entryController.forward();

    // Pulse glow for start button
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Castle bobbing animation
    _castleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _castleBob = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _castleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    _castleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0A0A18),
              Color(0xFF101030),
              Color(0xFF0A0A18),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: AnimatedBuilder(
          animation: _entryController,
          builder: (context, _) {
            return Transform.scale(
              scale: 0.8 + 0.2 * _scaleFade.value,
              child: Opacity(
                opacity: _scaleFade.value.clamp(0.0, 1.0),
                child: _buildContent(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Star currency display (top right)
            Align(
              alignment: Alignment.topRight,
              child: GameTheme.pixelCurrency(
                value: GameTheme.formatInt(widget.game.stars),
                isSoul: true,
              ),
            ),
            const Spacer(flex: 1),
            // Game title with gradient
            _buildTitle(),
            const SizedBox(height: 24),
            // Castle icon
            _buildCastleIcon(),
            const SizedBox(height: 32),
            // Stats
            _buildStats(),
            const Spacer(flex: 1),
            // Buttons
            _buildButtons(),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return ShaderMask(
      shaderCallback: (bounds) {
        return const LinearGradient(
          colors: [
            GameTheme.accentGold,
            Color(0xFFFFE082),
            GameTheme.accentGold,
          ],
        ).createShader(bounds);
      },
      child: Text(
        '동물 성벽\n지키기',
        textAlign: TextAlign.center,
        style: GameTheme.pixel(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildCastleIcon() {
    return AnimatedBuilder(
      animation: _castleController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _castleBob.value),
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: GameTheme.pixelPanelDecoration(
          fillColor: GameTheme.bgCard,
          glow: true,
          glowColor: GameTheme.accentGold,
        ),
        child: Column(
          children: [
            Text(
              '🏰',
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 8),
            Text(
              'CASTLE DEFENSE',
              style: GameTheme.pixel(
                fontSize: 7,
                color: GameTheme.textSecondary,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: GameTheme.pixelCardDecoration(
        fillColor: GameTheme.bgDeep.withValues(alpha: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _statItem('최고 웨이브', GameTheme.formatInt(widget.game.highestWave)),
          Container(
            width: 1,
            height: 24,
            color: GameTheme.pixelBorder,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          _statItem('총 런', GameTheme.formatInt(widget.game.totalRuns)),
        ],
      ),
    );
  }

  Widget _buildSecondaryButtons() {
    final showAchievement =
        widget.game.isSystemUnlocked(DefenseGame.unlockAchievement) ||
            widget.game.achievementManager.completedAchievements.length >= 3;

    return Column(
      children: [
        // First row: upgrade + codex
        Row(
          children: [
            Expanded(
              child: GameTheme.pixelButton(
                label: '업그레이드',
                onTap: () => widget.game.openStarShop(),
                gradient: GameTheme.gradientGold,
                fontSize: 8,
                verticalPad: 12,
                horizontalPad: 8,
                icon: Icons.auto_awesome,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GameTheme.pixelButton(
                label: '도감',
                onTap: () => widget.game.openCodex(),
                gradient: GameTheme.gradientGreen,
                fontSize: 8,
                verticalPad: 12,
                horizontalPad: 8,
                icon: Icons.menu_book,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Second row: achievement + settings
        Row(
          children: [
            if (showAchievement) ...[
              Expanded(
                child: GameTheme.pixelButton(
                  label: '업적',
                  onTap: () => widget.game.overlays.add('Achievement'),
                  gradient: GameTheme.gradientPurple,
                  fontSize: 8,
                  verticalPad: 12,
                  horizontalPad: 8,
                  icon: Icons.emoji_events,
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: GameTheme.pixelButton(
                label: '설정',
                onTap: () => widget.game.overlays.add('Settings'),
                color: GameTheme.bgPanel,
                fontSize: 8,
                verticalPad: 12,
                horizontalPad: 8,
                icon: Icons.settings,
              ),
            ),
            if (!showAchievement) ...[
              const SizedBox(width: 10),
              const Expanded(child: SizedBox()),
            ],
          ],
        ),
      ],
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GameTheme.pixel(
            fontSize: 12,
            color: GameTheme.accentGold,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GameTheme.pixel(
            fontSize: 6,
            color: GameTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        // Resume button (if saved run exists)
        if (widget.game.saveManager.hasRunState) ...[
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: GameTheme.accentGreen.withValues(alpha: 0.3 * _pulse.value),
                      blurRadius: 16 * _pulse.value,
                      spreadRadius: 2 * _pulse.value,
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: GameTheme.pixelButton(
              label: '이어하기',
              onTap: () => widget.game.resumeRun(),
              gradient: GameTheme.gradientGreen,
              fontSize: 12,
              verticalPad: 16,
              horizontalPad: 40,
              icon: Icons.play_circle_outline,
            ),
          ),
          const SizedBox(height: 12),
        ],
        // Daily reward button with notification badge
        Stack(
          clipBehavior: Clip.none,
          children: [
            GameTheme.pixelButton(
              label: '일일 보상',
              onTap: () => widget.game.openDaily(),
              gradient: GameTheme.gradientGold,
              fontSize: 9,
              verticalPad: 12,
              horizontalPad: 28,
              icon: Icons.calendar_today,
            ),
            if (widget.game.dailyManager.hasUnclaimedReward)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: GameTheme.accentRed,
                    shape: BoxShape.circle,
                    border: Border.all(color: GameTheme.bgDeep, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: GameTheme.accentRed.withValues(alpha: 0.6),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        // Start game button with pulse glow
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: GameTheme.accent.withValues(alpha: 0.3 * _pulse.value),
                    blurRadius: 16 * _pulse.value,
                    spreadRadius: 2 * _pulse.value,
                  ),
                ],
              ),
              child: child,
            );
          },
          child: GameTheme.pixelButton(
            label: widget.game.saveManager.hasRunState ? '새 게임' : '게임 시작',
            onTap: () {
              if (widget.game.totalRuns <= 1) {
                widget.game.overlays.remove('DefenseMainMenu');
                widget.game.overlays.add('Tutorial');
              } else {
                widget.game.startGame();
              }
            },
            gradient: GameTheme.gradientPrimary,
            fontSize: widget.game.saveManager.hasRunState ? 9 : 12,
            verticalPad: widget.game.saveManager.hasRunState ? 12 : 16,
            horizontalPad: widget.game.saveManager.hasRunState ? 28 : 40,
            icon: Icons.play_arrow,
          ),
        ),
        const SizedBox(height: 16),
        // Secondary buttons in 2-column grid for compact layout
        _buildSecondaryButtons(),
      ],
    );
  }
}
