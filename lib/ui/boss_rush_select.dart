import 'package:flutter/material.dart';
import '../classes/player_class.dart';
import '../bosses/boss_factory.dart';
import '../game/boss_rush_game.dart';
import '../main.dart';

class BossRushSelectScreen extends StatelessWidget {
  final PlayerClassType playerClass;

  const BossRushSelectScreen({super.key, required this.playerClass});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0A0A), Color(0xFF2A1A1A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white54),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    const Text(
                      'BOSS RUSH',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    return _BossCard(
                      stageIndex: index,
                      playerClass: playerClass,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BossCard extends StatelessWidget {
  final int stageIndex;
  final PlayerClassType playerClass;

  const _BossCard({
    required this.stageIndex,
    required this.playerClass,
  });

  @override
  Widget build(BuildContext context) {
    final bossName = BossFactory.getBossName(stageIndex);
    final stageName = StageThemes.getStageName(stageIndex);
    final bgColor = StageThemes.getBackgroundColor(stageIndex);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GameScreen(
              stageIndex: stageIndex,
              playerClass: playerClass,
              bossRushMode: true,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              bossName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              stageName,
              style: const TextStyle(color: Colors.white38, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}
