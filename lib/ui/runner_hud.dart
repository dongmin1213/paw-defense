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
  int _prevCombo = 0;
  double _displayCoins = 0;
  double _displayDistance = 0;

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
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _comboController.dispose();
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
          if (game.bonusStageManager.isActive)
            _buildBonusBanner(game),
          _buildWeatherInfo(game),
          _buildActionButtons(game),
          _buildModeIndicator(game),
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
          _HudInfoChip(
            icon: Icons.near_me,
            value: '${_displayDistance.toStringAsFixed(0)}m',
            color: GameTheme.textPrimary,
          ),
          const Spacer(),
          _HudInfoChip(
            icon: Icons.monetization_on,
            value: GameTheme.formatNumber(_displayCoins),
            color: GameTheme.accentGold,
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
        ? sin(_comboController.value * pi) * 4
        : 0.0;

    return Positioned(
      right: 16,
      top: 50,
      child: Transform.translate(
        offset: Offset(0, -bounce),
        child: Container(
          width: 80,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: GameTheme.bgPanel.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: comboColor.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: combo >= 10
                ? [BoxShadow(color: comboColor.withValues(alpha: 0.3), blurRadius: 12)]
                : null,
          ),
          child: Column(
            children: [
              Text(
                '$combo',
                style: TextStyle(
                  color: comboColor,
                  fontSize: combo >= 20 ? 28 : 24,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              if (comboTier.isNotEmpty)
                Text(comboTier, style: TextStyle(
                  color: comboColor, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1,
                )),
              const SizedBox(height: 2),
              Text(
                'x${comboMult.toStringAsFixed(1)}',
                style: TextStyle(color: comboColor.withValues(alpha: 0.8), fontSize: 11, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              GameTheme.progressBar(value: timerPercent, height: 3, fillColor: comboColor),
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
        decoration: GameTheme.cardDecoration(
          borderColor: GameTheme.accentRed.withValues(alpha: 0.3),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Icon(Icons.warning_amber_rounded, color: GameTheme.accentRed, size: 14),
                  const SizedBox(width: 4),
                  Text('BOSS', style: GameTheme.labelBold.copyWith(
                    color: GameTheme.accentRed, fontSize: 12, letterSpacing: 2,
                  )),
                ]),
                Text(
                  '${(boss.timePercent * 10).toStringAsFixed(1)}s',
                  style: GameTheme.bodySmall.copyWith(
                    color: boss.timePercent > 0.5 ? GameTheme.accentGreen : GameTheme.accentRed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            GameTheme.progressBar(value: boss.hpPercent, height: 8, fillGradient: GameTheme.gradientRed),
            const SizedBox(height: 3),
            GameTheme.progressBar(
              value: 1.0 - boss.timePercent, height: 3,
              fillColor: boss.timePercent > 0.5 ? GameTheme.accentGreen : GameTheme.accentOrange,
            ),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: GameTheme.glassDecoration(opacity: 0.1, borderRadius: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(game.weatherManager.weatherEmoji, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 5),
                Text(
                  '${game.weatherManager.timeDisplayName} · ${game.weatherManager.weatherDisplayName}',
                  style: GameTheme.bodySmall.copyWith(fontSize: 10),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [eventColor.withValues(alpha: 0.3), eventColor.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: eventColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(eventIcon, color: eventColor, size: 14),
          const SizedBox(width: 6),
          Text(
            '${game.activeEventName}  ${game.activeEventTimeLeft.toStringAsFixed(0)}s',
            style: GameTheme.labelBold.copyWith(color: eventColor, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildBonusBanner(RunnerGame game) {
    final bonus = game.bonusStageManager;
    return Positioned(
      top: 32,
      left: 100,
      right: 100,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              GameTheme.accentGold.withValues(alpha: 0.3),
              GameTheme.accentGold.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: GameTheme.accentGold.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, color: GameTheme.accentGold, size: 18),
            const SizedBox(width: 8),
            Text(
              'BONUS STAGE  ${bonus.timeLeft.toStringAsFixed(1)}s',
              style: GameTheme.labelBold.copyWith(
                color: GameTheme.accentGold,
                fontSize: 14,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: GameTheme.progressBar(
                value: 1.0 - bonus.progress,
                height: 4,
                fillGradient: GameTheme.gradientGold,
              ),
            ),
          ],
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
            _ActionButton(
              icon: Icons.pets,
              label: '${game.companionManager.equippedIds.length}/${game.companionManager.maxSlots}',
              color: GameTheme.accentOrange,
              onTap: () => game.openCompanionScreen(),
            ),
          if (game.canAscend)
            _ActionButton(
              icon: Icons.auto_awesome,
              label: '초월',
              color: GameTheme.accentGold,
              glow: true,
              onTap: () => game.openAscensionScreen(),
            ),
          if (game.ascensionManager.ascensionCount > 0)
            _ActionButton(
              icon: Icons.auto_awesome,
              label: '${game.ascensionManager.souls}',
              color: GameTheme.accentPurple,
              onTap: () => game.openSoulShop(),
            ),
          _ActionButton(
            icon: Icons.emoji_events_rounded,
            label: '${game.achievementManager.completedCount}',
            color: GameTheme.accentGold,
            onTap: () => game.openAchievementScreen(),
          ),
          _ActionButton(
            icon: Icons.shopping_bag_rounded,
            label: '상점',
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: game.isActiveMode
                ? GameTheme.accentGreen.withValues(alpha: 0.2)
                : GameTheme.textMuted.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: game.isActiveMode
                  ? GameTheme.accentGreen.withValues(alpha: 0.4)
                  : Colors.transparent,
            ),
          ),
          child: Text(
            game.isActiveMode ? 'ACTIVE' : 'IDLE',
            style: TextStyle(
              color: game.isActiveMode ? GameTheme.accentGreen : GameTheme.textMuted,
              fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class _HudInfoChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  const _HudInfoChip({required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: GameTheme.bgDeep.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool glow;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon, required this.label, required this.color,
    this.glow = false, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
            boxShadow: glow
                ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 10)]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
