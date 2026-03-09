import 'dart:math';

enum TimeOfDay { day, evening, night, dawn }
enum WeatherType { clear, rain, snow, storm, rainbow }

class WeatherManager {
  final Random _rng = Random();

  TimeOfDay _currentTime = TimeOfDay.day;
  WeatherType _currentWeather = WeatherType.clear;
  double _weatherTimer = 0;
  double _nextWeatherChange = 180; // 3 min
  double _rainbowTimer = 0; // rainbow lasts 30s

  TimeOfDay get currentTime => _currentTime;
  WeatherType get currentWeather => _currentWeather;
  bool get isRainbow => _currentWeather == WeatherType.rainbow && _rainbowTimer > 0;

  void update(double dt) {
    // Update time of day from system clock
    _updateTimeOfDay();

    // Weather cycle
    _weatherTimer += dt;
    if (_weatherTimer >= _nextWeatherChange) {
      _weatherTimer = 0;
      _nextWeatherChange = 180 + _rng.nextDouble() * 120; // 3-5 min
      _rollWeather();
    }

    // Rainbow countdown
    if (isRainbow) {
      _rainbowTimer -= dt;
      if (_rainbowTimer <= 0) {
        _currentWeather = WeatherType.clear;
      }
    }
  }

  void _updateTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 18) {
      _currentTime = TimeOfDay.day;
    } else if (hour >= 18 && hour < 22) {
      _currentTime = TimeOfDay.evening;
    } else if (hour >= 22 || hour < 4) {
      _currentTime = TimeOfDay.night;
    } else {
      _currentTime = TimeOfDay.dawn;
    }
  }

  void _rollWeather() {
    final roll = _rng.nextDouble() * 100;
    if (roll < 50) {
      _currentWeather = WeatherType.clear;
    } else if (roll < 70) {
      _currentWeather = WeatherType.rain;
    } else if (roll < 85) {
      _currentWeather = WeatherType.snow;
    } else if (roll < 95) {
      _currentWeather = WeatherType.storm;
    } else {
      _currentWeather = WeatherType.rainbow;
      _rainbowTimer = 30.0;
    }
  }

  // === Bonuses ===

  /// Coin multiplier from time of day
  double get timeCoinMultiplier {
    switch (_currentTime) {
      case TimeOfDay.day: return 1.0;
      case TimeOfDay.evening: return 1.2; // +20%
      case TimeOfDay.night: return 1.0;
      case TimeOfDay.dawn: return 1.0;
    }
  }

  /// Soul multiplier from time of day
  double get timeSoulMultiplier {
    switch (_currentTime) {
      case TimeOfDay.day: return 1.0;
      case TimeOfDay.evening: return 1.0;
      case TimeOfDay.night: return 1.5; // +50%
      case TimeOfDay.dawn: return 1.0;
    }
  }

  /// Legendary companion spawn multiplier from time of day
  double get legendarySpawnMultiplier {
    switch (_currentTime) {
      case TimeOfDay.dawn: return 2.0; // 2x legendary
      default: return 1.0;
    }
  }

  /// Coin multiplier from weather
  double get weatherCoinMultiplier {
    switch (_currentWeather) {
      case WeatherType.clear: return 1.0;
      case WeatherType.rain: return 1.3; // +30%
      case WeatherType.snow: return 1.0;
      case WeatherType.storm: return 2.0; // x2
      case WeatherType.rainbow: return isRainbow ? 2.0 : 1.0;
    }
  }

  /// Rare enemy spawn multiplier from weather
  double get rareEnemyMultiplier {
    switch (_currentWeather) {
      case WeatherType.snow: return 1.5; // +50%
      default: return 1.0;
    }
  }

  /// Combined coin multiplier
  double get totalCoinMultiplier => timeCoinMultiplier * weatherCoinMultiplier;

  /// Obstacle multiplier (storm = more obstacles)
  double get obstacleMultiplier {
    return _currentWeather == WeatherType.storm ? 2.0 : 1.0;
  }

  // === Display ===

  String get timeDisplayName {
    switch (_currentTime) {
      case TimeOfDay.day: return '낮';
      case TimeOfDay.evening: return '저녁';
      case TimeOfDay.night: return '밤';
      case TimeOfDay.dawn: return '새벽';
    }
  }

  String get weatherDisplayName {
    switch (_currentWeather) {
      case WeatherType.clear: return '맑음';
      case WeatherType.rain: return '비';
      case WeatherType.snow: return '눈';
      case WeatherType.storm: return '폭풍';
      case WeatherType.rainbow: return '무지개';
    }
  }

  String get weatherEmoji {
    switch (_currentWeather) {
      case WeatherType.clear: return '';
      case WeatherType.rain: return '';
      case WeatherType.snow: return '';
      case WeatherType.storm: return '';
      case WeatherType.rainbow: return '';
    }
  }
}
