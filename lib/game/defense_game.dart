import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' show Color, Paint;

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
import '../systems/sound_manager.dart';
import '../systems/combo_manager.dart';
import '../systems/skill_manager.dart';
import '../systems/achievement_manager.dart';
import '../systems/daily_manager.dart';
import '../systems/codex_manager.dart';
import '../systems/synergy_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/unit_data.dart';
import '../data/enemy_data.dart';
import '../data/balance_config.dart';
import '../data/hybrid_unit_data.dart';
import '../data/relic_data.dart';
import '../components/damage_number.dart';
import '../ui/defense_hud.dart' as hud;

/// Main game class for castle defense mode.
/// Portrait mode (400x700), fixed resolution viewport.
/// Manages all game state, spawning, overlays, and lifecycle.
class DefenseGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  // ── System Unlock IDs ──
  static const String unlockMergeHint = 'merge_hint';
  static const String unlockWaveReward = 'wave_reward';
  static const String unlockRelic = 'relic';
  static const String unlockHybrid = 'hybrid';
  static const String unlockCombo = 'combo';
  static const String unlockEvolution = 'evolution';
  static const String unlockAchievement = 'achievement';

  // ── Viewport ──
  static const double gameWidth = 400;
  static const double gameHeight = 700;

  // ── Managers ──
  late WaveManager waveManager;
  late RelicManager relicManager;
  late DefenseGameFeel gameFeel;
  late DefenseUpgradeManager upgradeManager;
  late DefenseSaveManager saveManager;
  late SoundManager soundManager;
  late ComboManager comboManager;
  late SkillManager skillManager;
  late AchievementManager achievementManager;
  late DailyManager dailyManager;
  late CodexManager codexManager;
  late SynergyManager synergyManager;

  // ── Core Components ──
  late Wall wall;
  late DefenseParticle particleEffect;
  final List<merge.UnitSlot> _unitSlots = [];

  /// Cached living enemy list, refreshed once per frame in update().
  List<DefenseEnemy> livingEnemies = [];

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
  double gameSpeed = 1.0; // 1x or 2x speed toggle

  // ── Merge/Achievement tracking ──
  int _totalMerges = 0;
  int get totalMerges => _totalMerges;
  final List<String> _achievementQueue = [];

  // ── System Unlock tracking ──
  Set<String> _unlockedSystems = {};

  // ── Unit placement cost ──
  int _unitsBought = 0;

  // ── Run-scoped reward buffs ──
  double rewardAtkMultiplier = 1.0;
  double rewardAtkSpeedMultiplier = 1.0;
  double rewardGoldMultiplier = 1.0;
  double rewardRangeMultiplier = 1.0;
  double rewardUnitCostMultiplier = 1.0;
  double rewardWallDefenseMultiplier = 1.0;
  double rewardWallRegenBonus = 0.0;

  // ── Slot config ──
  int get maxSlots => 8 + upgradeManager.getLevel(DefenseUpgradeId.slotExpansion);

  // ── Unit type mapping (derived from UnitDatabase) ──
  /// snake_case unit type IDs derived from UnitDatabase.
  static final List<String> _unitTypeIds = UnitDatabase.all
      .map((u) => _toSnakeCase(u.id))
      .toList();

  /// Unit emoji icons derived from UnitDatabase + HybridDatabase.
  static final Map<String, String> _unitIcons = {
    for (final u in UnitDatabase.all) _toSnakeCase(u.id): u.emoji,
    for (final h in HybridDatabase.all) h.id: h.emoji,
  };

  /// Convert camelCase to snake_case.
  static String _toSnakeCase(String s) =>
      s.replaceAllMapped(RegExp(r'[A-Z]'), (m) => '_${m[0]!.toLowerCase()}');

  // ── Wall tap heal ──
  double _healCooldown = 0;
  static const double healCooldownDuration = 10.0;
  double get healCooldown => _healCooldown;

  // ── Wave clear announcement ──
  bool showWaveClearBanner = false;
  int waveClearNumber = 0;
  double _waveClearTimer = 0;

  final Random _rng = Random();

  // ── Public accessors ──
  int get currentWave => waveManager.currentWave;

  /// Unit slots exposed for UI (HUD), with merge hints.
  List<hud.UnitSlot> get unitSlots {
    // Compute merge-hint data: count occurrences of (type, level)
    final counts = <String, int>{};
    for (final s in _unitSlots) {
      final u = s.unit;
      if (u != null && !u.isEvolved) {
        final key = '${u.unitTypeId}:${u.level}';
        counts[key] = (counts[key] ?? 0) + 1;
      }
    }
    final mergeNeeded = relicManager.hasDoubleMerge ? 2 : BalanceConfig.mergeCount;

    // Check if any cross-breed merge is possible
    final crossBreeds = merge.MergeManager.findCrossBreedMerges(_unitSlots);
    final crossBreedSlots = <int>{};
    for (final cb in crossBreeds) {
      crossBreedSlots.add(cb.slotIndexA);
      crossBreedSlots.add(cb.slotIndexB);
    }

    return List.generate(_unitSlots.length, (i) {
      final u = _unitSlots[i].unit;
      if (u == null) return const hud.UnitSlot();
      final key = '${u.unitTypeId}:${u.level}';
      final canMerge = !u.isEvolved && (counts[key] ?? 0) >= mergeNeeded;
      final canHybrid = crossBreedSlots.contains(i);
      return hud.UnitSlot(
        icon: _unitIcons[u.unitTypeId] ?? '❓',
        level: u.level,
        isOccupied: true,
        unitType: u.unitTypeId,
        canMerge: canMerge,
        canHybrid: canHybrid,
      );
    });
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
    soundManager = SoundManager();
    await saveManager.init();
    await soundManager.load();

    // Load persistent data
    saveManager.loadUpgrades(upgradeManager);
    stars = saveManager.stars;
    souls = saveManager.souls;
    highestWave = saveManager.highestWave;
    totalRuns = saveManager.totalRuns;
    totalKills = saveManager.totalKills;
    totalStarsEarned = saveManager.totalStarsEarned;
    totalBossKills = saveManager.totalBossKills;
    _totalMerges = saveManager.totalMerges;
    _unlockedSystems = saveManager.unlockedSystems;

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

    comboManager = ComboManager();
    world.add(comboManager);

    skillManager = SkillManager();
    world.add(skillManager);

    achievementManager = AchievementManager();
    await achievementManager.load();

    dailyManager = DailyManager();
    final dailyPrefs = await SharedPreferences.getInstance();
    await dailyManager.init(dailyPrefs);

    codexManager = CodexManager();
    final codexPrefs = await SharedPreferences.getInstance();
    await codexManager.init(codexPrefs);

    synergyManager = SynergyManager();

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
    gold = 50 + upgradeManager.getLevel(DefenseUpgradeId.startUnits) * 10
        + upgradeManager.startGoldBonus;
    _runKills = 0;
    _runGoldEarned = 0;
    _unitsBought = 0;
    isPlaying = true;
    _isPaused = false;

    // Reset reward buffs
    rewardAtkMultiplier = 1.0;
    rewardAtkSpeedMultiplier = 1.0;
    rewardGoldMultiplier = 1.0;
    rewardRangeMultiplier = 1.0;
    rewardUnitCostMultiplier = 1.0;
    rewardWallDefenseMultiplier = 1.0;
    rewardWallRegenBonus = 0.0;

    // Reset wall
    wall.currentHp = wall.maxHp;
    wall.level = 1;
    final wallHpMult = upgradeManager.wallHpMultiplier;
    wall.maxHp = 100.0 * wallHpMult;
    wall.currentHp = wall.maxHp;

    // Reset relics, combo, skill, and synergies
    relicManager.reset();
    comboManager.resetAll();
    skillManager.reset();
    synergyManager.reset();

    // Clear existing slots and enemies
    _clearAllUnits();
    _clearAllEnemies();

    // Reinit slots
    _initSlots();

    // NOTE: war_god relic halves wall HP (applied when relic is acquired)

    // Start wave system
    waveManager.reset();
    waveManager.startFirstWave();

    // Clear any saved run state
    saveManager.clearRunState();

    // Update overlays
    overlays.remove('DefenseMainMenu');
    overlays.remove('RunResult');
    overlays.remove('StarShop');
    overlays.add('DefenseHud');

    // Update skill type and synergies after initial unit placement
    _updateSkillType();
    _updateSynergies();

    totalRuns++;
  }

  // ── Mid-run save/load ──

  /// Build a snapshot of the current run state for mid-run save.
  Map<String, dynamic> buildRunState() {
    final slotData = <Map<String, dynamic>>[];
    for (final slot in _unitSlots) {
      final u = slot.unit;
      if (u != null) {
        slotData.add({
          'typeId': u.unitTypeId,
          'level': u.level,
          'isEvolved': u.isEvolved,
        });
      } else {
        slotData.add({'empty': true});
      }
    }
    return {
      'gold': gold,
      'runKills': _runKills,
      'runGoldEarned': _runGoldEarned,
      'unitsBought': _unitsBought,
      'wave': waveManager.currentWave,
      'wallHp': wall.currentHp,
      'wallMaxHp': wall.maxHp,
      'relics': relicManager.toList(),
      'slots': slotData,
      'rewardAtk': rewardAtkMultiplier,
      'rewardAtkSpeed': rewardAtkSpeedMultiplier,
      'rewardGold': rewardGoldMultiplier,
      'rewardRange': rewardRangeMultiplier,
      'rewardUnitCost': rewardUnitCostMultiplier,
      'rewardWallDefense': rewardWallDefenseMultiplier,
      'rewardWallRegen': rewardWallRegenBonus,
    };
  }

  /// Save the current run state (called from app lifecycle).
  void saveRunState() {
    if (!isPlaying) return;
    saveManager.saveRunState(buildRunState());
  }

  /// Resume from a saved run state. Returns true if successful.
  bool resumeRun() {
    final state = saveManager.loadRunState();
    if (state == null) return false;

    // Restore game state
    gold = (state['gold'] as num?)?.toInt() ?? 50;
    _runKills = (state['runKills'] as num?)?.toInt() ?? 0;
    _runGoldEarned = (state['runGoldEarned'] as num?)?.toInt() ?? 0;
    _unitsBought = (state['unitsBought'] as num?)?.toInt() ?? 0;
    isPlaying = true;
    _isPaused = false;

    // Restore reward multipliers
    rewardAtkMultiplier = (state['rewardAtk'] as num?)?.toDouble() ?? 1.0;
    rewardAtkSpeedMultiplier = (state['rewardAtkSpeed'] as num?)?.toDouble() ?? 1.0;
    rewardGoldMultiplier = (state['rewardGold'] as num?)?.toDouble() ?? 1.0;
    rewardRangeMultiplier = (state['rewardRange'] as num?)?.toDouble() ?? 1.0;
    rewardUnitCostMultiplier = (state['rewardUnitCost'] as num?)?.toDouble() ?? 1.0;
    rewardWallDefenseMultiplier = (state['rewardWallDefense'] as num?)?.toDouble() ?? 1.0;
    rewardWallRegenBonus = (state['rewardWallRegen'] as num?)?.toDouble() ?? 0.0;

    // Restore wall
    wall.maxHp = (state['wallMaxHp'] as num?)?.toDouble() ?? 100.0;
    wall.currentHp = (state['wallHp'] as num?)?.toDouble() ?? wall.maxHp;

    // Restore relics
    relicManager.reset();
    final relicList = state['relics'] as List<dynamic>?;
    if (relicList != null) {
      relicManager.loadFromList(relicList.cast<String>());
    }

    // Reset combo
    comboManager.resetAll();

    // Clear existing and restore slots/units
    _clearAllUnits();
    _clearAllEnemies();
    _initSlots();

    final slotsData = state['slots'] as List<dynamic>?;
    if (slotsData != null) {
      for (int i = 0; i < slotsData.length && i < _unitSlots.length; i++) {
        final s = slotsData[i] as Map<String, dynamic>;
        if (s['empty'] == true) continue;
        _unitSlots[i].place(merge.DefenseUnit(
          unitTypeId: s['typeId'] as String? ?? 'cat_archer',
          level: (s['level'] as num?)?.toInt() ?? 1,
          isEvolved: s['isEvolved'] as bool? ?? false,
        ));
      }
    }
    _refreshSlotComponents();
    _updateSkillType();
    _updateSynergies();

    // Restore wave and restart
    final savedWave = (state['wave'] as num?)?.toInt() ?? 1;
    waveManager.reset();
    waveManager.resumeAtWave(savedWave);

    // Clear saved state
    saveManager.clearRunState();

    // Update overlays
    overlays.remove('DefenseMainMenu');
    overlays.remove('RunResult');
    overlays.remove('StarShop');
    overlays.add('DefenseHud');

    return true;
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
      totalMerges: _totalMerges,
    );
    achievementManager.save();
    _checkUnlocks();
  }

  /// Poll and consume achievement notifications (for HUD banner).
  String? popAchievementNotification() {
    if (_achievementQueue.isEmpty) return null;
    return _achievementQueue.removeAt(0);
  }

  /// Update achievement progress and award stars for newly completed ones.
  void _updateAchievement(AchievementType type, int value) {
    final completed = achievementManager.updateProgress(type, value);
    for (final id in completed) {
      final def = AchievementDatabase.get(id);
      if (def != null) {
        stars += def.starReward;
        totalStarsEarned += def.starReward;
        _achievementQueue.add('${def.icon} ${def.name} (+${def.starReward}⭐)');
        showDamageNumber(
          wall.position,
          '🏆 +${def.starReward}⭐',
          const Color(0xFFFFD700),
        );
      }
    }
  }

  // ══════════════════════════════════════
  // System Unlock
  // ══════════════════════════════════════

  /// Whether a system has been unlocked.
  bool isSystemUnlocked(String id) => _unlockedSystems.contains(id);

  /// Check unlock conditions and unlock newly eligible systems.
  void _checkUnlocks() {
    // After ANY merge success → unlock merge_hint
    if (_totalMerges > 0) _unlockSystem(unlockMergeHint);

    // Wave >= 5 → unlock wave_reward
    if (currentWave >= 5) _unlockSystem(unlockWaveReward);

    // Wave >= 10 → unlock relic
    if (currentWave >= 10) _unlockSystem(unlockRelic);

    // Wave >= 15 OR totalRuns >= 3 → unlock hybrid
    if (currentWave >= 15 || totalRuns >= 3) _unlockSystem(unlockHybrid);

    // Wave >= 20 OR totalRuns >= 5 → unlock combo
    if (currentWave >= 20 || totalRuns >= 5) _unlockSystem(unlockCombo);

    // Any unit reaches level 5 → unlock evolution
    for (final slot in _unitSlots) {
      final u = slot.unit;
      if (u != null && u.level >= 5) {
        _unlockSystem(unlockEvolution);
        break;
      }
    }

    // achievementManager.completedCount >= 3 → unlock achievement
    if (achievementManager.completedAchievements.length >= 3) {
      _unlockSystem(unlockAchievement);
    }
  }

  /// Unlock a system by ID. No-op if already unlocked.
  void _unlockSystem(String id) {
    if (_unlockedSystems.contains(id)) return;
    _unlockedSystems.add(id);
    saveManager.unlockSystem(id);
    _achievementQueue.add('🔓 새 시스템 해금!');
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

    final effectiveDt = dt * gameFeel.timeScale * gameSpeed;
    super.update(effectiveDt);

    // Refresh cached enemy list once per frame
    livingEnemies = world.children
        .whereType<DefenseEnemy>()
        .where((e) => !e.isDead)
        .toList();

    // Apply zoom punch
    camera.viewfinder.zoom = gameFeel.currentZoom;

    // Wall regen from upgrades + reward buffs
    final regen = upgradeManager.wallRegenPerSec + rewardWallRegenBonus;
    if (regen > 0 && wall.currentHp < wall.maxHp && !wall.isDestroyed) {
      wall.heal(regen * effectiveDt);
    }

    // Relic: living wall — wall deals AoE DPS to nearby enemies
    final livingWallDps = relicManager.livingWallDps;
    if (livingWallDps > 0) {
      for (final enemy in livingEnemies) {
        final dist = wall.position.distanceTo(enemy.position);
        if (dist <= 60.0) {
          enemy.takeDamage(livingWallDps * effectiveDt);
        }
      }
    }

    // Relic: wall turret — auto-attack nearest enemy
    final turretDps = relicManager.wallTurretDps;
    if (turretDps > 0) {
      DefenseEnemy? nearest;
      double nearestDist = 150.0;
      for (final e in livingEnemies) {
        final d = wall.position.distanceTo(e.position);
        if (d < nearestDist) {
          nearestDist = d;
          nearest = e;
        }
      }
      if (nearest != null) {
        nearest.takeDamage(turretDps * effectiveDt);
      }
    }

    // Wave clear banner timer
    if (showWaveClearBanner) {
      _waveClearTimer -= effectiveDt;
      if (_waveClearTimer <= 0) {
        showWaveClearBanner = false;
      }
    }

    // Wall heal cooldown
    if (_healCooldown > 0) {
      _healCooldown -= effectiveDt;
      if (_healCooldown < 0) _healCooldown = 0;
    }
  }

  /// Called by WaveManager at the start of each wave.
  void onWaveStart(int waveNumber) {
    // Relic: wave gold bonus
    final bonusGold = relicManager.onWaveStart(waveNumber, _rng);
    if (bonusGold > 0) {
      addGold(bonusGold, popupPos: wall.position);
    }

    // Relic: blessing rain heal
    final healFraction = relicManager.onWaveStartHeal(waveNumber);
    if (healFraction > 0 && !wall.isDestroyed) {
      wall.heal(wall.maxHp * healFraction);
    }

    // Relic: rift — free random unit on wave start
    if (relicManager.hasRift) {
      final emptyIdx = _unitSlots.indexWhere((s) => s.isEmpty);
      if (emptyIdx != -1) {
        final typeId = getRandomUnitType(_rng);
        _unitSlots[emptyIdx].place(merge.DefenseUnit(
          unitTypeId: typeId,
          level: 1,
        ));
        _tryAutoMerge();
        _refreshSlotComponents();
      }
    }

    // Relic: time warp — slow motion at wave start
    if (relicManager.shouldTimeWarp(waveNumber)) {
      gameFeel.slowMotion(scale: 0.3, duration: 3.0);
    }

    // Relic: chaos — re-randomize all relics except chaos itself each wave
    if (relicManager.hasRelic('relic_chaos') && waveNumber > 1) {
      final relicCount = relicManager.relicCount - 1; // exclude chaos
      relicManager.reset();
      relicManager.addRelic('relic_chaos');
      // Re-roll random relics
      for (int i = 0; i < relicCount; i++) {
        final choices = relicManager.generateRelicChoices(
          _rng,
          choiceCount: 1,
          qualityBonus: upgradeManager.relicQualityBonus,
        );
        if (choices.isNotEmpty) {
          relicManager.addRelic(choices.first);
        }
      }
      showDamageNumber(wall.position, '카오스!', const Color(0xFFE040FB));
    }
  }

  /// Called by WaveManager when a wave is cleared.
  void onWaveClear(int waveNumber) {
    showWaveClearBanner = true;
    waveClearNumber = waveNumber;
    _waveClearTimer = 2.0;
    soundManager.playWaveClear();
    _checkUnlocks();
  }

  // ══════════════════════════════════════
  // Spawning
  // ══════════════════════════════════════

  /// Spawn an enemy. Called by WaveManager.
  /// Stats are looked up from DefenseEnemyDatabase.
  /// Wave modifier effects are applied here (HP/speed multipliers, auto-burn, flying override).
  void spawnEnemy({
    required String typeId,
    required Vector2 position,
    required double hp,
    required double speed,
  }) {
    final data = DefenseEnemyDatabase.get(typeId);
    final modifier = waveManager.waveModifier;

    // Wave modifier: sky_threat forces all enemies to be flying
    final isFlying = modifier.allFlying || (data?.isFlying ?? false);

    final enemy = DefenseEnemy(
      enemyId: typeId,
      maxHp: hp,
      speed: speed,
      damage: data?.baseDamage ?? 3,
      attackSpeed: data?.baseAtkSpeed ?? 1.0,
      goldDrop: data?.goldDrop ?? 2,
      wave: waveManager.currentWave,
      spawnPosition: position,
      wallPosition: wall.position,
      isFlying: isFlying,
    );
    world.add(enemy);

    // Codex: discover this enemy type
    codexManager.discoverEnemy(typeId);

    // Wave modifier: burning — apply automatic fire DoT to all enemies
    if (modifier.autoBurn) {
      enemy.applyDot(5.0, 99.0, 'fire');
    }
  }

  /// Spawn a boss enemy.
  void spawnBoss({
    required int wave,
    required Vector2 position,
    required double hpMultiplier,
  }) {
    final bossHp = BalanceConfig.bossBaseHp * hpMultiplier;
    final enemy = DefenseEnemy(
      enemyId: 'boss',
      maxHp: bossHp,
      speed: BalanceConfig.bossSpeed,
      damage: BalanceConfig.bossDamage,
      attackSpeed: BalanceConfig.bossAtkSpeed,
      goldDrop: BalanceConfig.bossGoldDrop,
      wave: wave,
      spawnPosition: position,
      wallPosition: wall.position,
    );
    world.add(enemy);

    // Codex: discover boss
    codexManager.discoverEnemy('boss');
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
    soundManager.playHit();

    // Skill gauge: charge on kill
    skillManager.onEnemyKilled();

    // Combo: track and scale effects
    final prevTier = comboManager.currentTier;
    comboManager.onEnemyKilled();
    final comboScale = comboManager.effectSizeMultiplier;

    // Combo-scaled death effect
    if (comboScale > 1.0) {
      particleEffect.spawnEnemyDeathScaled(
        enemy.position.x, enemy.position.y, comboScale);
    }

    // Combo tier-up flash
    if (comboManager.currentTier != prevTier && comboManager.currentTier.threshold > 0) {
      particleEffect.spawnComboFlash(
        wall.position.x, wall.position.y,
        comboManager.currentTier.color,
      );
    }

    // Relic: bonus gold on kill
    final bonusGold = relicManager.onEnemyKilled(_rng);
    if (bonusGold > 0) {
      addGold(bonusGold, popupPos: enemy.position);
    }

    // Relic: kill heal — heal wall on each kill
    final healAmt = relicManager.killHealAmount;
    if (healAmt > 0 && !wall.isDestroyed) {
      wall.heal(healAmt);
    }

    // Relic: chain lightning — deal 50% damage to nearby enemy
    // Wave modifier: chain — always trigger chain lightning on kill
    if (relicManager.hasChainLightning || waveManager.waveModifier.alwaysChain) {
      _applyChainLightning(enemy);
    }

    // Relic: convert — 5% chance to spawn a free unit on kill
    if (relicManager.convertChance > 0 && _rng.nextDouble() < relicManager.convertChance) {
      final emptyIdx = _unitSlots.indexWhere((s) => s.isEmpty);
      if (emptyIdx != -1) {
        final typeId = getRandomUnitType(_rng);
        _unitSlots[emptyIdx].place(merge.DefenseUnit(
          unitTypeId: typeId,
          level: 1,
        ));
        showDamageNumber(enemy.position, '전향!', const Color(0xFF64FFDA));
        _tryAutoMerge();
        _refreshSlotComponents();
      }
    }

    if (enemy.enemyId == 'boss') {
      waveManager.onBossKilled();
      totalBossKills++;
      gameFeel.onBossKill();
      soundManager.playBossKill();
      particleEffect.spawnBossExplosion(
        enemy.position.x,
        enemy.position.y,
      );

      // Boss gold bonus from relics
      if (relicManager.bossGoldMultiplier > 1.0) {
        final bossBonus =
            (BalanceConfig.bossGoldDrop * (relicManager.bossGoldMultiplier - 1.0))
                .round();
        addGold(bossBonus, popupPos: enemy.position);
      }

      // Show relic selection after boss kill
      showRelicSelection();

      // Achievement: boss kills
      _updateAchievement(AchievementType.bosses, totalBossKills);
    }

    // Achievement: total kills & combo
    _updateAchievement(AchievementType.kills, totalKills);
    final maxCombo = comboManager.maxCombo;
    if (maxCombo > 0) {
      _updateAchievement(AchievementType.combos, maxCombo);
    }

    // Check system unlocks
    _checkUnlocks();
  }

  /// Chain lightning: find nearest enemy to the killed one and deal 50% damage.
  void _applyChainLightning(DefenseEnemy source) {
    DefenseEnemy? nearest;
    double nearestDist = 100.0; // max chain range

    for (final e in livingEnemies) {
      if (identical(e, source)) continue;
      final dist = source.position.distanceTo(e.position);
      if (dist < nearestDist) {
        nearestDist = dist;
        nearest = e;
      }
    }

    if (nearest != null) {
      // Deal 50% of average unit ATK
      final chainDmg = _getAverageUnitAtk() * 0.5;
      nearest.takeDamage(chainDmg, sourcePosition: source.position);
      particleEffect.spawnChainKill(
        source.position.x, source.position.y,
        nearest.position.x, nearest.position.y,
      );
    }
  }

  /// Add gold to the player. Optionally show a floating number at [popupPos].
  void addGold(int amount, {Vector2? popupPos}) {
    final goldMult = upgradeManager.goldGainMultiplier *
        relicManager.goldMultiplier *
        rewardGoldMultiplier *
        waveManager.waveModifier.goldMultiplier *
        synergyManager.goldMultiplier;
    final finalAmount = (amount * goldMult).round();
    gold += finalAmount;
    _runGoldEarned += finalAmount;

    if (popupPos != null) {
      showDamageNumber(popupPos, '+$finalAmount', const Color(0xFFFFD54F));
    }
  }

  /// Called when the wall is destroyed — end the run.
  void onWallDestroyed() {
    isPlaying = false;
    soundManager.playGameOver();

    // Calculate star reward
    final baseStars = waveManager.currentWave;
    final starMult = upgradeManager.starBonusMultiplier *
        relicManager.starMultiplier;
    final earnedStars = (baseStars * starMult).round();

    stars += earnedStars;
    totalStarsEarned += earnedStars;

    // Soul reward — earn souls based on wave reached
    final earnedSouls = _calculateSouls();
    if (earnedSouls > 0) {
      souls += earnedSouls;
      _achievementQueue.add('👻 소울 +$earnedSouls 획득!');
    }
    _lastRunSouls = earnedSouls;

    // Update highest wave
    if (waveManager.currentWave > highestWave) {
      highestWave = waveManager.currentWave;
    }

    // Achievement: waves, gold, relics
    _updateAchievement(AchievementType.waves, waveManager.currentWave);
    _updateAchievement(AchievementType.gold, _runGoldEarned);
    _updateAchievement(AchievementType.relics, relicManager.ownedRelics.length);

    // Check daily challenge
    if (!dailyManager.challengeComplete &&
        waveManager.currentWave >= dailyManager.challengeTargetWave) {
      final bonus = dailyManager.challengeBonus;
      dailyManager.completeChallenge();
      stars += bonus;
      totalStarsEarned += bonus;
      _achievementQueue.add('📅 일일 도전 완료! +⭐$bonus');
    }

    // Save & clear in-run state
    saveGame();
    saveManager.clearRunState();

    // Show result overlay
    overlays.remove('DefenseHud');
    overlays.remove('WaveReward');
    overlays.add('RunResult');

    // Store result data for the overlay to read
    _lastRunStars = earnedStars;
  }

  int _lastRunStars = 0;
  int _lastRunSouls = 0;
  int get lastRunStars => _lastRunStars;
  int get lastRunSouls => _lastRunSouls;
  int get runKills => _runKills;
  int get runGoldEarned => _runGoldEarned;

  /// Calculate souls earned for this run.
  /// Souls are the prestige currency: wave 15+ starts earning, scaling with wave.
  int _calculateSouls() {
    final wave = waveManager.currentWave;
    if (wave < 15) return 0;
    // Base: (wave - 14) * 2, bonus for boss kills
    final base = (wave - 14) * 2;
    final bossBonus = waveManager.bossesKilled * 5;
    return base + bossBonus;
  }

  /// Soul-based permanent ATK multiplier. +2% per 50 souls spent equivalent.
  double get soulAtkMultiplier => 1.0 + (souls ~/ 100) * 0.02;

  /// Build summary data for run result screen.
  Map<String, dynamic> get runSummary {
    // Count unit types and highest levels
    final unitCounts = <String, int>{};
    int highestLevel = 0;
    int hybridCount = 0;
    for (final slot in _unitSlots) {
      final u = slot.unit;
      if (u == null) continue;
      final icon = _unitIcons[u.unitTypeId] ?? '❓';
      unitCounts[icon] = (unitCounts[icon] ?? 0) + 1;
      if (u.level > highestLevel) highestLevel = u.level;
      if (u.isHybrid) hybridCount++;
    }

    // Relic list
    final relicIcons = relicManager.ownedRelics.map((id) {
      final def = RelicDatabase.get(id);
      return def?.icon ?? '🔮';
    }).toList();

    return {
      'unitCounts': unitCounts,
      'highestLevel': highestLevel,
      'hybridCount': hybridCount,
      'relicIcons': relicIcons,
      'maxCombo': comboManager.maxCombo,
      'bossKills': waveManager.bossesKilled,
    };
  }

  /// Called when a perfect wave is achieved.
  void onPerfectWave(int consecutiveCount) {
    gameFeel.onPerfectWave();
    // Bonus gold for perfect waves
    addGold(BalanceConfig.perfectWaveGoldPerStreak * consecutiveCount,
        popupPos: wall.position);
  }

  // ══════════════════════════════════════
  // Active Skill
  // ══════════════════════════════════════

  /// Activate the charged skill. Called from HUD button.
  void activateSkill() {
    final effectId = skillManager.activate();
    if (effectId == null) return;

    // Apply immediate effects
    switch (effectId) {
      case 'arrow_rain':
        // Damage all enemies for ATK x2
        final avgAtk = _getAverageUnitAtk();
        for (final e in livingEnemies) {
          e.takeDamage(avgAtk * 2);
          particleEffect.spawnEnemyDeath(e.position.x, e.position.y);
        }
        break;
      case 'war_cry':
        // 5s ATK +50% — handled via skillManager.isEffectActive in unit damage calc
        break;
      case 'meteor':
        // Big explosion near wall center
        final meteorAtk = _getAverageUnitAtk();
        for (final e in livingEnemies) {
          final dist = e.position.distanceTo(wall.position);
          if (dist < 150) {
            e.takeDamage(meteorAtk * 5);
            particleEffect.spawnEnemyDeath(e.position.x, e.position.y);
          }
        }
        break;
      case 'ice_wall':
        // 5s all enemies speed -70% — handled via skillManager.isEffectActive in enemy update
        break;
      case 'assassin_mark':
        // 10s 100% crit — handled via skillManager.isEffectActive in unit damage calc
        skillManager.setEffectDuration(10.0); // Override to 10s
        break;
      case 'storm_call':
        // All flying instant kill + ground ATK x3
        final stormAtk = _getAverageUnitAtk();
        for (final e in livingEnemies) {
          if (e.isFlying) {
            e.takeDamage(e.hp * 2); // instant kill
          } else {
            e.takeDamage(stormAtk * 3);
          }
          particleEffect.spawnEnemyDeath(e.position.x, e.position.y);
        }
        break;
      case 'wall_heal':
        // Heal wall 30%
        wall.currentHp =
            (wall.currentHp + wall.maxHp * 0.3).clamp(0.0, wall.maxHp);
        // 5s invincible — handled via skillManager.isEffectActive
        break;
      case 'mana_burst':
        // All enemies lose 30% HP
        for (final e in livingEnemies) {
          e.takeDamage(e.hp * 0.3);
          particleEffect.spawnEnemyDeath(e.position.x, e.position.y);
        }
        break;
    }

    // Skill activation visual + game feel
    final skillColor = _getSkillColor(effectId);
    particleEffect.spawnSkillActivation(
      wall.position.x, wall.position.y, skillColor);
    gameFeel.slowMotion(scale: 0.3, duration: 0.3);
    gameFeel.zoomPunch(targetZoom: 1.05, duration: 0.3);
    soundManager.playMerge(); // Reuse existing sound
  }

  /// Skill color per effect type.
  static Color _getSkillColor(String effectId) {
    switch (effectId) {
      case 'arrow_rain': return const Color(0xFFFFD54F);
      case 'war_cry': return const Color(0xFFFF6D00);
      case 'meteor': return const Color(0xFFFF3D00);
      case 'ice_wall': return const Color(0xFF42A5F5);
      case 'assassin_mark': return const Color(0xFFE040FB);
      case 'storm_call': return const Color(0xFF00BCD4);
      case 'wall_heal': return const Color(0xFF66BB6A);
      case 'mana_burst': return const Color(0xFF7C4DFF);
      default: return const Color(0xFFFFFFFF);
    }
  }

  /// Average ATK of all placed units, for skill damage calculations.
  double _getAverageUnitAtk() {
    int count = 0;
    double total = 0;
    for (final s in _unitSlots) {
      final u = s.unit;
      if (u != null) {
        final baseAtk = _lookupBaseAtk(u.unitTypeId);
        total += baseAtk * pow(BalanceConfig.unitAtkLevelBase, u.level - 1);
        count++;
      }
    }
    return count > 0 ? total / count : 10.0;
  }

  /// Look up base ATK for a unit type ID (supports both normal and hybrid).
  static double _lookupBaseAtk(String typeId) {
    final hybrid = HybridDatabase.get(typeId);
    if (hybrid != null) return hybrid.baseAtk;
    for (final u in UnitDatabase.all) {
      if (_toSnakeCase(u.id) == typeId) return u.baseAtk;
    }
    return 10.0;
  }

  /// Recalculate unit synergy bonuses. Called whenever unit composition changes.
  void _updateSynergies() {
    // Build hybrid parent map
    final hybridParents = <String, (String, String)>{};
    for (final h in HybridDatabase.all) {
      hybridParents[h.id] = (h.parentA, h.parentB);
    }
    synergyManager.setHybridParents(hybridParents);
    synergyManager.recalculate(_unitSlots);
  }

  /// Update the dominant unit type for skill selection.
  /// Called whenever the unit composition changes.
  void _updateSkillType() {
    final counts = <String, int>{};
    for (final s in _unitSlots) {
      final u = s.unit;
      if (u != null) {
        // For hybrids, count toward both parent types
        final hybridData = HybridDatabase.get(u.unitTypeId);
        if (hybridData != null) {
          counts[hybridData.parentA] = (counts[hybridData.parentA] ?? 0) + 1;
          counts[hybridData.parentB] = (counts[hybridData.parentB] ?? 0) + 1;
        } else {
          counts[u.unitTypeId] = (counts[u.unitTypeId] ?? 0) + 1;
        }
      }
    }
    skillManager.updateDominantType(counts);
  }

  // ══════════════════════════════════════
  // Unit Buying & Merging
  // ══════════════════════════════════════

  /// Get cost for buying a new unit.
  int getUnitCost() {
    final discount = upgradeManager.unitCostDiscount * rewardUnitCostMultiplier;
    return (BalanceConfig.baseUnitCost *
            pow(BalanceConfig.unitCostScale, _unitsBought) *
            discount)
        .ceil();
  }

  /// Get a random unit type.
  String getRandomUnitType(Random rng) {
    return _unitTypeIds[rng.nextInt(_unitTypeIds.length)];
  }

  /// Buy and place a random unit in an empty slot.
  void buyUnit() {
    // Relic: gambler — 50% free, 50% double cost
    final gamblerMult = relicManager.gamblerCostMultiplier(_rng);
    final cost = (getUnitCost() * gamblerMult).ceil();
    if (gold < cost) return;

    // Find empty slot
    final emptyIdx = _unitSlots.indexWhere((s) => s.isEmpty);
    if (emptyIdx == -1) return; // No empty slots

    gold -= cost;
    _unitsBought++;
    soundManager.playBuy();

    // Relic: doppelganger — buy the most common unit type
    final typeId = relicManager.hasDoppelganger
        ? _getMostCommonUnitType() ?? getRandomUnitType(_rng)
        : getRandomUnitType(_rng);

    _unitSlots[emptyIdx].place(merge.DefenseUnit(
      unitTypeId: typeId,
      level: 1,
    ));

    // Codex: discover this unit type
    codexManager.discoverUnit(typeId);

    // Relic: twin — 30% chance to spawn an extra unit
    if (relicManager.twinProc(_rng)) {
      final twinIdx = _unitSlots.indexWhere((s) => s.isEmpty);
      if (twinIdx != -1) {
        _unitSlots[twinIdx].place(merge.DefenseUnit(
          unitTypeId: typeId,
          level: 1,
        ));
      }
    }

    // Check for auto-merge after placing
    _tryAutoMerge();

    // Refresh visual components
    // Update skill type and synergies after buying unit
    _updateSkillType();
    _updateSynergies();
    _refreshSlotComponents();
  }

  /// Find the most common unit type among placed units.
  String? _getMostCommonUnitType() {
    final counts = <String, int>{};
    for (final slot in _unitSlots) {
      final unit = slot.unit;
      if (unit != null) {
        counts[unit.unitTypeId] = (counts[unit.unitTypeId] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  /// Public entry point for auto-merge (called by DefenseGameFeel).
  void tryAutoMerge() => _tryAutoMerge();

  /// Try to auto-merge if enough same units exist (3, or 2 with double merge relic).
  void _tryAutoMerge() {
    final needed = relicManager.hasDoubleMerge ? 2 : BalanceConfig.mergeCount;
    final merges = merge.MergeManager.findPossibleMerges(_unitSlots, mergeCount: needed);
    if (merges.isEmpty) return;

    final indices = merges.first;
    if (indices.length < needed) return;

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

    _totalMerges++;
    _updateAchievement(AchievementType.merges, _totalMerges);

    gameFeel.onMerge(newLevel);
    soundManager.playMerge();
    particleEffect.spawnMerge(
      wall.position.x,
      wall.position.y,
    );

    // Update skill type and synergies after unit composition change
    _updateSkillType();
    _updateSynergies();

    // Relic: merge bomb — deal AoE damage on merge
    final mergeBombDmg = relicManager.mergeBombDamage;
    if (mergeBombDmg > 0) {
      for (final enemy in livingEnemies) {
        final dist = wall.position.distanceTo(enemy.position);
        if (dist <= 120.0) {
          enemy.takeDamage(mergeBombDmg * newLevel);
        }
      }
    }

    // Recursive merge check
    _tryAutoMerge();

    // NOTE: Cross-breed (hybrid) merge now requires manual drag (Phase 1).
    // _tryCrossBreedMerge() is only called from manualMerge().

    // Check system unlocks after merge
    _checkUnlocks();
  }

  /// Try to cross-breed merge two different unit types into a hybrid.
  void _tryCrossBreedMerge() {
    final crossBreeds = merge.MergeManager.findCrossBreedMerges(_unitSlots);
    if (crossBreeds.isEmpty) return;

    final cb = crossBreeds.first;
    final hybrid = merge.MergeManager.performCrossBreed(cb);

    // Clear both source slots
    _unitSlots[cb.slotIndexA].clear();
    _unitSlots[cb.slotIndexB].clear();

    // Place hybrid in first slot
    _unitSlots[cb.slotIndexA].place(hybrid);

    gameFeel.onEvolve();
    particleEffect.spawnHybridMerge(
      wall.position.x,
      wall.position.y,
    );

    // Achievement: hybrid creation
    achievementManager.totalHybridsCreated++;
    _updateAchievement(AchievementType.hybrids, achievementManager.totalHybridsCreated);

    // Codex: discover this hybrid
    codexManager.discoverHybrid(hybrid.unitTypeId);

    _refreshSlotComponents();
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

  /// Open the daily rewards screen.
  void openDaily() {
    overlays.add('Daily');
    overlays.remove('DefenseMainMenu');
  }

  /// Close the daily rewards screen and return to menu.
  void closeDaily() {
    overlays.remove('Daily');
    overlays.add('DefenseMainMenu');
  }

  /// Open the codex (encyclopedia) screen.
  void openCodex() {
    overlays.add('Codex');
    overlays.remove('DefenseMainMenu');
  }

  /// Close the codex screen and return to menu.
  void closeCodex() {
    overlays.remove('Codex');
    overlays.add('DefenseMainMenu');
  }

  /// Toggle game speed between 1x and 2x.
  void toggleGameSpeed() {
    gameSpeed = gameSpeed >= 2.0 ? 1.0 : 2.0;
  }

  /// Go back to main menu from results.
  void goToMainMenu() {
    overlays.remove('RunResult');
    overlays.remove('DefenseHud');
    overlays.add('DefenseMainMenu');
  }

  // ══════════════════════════════════════
  // Damage Numbers & Relic Selection
  // ══════════════════════════════════════

  /// Show a floating damage/gold number at the given position.
  void showDamageNumber(Vector2 pos, String text, Color color,
      {bool isCritical = false}) {
    world.add(DamageNumber(
      position: pos,
      text: text,
      color: color,
      isCritical: isCritical,
    ));
  }

  /// Generate relic choices from relicManager and show the overlay.
  void showRelicSelection() {
    if (relicManager.isFull) return;

    final choices = relicManager.generateRelicChoices(
      _rng,
      choiceCount: 3,
      qualityBonus: upgradeManager.relicQualityBonus,
    );
    if (choices.isEmpty) return;

    _relicChoices = choices;
    _isPaused = true;
    overlays.add('RelicSelection');
  }

  /// Current relic choices for the overlay to read.
  List<String> _relicChoices = [];
  List<String> get relicChoices => _relicChoices;

  /// Called when the player selects a relic from the overlay.
  void onRelicSelected(String relicId) {
    relicManager.addRelic(relicId);

    // Codex: discover this relic
    codexManager.discoverRelic(relicId);

    // Immediate effects on acquire
    if (relicId == 'relic_war_god') {
      // War God: ATK x3 but wall HP halved
      wall.maxHp *= 0.5;
      wall.currentHp = wall.currentHp.clamp(0, wall.maxHp);
    }
  }

  // ══════════════════════════════════════
  // Unit Sell & Reroll
  // ══════════════════════════════════════

  /// Sell a unit from the given slot index.
  /// Refunds based on sell rate (default 50%, relic can change to 80%).
  void sellUnit(int slotIndex) {
    if (slotIndex < 0 || slotIndex >= _unitSlots.length) return;
    if (_unitSlots[slotIndex].isEmpty) return;

    _unitSlots[slotIndex].clear();

    // Refund based on sell rate (relic_recycle: 80%)
    final refund = (getUnitCost() * relicManager.sellRefundRate).ceil();
    gold += refund;
    _runGoldEarned += refund;

    // Show gold popup at wall position
    showDamageNumber(
      wall.position,
      '+$refund',
      const Color(0xFFFFD54F),
    );

    // Update skill type and synergies after selling unit
    _updateSkillType();
    _updateSynergies();
    _refreshSlotComponents();
  }

  /// Reroll all units. Costs 20 gold.
  /// Clears all units and places the same count of random new ones.
  void rerollUnits() {
    if (gold < BalanceConfig.rerollCost) return;

    // Count existing units
    int unitCount = 0;
    for (final slot in _unitSlots) {
      if (!slot.isEmpty) unitCount++;
    }
    if (unitCount == 0) return;

    gold -= BalanceConfig.rerollCost;

    // Clear all units
    for (final slot in _unitSlots) {
      slot.clear();
    }

    // Place same count of random new units
    for (int i = 0; i < unitCount && i < _unitSlots.length; i++) {
      final typeId = getRandomUnitType(_rng);
      _unitSlots[i].place(merge.DefenseUnit(
        unitTypeId: typeId,
        level: 1,
      ));
    }

    // Check for auto-merge after placing
    _tryAutoMerge();

    _updateSkillType();
    _updateSynergies();
    _refreshSlotComponents();
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
    super.onTapDown(event);
    if (!isPlaying || _isPaused) return;

    final tapPos = event.localPosition;
    final distToWall = tapPos.distanceTo(wall.position);

    // Tap on wall = emergency heal (costs gold, has cooldown)
    if (distToWall <= 50 && _healCooldown <= 0) {
      final cost = 10 + waveManager.currentWave * 2;
      if (gold >= cost) {
        gold -= cost;
        final healAmount = wall.maxHp * 0.05;
        wall.heal(healAmount);
        _healCooldown = healCooldownDuration;
        gameFeel.onMerge(1);
        showDamageNumber(
          wall.position,
          '+${healAmount.toInt()} HP',
          const Color(0xFF66BB6A),
        );
      }
    }
  }

  // ══════════════════════════════════════
  // Manual Merge (Drag-based)
  // ══════════════════════════════════════

  /// Manual merge/move via drag-and-drop from HUD.
  /// Returns a description of what happened for UI feedback.
  String? manualMerge(int fromSlot, int toSlot) {
    if (fromSlot == toSlot) return null;
    if (fromSlot < 0 || fromSlot >= _unitSlots.length) return null;
    if (toSlot < 0 || toSlot >= _unitSlots.length) return null;

    final unitA = _unitSlots[fromSlot].unit;
    if (unitA == null) return null;

    final unitB = _unitSlots[toSlot].unit;

    // Case 1: Drop on empty slot → move
    if (unitB == null) {
      _unitSlots[toSlot].place(unitA);
      _unitSlots[fromSlot].clear();
      _refreshSlotComponents();
      return 'move';
    }

    // Case 2: Same type + same level → manual merge (only 2 needed for drag!)
    if (unitA.unitTypeId == unitB.unitTypeId &&
        unitA.level == unitB.level &&
        unitA.level < merge.MergeManager.maxLevel &&
        !unitA.isEvolved) {
      final newLevel = unitA.level + 1;
      _unitSlots[fromSlot].clear();
      _unitSlots[toSlot].place(merge.DefenseUnit(
        unitTypeId: unitA.unitTypeId,
        level: newLevel,
      ));
      _totalMerges++;
      _updateAchievement(AchievementType.merges, _totalMerges);
      gameFeel.onMerge(newLevel);
      particleEffect.spawnMerge(wall.position.x, wall.position.y);

      // Relic: merge bomb
      final mergeBombDmg = relicManager.mergeBombDamage;
      if (mergeBombDmg > 0) {
        for (final enemy in livingEnemies) {
          final dist = wall.position.distanceTo(enemy.position);
          if (dist <= 120.0) {
            enemy.takeDamage(mergeBombDmg * newLevel);
          }
        }
      }

      // Recursive auto-merge check (same-type only)
      _tryAutoMerge();
      _checkUnlocks();
      _refreshSlotComponents();
      return 'merge';
    }

    // Case 3: Cross-breed (different types, both Lv3+)
    if (merge.MergeManager.canCrossBreed(unitA, unitB)) {
      final recipe = HybridDatabase.findRecipe(unitA.unitTypeId, unitB.unitTypeId);
      if (recipe != null) {
        _unitSlots[fromSlot].clear();
        _unitSlots[toSlot].place(merge.DefenseUnit(
          unitTypeId: recipe.hybridId,
          level: unitA.level,
        ));
        gameFeel.onEvolve();
        particleEffect.spawnHybridMerge(wall.position.x, wall.position.y);
        achievementManager.totalHybridsCreated++;
        _updateAchievement(
            AchievementType.hybrids, achievementManager.totalHybridsCreated);
        // Codex: discover this hybrid
        codexManager.discoverHybrid(recipe.hybridId);
        _checkUnlocks();
        _refreshSlotComponents();
        return 'hybrid';
      }
    }

    // Case 4: Swap positions (fallback)
    _unitSlots[fromSlot].place(unitB);
    _unitSlots[toSlot].place(unitA);
    _refreshSlotComponents();
    return 'swap';
  }

  /// Get the hybrid preview for a potential cross-breed between two slots.
  /// Returns [hybridId, hybridEmoji, hybridName] or null.
  Map<String, String>? getCrossBreedPreview(int slotA, int slotB) {
    if (slotA < 0 || slotA >= _unitSlots.length) return null;
    if (slotB < 0 || slotB >= _unitSlots.length) return null;
    final unitA = _unitSlots[slotA].unit;
    final unitB = _unitSlots[slotB].unit;
    if (unitA == null || unitB == null) return null;
    if (!merge.MergeManager.canCrossBreed(unitA, unitB)) return null;
    final recipe = HybridDatabase.findRecipe(unitA.unitTypeId, unitB.unitTypeId);
    if (recipe == null) return null;
    final hybrid = HybridDatabase.get(recipe.hybridId);
    if (hybrid == null) return null;
    return {
      'id': recipe.hybridId,
      'emoji': hybrid.emoji,
      'name': hybrid.name,
      'ability': hybrid.specialAbilityDesc,
    };
  }

  // ══════════════════════════════════════
  // Wave Rush (Skip between-wave pause)
  // ══════════════════════════════════════

  /// Skip the between-wave pause for a rush bonus.
  void rushWave() {
    if (!waveManager.betweenWaves) return;
    waveManager.skipPause();
    addGold(5, popupPos: wall.position);
    showDamageNumber(wall.position, 'RUSH +5G', const Color(0xFF64FFDA));
  }
}
