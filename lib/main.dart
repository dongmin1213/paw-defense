import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/defense_game.dart';
import 'ui/defense_main_menu.dart';
import 'ui/defense_hud.dart';
import 'ui/wave_reward_screen.dart';
import 'ui/star_shop_screen.dart';
import 'ui/run_result_screen.dart';
import 'ui/defense_pause_screen.dart';
import 'ui/relic_selection_screen.dart';
import 'ui/tutorial_screen.dart';
import 'ui/settings_screen.dart';
import 'ui/achievement_screen.dart';
import 'ui/daily_screen.dart';
import 'ui/codex_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Immersive fullscreen
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const CastleDefenseApp());
}

class CastleDefenseApp extends StatelessWidget {
  const CastleDefenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '동물 성벽 지키기',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0D1A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4FC3F7),
          secondary: Color(0xFFFFD54F),
          surface: Color(0xFF141428),
        ),
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late DefenseGame _game;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _game = DefenseGame();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Pause audio when app goes to background
      _game.soundManager.onAppPaused();
      if (_game.isPlaying) {
        _game.saveRunState();
        _game.saveGame();
      }
    } else if (state == AppLifecycleState.resumed) {
      // Resume audio when app returns to foreground
      _game.soundManager.onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: _game,
        overlayBuilderMap: {
          'DefenseMainMenu': (context, game) =>
              DefenseMainMenu(game: game as DefenseGame),
          'DefenseHud': (context, game) =>
              DefenseHud(game: game as DefenseGame),
          'WaveReward': (context, game) =>
              WaveRewardScreen(game: game as DefenseGame),
          'StarShop': (context, game) =>
              StarShopScreen(game: game as DefenseGame),
          'RunResult': (context, game) {
            final g = game as DefenseGame;
            return RunResultScreen(
              game: g,
              wavesCleared: g.currentWave,
              goldEarned: g.runGoldEarned,
              starsEarned: g.lastRunStars,
              killCount: g.runKills,
            );
          },
          'Pause': (context, game) =>
              DefensePauseScreen(game: game as DefenseGame),
          'RelicSelection': (context, game) =>
              RelicSelectionScreen(game: game as DefenseGame),
          'Tutorial': (context, game) =>
              TutorialScreen(game: game as DefenseGame),
          'Settings': (context, game) =>
              SettingsScreen(game: game as DefenseGame),
          'Achievement': (context, game) =>
              AchievementScreen(game: game as DefenseGame),
          'Daily': (context, game) =>
              DailyScreen(game: game as DefenseGame),
          'Codex': (context, game) =>
              CodexScreen(game: game as DefenseGame),
        },
      ),
    );
  }
}
