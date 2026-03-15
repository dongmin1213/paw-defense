import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../data/balance_config.dart';
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
    // Active skill: wall_heal grants invincibility
    if (game.skillManager.isEffectActive('wall_heal')) return;
    currentHp = (currentHp - amount).clamp(0, maxHp);
    _isDamageFlash = true;
    _damageFlashTimer = BalanceConfig.wallDamageFlashDuration;
    game.gameFeel.onWallHit();
    game.particleEffect.spawnWallHit(position.x, position.y);
    if (isDestroyed) {
      // Check for last stand / phoenix relic before declaring death
      if (game.relicManager.onWallFatalDamage()) {
        if (game.relicManager.phoenixJustUsed) {
          // Phoenix: revive with configured HP
          currentHp = maxHp * BalanceConfig.wallPhoenixRevivePercent;
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
    maxHp = 100.0 + (level - 1) * BalanceConfig.wallHpPerLevel;
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
    // Invincibility shield glow (pulsing green)
    if (game.skillManager.isEffectActive('wall_heal')) {
      final pulse = ((_animTimer * 4) % 6.28);
      final alpha = 50 + (30 * (pulse < 3.14 ? pulse / 3.14 : 2.0 - pulse / 3.14)).toInt();
      final shieldPaint = Paint()
        ..color = Color.fromARGB(alpha.clamp(30, 90), 100, 220, 100);
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        size.x * 0.55,
        shieldPaint,
      );
    }

    // Low HP warning glow (pulsing red when below 25%)
    if (hpPercent < 0.25 && hpPercent > 0) {
      final pulse = ((_animTimer * 5) % 6.28);
      final alpha = (20 + 25 * (pulse < 3.14 ? pulse / 3.14 : 2.0 - pulse / 3.14)).toInt();
      final warnPaint = Paint()
        ..color = Color.fromARGB(alpha.clamp(15, 50), 255, 50, 50);
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        size.x * 0.5,
        warnPaint,
      );
    }

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
