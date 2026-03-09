import 'dart:math';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';

import '../components/runner_player.dart';
import '../components/ground_segment.dart';
import '../components/parallax_layer.dart';
import '../components/boss.dart';
import '../components/coin.dart';
import '../components/weather_effect.dart';
import '../components/particle_effect.dart';
import '../systems/level_generator.dart';
import '../systems/upgrade_manager.dart';
import '../systems/ascension_manager.dart';
import '../systems/companion_manager.dart';
import '../systems/weather_manager.dart';
import '../systems/ad_manager.dart';
import '../systems/save_manager.dart';
import '../systems/offline_reward.dart';
import '../systems/game_feel.dart';
import '../systems/sound_manager.dart';
import '../ui/ui_effects.dart';
import '../systems/achievement_manager.dart';
import '../systems/daily_bonus_manager.dart';
import '../systems/bonus_stage_manager.dart';
import '../data/balance_config.dart';
import '../data/region_data.dart';
import '../utils/constants.dart';

class RunnerGame extends FlameGame with HasCollisionDetection, TapCallbacks {
  late RunnerPlayer player;
  late LevelGenerator levelGenerator;
  final UpgradeManager upgradeManager = UpgradeManager();
  final AscensionManager ascensionManager = AscensionManager();
  final CompanionManager companionManager = CompanionManager();
  final WeatherManager weatherManager = WeatherManager();
  final AdManager adManager = AdManager();
  late final SaveManager saveManager;
  late ParticleEffect particleEffect;
  late GameFeelSystem gameFeel;
  final AchievementManager achievementManager = AchievementManager();
  final DailyBonusManager dailyBonusManager = DailyBonusManager();
  late BonusStageManager bonusStageManager;
  late SoundManager soundManager;

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
  double _dustTimer = 0;

  // Boss
  Boss? activeBoss;

  // Special events
  bool isGoldenHour = false;
  double _goldenHourTimer = 0;
  bool isMeteorShower = false;
  double _meteorTimer = 0;
  bool isCompanionRally = false;
  double _companionRallyTimer = 0;
  double _specialEventCooldown = 0;
  final Random _eventRng = Random();

  // Offline reward pending
  OfflineRewardResult? pendingOfflineReward;

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
    saveManager.loadAscension(ascensionManager);
    saveManager.loadCompanions(companionManager);
    saveManager.loadAchievements(achievementManager);
    saveManager.loadDailyBonus(dailyBonusManager);
    currentRegionId = saveManager.currentRegion;

    // Initialize ad manager
    await adManager.init();

    // Calculate offline reward
    final reward = OfflineReward.calculate(
      lastOnlineTime: saveManager.lastOnlineTime,
      upgradeManager: upgradeManager,
      ascensionManager: ascensionManager,
      companionManager: companionManager,
      regionCoinMultiplier: currentRegion.coinMultiplier,
    );
    if (reward.coins > 0) {
      pendingOfflineReward = reward;
    }
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

    // Show offline reward popup if pending
    if (pendingOfflineReward != null) {
      overlays.add('OfflinePopup');
    }

    // Add parallax background layers
    world.add(ParallaxLayer(scrollFactor: 0.1, layerIndex: 0));
    world.add(ParallaxLayer(scrollFactor: 0.3, layerIndex: 1));
    world.add(ParallaxLayer(scrollFactor: 0.5, layerIndex: 2));

    // Create player
    player = RunnerPlayer();
    world.add(player);

    // Create initial ground segments
    _spawnInitialGround();

    // Level generator
    levelGenerator = LevelGenerator();
    world.add(levelGenerator);

    // Weather visual effect
    world.add(WeatherEffect());

    // Particle effect system
    particleEffect = ParticleEffect();
    world.add(particleEffect);

    // Game feel system (screen shake, hit stop, auto systems)
    gameFeel = GameFeelSystem();
    world.add(gameFeel);

    // Sound manager
    soundManager = SoundManager();
    soundManager.init();
    world.add(soundManager);

    // Bonus stage manager
    bonusStageManager = BonusStageManager();
    world.add(bonusStageManager);

    // Apply saved upgrades
    applyUpgrades();

    // Show HUD overlay
    overlays.add('RunnerHud');
    isPlaying = true;

    // Daily bonus popup (if not claimed today)
    if (dailyBonusManager.canClaim) {
      overlays.add('DailyBonus');
    }
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

    // 히트스탑 중이면 프레임 스킵
    if (gameFeel.isHitStopped) return;

    // 슬로모션 적용
    final effectiveDt = dt * gameFeel.timeScale;
    _gameTime += effectiveDt;

    // Update weather system
    weatherManager.update(effectiveDt);

    // Update camera to follow player + 쉐이크 오프셋 + 줌 펀치
    camera.viewfinder.position = Vector2(
      player.position.x - 150 + gameFeel.shakeOffset.x,
      gameFeel.shakeOffset.y,
    );
    camera.viewfinder.zoom = gameFeel.currentZoom;

    // Update distance
    distance = player.position.x - GameConstants.playerStartX;
    if (distance < 0) distance = 0;

    // Combo timer (includes companion bonus)
    if (combo > 0) {
      comboTimer -= dt;
      final comboTime = BalanceConfig.comboResetTime + companionManager.extraComboTime;
      if (comboTimer <= 0) {
        combo = upgradeManager.comboAfterTimeout(combo);
        if (combo > 0) {
          comboTimer = comboTime;
        }
      }
    }

    // Active/idle mode detection
    if (_gameTime - _lastTapTime > BalanceConfig.idleDetectionTime) {
      isActiveMode = false;
    }

    // Boss completion check
    if (activeBoss != null && activeBoss!.isDead) {
      levelGenerator.onBossComplete();
    }

    // Dust trail particles (only when on ground)
    _dustTimer += dt;
    if (_dustTimer > 0.08 && !player.isJumping) {
      _dustTimer = 0;
      particleEffect.spawnDustTrail(
        player.position.x,
        player.position.y + player.size.y,
      );
    }

    // Special events
    _updateSpecialEvents(dt);

    // Achievement tracking
    achievementManager.onDistanceUpdate(distance);
    achievementManager.onCoinsEarned(totalCoinsEarned);
    achievementManager.onComboUpdate(combo);
    achievementManager.onCompanionUpdate(companionManager.ownedCount);
    achievementManager.onRegionUpdate(ascensionManager.unlockedRegionIds.length);
    achievementManager.onAscension(ascensionManager.ascensionCount);
    achievementManager.checkAll();

    // Auto-save every 30 seconds
    _saveTimer += dt;
    if (_saveTimer >= 30.0) {
      _saveTimer = 0;
      saveGame();
    }
  }

  void _updateSpecialEvents(double dt) {
    // Cooldown between events
    if (_specialEventCooldown > 0) {
      _specialEventCooldown -= dt;
    }

    // Random event trigger (average every 10 minutes)
    if (_specialEventCooldown <= 0 && !isGoldenHour && !isMeteorShower && !isCompanionRally) {
      if (_eventRng.nextDouble() < dt / 600.0) {
        final roll = _eventRng.nextInt(3);
        _specialEventCooldown = 300; // 5 min cooldown after event
        switch (roll) {
          case 0:
            isGoldenHour = true;
            _goldenHourTimer = 20;
            UIEffectManager.instance.spawnImpactText(
              text: 'GOLDEN HOUR!',
              color: const Color(0xFFFFD54F),
              fontSize: 22,
              duration: 1.8,
            );
            UIEffectManager.instance.screenFlash(
              color: const Color(0xFFFFD54F),
              duration: 0.3,
              maxAlpha: 0.4,
            );
            break;
          case 1:
            isMeteorShower = true;
            _meteorTimer = 30;
            UIEffectManager.instance.spawnImpactText(
              text: 'METEOR SHOWER!',
              color: const Color(0xFF4FC3F7),
              fontSize: 22,
              duration: 1.8,
            );
            break;
          case 2:
            isCompanionRally = true;
            _companionRallyTimer = 60;
            UIEffectManager.instance.spawnImpactText(
              text: 'COMPANION RALLY!',
              color: const Color(0xFFFF9800),
              fontSize: 22,
              duration: 1.8,
            );
            break;
        }
      }
    }

    // Golden hour (all enemies golden, coins x5)
    if (isGoldenHour) {
      _goldenHourTimer -= dt;
      if (_goldenHourTimer <= 0) isGoldenHour = false;
    }

    // Meteor shower (coins rain from sky)
    if (isMeteorShower) {
      _meteorTimer -= dt;
      if (_meteorTimer <= 0) {
        isMeteorShower = false;
      } else if (_eventRng.nextDouble() < dt * 3) {
        // Spawn falling coins
        final cameraX = camera.viewfinder.position.x;
        final x = cameraX + _eventRng.nextDouble() * GameConstants.worldWidth;
        world.add(Coin(
          spawnPosition: Vector2(x, -10),
          value: 3,
        ));
      }
    }

    // Companion rally (5x spawn rate)
    if (isCompanionRally) {
      _companionRallyTimer -= dt;
      if (_companionRallyTimer <= 0) isCompanionRally = false;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!isPlaying) return;
    _lastTapTime = _gameTime;
    isActiveMode = true;

    // If boss is active, tap attacks boss
    if (activeBoss != null && !activeBoss!.isDead) {
      activeBoss!.onTapAttack();
      soundManager.playBossHit();
    }

    soundManager.playJump();
    player.jump();
  }

  void addCoins(double amount) {
    final comboBase = BalanceConfig.comboMultiplierPerStack + ascensionManager.extraComboMultiplier;
    final comboMult = 1.0 + combo * comboBase;
    final regionMult = currentRegion.coinMultiplier;
    final activeBonus = isActiveMode ? BalanceConfig.activePlayCoinBonus : 1.0;
    final upgradeMult = upgradeManager.coinMultiplier;
    final soulMult = ascensionManager.soulCoinMultiplier;
    final companionMult = companionManager.coinMultiplier;
    final weatherCoinMult = weatherManager.weatherCoinMultiplier;
    final timeCoinMult = weatherManager.timeCoinMultiplier;
    final goldenMult = isGoldenHour ? 5.0 : 1.0;
    final rainbowMult = weatherManager.currentWeather == WeatherType.rainbow ? 2.0 : 1.0;
    // 장갑 장비 효과: 처치 시 추가 코인 +30%
    final gauntletMult = ascensionManager.hasGauntlet ? 1.3 : 1.0;
    final total = amount * comboMult * regionMult * activeBonus * upgradeMult
        * soulMult * companionMult * weatherCoinMult * timeCoinMult * goldenMult
        * rainbowMult * gauntletMult;

    coins += total;
    totalCoinsEarned += total;
  }

  void addCombo(int amount) {
    final prevMilestone = (combo ~/ 10) * 10;
    combo += amount;
    comboTimer = BalanceConfig.comboResetTime + companionManager.extraComboTime;

    // 콤보 마일스톤 피드백 (10단위)
    final newMilestone = (combo ~/ 10) * 10;
    if (newMilestone > prevMilestone && newMilestone > 0) {
      soundManager.playComboMilestone(combo);
      UIEffectManager.instance.spawnImpactText(
        text: 'COMBO x$combo!',
        color: const Color(0xFF4FC3F7),
        fontSize: 20,
        duration: 1.2,
      );
    }
  }

  double get comboMultiplier {
    final base = BalanceConfig.comboMultiplierPerStack + ascensionManager.extraComboMultiplier;
    return 1.0 + combo * base;
  }

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

  // === Soul Shop ===

  void openSoulShop() {
    overlays.add('SoulShop');
    pauseEngine();
  }

  void closeSoulShop() {
    overlays.remove('SoulShop');
    resumeEngine();
  }

  // === Companion Screen ===

  void openCompanionScreen() {
    overlays.add('CompanionScreen');
    pauseEngine();
  }

  void closeCompanionScreen() {
    overlays.remove('CompanionScreen');
    resumeEngine();
  }

  // === Achievement Screen ===

  void openAchievementScreen() {
    overlays.add('AchievementScreen');
    pauseEngine();
  }

  void closeAchievementScreen() {
    overlays.remove('AchievementScreen');
    resumeEngine();
  }

  // === Daily Bonus ===

  void closeDailyBonus() {
    overlays.remove('DailyBonus');
  }

  // === Ascension ===

  bool get canAscend => ascensionManager.canAscend(totalCoinsEarned);

  void openAscensionScreen() {
    overlays.add('AscensionScreen');
    pauseEngine();
  }

  void closeAscensionScreen() {
    overlays.remove('AscensionScreen');
    if (!isPlaying) {
      // After ascension, go to main menu
      overlays.add('MainMenu');
    } else {
      resumeEngine();
    }
  }

  void executeAscension() {
    // 극적 초월 연출
    gameFeel.onAscension();
    soundManager.playAscension();
    UIEffectManager.instance.screenFlash(
      color: const Color(0xFFCE93D8),
      duration: 0.6,
      maxAlpha: 0.8,
    );
    UIEffectManager.instance.spawnImpactText(
      text: 'ASCENDED!',
      color: const Color(0xFFCE93D8),
      fontSize: 28,
      duration: 2.0,
    );

    ascensionManager.performAscension(totalCoinsEarned);

    // Reset regular upgrades and coins
    upgradeManager.resetAll();
    coins = 0;
    totalCoinsEarned = 0;
    distance = 0;
    combo = 0;
    comboTimer = 0;
    activeBoss = null;

    // Stop playing — will restart from menu
    isPlaying = false;
    overlays.remove('RunnerHud');

    // Clear world
    world.removeAll(world.children);

    // Save
    saveManager.resetForAscension();
    saveGame();
  }

  // === Region Change ===

  void changeRegion(String regionId) {
    if (ascensionManager.isRegionUnlocked(regionId)) {
      currentRegionId = regionId;
      saveManager.currentRegion = regionId;
    }
  }

  // === Upgrades ===

  void applyUpgrades() {
    if (upgradeManager.hasDoubleJump) {
      player.enableDoubleJump();
    }
  }

  // === Offline Popup ===

  void closeOfflinePopup() {
    overlays.remove('OfflinePopup');
    pendingOfflineReward = null;
  }

  // === Active event display ===

  String? get activeEventName {
    if (isGoldenHour) return '골든 아워';
    if (isMeteorShower) return '유성우';
    if (isCompanionRally) return '동료 집회';
    return null;
  }

  double get activeEventTimeLeft {
    if (isGoldenHour) return _goldenHourTimer;
    if (isMeteorShower) return _meteorTimer;
    if (isCompanionRally) return _companionRallyTimer;
    return 0;
  }

  /// Companion rally multiplier for level_generator
  double get companionSpawnMultiplier => isCompanionRally ? 5.0 : 1.0;

  // === Save ===

  void saveGame() {
    saveManager.saveGameState(
      coins: coins,
      totalCoinsEarned: totalCoinsEarned,
      highScore: distance,
      upgradeManager: upgradeManager,
      ascensionManager: ascensionManager,
      companionManager: companionManager,
      achievementManager: achievementManager,
      dailyBonusManager: dailyBonusManager,
      currentRegion: currentRegionId,
    );
  }
}
