import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../game/runner_game.dart';
import '../renderers/boss_renderer.dart';
import '../utils/constants.dart';
import 'coin.dart';

class Boss extends PositionComponent
    with HasGameReference<RunnerGame>, CollisionCallbacks {
  final String regionId;
  final int bossIndex; // which boss encounter (1st, 2nd, etc.)

  double maxHp = 50;
  double hp = 50;
  double _timer = 0;
  double _autoAttackTimer = 0;
  double _animTimer = 0;
  bool _isDead = false;
  bool _isIntro = true;
  double _introTimer = 0;
  double _deathTimer = 0;

  static const double bossTimeLimit = 10.0;
  static const double autoAttackInterval = 0.5;

  Boss({
    required this.regionId,
    required this.bossIndex,
    required Vector2 spawnPosition,
  }) : super(
          position: spawnPosition,
          size: Vector2(60, 60),
          priority: 5,
        ) {
    _calculateHp();
  }

  void _calculateHp() {
    // HP scales with region and boss index
    final regionMult = _regionHpMultiplier();
    maxHp = (30 + bossIndex * 20) * regionMult;
    hp = maxHp;
  }

  double _regionHpMultiplier() {
    switch (regionId) {
      case 'meadow': return 1.0;
      case 'forest': return 2.5;
      case 'desert': return 6.0;
      case 'snowfield': return 15.0;
      case 'volcano': return 40.0;
      default: return 1.0;
    }
  }

  double get coinReward {
    switch (regionId) {
      case 'meadow': return 50.0 + bossIndex * 20;
      case 'forest': return 200.0 + bossIndex * 80;
      case 'desert': return 800.0 + bossIndex * 300;
      case 'snowfield': return 3000.0 + bossIndex * 1000;
      case 'volcano': return 10000.0 + bossIndex * 5000;
      default: return 50.0;
    }
  }

  double get soulReward {
    // Small soul drop from bosses
    switch (regionId) {
      case 'meadow': return 0;
      case 'forest': return 0.5;
      case 'desert': return 1;
      case 'snowfield': return 2;
      case 'volcano': return 5;
      default: return 0;
    }
  }

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(isSolid: true));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _animTimer += dt;

    if (_isDead) {
      _deathTimer += dt;
      if (_deathTimer > 0.6) {
        removeFromParent();
      }
      return;
    }

    // Intro slide-in
    if (_isIntro) {
      _introTimer += dt;
      // Boss slides to position right of player
      final targetX = game.player.position.x + 180;
      position.x += (targetX - position.x) * 2 * dt;
      if (_introTimer > 1.0) {
        _isIntro = false;
      }
      return;
    }

    // Follow player (stay to the right)
    final targetX = game.player.position.x + 180;
    position.x += (targetX - position.x) * 3 * dt;

    // Timer
    _timer += dt;
    if (_timer >= bossTimeLimit) {
      // Boss escapes
      _escape();
      return;
    }

    // Auto-attack from player
    _autoAttackTimer += dt;
    if (_autoAttackTimer >= autoAttackInterval / game.upgradeManager.attackMultiplier.clamp(0.5, 10)) {
      _autoAttackTimer = 0;
      _takeDamage(1.0 * game.upgradeManager.attackMultiplier);
    }
  }

  void onTapAttack() {
    if (_isDead || _isIntro) return;
    // Player tap = extra attack (2x DPS)
    _takeDamage(2.0 * game.upgradeManager.attackMultiplier);
  }

  void _takeDamage(double damage) {
    hp -= damage;
    if (hp <= 0) {
      hp = 0;
      _die();
    }
  }

  void _die() {
    _isDead = true;

    // Spawn coins
    final rng = Random();
    final coinCount = 8 + rng.nextInt(5);
    for (var i = 0; i < coinCount; i++) {
      final coinX = position.x + rng.nextDouble() * 40 - 20;
      final coinY = position.y + rng.nextDouble() * 30 - 15;
      game.world.add(Coin(
        spawnPosition: Vector2(coinX, coinY),
        value: coinReward / coinCount,
      ));
    }

    // Combo bonus
    game.addCombo(5);
  }

  void _escape() {
    _isDead = true;
  }

  double get hpPercent => hp / maxHp;
  double get timePercent => _timer / bossTimeLimit;
  bool get isDead => _isDead;

  @override
  void render(Canvas canvas) {
    if (_isDead) {
      // Death flash
      final flashPaint = Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.5);
      canvas.drawCircle(Offset(size.x / 2, size.y / 2), 30, flashPaint);
      return;
    }

    // Render boss
    BossRenderer.render(canvas, regionId, size.toSize(), _animTimer);

    // HP bar
    final barWidth = size.x + 10;
    final barHeight = 5.0;
    final barX = (size.x - barWidth) / 2;
    final barY = -10.0;

    // BG
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(barX, barY, barWidth, barHeight), const Radius.circular(2)),
      Paint()..color = const Color(0xFF333333),
    );

    // HP fill
    final hpColor = hpPercent > 0.5
        ? const Color(0xFFE53935)
        : hpPercent > 0.25
            ? const Color(0xFFFF9800)
            : const Color(0xFFFF1744);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(barX, barY, barWidth * hpPercent, barHeight), const Radius.circular(2)),
      Paint()..color = hpColor,
    );

    // Timer bar
    final timerY = barY - 6;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(barX, timerY, barWidth, 3), const Radius.circular(1)),
      Paint()..color = const Color(0xFF555555),
    );
    final timeColor = timePercent < 0.5
        ? const Color(0xFF4CAF50)
        : timePercent < 0.8
            ? const Color(0xFFFF9800)
            : const Color(0xFFE53935);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(barX, timerY, barWidth * (1 - timePercent), 3), const Radius.circular(1)),
      Paint()..color = timeColor,
    );
  }
}
