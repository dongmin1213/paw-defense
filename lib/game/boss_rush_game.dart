import 'dart:math';
import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../components/player.dart';
import '../components/ground.dart';
import '../components/enemy.dart';
import '../bosses/boss_base.dart';
import '../bosses/boss_factory.dart';
import '../classes/player_class.dart';
import '../utils/constants.dart';

enum GamePhase { exploration, boss }

class BossRushGame extends FlameGame with HasCollisionDetection {
  final int stageIndex;
  final PlayerClassType playerClass;
  final bool bossRushMode;
  late Player player;
  late BossBase boss;
  late PlayerClassData classData;

  int playerHp = 3;
  double specialGauge = 0;
  bool isGameOver = false;
  bool isVictory = false;

  GamePhase currentPhase = GamePhase.exploration;
  bool _bossSpawned = false;
  final List<Enemy> _enemies = [];

  // Screen shake
  double _shakeTimer = 0;
  double _shakeIntensity = 0;

  BossRushGame({
    required this.stageIndex,
    required this.playerClass,
    this.bossRushMode = false,
  });

  @override
  Color backgroundColor() => const Color(0xFF000000);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    classData = PlayerClassData.get(playerClass);
    playerHp = classData.maxHp;

    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewport = FixedResolutionViewport(
      resolution: Vector2(GameConstants.worldWidth, GameConstants.worldHeight),
    );

    // Background
    world.add(RectangleComponent(
      size: Vector2(GameConstants.worldWidth, GameConstants.worldHeight),
      paint: Paint()..color = StageThemes.getBackgroundColor(stageIndex),
    ));

    // Ground
    world.add(Ground(stageIndex: stageIndex));

    // Player
    player = Player(classData: classData);
    player.position = Vector2(100, GameConstants.groundY - GameConstants.playerHeight);
    world.add(player);

    // Show game overlay
    overlays.add('GameOverlay');

    if (bossRushMode) {
      _enterBossPhase();
    } else {
      _spawnStageEnemies();
    }
  }

  void _spawnStageEnemies() {
    final enemyDefs = StageThemes.getEnemies(stageIndex);
    for (final def in enemyDefs) {
      final enemy = Enemy(
        type: def.type,
        startPosition: def.position,
        patrolRange: def.patrolRange,
      );
      _enemies.add(enemy);
      world.add(enemy);
    }
  }

  void onEnemyDefeated(Enemy enemy) {
    _enemies.remove(enemy);
    addSpecialGauge(4);

    // All enemies defeated -> enter boss phase
    if (_enemies.isEmpty && !_bossSpawned) {
      _enterBossPhase();
    }
  }

  void _enterBossPhase() {
    currentPhase = GamePhase.boss;
    _bossSpawned = true;

    // Reset player position for boss fight
    player.position = Vector2(100, GameConstants.groundY - GameConstants.playerHeight);

    // Spawn boss
    boss = BossFactory.createBoss(stageIndex, this);
    world.add(boss);
  }

  void enterBossDirectly() {
    // Remove all enemies
    for (final e in _enemies) {
      if (e.isMounted) e.removeFromParent();
    }
    _enemies.clear();
    _enterBossPhase();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_shakeTimer > 0) {
      _shakeTimer -= dt;
      final progress = _shakeTimer / (_shakeTimer + dt); // decay
      final offsetX = sin(_shakeTimer * 40) * _shakeIntensity * progress;
      final offsetY = cos(_shakeTimer * 35) * _shakeIntensity * 0.5 * progress;
      camera.viewfinder.position = Vector2(offsetX, offsetY);

      if (_shakeTimer <= 0) {
        camera.viewfinder.position = Vector2.zero();
      }
    }
  }

  void triggerShake({double intensity = 3.0, double duration = 0.15}) {
    _shakeIntensity = intensity;
    _shakeTimer = duration;
  }

  void onPlayerHit() {
    if (player.isInvincible || isGameOver) return;

    playerHp--;
    player.startInvincibility();
    triggerShake(intensity: 4.0, duration: 0.2);

    if (playerHp <= 0) {
      gameOver();
    }
  }

  void addSpecialGauge(double amount) {
    specialGauge = (specialGauge + amount).clamp(0, GameConstants.specialGaugeMax);
  }

  bool useSpecialAttack() {
    if (specialGauge >= GameConstants.specialGaugeMax) {
      specialGauge = 0;
      return true;
    }
    return false;
  }

  void onBossDefeated() {
    if (isVictory) return;
    isVictory = true;
    overlays.add('Victory');
    pauseEngine();
  }

  void gameOver() {
    if (isGameOver) return;
    isGameOver = true;
    overlays.add('GameOver');
    pauseEngine();
  }

  void resetGame() {
    isGameOver = false;
    isVictory = false;
    playerHp = classData.maxHp;
    specialGauge = 0;
    currentPhase = GamePhase.exploration;
    _bossSpawned = false;
    _enemies.clear();
    _shakeTimer = 0;
    camera.viewfinder.position = Vector2.zero();

    world.removeAll(world.children.toList());
    resumeEngine();
    onLoad();
  }
}

/// Stage theme data
class StageThemes {
  static Color getBackgroundColor(int stage) {
    const colors = [
      Color(0xFF1A1A2E), // 돌의 성채
      Color(0xFF0D0D1A), // 그림자 골목
      Color(0xFF1A0A2E), // 마녀의 탑
      Color(0xFF1A1A1A), // 강철 요새
      Color(0xFF1A2A2E), // 거울의 미궁
      Color(0xFF2E1A0A), // 벌집 동굴
      Color(0xFF0A1A2E), // 폭풍 봉우리
      Color(0xFF1A0A0A), // 암흑의 왕좌
    ];
    return stage < colors.length ? colors[stage] : colors[0];
  }

  static Color getGroundColor(int stage) {
    const colors = [
      Color(0xFF3D3D5C),
      Color(0xFF2D2D3D),
      Color(0xFF3D2D4C),
      Color(0xFF4D4D4D),
      Color(0xFF3D4D5C),
      Color(0xFF5C4D2D),
      Color(0xFF3D4D5C),
      Color(0xFF3D2D2D),
    ];
    return stage < colors.length ? colors[stage] : colors[0];
  }

  static String getStageName(int stage) {
    const names = [
      '돌의 성채',
      '그림자 골목',
      '마녀의 탑',
      '강철 요새',
      '거울의 미궁',
      '벌집 동굴',
      '폭풍 봉우리',
      '암흑의 왕좌',
    ];
    return stage < names.length ? names[stage] : '???';
  }

  static List<EnemyDef> getEnemies(int stage) {
    final List<EnemyDef> enemies = [];

    // Base enemies for all stages
    enemies.addAll([
      EnemyDef(EnemyType.slime, Vector2(300, GameConstants.groundY - 30), 80),
      EnemyDef(EnemyType.slime, Vector2(550, GameConstants.groundY - 30), 60),
      EnemyDef(EnemyType.bat, Vector2(400, 320), 100),
    ]);

    if (stage >= 1) {
      enemies.add(EnemyDef(EnemyType.skeleton, Vector2(650, GameConstants.groundY - 40), 70));
      enemies.add(EnemyDef(EnemyType.bat, Vector2(250, 280), 120));
    }
    if (stage >= 2) {
      enemies.add(EnemyDef(EnemyType.skeleton, Vector2(450, GameConstants.groundY - 40), 90));
    }
    if (stage >= 4) {
      enemies.add(EnemyDef(EnemyType.skeleton, Vector2(350, GameConstants.groundY - 40), 80));
      enemies.add(EnemyDef(EnemyType.bat, Vector2(500, 250), 150));
    }

    return enemies;
  }
}

class EnemyDef {
  final EnemyType type;
  final Vector2 position;
  final double patrolRange;

  EnemyDef(this.type, this.position, this.patrolRange);
}
