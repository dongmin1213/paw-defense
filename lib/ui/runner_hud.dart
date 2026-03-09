import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../game/runner_game.dart';
import 'game_theme.dart';

class RunnerHud extends StatefulWidget {
  final RunnerGame game;
  const RunnerHud({super.key, required this.game});

  @override
  State<RunnerHud> createState() => _RunnerHudState();
}

class _RunnerHudState extends State<RunnerHud> with TickerProviderStateMixin {
  Timer? _updateTimer;
  late AnimationController _comboController;
  late AnimationController _comboPulse;
  late AnimationController _coinFlash;
  int _prevCombo = 0;
  double _displayCoins = 0;
  double _displayDistance = 0;
  double _prevCoins = 0;

  @override
  void initState() {
    super.initState();
    _updateTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (mounted) {
        _animateValues();
        setState(() {});
      }
    });
    _comboController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _comboPulse = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    _coinFlash = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  void _animateValues() {
    final game = widget.game;
    _displayCoins += (game.coins - _displayCoins) * 0.15;
    _displayDistance += (game.distanceInMeters - _displayDistance) * 0.2;
    if (game.combo != _prevCombo) {
      if (game.combo > _prevCombo) {
        _comboController.forward(from: 0);
      }
      _prevCombo = game.combo;
    }
    // Coin flash on significant gain
    final coinDelta = game.coins - _prevCoins;
    if (coinDelta > 0 && coinDelta > game.coins * 0.02) {
      _coinFlash.forward(from: 0);
    }
    _prevCoins = game.coins;
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _comboController.dispose();
    _comboPulse.dispose();
    _coinFlash.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    return SafeArea(
      child: Stack(
        children: [
          _buildTopBar(game),
          if (game.combo > 0) _buildComboMeter(game),
          if (game.activeBoss != null && !game.activeBoss!.isDead)
            _buildBossBar(game),
          if (game.bonusStageManager.isActive) _buildBonusBanner(game),
          _buildWeatherInfo(game),
          _buildActionButtons(game),
          _buildModeIndicator(game),
          if (game.levelGenerator.isDangerZone || game.levelGenerator.isPeaceZone)
            _buildZoneIndicator(game),
          // Zone screen tint overlay
          if (game.levelGenerator.isDangerZone)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.red.withValues(alpha: 0.06),
                ),
              ),
            ),
          if (game.levelGenerator.isPeaceZone)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.green.withValues(alpha: 0.04),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar(RunnerGame game) {
    return Positioned(
      top: 8,
      left: 12,
      right: 12,
      child: Row(
        children: [
          _PixelHudChip(
            icon: Icons.near_me,
            value: '${_displayDistance.toStringAsFixed(0)}m',
            color: GameTheme.textPrimary,
          ),
          const Spacer(),
          _PixelHudChip(
            icon: Icons.monetization_on,
            value: GameTheme.formatNumber(_displayCoins),
            color: GameTheme.accentGold,
            flashAnimation: _coinFlash,
          ),
        ],
      ),
    );
  }

  Widget _buildComboMeter(RunnerGame game) {
    final combo = game.combo;
    final comboMult = game.comboMultiplier;
    final comboTimer = game.comboTimer;
    final maxTime = 3.0 + game.companionManager.extraComboTime;
    final timerPercent = (comboTimer / maxTime).clamp(0.0, 1.0);

    Color comboColor;
    String comboTier;
    if (combo >= 50) {
      comboColor = const Color(0xFFFF1744);
      comboTier = 'INSANE';
    } else if (combo >= 30) {
      comboColor = const Color(0xFFFF6D00);
      comboTier = 'EPIC';
    } else if (combo >= 20) {
      comboColor = const Color(0xFFFFD600);
      comboTier = 'GREAT';
    } else if (combo >= 10) {
      comboColor = const Color(0xFF00E676);
      comboTier = 'NICE';
    } else {
      comboColor = GameTheme.textPrimary;
      comboTier = '';
    }

    final bounce = _comboController.isAnimating
        ? sin(_comboController.value * pi) * (combo >= 30 ? 10 : combo >= 10 ? 7 : 4)
        : 0.0;

    return Positioned(
      right: 16,
      top: 50,
      child: Transform.translate(
        offset: Offset(0, -bounce),
        child: Container(
          width: 80,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          decoration: GameTheme.pixelPanelDecoration(
            fillColor: GameTheme.bgPanel.withValues(alpha: 0.9),
            glow: combo >= 10,
            glowColor: comboColor,
          ),
          child: Column(
            children: [
              Text(
                '$combo',
                style: GameTheme.pixel(
                  fontSize: combo >= 20 ? 16 : 14,
                  color: comboColor,
                  shadows: combo >= 20
                      ? [
                          Shadow(
                              color: comboColor.withValues(alpha: 0.6),
                              blurRadius: 8)
                        ]
                      : null,
                ),
              ),
              if (comboTier.isNotEmpty)
                AnimatedBuilder(
                  animation: _comboPulse,
                  builder: (context, _) {
                    return Opacity(
                      opacity:
                          combo >= 30 ? 0.7 + _comboPulse.value * 0.3 : 1.0,
                      child: Text(comboTier,
                          style: GameTheme.pixel(
                            fontSize: 6,
                            color: comboColor,
                            letterSpacing: 1,
                          )),
                    );
                  },
                ),
              const SizedBox(height: 2),
              Text(
                'x${comboMult.toStringAsFixed(1)}',
                style: GameTheme.pixel(
                  fontSize: 7,
                  color: comboColor.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 4),
              GameTheme.pixelProgressBar(
                  value: timerPercent, height: 5, fillColor: comboColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBossBar(RunnerGame game) {
    final boss = game.activeBoss!;
    return Positioned(
      top: 32,
      left: 80,
      right: 80,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: GameTheme.pixelPanelDecoration(
          fillColor: GameTheme.bgCard,
          glow: true,
          glowColor: GameTheme.accentRed,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Icon(Icons.warning_amber_rounded,
                      color: GameTheme.accentRed, size: 14),
                  const SizedBox(width: 4),
                  Text('BOSS',
                      style: GameTheme.pixel(
                        fontSize: 8,
                        color: GameTheme.accentRed,
                        letterSpacing: 2,
                      )),
                ]),
                Text(
                  '${(boss.timePercent * 10).toStringAsFixed(1)}s',
                  style: GameTheme.pixel(
                    fontSize: 7,
                    color: boss.timePercent > 0.5
                        ? GameTheme.accentGreen
                        : GameTheme.accentRed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            GameTheme.pixelProgressBar(
                value: boss.hpPercent,
                height: 10,
                fillGradient: GameTheme.gradientRed),
            const SizedBox(height: 3),
            GameTheme.pixelProgressBar(
              value: 1.0 - boss.timePercent,
              height: 4,
              fillColor: boss.timePercent > 0.5
                  ? GameTheme.accentGreen
                  : GameTheme.accentOrange,
            ),
            if (game.tapCombo >= 3) ...[
              const SizedBox(height: 4),
              Text(
                'TAP COMBO x${game.tapCombo}',
                style: GameTheme.pixel(
                  fontSize: 7,
                  color: game.tapCombo >= 10
                      ? GameTheme.accentGold
                      : GameTheme.accentOrange,
                  letterSpacing: 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherInfo(RunnerGame game) {
    return Positioned(
      bottom: 12,
      left: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (game.activeEventName != null) _buildEventBanner(game),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: GameTheme.pixelCardDecoration(
              fillColor: GameTheme.bgDeep.withValues(alpha: 0.7),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(game.weatherManager.weatherEmoji,
                    style: const TextStyle(fontSize: 11)),
                const SizedBox(width: 5),
                Text(
                  '${game.weatherManager.timeDisplayName} ${game.weatherManager.weatherDisplayName}',
                  style: GameTheme.bodySmall.copyWith(fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventBanner(RunnerGame game) {
    Color eventColor;
    IconData eventIcon;
    if (game.isGoldenHour) {
      eventColor = GameTheme.accentGold;
      eventIcon = Icons.star;
    } else if (game.isMeteorShower) {
      eventColor = GameTheme.accent;
      eventIcon = Icons.grain;
    } else {
      eventColor = GameTheme.accentOrange;
      eventIcon = Icons.pets;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: GameTheme.pixelCardDecoration(
        fillColor: eventColor.withValues(alpha: 0.2),
        borderColor: eventColor.withValues(alpha: 0.5),
        glow: true,
        glowColor: eventColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(eventIcon, color: eventColor, size: 12),
          const SizedBox(width: 6),
          Text(
            '${game.activeEventName}  ${game.activeEventTimeLeft.toStringAsFixed(0)}s',
            style: GameTheme.pixel(fontSize: 7, color: eventColor),
          ),
        ],
      ),
    );
  }

  Widget _buildBonusBanner(RunnerGame game) {
    final bonus = game.bonusStageManager;
    final isUrgent = bonus.timeLeft < 2.0;
    final bannerColor = isUrgent ? GameTheme.accentRed : GameTheme.accentGold;
    return Positioned(
      top: 32,
      left: 100,
      right: 100,
      child: ShimmerGlow(
        glowColor: bannerColor,
        intensity: isUrgent ? 0.6 : 0.4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: GameTheme.pixelPanelDecoration(
            fillColor: bannerColor.withValues(alpha: isUrgent ? 0.25 : 0.15),
            glow: true,
            glowColor: bannerColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isUrgent ? Icons.timer : Icons.star,
                  color: bannerColor, size: 16),
              const SizedBox(width: 8),
              Text(
                'BONUS  ${bonus.timeLeft.toStringAsFixed(1)}s',
                style: GameTheme.pixel(
                  fontSize: isUrgent ? 11 : 9,
                  color: bannerColor,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: GameTheme.pixelProgressBar(
                  value: 1.0 - bonus.progress,
                  height: 6,
                  fillGradient: GameTheme.gradientGold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(RunnerGame game) {
    return Positioned(
      bottom: 10,
      right: 12,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (game.companionManager.ownedCount > 0)
            _PixelActionButton(
              icon: Icons.pets,
              label:
                  '${game.companionManager.equippedIds.length}/${game.companionManager.maxSlots}',
              color: GameTheme.accentOrange,
              onTap: () => game.openCompanionScreen(),
            ),
          if (game.canAscend)
            PixelSparkle(
              color: GameTheme.accentGold,
              child: _PixelActionButton(
                icon: Icons.auto_awesome,
                label: 'ASC',
                color: GameTheme.accentGold,
                glow: true,
                onTap: () => game.openAscensionScreen(),
              ),
            ),
          if (game.ascensionManager.ascensionCount > 0)
            _PixelActionButton(
              icon: Icons.auto_awesome,
              label: '${game.ascensionManager.souls}',
              color: GameTheme.accentPurple,
              onTap: () => game.openSoulShop(),
            ),
          _PixelActionButton(
            icon: Icons.assignment,
            label: '${game.missionManager.completedDailyCount}/3',
            color: GameTheme.accent,
            onTap: () => game.openMissionScreen(),
          ),
          _PixelActionButton(
            icon: Icons.emoji_events_rounded,
            label: '${game.achievementManager.completedCount}',
            color: GameTheme.accentGold,
            onTap: () => game.openAchievementScreen(),
          ),
          _PixelActionButton(
            icon: Icons.shopping_bag_rounded,
            label: 'SHOP',
            color: GameTheme.accent,
            onTap: () => game.toggleShop(),
          ),
        ],
      ),
    );
  }

  Widget _buildModeIndicator(RunnerGame game) {
    return Positioned(
      top: 10,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: GameTheme.pixelCardDecoration(
            fillColor: game.isActiveMode
                ? GameTheme.accentGreen.withValues(alpha: 0.2)
                : GameTheme.bgCard.withValues(alpha: 0.5),
            borderColor: game.isActiveMode
                ? GameTheme.accentGreen.withValues(alpha: 0.5)
                : GameTheme.pixelBorder,
          ),
          child: Text(
            game.isActiveMode ? 'ACTIVE' : 'IDLE',
            style: GameTheme.pixel(
              fontSize: 6,
              color: game.isActiveMode
                  ? GameTheme.accentGreen
                  : GameTheme.textMuted,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZoneIndicator(RunnerGame game) {
    final isDanger = game.levelGenerator.isDangerZone;
    final color = isDanger ? GameTheme.accentRed : GameTheme.accentGreen;
    final label = isDanger ? 'DANGER x3' : 'PEACE';
    final icon = isDanger ? Icons.warning_amber_rounded : Icons.park;

    return Positioned(
      top: 28,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: GameTheme.pixelCardDecoration(
            fillColor: color.withValues(alpha: 0.2),
            borderColor: color.withValues(alpha: 0.5),
            glow: true,
            glowColor: color,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 12),
              const SizedBox(width: 6),
              Text(
                label,
                style: GameTheme.pixel(
                  fontSize: 7,
                  color: color,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PixelHudChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  final AnimationController? flashAnimation;
  const _PixelHudChip({
    required this.icon,
    required this.value,
    required this.color,
    this.flashAnimation,
  });

  @override
  Widget build(BuildContext context) {
    Widget chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: GameTheme.pixelCardDecoration(
        fillColor: GameTheme.bgDeep.withValues(alpha: 0.75),
        borderColor: color.withValues(alpha: 0.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            value,
            style: GameTheme.pixel(fontSize: 9, color: color),
          ),
        ],
      ),
    );

    if (flashAnimation != null) {
      return AnimatedBuilder(
        animation: flashAnimation!,
        builder: (context, _) {
          final flash = (1.0 - flashAnimation!.value);
          final glowAlpha = flash * 0.5;
          return Container(
            decoration: glowAlpha > 0.01
                ? BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: glowAlpha),
                        blurRadius: 16 * flash,
                        spreadRadius: 3 * flash,
                      ),
                    ],
                  )
                : null,
            child: Transform.scale(
              scale: 1.0 + flash * 0.15,
              child: chip,
            ),
          );
        },
      );
    }
    return chip;
  }
}

class _PixelActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool glow;
  final VoidCallback onTap;
  const _PixelActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.glow = false,
    required this.onTap,
  });

  @override
  State<_PixelActionButton> createState() => _PixelActionButtonState();
}

class _PixelActionButtonState extends State<_PixelActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.9 : 1.0,
          duration: const Duration(milliseconds: 80),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: GameTheme.pixelCardDecoration(
              fillColor: _pressed
                  ? widget.color.withValues(alpha: 0.25)
                  : widget.color.withValues(alpha: 0.12),
              borderColor: _pressed
                  ? widget.color.withValues(alpha: 0.6)
                  : widget.color.withValues(alpha: 0.35),
              glow: widget.glow || _pressed,
              glowColor: widget.color,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, color: widget.color, size: 12),
                const SizedBox(width: 4),
                Text(
                  widget.label,
                  style: GameTheme.pixel(fontSize: 6, color: widget.color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
