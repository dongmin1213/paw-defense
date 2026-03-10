import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../data/balance_config.dart';
import '../game/defense_game.dart';
import '../renderers/defense_enemy_renderer.dart';
import 'wall.dart';

/// An enemy that moves toward the wall from the screen edges.
/// When reaching the wall, it attacks periodically until killed.
///
/// Special enemy types:
/// - **healer**: Heals nearby allies every 3 seconds for 10% of their maxHp.
/// - **bomber**: Explodes on reaching the wall, dealing 3x damage but dying immediately.
/// - **shielded**: Takes 50% reduced damage from the front.
/// - **boss**: 1.5x size, red glow, 0.5 attack speed.
class DefenseEnemy extends PositionComponent
    with HasGameReference<DefenseGame>, CollisionCallbacks {
  final String enemyId;
  double hp;
  double maxHp;
  final double speed;
  final double damage;
  final double attackSpeed;
  final bool isFlying;
  final int goldDrop;
  final int wave;

  Vector2 direction;
  double _attackTimer = 0;
  double _animTimer = 0;
  bool _isHit = false;
  double _hitFlashTimer = 0;
  bool _reachedWall = false;
  bool _isDead = false;

  // Special behavior timers
  double _healTimer = 0;

  // Slow debuff
  double _slowIntensity = 0; // 0.0 = no slow, 0.3 = 30% slow
  double _slowTimer = 0;

  static const double wallProximity = 35.0;

  // Special type detection helpers
  bool get _isHealer => enemyId.contains('healer');
  bool get _isBomber => enemyId.contains('bomber');
  bool get _isShielded => enemyId.contains('shielded') || enemyId.contains('shield');
  bool get _isBoss => enemyId.contains('boss');

  DefenseEnemy({
    required this.enemyId,
    required this.maxHp,
    required this.speed,
    required this.damage,
    required this.attackSpeed,
    required this.goldDrop,
    required this.wave,
    required Vector2 spawnPosition,
    required Vector2 wallPosition,
    this.isFlying = false,
  })  : hp = maxHp,
        direction = (wallPosition - spawnPosition).normalized(),
        super(
          position: spawnPosition.clone(),
          size: Vector2(20, 20),
          anchor: Anchor.center,
          priority: 12,
        );

  bool get isDead => _isDead;
  double get hpPercent => hp / maxHp;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());

    // Boss: 1.5x size
    if (_isBoss) {
      size = Vector2(30, 30);
    }
  }

  /// Apply damage to this enemy.
  /// For shielded enemies, checks if damage comes from the front (50% reduction).
  void takeDamage(double amount, {Vector2? sourcePosition}) {
    if (_isDead) return;

    double finalAmount = amount;

    // Shielded: 50% reduced damage from the front
    if (_isShielded && sourcePosition != null) {
      final toSource = (sourcePosition - position).normalized();
      // Front = same direction as movement direction
      // dot > 0 means source is in front of the enemy (enemy facing toward wall)
      final dot = direction.dot(toSource);
      if (dot > 0) {
        finalAmount *= 0.5;
      }
    }

    hp -= finalAmount;
    _isHit = true;
    _hitFlashTimer = 0.1;

    // Lifesteal: heal wall for a percentage of damage dealt
    final lifesteal = game.relicManager.lifestealPercent;
    if (lifesteal > 0 && !game.wall.isDestroyed) {
      game.wall.heal(finalAmount * lifesteal);
    }

    // Knockback away from wall
    position.add(direction * -3);

    if (hp <= 0) {
      hp = 0;
      _die();
    }
  }

  void _die() {
    _isDead = true;
    game.addGold(goldDrop, popupPos: position);
    game.onEnemyKilled(this);
    game.particleEffect.spawnEnemyDeath(
      position.x,
      position.y,
    );
    removeFromParent();
  }

  /// Apply a slow debuff to this enemy.
  void applySlow(double intensity, double duration) {
    if (intensity > _slowIntensity) {
      _slowIntensity = intensity;
    }
    _slowTimer = duration;
  }

  /// Effective speed accounting for slow debuff and relic slow aura.
  double get _effectiveSpeed {
    double s = speed;
    // Slow debuff (from bear tanker)
    if (_slowTimer > 0) {
      s *= (1.0 - _slowIntensity);
    }
    // Relic slow aura near wall
    if (game.relicManager.hasSlowAura && !_reachedWall) {
      final distToWall = position.distanceTo(game.wall.position);
      if (distToWall <= BalanceConfig.relicSlowAuraRadius) {
        s *= (1.0 - BalanceConfig.relicSlowAuraIntensity);
      }
    }
    return s;
  }

  /// Healer: heal all allies within 50px for 10% of their maxHp.
  void _healNearbyAllies() {
    final enemies = game.world.children.whereType<DefenseEnemy>();
    for (final ally in enemies) {
      if (ally.isDead || identical(ally, this)) continue;
      final dist = position.distanceTo(ally.position);
      if (dist <= 50.0) {
        final healAmount = ally.maxHp * 0.10;
        ally.hp = (ally.hp + healAmount).clamp(0.0, ally.maxHp);
      }
    }
  }

  /// Bomber: explode on reaching wall, dealing 3x damage and dying.
  void _explode() {
    if (game.wall.isDestroyed) return;
    final wallDefense = game.rewardWallDefenseMultiplier *
        (1.0 - game.relicManager.wallDamageReduction) *
        game.upgradeManager.wallDefenseMultiplier;
    game.wall.takeDamage(damage * BalanceConfig.bomberExplosionMultiplier * wallDefense);
    game.waveManager.onWallDamaged();
    game.particleEffect.spawnEnemyDeath(position.x, position.y);
    _isDead = true;
    game.addGold(goldDrop, popupPos: position);
    game.onEnemyKilled(this);
    removeFromParent();
  }

  /// Effective attack speed (boss has fixed 0.5).
  double get _effectiveAttackSpeed => _isBoss ? 0.5 : attackSpeed;

  @override
  void update(double dt) {
    super.update(dt);
    if (_isDead) return;

    _animTimer += dt;

    // Hit flash countdown
    if (_isHit) {
      _hitFlashTimer -= dt;
      if (_hitFlashTimer <= 0) {
        _isHit = false;
      }
    }

    // Slow debuff countdown
    if (_slowTimer > 0) {
      _slowTimer -= dt;
      if (_slowTimer <= 0) {
        _slowTimer = 0;
        _slowIntensity = 0;
      }
    }

    // Healer: heal allies every 3 seconds
    if (_isHealer) {
      _healTimer += dt;
      if (_healTimer >= 3.0) {
        _healTimer -= 3.0;
        _healNearbyAllies();
      }
    }

    if (!_reachedWall) {
      // Move toward the wall
      final wallPos = game.wall.position;
      final dist = position.distanceTo(wallPos);

      if (dist <= wallProximity) {
        _reachedWall = true;
        _attackTimer = 0;

        // Bomber: explode immediately on reaching wall
        if (_isBomber) {
          _explode();
          return;
        }
      } else {
        // Recalculate direction in case wall position changes
        direction = (wallPos - position).normalized();

        // Flying enemies hover with a sine wave offset
        final spd = _effectiveSpeed;
        if (isFlying) {
          final hover = _sin(_animTimer * 4) * 3;
          position.add(Vector2(
            direction.x * spd * dt,
            direction.y * spd * dt + hover * dt,
          ));
        } else {
          position.add(direction * spd * dt);
        }
      }
    } else {
      // Attack the wall periodically
      _attackTimer += dt;
      final interval = 1.0 / _effectiveAttackSpeed;
      if (_attackTimer >= interval) {
        _attackTimer -= interval;
        _attackWall();
      }
    }

    // Remove if somehow way off screen (safety)
    if (position.x < -100 ||
        position.x > 500 ||
        position.y < -100 ||
        position.y > 800) {
      removeFromParent();
    }
  }

  void _attackWall() {
    if (game.wall.isDestroyed) return;
    final wallDefense = game.rewardWallDefenseMultiplier *
        (1.0 - game.relicManager.wallDamageReduction) *
        game.upgradeManager.wallDefenseMultiplier;
    game.wall.takeDamage(damage * wallDefense);
    game.waveManager.onWallDamaged();
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    if (other is Wall && !_reachedWall) {
      _reachedWall = true;
      _attackTimer = 0;

      // Bomber: explode on collision with wall
      if (_isBomber) {
        _explode();
        return;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    // Boss: red glow effect
    if (_isBoss) {
      final glowPaint = Paint()
        ..color = Color.fromARGB(
          (40 + 20 * _sin(_animTimer * 3).abs()).toInt(),
          255, 0, 0,
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        size.x * 0.6,
        glowPaint,
      );
    }

    DefenseEnemyRenderer.render(
      canvas,
      size.toSize(),
      enemyId: enemyId,
      animTimer: _animTimer,
      isHit: _isHit,
      isBoss: _isBoss,
      isFlying: isFlying,
      hpPercent: hpPercent,
    );

    // HP bar above enemy
    if (hp < maxHp && !_isDead) {
      _renderHpBar(canvas);
    }
  }

  void _renderHpBar(Canvas canvas) {
    const barWidth = 18.0;
    const barHeight = 3.0;
    final barX = (size.x - barWidth) / 2;
    const barY = -5.0;

    // Background
    final bgPaint = Paint()
      ..color = const Color(0xFF333333)
      ..isAntiAlias = false;
    canvas.drawRect(
      Rect.fromLTWH(barX, barY, barWidth, barHeight),
      bgPaint,
    );

    // Fill
    final fillColor = hpPercent > 0.5
        ? const Color(0xFF4CAF50)
        : hpPercent > 0.25
            ? const Color(0xFFFF9800)
            : const Color(0xFFF44336);
    final fillPaint = Paint()
      ..color = fillColor
      ..isAntiAlias = false;
    canvas.drawRect(
      Rect.fromLTWH(barX, barY, barWidth * hpPercent, barHeight),
      fillPaint,
    );
  }

  double _sin(double x) {
    x = x % 6.2832;
    if (x < 0) x += 6.2832;
    if (x > 3.1416) {
      x -= 3.1416;
      return -(x * (4 - x * 1.2732) * 0.405 + x * (4 - x * 1.2732) * 0.595);
    }
    return x * (4 - x * 1.2732) * 0.405 + x * (4 - x * 1.2732) * 0.595;
  }
}
