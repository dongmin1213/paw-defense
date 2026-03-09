import 'package:flutter/material.dart';
import '../classes/player_class.dart';
import '../data/game_data.dart';
import '../game/boss_rush_game.dart';
import '../bosses/boss_factory.dart';
import '../main.dart';

class OverworldScreen extends StatelessWidget {
  final PlayerClassType playerClass;

  const OverworldScreen({super.key, required this.playerClass});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A1A0A), Color(0xFF1A2A1A), Color(0xFF0A1A2E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white54),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    Text(
                      'WORLD MAP',
                      style: TextStyle(
                        color: Colors.amber.shade200,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                    const Spacer(),
                    // Class indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: PlayerClassData.get(playerClass).accentColor,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        PlayerClassData.get(playerClass).name,
                        style: TextStyle(
                          color: PlayerClassData.get(playerClass).accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Stage map
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: Row(
                      children: List.generate(8, (index) {
                        return Row(
                          children: [
                            _StageNode(
                              stageIndex: index,
                              playerClass: playerClass,
                            ),
                            if (index < 7)
                              Container(
                                width: 40,
                                height: 2,
                                color: Colors.white24,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                              ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StageNode extends StatelessWidget {
  final int stageIndex;
  final PlayerClassType playerClass;

  const _StageNode({
    required this.stageIndex,
    required this.playerClass,
  });

  @override
  Widget build(BuildContext context) {
    final stageName = StageThemes.getStageName(stageIndex);
    final bossName = BossFactory.getBossName(stageIndex);
    final bgColor = StageThemes.getBackgroundColor(stageIndex);
    final isUnlocked = GameData.instance.isStageUnlocked(stageIndex);
    final isCleared = stageIndex <= GameData.instance.maxClearedStage;

    return GestureDetector(
      onTap: isUnlocked
          ? () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GameScreen(
                    stageIndex: stageIndex,
                    playerClass: playerClass,
                  ),
                ),
              );
            }
          : null,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isUnlocked ? bgColor : Colors.grey.shade900,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCleared
                ? Colors.amber
                : isUnlocked
                    ? Colors.amber.withValues(alpha: 0.5)
                    : Colors.white12,
            width: isCleared ? 2 : 1.5,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: bgColor.withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isUnlocked)
              const Icon(Icons.lock, color: Colors.white24, size: 28)
            else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${stageIndex + 1}',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isCleared) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.check_circle, color: Colors.greenAccent, size: 14),
                  ],
                ],
              ),
            ],
            const SizedBox(height: 4),
            Text(
              isUnlocked ? stageName : '???',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isUnlocked ? Colors.white : Colors.white24,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isUnlocked ? bossName : '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
