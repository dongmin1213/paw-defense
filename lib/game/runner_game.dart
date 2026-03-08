import 'package:flame/camera.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';

import '../components/runner_player.dart';
import '../components/ground_segment.dart';
import '../systems/level_generator.dart';
import '../systems/upgrade_manager.dart';
import '../systems/save_manager.dart';
import '../data/balance_config.dart';
import '../data/region_data.dart';
import '../utils/constants.dart';

class RunnerGame extends FlameGame with HasCollisionDetection, TapCallbacks {
  late RunnerPlayer player;
  late LevelGenerator levelGenerator;
  final UpgradeManager upgradeManager = UpgradeManager();
  late final SaveManager saveManager;

  // Game state
  double coins = 0;
  double totalCoinsEarned = 0;
  double distance = 0;
  int combo = 0;
  double comboTimer = 0;
  bool isActiveMode = true;
  bool isPlaying = false;
  bool isShopOpen = false;
  double _lastTapTime = 0;
  double _gameTime = 0;
  double _saveTimer = 0;

  // Current region
  String currentRegionId = 'meadow';

  RegionData get currentRegion => RegionDatabase.getRegion(currentRegionId);

  @override
  Color backgroundColor() => currentRegion.skyColor;

  Future<void> initSaveManager(SaveManager manager) async {
    saveManager = manager;
    // Load saved state
    coins = saveManager.coins;
    totalCoinsEarned = saveManager.totalCoinsEarned;
    saveManager.loadUpgrades(upgradeManager);
  }

  @override
  Future<void> onLoad() async {
    // Camera setup
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewport = FixedResolutionViewport(
      resolution: Vector2(GameConstants.worldWidth, GameConstants.worldHeight),
    );

    // Show main menu first
    overlays.add('MainMenu');
  }

  void startGame() {
    overlays.remove('MainMenu');

    // Create player
    player = RunnerPlayer();
    world.add(player);

    // Create initial ground segments
    _spawnInitialGround();

    // Level generator
    levelGenerator = LevelGenerator();
    world.add(levelGenerator);

    // Apply saved upgrades
    applyUpgrades();

    // Show HUD overlay
    overlays.add('RunnerHud');
    isPlaying = true;
  }

  void _spawnInitialGround() {
    final segmentCount = (GameConstants.worldWidth / GameConstants.groundSegmentWidth).ceil() + 2;
    for (var i = 0; i < segmentCount; i++) {
      world.add(GroundSegment(
        startX: i * GameConstants.groundSegmentWidth,
        region: currentRegion,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isPlaying) return;

    _gameTime += dt;

    // Update camera to follow player
    camera.viewfinder.position = Vector2(
      player.position.x - 150,
      0,
    );

    // Update distance
    distance = player.position.x - GameConstants.playerStartX;
    if (distance < 0) distance = 0;

    // Combo timer
    if (combo > 0) {
      comboTimer -= dt;
      if (comboTimer <= 0) {
        combo = upgradeManager.comboAfterTimeout(combo);
        if (combo > 0) {
          comboTimer = BalanceConfig.comboResetTime;
        }
      }
    }

    // Active/idle mode detection
    if (_gameTime - _lastTapTime > BalanceConfig.idleDetectionTime) {
      isActiveMode = false;
    }

    // Auto-save every 30 seconds
    _saveTimer += dt;
    if (_saveTimer >= 30.0) {
      _saveTimer = 0;
      saveGame();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!isPlaying) return;
    _lastTapTime = _gameTime;
    isActiveMode = true;
    player.jump();
  }

  void addCoins(double amount) {
    final comboMult = 1.0 + combo * BalanceConfig.comboMultiplierPerStack;
    final regionMult = currentRegion.coinMultiplier;
    final activeBonus = isActiveMode ? BalanceConfig.activePlayCoinBonus : 1.0;
    final upgradeMult = upgradeManager.coinMultiplier;
    final total = amount * comboMult * regionMult * activeBonus * upgradeMult;

    coins += total;
    totalCoinsEarned += total;
  }

  void addCombo(int amount) {
    combo += amount;
    comboTimer = BalanceConfig.comboResetTime;
  }

  double get comboMultiplier => 1.0 + combo * BalanceConfig.comboMultiplierPerStack;

  double get distanceInMeters => distance / 10.0;

  // === Shop ===

  void toggleShop() {
    if (isShopOpen) {
      overlays.remove('UpgradeShop');
      isShopOpen = false;
      resumeEngine();
    } else {
      overlays.add('UpgradeShop');
      isShopOpen = true;
      pauseEngine();
    }
  }

  // === Upgrades ===

  void applyUpgrades() {
    if (upgradeManager.hasDoubleJump) {
      player.enableDoubleJump();
    }
  }

  // === Save ===

  void saveGame() {
    saveManager.saveGameState(
      coins: coins,
      totalCoinsEarned: totalCoinsEarned,
      highScore: distance,
      upgradeManager: upgradeManager,
    );
  }
}
