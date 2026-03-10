import 'package:flutter/material.dart';
import 'game_theme.dart';
import '../game/defense_game.dart';

/// Castle defense main menu overlay — professional layout with unified button sizes.
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

    _entryController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleFade = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutBack,
    );
    _entryController.forward();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _castleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _castleBob = Tween<double>(begin: -3.0, end: 3.0).animate(
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
        decoration: const BoxDecoration(gradient: GameTheme.bgVignette),
        child: AnimatedBuilder(
          animation: _entryController,
          builder: (context, _) {
            return Transform.scale(
              scale: 0.85 + 0.15 * _scaleFade.value,
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
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        child: Column(
          children: [
            // Top bar — currency
            Align(
              alignment: Alignment.topRight,
              child: GameTheme.pixelCurrency(
                value: GameTheme.formatInt(widget.game.stars),
                isSoul: true,
              ),
            ),
            const Spacer(flex: 2),
            // Title
            _buildTitle(),
            const SizedBox(height: 20),
            // Castle icon with stats overlay
            _buildCastleWithStats(),
            const Spacer(flex: 2),
            // Buttons — unified width
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

  Widget _buildCastleWithStats() {
    return AnimatedBuilder(
      animation: _castleController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _castleBob.value),
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        decoration: GameTheme.pixelPanelDecoration(
          fillColor: GameTheme.bgCard,
          glow: true,
          glowColor: GameTheme.accentGold.withValues(alpha: 0.3),
        ),
        child: Column(
          children: [
            const Text('🏰', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            // Stats row integrated into castle panel
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: GameTheme.bgDeep.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(GameTheme.radiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _statItem('최고 웨이브', GameTheme.formatInt(widget.game.highestWave)),
                  Container(
                    width: 1,
                    height: 28,
                    color: GameTheme.pixelBorder.withValues(alpha: 0.4),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  _statItem('총 런', GameTheme.formatInt(widget.game.totalRuns)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GameTheme.pixel(
            fontSize: 14,
            color: GameTheme.accentGold,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
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
    final hasResume = widget.game.saveManager.hasRunState;
    final showAchievement =
        widget.game.isSystemUnlocked(DefenseGame.unlockAchievement) ||
            widget.game.achievementManager.completedAchievements.length >= 3;

    return Column(
      children: [
        // Primary action — Resume or Start
        if (hasResume) ...[
          _fullWidthButton(
            label: '이어하기',
            icon: Icons.play_circle_outline,
            gradient: GameTheme.gradientGreen,
            onTap: () => widget.game.resumeRun(),
            isPrimary: true,
            pulse: true,
          ),
          const SizedBox(height: 10),
        ],
        // Daily reward
        _fullWidthButton(
          label: '일일 보상',
          icon: Icons.calendar_today,
          gradient: GameTheme.gradientGold,
          onTap: () => widget.game.openDaily(),
          badge: widget.game.dailyManager.hasUnclaimedReward,
        ),
        const SizedBox(height: 10),
        // New game / start
        _fullWidthButton(
          label: hasResume ? '새 게임' : '게임 시작',
          icon: Icons.play_arrow,
          gradient: GameTheme.gradientPrimary,
          onTap: () {
            if (widget.game.totalRuns <= 1) {
              widget.game.overlays.remove('DefenseMainMenu');
              widget.game.overlays.add('Tutorial');
            } else {
              widget.game.startGame();
            }
          },
          isPrimary: !hasResume,
          pulse: !hasResume,
        ),
        const SizedBox(height: 16),
        // Secondary row — 2 equal buttons
        Row(
          children: [
            Expanded(
              child: _secondaryButton(
                label: '업그레이드',
                icon: Icons.auto_awesome,
                color: GameTheme.accentGold,
                onTap: () => widget.game.openStarShop(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _secondaryButton(
                label: '도감',
                icon: Icons.menu_book,
                color: GameTheme.accentGreen,
                onTap: () => widget.game.openCodex(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Third row — 2 equal buttons
        Row(
          children: [
            if (showAchievement) ...[
              Expanded(
                child: _secondaryButton(
                  label: '업적',
                  icon: Icons.emoji_events,
                  color: GameTheme.accentPurple,
                  onTap: () => widget.game.overlays.add('Achievement'),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: _secondaryButton(
                label: '설정',
                icon: Icons.settings,
                color: GameTheme.textSecondary,
                onTap: () => widget.game.overlays.add('Settings'),
              ),
            ),
            if (!showAchievement) ...[
              const SizedBox(width: 8),
              const Expanded(child: SizedBox()),
            ],
          ],
        ),
      ],
    );
  }

  /// Full-width primary/secondary action button
  Widget _fullWidthButton({
    required String label,
    required IconData icon,
    required LinearGradient gradient,
    required VoidCallback onTap,
    bool isPrimary = false,
    bool pulse = false,
    bool badge = false,
  }) {
    Widget button = SizedBox(
      width: double.infinity,
      child: GameTheme.pixelButton(
        label: label,
        onTap: onTap,
        gradient: gradient,
        fontSize: isPrimary ? 11 : 9,
        verticalPad: isPrimary ? 16 : 12,
        horizontalPad: 20,
        icon: icon,
      ),
    );

    if (pulse) {
      button = AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(GameTheme.radiusSm),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withValues(alpha: 0.25 * _pulse.value),
                  blurRadius: 16 * _pulse.value,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: child,
          );
        },
        child: button,
      );
    }

    if (badge) {
      button = Stack(
        clipBehavior: Clip.none,
        children: [
          button,
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: GameTheme.accentRed,
                shape: BoxShape.circle,
                border: Border.all(color: GameTheme.bgDeep, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: GameTheme.accentRed.withValues(alpha: 0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return button;
  }

  /// Compact secondary button with icon-tinted background
  Widget _secondaryButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(GameTheme.radiusSm),
          border: Border.all(
            color: color.withValues(alpha: 0.20),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: GameTheme.pixel(
                fontSize: 7,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
