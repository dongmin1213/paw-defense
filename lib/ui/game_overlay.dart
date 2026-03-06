import 'package:flutter/material.dart';
import '../game/boss_rush_game.dart';
import '../utils/constants.dart';

class GameOverlay extends StatelessWidget {
  final BossRushGame game;

  const GameOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 8,
          left: 16,
          right: 16,
          child: _TopHud(game: game),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _ControlButtons(game: game),
        ),
      ],
    );
  }
}

class _TopHud extends StatefulWidget {
  final BossRushGame game;

  const _TopHud({required this.game});

  @override
  State<_TopHud> createState() => _TopHudState();
}

class _TopHudState extends State<_TopHud> {
  @override
  void initState() {
    super.initState();
    _startUpdate();
  }

  void _startUpdate() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBossPhase = widget.game.currentPhase == GamePhase.boss;

    return Row(
      children: [
        _buildPlayerHp(),
        const SizedBox(width: 12),
        _buildSpecialGauge(),
        const SizedBox(width: 8),
        // Phase indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isBossPhase
                ? Colors.red.withValues(alpha: 0.3)
                : Colors.green.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            isBossPhase ? 'BOSS' : 'EXPLORE',
            style: TextStyle(
              color: isBossPhase ? Colors.red : Colors.greenAccent,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Spacer(),
        if (isBossPhase) Expanded(flex: 3, child: _buildBossHp()),
      ],
    );
  }

  Widget _buildPlayerHp() {
    return Row(
      children: List.generate(widget.game.classData.maxHp, (i) {
        final isFilled = i < widget.game.playerHp;
        return Padding(
          padding: const EdgeInsets.only(right: 3),
          child: Icon(
            isFilled ? Icons.favorite : Icons.favorite_border,
            color: isFilled ? Colors.red : Colors.red.shade900,
            size: 20,
          ),
        );
      }),
    );
  }

  Widget _buildSpecialGauge() {
    final percentage = widget.game.specialGauge / GameConstants.specialGaugeMax;
    final isFull = widget.game.specialGauge >= GameConstants.specialGaugeMax;
    return Container(
      width: 50,
      height: 8,
      decoration: BoxDecoration(
        border: Border.all(
          color: isFull ? Colors.amber : Colors.white30,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: percentage,
        child: Container(
          decoration: BoxDecoration(
            color: isFull ? Colors.amber : GameConstants.specialGaugeColor.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  Widget _buildBossHp() {
    final boss = widget.game.boss;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          boss.bossName,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: GameConstants.hpBackgroundColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white24, width: 0.5),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: boss.hpPercentage,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade700, Colors.red.shade400],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ControlButtons extends StatefulWidget {
  final BossRushGame game;

  const _ControlButtons({required this.game});

  @override
  State<_ControlButtons> createState() => _ControlButtonsState();
}

class _ControlButtonsState extends State<_ControlButtons> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildDPad(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildDPad() {
    return Row(
      children: [
        _DirectionButton(
          icon: Icons.chevron_left,
          onPressed: () => widget.game.player.moveDirection = -1,
          onReleased: () {
            if (widget.game.player.moveDirection == -1) {
              widget.game.player.moveDirection = 0;
            }
          },
        ),
        const SizedBox(width: 8),
        _DirectionButton(
          icon: Icons.chevron_right,
          onPressed: () => widget.game.player.moveDirection = 1,
          onReleased: () {
            if (widget.game.player.moveDirection == 1) {
              widget.game.player.moveDirection = 0;
            }
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final isSpecialReady =
        widget.game.specialGauge >= GameConstants.specialGaugeMax;
    final classColor = widget.game.classData.accentColor;

    return Row(
      children: [
        _ActionButton(
          label: 'ATK',
          color: classColor,
          onPressed: () => widget.game.player.wantsShoot = true,
          onReleased: () => widget.game.player.wantsShoot = false,
        ),
        const SizedBox(width: 6),
        _ActionButton(
          label: 'JUMP',
          color: Colors.blue.shade700,
          onTap: () => widget.game.player.wantsJump = true,
        ),
        const SizedBox(width: 6),
        _ActionButton(
          label: 'DASH',
          color: Colors.cyan.shade700,
          onTap: () => widget.game.player.wantsDash = true,
        ),
        const SizedBox(width: 6),
        _ActionButton(
          label: 'SKILL',
          color: classColor.withValues(alpha: 0.7),
          onTap: () => widget.game.player.wantsSkill = true,
        ),
        const SizedBox(width: 6),
        _ActionButton(
          label: 'SP',
          color: isSpecialReady ? Colors.orange : Colors.grey.shade700,
          onTap: () => widget.game.player.wantsSpecial = true,
        ),
      ],
    );
  }
}

class _DirectionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final VoidCallback onReleased;

  const _DirectionButton({
    required this.icon,
    required this.onPressed,
    required this.onReleased,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onPressed(),
      onTapUp: (_) => onReleased(),
      onTapCancel: () => onReleased(),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white70, size: 28),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final VoidCallback? onPressed;
  final VoidCallback? onReleased;

  const _ActionButton({
    required this.label,
    required this.color,
    this.onTap,
    this.onPressed,
    this.onReleased,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        onTap?.call();
        onPressed?.call();
      },
      onTapUp: (_) => onReleased?.call(),
      onTapCancel: () => onReleased?.call(),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.5),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
