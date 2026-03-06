import 'package:flutter/material.dart';
import '../main.dart';
import '../bosses/boss_factory.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            const Text(
              'BOSS RUSH',
              style: TextStyle(
                color: Colors.white,
                fontSize: 56,
                fontWeight: FontWeight.w900,
                letterSpacing: 8,
                shadows: [
                  Shadow(color: Colors.red, blurRadius: 20),
                  Shadow(color: Colors.red, blurRadius: 40),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'DEFEAT THEM ALL',
              style: TextStyle(
                color: Colors.red.shade300,
                fontSize: 14,
                letterSpacing: 6,
              ),
            ),
            const SizedBox(height: 48),
            // Boss selection grid
            SizedBox(
              width: 500,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: List.generate(8, (i) => _BossCard(index: i)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BossCard extends StatelessWidget {
  final int index;

  const _BossCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final isAvailable = BossFactory.isBossAvailable(index);
    final name = BossFactory.getBossName(index);

    return GestureDetector(
      onTap: isAvailable
          ? () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GameScreen(bossIndex: index),
                ),
              );
            }
          : null,
      child: Container(
        width: 110,
        height: 80,
        decoration: BoxDecoration(
          color: isAvailable ? const Color(0xFF1A1A2E) : const Color(0xFF0D0D1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAvailable ? Colors.red.shade700 : Colors.grey.shade800,
            width: isAvailable ? 2 : 1,
          ),
          boxShadow: isAvailable
              ? [BoxShadow(color: Colors.red.withValues(alpha: 0.2), blurRadius: 8)]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${index + 1}',
              style: TextStyle(
                color: isAvailable ? Colors.white : Colors.grey.shade700,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isAvailable ? name : '???',
              style: TextStyle(
                color: isAvailable ? Colors.white70 : Colors.grey.shade800,
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
