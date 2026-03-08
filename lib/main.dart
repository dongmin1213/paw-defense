import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/runner_game.dart';
import 'systems/save_manager.dart';
import 'ui/runner_hud.dart';
import 'ui/upgrade_shop.dart';
import 'ui/main_menu.dart';
import 'ui/soul_shop.dart';
import 'ui/ascension_screen.dart';
import 'ui/companion_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to landscape
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Immersive fullscreen
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Initialize save manager
  final saveManager = SaveManager();
  await saveManager.init();

  runApp(BichonRunApp(saveManager: saveManager));
}

class BichonRunApp extends StatelessWidget {
  final SaveManager saveManager;

  const BichonRunApp({super.key, required this.saveManager});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "The Bichon's Run",
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: GameScreen(saveManager: saveManager),
    );
  }
}

class GameScreen extends StatefulWidget {
  final SaveManager saveManager;

  const GameScreen({super.key, required this.saveManager});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late RunnerGame _game;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _game = RunnerGame();
    _game.initSaveManager(widget.saveManager);
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
      if (_game.isPlaying) {
        _game.saveGame();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: _game,
        overlayBuilderMap: {
          'MainMenu': (context, game) => MainMenu(game: game as RunnerGame),
          'RunnerHud': (context, game) => RunnerHud(game: game as RunnerGame),
          'UpgradeShop': (context, game) => UpgradeShop(game: game as RunnerGame),
          'SoulShop': (context, game) => SoulShop(game: game as RunnerGame),
          'AscensionScreen': (context, game) => AscensionScreen(game: game as RunnerGame),
          'CompanionScreen': (context, game) => CompanionScreen(game: game as RunnerGame),
        },
      ),
    );
  }
}
