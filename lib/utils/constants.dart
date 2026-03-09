import 'dart:ui';

class GameConstants {
  // World
  static const double gravity = 980.0;
  static const double groundY = 500.0;
  static const double worldWidth = 1200.0;
  static const double worldHeight = 600.0;

  // Player
  static const double playerSpeed = 200.0;
  static const double playerJumpForce = -450.0;
  static const double playerDashSpeed = 500.0;
  static const double playerDashDuration = 0.2;
  static const double playerDashCooldown = 0.8;
  static const int playerMaxHp = 3;
  static const double playerInvincibleDuration = 1.5;
  static const double playerWidth = 40.0;
  static const double playerHeight = 50.0;

  // Projectile
  static const double bulletSpeed = 400.0;
  static const double bulletDamage = 1.0;
  static const double fireRate = 0.15; // seconds between shots

  // Special attack
  static const double specialGaugeMax = 100.0;
  static const double specialGaugePerHit = 8.0;
  static const double specialDamage = 15.0;

  // Colors
  static const Color playerColor = Color(0xFF4FC3F7);
  static const Color bulletColor = Color(0xFFFFEB3B);
  static const Color enemyBulletColor = Color(0xFFFF5252);
  static const Color dashTrailColor = Color(0x804FC3F7);
  static const Color hpColor = Color(0xFFE53935);
  static const Color hpBackgroundColor = Color(0xFF424242);
  static const Color specialGaugeColor = Color(0xFFFFD600);
}
