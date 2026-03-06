import 'package:flutter/material.dart';
import '../classes/player_class.dart';
import 'overworld_screen.dart';
import 'boss_rush_select.dart';

class ClassSelectScreen extends StatefulWidget {
  final bool bossRushMode;

  const ClassSelectScreen({super.key, this.bossRushMode = false});

  @override
  State<ClassSelectScreen> createState() => _ClassSelectScreenState();
}

class _ClassSelectScreenState extends State<ClassSelectScreen> {
  PlayerClassType? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A1A), Color(0xFF1A1A3E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text(
                'SELECT YOUR CLASS',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: PlayerClassType.values.map((type) {
                    final data = PlayerClassData.get(type);
                    final isSelected = _selected == type;
                    return _ClassCard(
                      data: data,
                      isSelected: isSelected,
                      onTap: () => setState(() => _selected = type),
                    );
                  }).toList(),
                ),
              ),
              if (_selected != null) ...[
                _ClassStats(data: PlayerClassData.get(_selected!)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    final screen = widget.bossRushMode
                        ? BossRushSelectScreen(playerClass: _selected!)
                        : OverworldScreen(playerClass: _selected!);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => screen),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.amber, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.amber.withValues(alpha: 0.15),
                    ),
                    child: const Text(
                      'CONFIRM',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final PlayerClassData data;
  final bool isSelected;
  final VoidCallback onTap;

  const _ClassCard({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isSelected ? 110 : 100,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? data.accentColor : Colors.white24,
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? data.color.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Class icon placeholder
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomPaint(
                painter: _ClassIconPainter(data.type, data.color, data.accentColor),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              data.name,
              style: TextStyle(
                color: isSelected ? data.accentColor : Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              data.nameKo,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white38,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClassIconPainter extends CustomPainter {
  final PlayerClassType type;
  final Color color;
  final Color accent;

  _ClassIconPainter(this.type, this.color, this.accent);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Bichon head
    final white = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy - 4), 12, white);
    canvas.drawCircle(Offset(cx - 8, cy - 10), 5, white);
    canvas.drawCircle(Offset(cx + 8, cy - 10), 5, white);

    // Eyes
    final eye = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(cx - 3, cy - 5), 2, eye);
    canvas.drawCircle(Offset(cx + 3, cy - 5), 2, eye);
    canvas.drawCircle(Offset(cx, cy - 1), 1.5, eye);

    // Class-specific accessory
    final accentPaint = Paint()..color = accent;
    switch (type) {
      case PlayerClassType.knight:
        // Helmet
        canvas.drawRect(Rect.fromLTWH(cx - 10, cy - 18, 20, 6), Paint()..color = Colors.grey);
        // Sword
        canvas.drawRect(Rect.fromLTWH(cx + 12, cy - 8, 3, 24), Paint()..color = Colors.white70);
        break;
      case PlayerClassType.assassin:
        // Hood
        canvas.drawPath(
          Path()
            ..moveTo(cx - 12, cy - 6)
            ..lineTo(cx, cy - 22)
            ..lineTo(cx + 12, cy - 6)
            ..close(),
          Paint()..color = Colors.grey.shade800,
        );
        // Daggers
        canvas.drawRect(Rect.fromLTWH(cx + 10, cy, 2, 14), Paint()..color = Colors.white70);
        canvas.drawRect(Rect.fromLTWH(cx - 12, cy, 2, 14), Paint()..color = Colors.white70);
        break;
      case PlayerClassType.archer:
        // Hat
        canvas.drawPath(
          Path()
            ..moveTo(cx - 10, cy - 12)
            ..lineTo(cx, cy - 24)
            ..lineTo(cx + 10, cy - 12)
            ..close(),
          Paint()..color = Colors.green.shade800,
        );
        // Bow
        final bow = Paint()
          ..color = Colors.brown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawArc(Rect.fromLTWH(cx + 8, cy - 6, 10, 24), -1.2, 2.4, false, bow);
        break;
      case PlayerClassType.mage:
        // Wizard hat
        canvas.drawPath(
          Path()
            ..moveTo(cx - 14, cy - 10)
            ..lineTo(cx, cy - 28)
            ..lineTo(cx + 14, cy - 10)
            ..close(),
          Paint()..color = color,
        );
        // Staff orb
        canvas.drawCircle(Offset(cx + 14, cy - 4), 4, accentPaint);
        break;
      case PlayerClassType.gunner:
        // Bandana
        canvas.drawRect(Rect.fromLTWH(cx - 10, cy - 16, 20, 5), Paint()..color = Colors.red.shade700);
        // Cannon
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(cx + 6, cy + 2, 18, 8),
            const Radius.circular(2),
          ),
          Paint()..color = Colors.grey.shade700,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ClassStats extends StatelessWidget {
  final PlayerClassData data;

  const _ClassStats({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: data.accentColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              data.description,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatBar('HP', data.maxHp / 5, Colors.red),
              _StatBar('SPD', data.speed / 250, Colors.cyan),
              _StatBar('ATK', data.attackDamage / 4, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _StatBar(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ),
          Container(
            width: 60,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value.clamp(0, 1),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
