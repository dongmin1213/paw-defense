import 'dart:ui';

class GameConstants {
  // World
  static const double worldWidth = 800.0;
  static const double worldHeight = 600.0;
  static const double groundY = 500.0;
  static const double groundHeight = 100.0;

  // Physics
  static const double gravity = 980.0;
  static const double basePlayerSpeed = 120.0;
  static const double baseJumpForce = -420.0;

  // Player
  static const double playerWidth = 36.0;
  static const double playerHeight = 40.0;
  static const double playerStartX = 200.0;

  // Generation
  static const double segmentWidth = 300.0;
  static const double spawnAheadDistance = 400.0;
  static const double despawnBehindDistance = 200.0;
  static const double groundSegmentWidth = 400.0;

  // Colors
  static const Color backgroundColor = Color(0xFF87CEEB);
  static const Color groundColor = Color(0xFF4A7C3F);
  static const Color groundDarkColor = Color(0xFF3A6230);
}
