import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/boss_rush_game.dart';
import '../components/player.dart';

abstract class BossBase extends PositionComponent with HasGameRef<BossRushGame>, CollisionCallbacks {
  final String bossName;
  final double maxHp;
  late double currentHp;
  int currentPhase = 1;
  final int totalPhases;
  bool isDefeated = false;
  double _hitFlashTimer = 0;

  BossBase({
    required this.bossName,
    required this.maxHp,
    required this.totalPhases,
    required Vector2 size,
    required Vector2 position,
  }) : super(size: size, position: position) {
    currentHp = maxHp;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  void takeDamage(double damage) {
    if (isDefeated) return;
    currentHp -= damage;
    _hitFlashTimer = 0.1;

    // Phase transitions
    final phaseThreshold = maxHp / totalPhases;
    final newPhase = (totalPhases - (currentHp / phaseThreshold).floor()).clamp(1, totalPhases);
    if (newPhase > currentPhase) {
      currentPhase = newPhase;
      onPhaseChange(currentPhase);
    }

    if (currentHp <= 0) {
      currentHp = 0;
      isDefeated = true;
      onDefeat();
      gameRef.onBossDefeated();
    }
  }

  double get hpPercentage => currentHp / maxHp;

  /// Called when boss transitions to a new phase
  void onPhaseChange(int newPhase);

  /// Called when boss is defeated
  void onDefeat();

  /// Override this to implement boss-specific attack patterns
  void updateBehavior(double dt);

  @override
  void update(double dt) {
    super.update(dt);
    if (_hitFlashTimer > 0) _hitFlashTimer -= dt;
    if (!isDefeated) {
      updateBehavior(dt);
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Player) {
      gameRef.onPlayerHit();
    }
  }

  bool get isFlashing => _hitFlashTimer > 0;

  Paint get basePaint => Paint()..color = isFlashing ? Colors.white : Colors.red;
}
