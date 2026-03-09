import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../game/defense_game.dart';
import '../renderers/defense_enemy_renderer.dart';
import 'wall.dart';

/// An enemy that moves toward the wall from the screen edges.
/// When reaching the wall, it attacks periodically until killed.
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

  static const double wallProximity = 35.0;

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
  }

  /// Apply damage to this enemy.
  void takeDamage(double amount) {
    if (_isDead) return;
    hp -= amount;
    _isHit = true;
    _hitFlashTimer = 0.1;

    // Knockback away from wall
    position.add(direction * -3);

    if (hp <= 0) {
      hp = 0;
      _die();
    }
  }

  void _die() {
    _isDead = true;
    game.addGold(goldDrop);
    game.onEnemyKilled(this);
    game.particleEffect.spawnEnemyDeath(
      position.x,
      position.y,
    );
    removeFromParent();
  }

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

    if (!_reachedWall) {
      // Move toward the wall
      final wallPos = game.wall.position;
      final dist = position.distanceTo(wallPos);

      if (dist <= wallProximity) {
        _reachedWall = true;
        _attackTimer = 0;
      } else {
        // Recalculate direction in case wall position changes
        direction = (wallPos - position).normalized();

        // Flying enemies hover with a sine wave offset
        if (isFlying) {
          final hover = _sin(_animTimer * 4) * 3;
          position.add(Vector2(
            direction.x * speed * dt,
            direction.y * speed * dt + hover * dt,
          ));
        } else {
          position.add(direction * speed * dt);
        }
      }
    } else {
      // Attack the wall periodically
      _attackTimer += dt;
      final interval = 1.0 / attackSpeed;
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
    game.wall.takeDamage(damage);
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    if (other is Wall && !_reachedWall) {
      _reachedWall = true;
      _attackTimer = 0;
    }
  }

  @override
  void render(Canvas canvas) {
    DefenseEnemyRenderer.render(
      canvas,
      size.toSize(),
      enemyId: enemyId,
      animTimer: _animTimer,
      isHit: _isHit,
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
