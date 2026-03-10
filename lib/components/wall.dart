import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../game/defense_game.dart';
import '../renderers/wall_renderer.dart';

/// The central wall/castle that the player must defend.
/// Positioned at the center of the map. Enemies converge on it.
class Wall extends PositionComponent
    with HasGameReference<DefenseGame>, CollisionCallbacks {
  double maxHp = 100;
  double currentHp = 100;
  int level = 1;
  double _animTimer = 0;
  bool _isDamageFlash = false;
  double _damageFlashTimer = 0;

  Wall()
      : super(
          size: Vector2(60, 60),
          anchor: Anchor.center,
          priority: 10,
        );

  double get hpPercent => currentHp / maxHp;
  bool get isDestroyed => currentHp <= 0;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  /// Apply damage from an enemy reaching the wall.
  void takeDamage(double amount) {
    if (isDestroyed) return;
    currentHp = (currentHp - amount).clamp(0, maxHp);
    _isDamageFlash = true;
    _damageFlashTimer = 0.15;
    game.gameFeel.onWallHit();
    game.particleEffect.spawnWallHit(position.x, position.y);
    if (isDestroyed) {
      // Check for last stand / phoenix relic before declaring death
      if (game.relicManager.onWallFatalDamage()) {
        if (game.relicManager.phoenixJustUsed) {
          // Phoenix: revive with 50% HP
          currentHp = maxHp * 0.5;
        } else {
          // Last stand: survive with 1 HP
          currentHp = 1.0;
        }
        game.particleEffect.spawnBossExplosion(position.x, position.y);
        return;
      }
      game.onWallDestroyed();
    }
  }

  /// Heal the wall by [amount] HP.
  void heal(double amount) {
    currentHp = (currentHp + amount).clamp(0, maxHp);
  }

  /// Upgrade the wall, increasing max HP and restoring some health.
  void upgrade() {
    level++;
    final oldMax = maxHp;
    maxHp = 100.0 + (level - 1) * 30.0;
    // Heal proportionally to the HP increase
    currentHp = (currentHp + (maxHp - oldMax)).clamp(0, maxHp);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _animTimer += dt;

    if (_isDamageFlash) {
      _damageFlashTimer -= dt;
      if (_damageFlashTimer <= 0) {
        _isDamageFlash = false;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    WallRenderer.render(
      canvas,
      size.toSize(),
      hpPercent: hpPercent,
      animTimer: _animTimer,
      level: level,
      isDamageFlash: _isDamageFlash,
    );
  }
}
