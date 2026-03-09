import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'classes/player_class.dart';
import 'data/game_data.dart';
import 'game/boss_rush_game.dart';
import 'ui/game_overlay.dart';
import 'ui/main_menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GameData.instance.init();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const BossRushApp());
}

class BossRushApp extends StatelessWidget {
  const BossRushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "The Bichon's Odyssey",
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const MainMenuScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  final int stageIndex;
  final PlayerClassType playerClass;
  final bool bossRushMode;

  const GameScreen({
    super.key,
    required this.stageIndex,
    required this.playerClass,
    this.bossRushMode = false,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late BossRushGame game;

  @override
  void initState() {
    super.initState();
    game = BossRushGame(
      stageIndex: widget.stageIndex,
      playerClass: widget.playerClass,
      bossRushMode: widget.bossRushMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GameWidget(
            game: game,
            overlayBuilderMap: {
              'GameOverlay': (context, BossRushGame game) {
                return GameOverlay(game: game);
              },
              'GameOver': (context, BossRushGame game) {
                return _GameOverScreen(game: game);
              },
              'Victory': (context, BossRushGame game) {
                return _VictoryScreen(
                  game: game,
                  stageIndex: widget.stageIndex,
                );
              },
            },
          ),
        ],
      ),
    );
  }
}

class _GameOverScreen extends StatelessWidget {
  final BossRushGame game;

  const _GameOverScreen({required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GAME OVER',
              style: TextStyle(
                color: Colors.red,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                game.overlays.remove('GameOver');
                game.resetGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade800,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('RETRY', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('BACK TO MAP', style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }
}

class _VictoryScreen extends StatelessWidget {
  final BossRushGame game;
  final int stageIndex;

  const _VictoryScreen({required this.game, required this.stageIndex});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amber, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'VICTORY!',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              StageThemes.getStageName(stageIndex),
              style: const TextStyle(color: Colors.white60, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                const SizedBox(width: 6),
                Text(
                  '+${game.coinsEarned}',
                  style: const TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'CONTINUE',
                style: TextStyle(color: Colors.amber, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
