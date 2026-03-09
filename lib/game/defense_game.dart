import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' show Colors;

import '../components/wall.dart';
import '../components/unit_slot.dart' as slot_component;
import '../components/defense_unit.dart' as unit_component;
import '../components/defense_enemy.dart';
import '../components/defense_particle.dart';
import '../systems/wave_manager.dart';
import '../systems/merge_manager.dart' as merge;
import '../systems/relic_manager.dart';
import '../systems/defense_game_feel.dart';
import '../systems/defense_upgrade_manager.dart';
import '../systems/defense_save_manager.dart';
import '../data/unit_data.dart';
import '../ui/defense_hud.dart' as hud;

/// Main game class for castle defense mode.
/// Portrait mode (400x700), fixed resolution viewport.
/// Manages all game state, spawning, overlays, and lifecycle.
class DefenseGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  // ── Viewport ──
  static const double gameWidth = 400;
  static const double gameHeight = 700;

  // ── Managers ──
  late WaveManager waveManager;
  late RelicManager relicManager;
  late DefenseGameFeel gameFeel;
  late DefenseUpgradeManager upgradeManager;
  late DefenseSaveManager saveManager;

  // ── Core Components ──
  late Wall wall;
  late DefenseParticle particleEffect;
  final List<merge.UnitSlot> _unitSlots = [];

  // ── Game State ──
  int gold = 0;
  int stars = 0;
  int souls = 0;
  int totalKills = 0;
  int totalRuns = 0;
  int highestWave = 0;
  int totalStarsEarned = 0;
  int totalBossKills = 0;
  int _runKills = 0;
  int _runGoldEarned = 0;

  bool isPlaying = false;
  bool _isPaused = false;

  // ── Unit placement cost ──
  int _unitsBought = 0;
  static const int baseUnitCost = 10;

  // ── Slot config ──
  int get maxSlots => 8 + upgradeManager.getLevel(DefenseUpgradeId.slotExpansion);

  // ── Unit icon mapping ──
  static const Map<String, String> _unitIcons = {
    'cat_archer': '🐱',
    'dog_warrior': '🐶',
    'rabbit_mage': '🐰',
    'bear_tanker': '🐻',
    'fox_assassin': '🦊',
    'bird_scout': '🐦',
  };

  static const List<String> _unitTypeIds = [
    'cat_archer',
    'dog_warrior',
    'rabbit_mage',
    'bear_tanker',
    'fox_assassin',
    'bird_scout',
  ];

  final Random _rng = Random();

  // ── Public accessors ──
  int get currentWave => waveManager.currentWave;

  /// Unit slots exposed for UI (HUD).
  List<hud.UnitSlot> get unitSlots {
    return _unitSlots.map((s) {
      final u = s.unit;
      if (u == null) {
        return const hud.UnitSlot();
      }
      return hud.UnitSlot(
        icon: _unitIcons[u.unitTypeId] ?? '❓',
        level: u.level,
        isOccupied: true,
        unitType: u.unitTypeId,
      );
    }).toList();
  }

  DefenseGame()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: gameWidth,
            height: gameHeight,
          ),
        );

  @override
  Future<void> onLoad() async {
    // Background color
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.backdrop.add(RectangleComponent(
      size: Vector2(gameWidth, gameHeight),
      paint: _bgPaint,
    ));

    // Initialize managers
    upgradeManager = DefenseUpgradeManager();
    saveManager = DefenseSaveManager();
    await saveManager.init();

    // Load persistent data
    saveManager.loadUpgrades(upgradeManager);
    stars = saveManager.stars;
    souls = saveManager.souls;
    highestWave = saveManager.highestWave;
    totalRuns = saveManager.totalRuns;
    totalKills = saveManager.totalKills;
    totalStarsEarned = saveManager.totalStarsEarned;
    totalBossKills = saveManager.totalBossKills;

    // Initialize components
    wall = Wall();
    wall.position = Vector2(gameWidth / 2, gameHeight / 2 - 40);
    world.add(wall);

    particleEffect = DefenseParticle();
    world.add(particleEffect);

    gameFeel = DefenseGameFeel();
    world.add(gameFeel);

    waveManager = WaveManager();
    world.add(waveManager);

    relicManager = RelicManager();

    // Initialize unit slots
    _initSlots();

    // Show main menu
    overlays.add('DefenseMainMenu');
  }

  static final _bgPaint = () {
    final paint = basicPaint();
    paint.color = const Color(0xFF1A1A2E);
    return paint;
  }();

  static Paint basicPaint() => Paint()..isAntiAlias = false;

  void _initSlots() {
    _unitSlots.clear();
    for (int i = 0; i < maxSlots; i++) {
      _unitSlots.add(merge.UnitSlot(slotIndex: i));
    }

    // Add visual slot components around wall
    _refreshSlotComponents();
  }

  void _refreshSlotComponents() {
    // Remove existing slot components
    world.children
        .whereType<slot_component.UnitSlot>()
        .toList()
        .forEach((c) => c.removeFromParent());

    // Remove existing unit components
    world.children
        .whereType<unit_component.DefenseUnit>()
        .toList()
        .forEach((c) => c.removeFromParent());

    final positions = slot_component.UnitSlot.generateSlotPositions(
      center: wall.position,
      count: maxSlots,
    );

    for (int i = 0; i < maxSlots; i++) {
      final slotComp = slot_component.UnitSlot(slotIndex: i);
      slotComp.position = positions[i];
      world.add(slotComp);

      // If slot has a unit, add the visual unit component
      final unitData = _unitSlots[i].unit;
      if (unitData != null) {
        final unitComp = unit_component.DefenseUnit(
          unitTypeId: unitData.unitTypeId,
          level: unitData.level,
          isEvolved: unitData.isEvolved,
          slotIndex: i,
        );
        unitComp.position = positions[i];
        world.add(unitComp);
      }
    }
  }

  // ══════════════════════════════════════
  // Game Lifecycle
  // ══════════════════════════════════════

  /// Start a new game run.
  void startGame() {
    // Reset run state
    gold = 50 + upgradeManager.getLevel(DefenseUpgradeId.startUnits) * 10;
    _runKills = 0;
    _runGoldEarned = 0;
    _unitsBought = 0;
    isPlaying = true;
    _isPaused = false;

    // Reset wall
    wall.currentHp = wall.maxHp;
    wall.level = 1;
    final wallHpMult = upgradeManager.wallHpMultiplier;
    wall.maxHp = 100.0 * wallHpMult;
    wall.currentHp = wall.maxHp;

    // Reset relics
    relicManager.reset();

    // Clear existing slots and enemies
    _clearAllUnits();
    _clearAllEnemies();

    // Reinit slots
    _initSlots();

    // Start wave system
    waveManager.reset();
    waveManager.startFirstWave();

    // Update overlays
    overlays.remove('DefenseMainMenu');
    overlays.remove('RunResult');
    overlays.remove('StarShop');
    overlays.add('DefenseHud');

    totalRuns++;
  }

  /// Pause the game.
  void pauseGame() {
    _isPaused = true;
    // Could show a pause overlay
  }

  /// Resume the game.
  void resumeGame() {
    _isPaused = false;
  }

  /// Save persistent game data.
  void saveGame() {
    saveManager.saveAll(
      stars: stars,
      upgrades: upgradeManager,
      souls: souls,
      highestWave: highestWave,
      ascensionCount: 0,
      totalKills: totalKills,
      totalRuns: totalRuns,
      totalStarsEarned: totalStarsEarned,
      totalBossKills: totalBossKills,
    );
  }

  // ══════════════════════════════════════
  // Game Update
  // ══════════════════════════════════════

  @override
  void update(double dt) {
    if (!isPlaying || _isPaused) {
      super.update(dt);
      return;
    }

    // Apply game feel effects
    if (gameFeel.isHitStopped) {
      // During hit-stop, only update game feel (to decrement timer)
      gameFeel.update(dt);
      return;
    }

    final effectiveDt = dt * gameFeel.timeScale;
    super.update(effectiveDt);

    // Wall regen from upgrades
    final regen = upgradeManager.wallRegenPerSec;
    if (regen > 0 && wall.currentHp < wall.maxHp && !wall.isDestroyed) {
      wall.heal(regen * effectiveDt);
    }
  }

  // ══════════════════════════════════════
  // Spawning
  // ══════════════════════════════════════

  /// Spawn an enemy. Called by WaveManager.
  void spawnEnemy({
    required String typeId,
    required Vector2 position,
    required double hp,
    required double speed,
  }) {
    // Determine stats based on enemy type
    double damage;
    double atkSpeed;
    int goldDrop;
    bool isFlying;

    switch (typeId) {
      case 'bat':
        damage = 3;
        atkSpeed = 1.5;
        goldDrop = 3;
        isFlying = true;
        break;
      case 'goblin':
        damage = 5;
        atkSpeed = 1.2;
        goldDrop = 4;
        isFlying = false;
        break;
      case 'orc':
        damage = 10;
        atkSpeed = 0.6;
        goldDrop = 8;
        isFlying = false;
        break;
      case 'shielded':
        damage = 7;
        atkSpeed = 0.8;
        goldDrop = 10;
        isFlying = false;
        break;
      case 'bomber':
        damage = 15;
        atkSpeed = 0.5;
        goldDrop = 12;
        isFlying = false;
        break;
      case 'healer':
        damage = 4;
        atkSpeed = 1.0;
        goldDrop = 6;
        isFlying = false;
        break;
      default: // slime
        damage = 3;
        atkSpeed = 1.0;
        goldDrop = 2;
        isFlying = false;
    }

    final enemy = DefenseEnemy(
      enemyId: typeId,
      maxHp: hp,
      speed: speed,
      damage: damage,
      attackSpeed: atkSpeed,
      goldDrop: goldDrop,
      wave: waveManager.currentWave,
      spawnPosition: position,
      wallPosition: wall.position,
      isFlying: isFlying,
    );

    world.add(enemy);
  }

  /// Spawn a boss enemy.
  void spawnBoss({
    required int wave,
    required Vector2 position,
    required double hpMultiplier,
  }) {
    final bossHp = 200.0 * hpMultiplier;
    final enemy = DefenseEnemy(
      enemyId: 'boss',
      maxHp: bossHp,
      speed: 20,
      damage: 20,
      attackSpeed: 0.5,
      goldDrop: 50,
      wave: wave,
      spawnPosition: position,
      wallPosition: wall.position,
    );
    world.add(enemy);
  }

  // ══════════════════════════════════════
  // Events
  // ══════════════════════════════════════

  /// Called when an enemy is killed.
  void onEnemyKilled(DefenseEnemy enemy) {
    _runKills++;
    totalKills++;
    waveManager.onEnemyKilled();
    gameFeel.onEnemyKill();

    if (enemy.enemyId == 'boss') {
      waveManager.onBossKilled();
      totalBossKills++;
      gameFeel.onBossKill();
      particleEffect.spawnBossExplosion(
        enemy.position.x,
        enemy.position.y,
      );
    }
  }

  /// Add gold to the player.
  void addGold(int amount) {
    final goldMult = upgradeManager.goldGainMultiplier *
        relicManager.goldMultiplier;
    final finalAmount = (amount * goldMult).round();
    gold += finalAmount;
    _runGoldEarned += finalAmount;
  }

  /// Called when the wall is destroyed — end the run.
  void onWallDestroyed() {
    isPlaying = false;

    // Calculate star reward
    final baseStars = waveManager.currentWave;
    final starMult = upgradeManager.starBonusMultiplier *
        relicManager.starMultiplier;
    final earnedStars = (baseStars * starMult).round();

    stars += earnedStars;
    totalStarsEarned += earnedStars;

    // Update highest wave
    if (waveManager.currentWave > highestWave) {
      highestWave = waveManager.currentWave;
    }

    // Save
    saveGame();

    // Show result overlay
    overlays.remove('DefenseHud');
    overlays.remove('WaveReward');
    overlays.add('RunResult');

    // Store result data for the overlay to read
    _lastRunStars = earnedStars;
  }

  int _lastRunStars = 0;
  int get lastRunStars => _lastRunStars;
  int get runKills => _runKills;
  int get runGoldEarned => _runGoldEarned;

  /// Called when a perfect wave is achieved.
  void onPerfectWave(int consecutiveCount) {
    gameFeel.onPerfectWave();
    // Bonus gold for perfect waves
    addGold(5 * consecutiveCount);
  }

  // ══════════════════════════════════════
  // Unit Buying & Merging
  // ══════════════════════════════════════

  /// Get cost for buying a new unit.
  int getUnitCost() {
    final discount = upgradeManager.unitCostDiscount;
    return (baseUnitCost * pow(1.15, _unitsBought) * discount).ceil();
  }

  /// Get a random unit type.
  String getRandomUnitType(Random rng) {
    return _unitTypeIds[rng.nextInt(_unitTypeIds.length)];
  }

  /// Buy and place a random unit in an empty slot.
  void buyUnit() {
    final cost = getUnitCost();
    if (gold < cost) return;

    // Find empty slot
    final emptyIdx = _unitSlots.indexWhere((s) => s.isEmpty);
    if (emptyIdx == -1) return; // No empty slots

    gold -= cost;
    _unitsBought++;

    final typeId = getRandomUnitType(_rng);
    _unitSlots[emptyIdx].place(merge.DefenseUnit(
      unitTypeId: typeId,
      level: 1,
    ));

    // Check for auto-merge after placing
    _tryAutoMerge();

    // Refresh visual components
    _refreshSlotComponents();
  }

  /// Try to auto-merge if 3 same units exist.
  void _tryAutoMerge() {
    final merges = merge.MergeManager.findPossibleMerges(_unitSlots);
    if (merges.isEmpty) return;

    final indices = merges.first;
    if (indices.length < 3) return;

    final unit = _unitSlots[indices[0]].unit;
    if (unit == null) return;

    final newLevel = unit.level + 1;
    final mergedUnit = merge.DefenseUnit(
      unitTypeId: unit.unitTypeId,
      level: newLevel,
    );

    // Clear source slots
    for (final idx in indices) {
      _unitSlots[idx].clear();
    }

    // Place merged unit
    _unitSlots[indices[0]].place(mergedUnit);

    gameFeel.onMerge(newLevel);
    particleEffect.spawnMerge(
      wall.position.x,
      wall.position.y,
    );

    // Recursive merge check
    _tryAutoMerge();
  }

  // ══════════════════════════════════════
  // Overlay Management
  // ══════════════════════════════════════

  /// Show the wave reward card selection screen.
  void showRewardSelection() {
    _isPaused = true;
    overlays.add('WaveReward');
  }

  /// Close the wave reward screen and resume.
  void closeRewardSelection() {
    overlays.remove('WaveReward');
    _isPaused = false;
  }

  /// Open the star shop (between runs or from menu).
  void openStarShop() {
    overlays.add('StarShop');
  }

  /// Close the star shop.
  void closeStarShop() {
    overlays.remove('StarShop');
    saveGame();
  }

  /// Go back to main menu from results.
  void goToMainMenu() {
    overlays.remove('RunResult');
    overlays.remove('DefenseHud');
    overlays.add('DefenseMainMenu');
  }

  // ══════════════════════════════════════
  // Helpers
  // ══════════════════════════════════════

  void _clearAllUnits() {
    world.children
        .whereType<unit_component.DefenseUnit>()
        .toList()
        .forEach((c) => c.removeFromParent());
    _unitSlots.clear();
  }

  void _clearAllEnemies() {
    world.children
        .whereType<DefenseEnemy>()
        .toList()
        .forEach((c) => c.removeFromParent());
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Can be used for direct tap interactions in the future
    super.onTapDown(event);
  }
}
