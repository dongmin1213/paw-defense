import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

class _TopHudState extends State<_TopHud> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  int _lastHp = 0;
  double _lastGauge = 0;
  double _lastBossHp = -1;
  GamePhase _lastPhase = GamePhase.exploration;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final g = widget.game;
    final bossHp = g.currentPhase == GamePhase.boss ? g.boss.hpPercentage : -1.0;
    // Only rebuild if values actually changed
    if (g.playerHp != _lastHp ||
        g.specialGauge != _lastGauge ||
        g.currentPhase != _lastPhase ||
        bossHp != _lastBossHp) {
      _lastHp = g.playerHp;
      _lastGauge = g.specialGauge;
      _lastPhase = g.currentPhase;
      _lastBossHp = bossHp;
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
    return _Joystick(
      onDirectionChanged: (dx) {
        widget.game.player.moveDirection = dx;
        if (dx != 0) {
          widget.game.player.facingDirection = dx > 0 ? 1 : -1;
        }
      },
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

class _Joystick extends StatefulWidget {
  final ValueChanged<double> onDirectionChanged;

  const _Joystick({required this.onDirectionChanged});

  @override
  State<_Joystick> createState() => _JoystickState();
}

class _JoystickState extends State<_Joystick> {
  static const double _baseRadius = 50;
  static const double _knobRadius = 20;
  static const double _deadZone = 0.15;

  Offset _knobOffset = Offset.zero;
  bool _isDragging = false;

  void _updateKnob(Offset localPosition) {
    final center = const Offset(_baseRadius, _baseRadius);
    var delta = localPosition - center;
    final distance = delta.distance;
    final maxDist = _baseRadius - _knobRadius;

    if (distance > maxDist) {
      delta = delta / distance * maxDist;
    }

    setState(() {
      _knobOffset = delta;
    });

    // Normalize x to -1..1
    final nx = delta.dx / maxDist;
    if (nx.abs() < _deadZone) {
      widget.onDirectionChanged(0);
    } else {
      widget.onDirectionChanged(nx.clamp(-1, 1));
    }
  }

  void _resetKnob() {
    setState(() {
      _knobOffset = Offset.zero;
      _isDragging = false;
    });
    widget.onDirectionChanged(0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        _isDragging = true;
        _updateKnob(details.localPosition);
      },
      onPanUpdate: (details) {
        _updateKnob(details.localPosition);
      },
      onPanEnd: (_) => _resetKnob(),
      onPanCancel: () => _resetKnob(),
      child: SizedBox(
        width: _baseRadius * 2,
        height: _baseRadius * 2,
        child: CustomPaint(
          painter: _JoystickPainter(
            knobOffset: _knobOffset,
            baseRadius: _baseRadius,
            knobRadius: _knobRadius,
            isDragging: _isDragging,
          ),
        ),
      ),
    );
  }
}

class _JoystickPainter extends CustomPainter {
  final Offset knobOffset;
  final double baseRadius;
  final double knobRadius;
  final bool isDragging;

  _JoystickPainter({
    required this.knobOffset,
    required this.baseRadius,
    required this.knobRadius,
    required this.isDragging,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Base circle
    final basePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, baseRadius - 2, basePaint);

    // Base ring
    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: isDragging ? 0.3 : 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, baseRadius - 2, ringPaint);

    // Direction indicators (L/R arrows)
    final arrowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    // Left arrow
    final leftArrow = Path()
      ..moveTo(center.dx - baseRadius + 14, center.dy)
      ..lineTo(center.dx - baseRadius + 22, center.dy - 6)
      ..lineTo(center.dx - baseRadius + 22, center.dy + 6)
      ..close();
    canvas.drawPath(leftArrow, arrowPaint);
    // Right arrow
    final rightArrow = Path()
      ..moveTo(center.dx + baseRadius - 14, center.dy)
      ..lineTo(center.dx + baseRadius - 22, center.dy - 6)
      ..lineTo(center.dx + baseRadius - 22, center.dy + 6)
      ..close();
    canvas.drawPath(rightArrow, arrowPaint);

    // Knob
    final knobCenter = center + knobOffset;
    final knobPaint = Paint()
      ..color = Colors.white.withValues(alpha: isDragging ? 0.5 : 0.25);
    canvas.drawCircle(knobCenter, knobRadius, knobPaint);

    // Knob border
    final knobBorder = Paint()
      ..color = Colors.white.withValues(alpha: isDragging ? 0.6 : 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(knobCenter, knobRadius, knobBorder);
  }

  @override
  bool shouldRepaint(covariant _JoystickPainter old) =>
      old.knobOffset != knobOffset || old.isDragging != isDragging;
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
