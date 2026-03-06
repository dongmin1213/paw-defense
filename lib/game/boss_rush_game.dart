import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../components/player.dart';
import '../components/ground.dart';
import '../bosses/boss_base.dart';
import '../bosses/boss_factory.dart';
import '../utils/constants.dart';

class BossRushGame extends FlameGame with HasCollisionDetection {
  final int bossIndex;
  late Player player;
  late BossBase boss;

  int playerHp = GameConstants.playerMaxHp;
  double specialGauge = 0;
  bool isGameOver = false;
  bool isVictory = false;

  BossRushGame({required this.bossIndex});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewport = FixedResolutionViewport(
      resolution: Vector2(GameConstants.worldWidth, GameConstants.worldHeight),
    );

    // Background
    world.add(RectangleComponent(
      size: Vector2(GameConstants.worldWidth, GameConstants.worldHeight),
      paint: Paint()..color = const Color(0xFF1A1A2E),
    ));

    // Ground
    world.add(Ground());

    // Player
    player = Player();
    player.position = Vector2(100, GameConstants.groundY - GameConstants.playerHeight);
    world.add(player);

    // Boss
    boss = BossFactory.createBoss(bossIndex, this);
    world.add(boss);

    // Show game overlay
    overlays.add('GameOverlay');
  }

  void onPlayerHit() {
    if (player.isInvincible || isGameOver) return;

    playerHp--;
    player.startInvincibility();

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
    playerHp = GameConstants.playerMaxHp;
    specialGauge = 0;

    // Remove all world children and reload
    world.removeAll(world.children);
    resumeEngine();
    onLoad();
  }
}
