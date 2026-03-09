import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../game/runner_game.dart';
import '../renderers/boss_renderer.dart';
import '../ui/ui_effects.dart';
import 'boss_projectile.dart';
import 'coin.dart';

class Boss extends PositionComponent
    with HasGameReference<RunnerGame>, CollisionCallbacks {
  final String regionId;
  final int bossIndex;

  double maxHp = 50;
  double hp = 50;
  double _timer = 0;
  double _autoAttackTimer = 0;
  bool _isDead = false;
  bool _isIntro = true;
  double _introTimer = 0;
  double _deathTimer = 0;
  double _animTimer = 0;

  // Phase system
  int _currentPhase = 1;
  bool _phaseTransitioning = false;
  double _phaseTransitionTimer = 0;

  // Attack patterns
  double _attackCooldown = 0;
  int _attackPatternIndex = 0;
  final Random _rng = Random();

  // Enrage
  bool _isEnraged = false;

  static const double bossTimeLimit = 15.0;
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
    switch (regionId) {
      case 'meadow': return 0;
      case 'forest': return 0.5;
      case 'desert': return 1;
      case 'snowfield': return 2;
      case 'volcano': return 5;
      default: return 0;
    }
  }

  int get _maxPhases {
    switch (regionId) {
      case 'meadow': return 2;
      case 'forest': return 2;
      case 'desert': return 3;
      case 'snowfield': return 3;
      case 'volcano': return 3;
      default: return 2;
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

    // Phase transition animation
    if (_phaseTransitioning) {
      _phaseTransitionTimer -= dt;
      if (_phaseTransitionTimer <= 0) {
        _phaseTransitioning = false;
      }
      return;
    }

    // Intro slide-in
    if (_isIntro) {
      _introTimer += dt;
      final targetX = game.player.position.x + 180;
      position.x += (targetX - position.x) * 2 * dt;
      if (_introTimer > 1.0) {
        _isIntro = false;
      }
      return;
    }

    // Follow player
    final targetX = game.player.position.x + 180;
    position.x += (targetX - position.x) * 3 * dt;

    // Timer
    _timer += dt;
    if (_timer >= bossTimeLimit) {
      _escape();
      return;
    }

    // Auto-attack from player
    _autoAttackTimer += dt;
    if (_autoAttackTimer >= autoAttackInterval / game.upgradeManager.attackMultiplier.clamp(0.5, 10)) {
      _autoAttackTimer = 0;
      _takeDamage(1.0 * game.upgradeManager.attackMultiplier);
    }

    // Boss attacks player
    _attackCooldown -= dt;
    if (_attackCooldown <= 0) {
      _performAttack();
    }

    // Phase check
    _checkPhaseTransition();

    // Enrage at <25% HP
    if (!_isEnraged && hp / maxHp < 0.25) {
      _isEnraged = true;
      UIEffectManager.instance.spawnImpactText(
        text: 'ENRAGED!',
        color: const Color(0xFFFF1744),
        fontSize: 20,
        duration: 1.5,
      );
      UIEffectManager.instance.screenFlash(
        color: const Color(0xFFFF1744),
        duration: 0.3,
        maxAlpha: 0.4,
      );
      game.gameFeel.shake(intensity: 6, duration: 0.3);
    }
  }

  void _checkPhaseTransition() {
    final hpRatio = hp / maxHp;
    int newPhase;
    if (_maxPhases == 3) {
      newPhase = hpRatio > 0.66 ? 1 : (hpRatio > 0.33 ? 2 : 3);
    } else {
      newPhase = hpRatio > 0.5 ? 1 : 2;
    }

    if (newPhase > _currentPhase) {
      _currentPhase = newPhase;
      _phaseTransitioning = true;
      _phaseTransitionTimer = 0.5;

      game.gameFeel.shake(intensity: 8, duration: 0.3);
      game.gameFeel.hitStop(duration: 0.1);
      game.gameFeel.zoomPunch(targetZoom: 1.05, duration: 0.3);
      game.soundManager.playBossHit();

      UIEffectManager.instance.spawnImpactText(
        text: 'PHASE $_currentPhase',
        color: const Color(0xFFFF9800),
        fontSize: 18,
        duration: 1.2,
      );
      UIEffectManager.instance.screenFlash(
        color: _regionColor(),
        duration: 0.3,
        maxAlpha: 0.3,
      );
    }
  }

  void _performAttack() {
    final baseInterval = _isEnraged ? 0.8 : 1.5;
    final phaseSpeedUp = 1.0 - (_currentPhase - 1) * 0.15;
    _attackCooldown = baseInterval * phaseSpeedUp + _rng.nextDouble() * 0.5;

    _attackPatternIndex = (_attackPatternIndex + 1) % 3;

    switch (_attackPatternIndex) {
      case 0:
        _fireProjectile(ProjectilePattern.straight);
        break;
      case 1:
        _fireProjectile(ProjectilePattern.sine);
        break;
      case 2:
        // Multi-shot in later phases
        _fireProjectile(ProjectilePattern.straight);
        if (_currentPhase >= 2) {
          _fireProjectile(ProjectilePattern.falling, yOffset: -20);
        }
        if (_currentPhase >= 3) {
          _fireProjectile(ProjectilePattern.sine, yOffset: 15);
        }
        break;
    }
  }

  void _fireProjectile(ProjectilePattern pattern, {double yOffset = 0}) {
    final spawnPos = Vector2(
      position.x - 10,
      position.y + size.y / 2 + yOffset,
    );
    final speed = _isEnraged ? -320.0 : -250.0;

    game.world.add(BossProjectile(
      spawnPosition: spawnPos,
      speed: speed,
      color: _regionColor(),
      pattern: pattern,
    ));
  }

  Color _regionColor() {
    switch (regionId) {
      case 'meadow': return const Color(0xFF66BB6A);
      case 'forest': return const Color(0xFF558B2F);
      case 'desert': return const Color(0xFFFF8F00);
      case 'snowfield': return const Color(0xFF81D4FA);
      case 'volcano': return const Color(0xFFFF5722);
      default: return const Color(0xFFFF4444);
    }
  }

  void onTapAttack() {
    if (_isDead || _isIntro) return;
    _takeDamage(2.0 * game.upgradeManager.attackMultiplier);
  }

  void onTapAttackWithDamage(double damage) {
    if (_isDead || _isIntro) return;
    _takeDamage(damage);
  }

  void _takeDamage(double damage) {
    hp -= damage;
    game.gameFeel.onBossHit();
    game.soundManager.playBossHit();

    // Damage number
    UIEffectManager.instance.spawnFloatingText(
      text: '-${damage.toInt()}',
      relX: 0.75 + _rng.nextDouble() * 0.1 - 0.05,
      relY: 0.25 + _rng.nextDouble() * 0.1 - 0.05,
      color: damage >= 5 ? const Color(0xFFFFD54F) : const Color(0xFFFFFFFF),
      fontSize: damage >= 5 ? 16.0 : 12.0,
      duration: 0.6,
    );

    if (hp <= 0) {
      hp = 0;
      _die();
    }
  }

  void _die() {
    _isDead = true;

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

    game.addCombo(5);
    game.gameFeel.onBossKill();
    game.soundManager.playBossKill();

    UIEffectManager.instance.screenFlash(
      color: const Color(0xFFE53935),
      duration: 0.4,
      maxAlpha: 0.6,
    );
    UIEffectManager.instance.spawnImpactText(
      text: 'BOSS KILL!',
      color: const Color(0xFFFFD54F),
      fontSize: 26,
      duration: 1.8,
    );

    game.achievementManager.onBossKill();
    game.missionManager.onBossKill(_timer);

    if (soulReward > 0) {
      game.ascensionManager.souls += soulReward.toInt();
      UIEffectManager.instance.spawnFloatingText(
        text: '+${soulReward.toInt()} SOUL',
        relX: 0.5, relY: 0.25,
        color: const Color(0xFFCE93D8),
        fontSize: 14,
      );
    }

    game.particleEffect.spawnBossExplosion(
      position.x + size.x / 2,
      position.y + size.y / 2,
    );

    // Clean up boss projectiles
    game.world.children.whereType<BossProjectile>().toList().forEach((p) => p.removeFromParent());
  }

  void _escape() {
    _isDead = true;
    // Clean up boss projectiles
    game.world.children.whereType<BossProjectile>().toList().forEach((p) => p.removeFromParent());
  }

  double get hpPercent => hp / maxHp;
  double get timePercent => _timer / bossTimeLimit;
  bool get isDead => _isDead;

  @override
  void render(Canvas canvas) {
    if (_isDead) {
      final flashPaint = Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.5);
      canvas.drawCircle(Offset(size.x / 2, size.y / 2), 30, flashPaint);
      return;
    }

    // Phase transition flash
    if (_phaseTransitioning) {
      final flash = (_phaseTransitionTimer * 6).remainder(1.0);
      if (flash > 0.5) {
        final p = Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.6);
        canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), p);
        return;
      }
    }

    // Enrage glow
    if (_isEnraged) {
      final pulse = (sin(_animTimer * 8) * 0.3 + 0.4).clamp(0.0, 1.0);
      final glow = Paint()..color = const Color(0xFFFF1744).withValues(alpha: pulse);
      canvas.drawCircle(Offset(size.x / 2, size.y / 2), 35, glow);
    }

    BossRenderer.render(canvas, regionId, Size(size.x, size.y), _animTimer);

    // HP bar (pixel style)
    const barWidth = 70.0;
    const barHeight = 5.0;
    const barX = (60 - barWidth) / 2;
    const barY = -10.0;
    final paint = Paint()..isAntiAlias = false;

    // Background
    paint.color = const Color(0xFF333333);
    canvas.drawRect(const Rect.fromLTWH(barX, barY, barWidth, barHeight), paint);

    // HP fill
    final hpColor = hpPercent > 0.5
        ? const Color(0xFFE53935)
        : hpPercent > 0.25
            ? const Color(0xFFFF9800)
            : const Color(0xFFFF1744);
    paint.color = hpColor;
    canvas.drawRect(Rect.fromLTWH(barX, barY, barWidth * hpPercent, barHeight), paint);

    // Phase pips
    if (_maxPhases > 1) {
      for (int i = 0; i < _maxPhases; i++) {
        final pipX = barX + (barWidth / _maxPhases) * i;
        paint.color = i < _currentPhase
            ? const Color(0xFFFFD600)
            : const Color(0xFF666666);
        canvas.drawRect(Rect.fromLTWH(pipX, barY - 4, 4, 3), paint);
      }
    }

    // Border
    paint.color = const Color(0xFFFFFFFF);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;
    canvas.drawRect(const Rect.fromLTWH(barX, barY, barWidth, barHeight), paint);
    paint.style = PaintingStyle.fill;

    // Timer bar
    const timerY = barY - 6;
    paint.color = const Color(0xFF555555);
    canvas.drawRect(const Rect.fromLTWH(barX, timerY, barWidth, 3), paint);
    final timeColor = timePercent < 0.5
        ? const Color(0xFF4CAF50)
        : timePercent < 0.8
            ? const Color(0xFFFF9800)
            : const Color(0xFFE53935);
    paint.color = timeColor;
    canvas.drawRect(Rect.fromLTWH(barX, timerY, barWidth * (1 - timePercent), 3), paint);
  }
}
