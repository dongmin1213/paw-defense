import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show HSVColor;

import '../game/runner_game.dart';
import '../systems/weather_manager.dart';
import '../utils/constants.dart';

/// Renders weather particle effects (rain, snow, storm)
class WeatherEffect extends PositionComponent with HasGameReference<RunnerGame> {
  final List<_Particle> _particles = [];
  final Random _rng = Random();
  WeatherType _lastWeather = WeatherType.clear;

  WeatherEffect() : super(priority: 50); // render above most things

  @override
  void update(double dt) {
    super.update(dt);

    final weather = game.weatherManager.currentWeather;

    // Reset particles on weather change
    if (weather != _lastWeather) {
      _particles.clear();
      _lastWeather = weather;
    }

    final cameraX = game.camera.viewfinder.position.x;

    // Spawn new particles
    if (weather != WeatherType.clear && weather != WeatherType.rainbow) {
      final spawnRate = weather == WeatherType.storm ? 8 : 4;
      for (var i = 0; i < spawnRate; i++) {
        _particles.add(_Particle(
          x: cameraX + _rng.nextDouble() * GameConstants.worldWidth,
          y: -10,
          vx: weather == WeatherType.storm ? -30 - _rng.nextDouble() * 50 : -5,
          vy: _particleSpeed(weather),
          size: _particleSize(weather),
          life: 3.0 + _rng.nextDouble() * 2,
        ));
      }
    }

    // Rainbow sparkles
    if (weather == WeatherType.rainbow) {
      if (_rng.nextDouble() < 0.3) {
        _particles.add(_Particle(
          x: cameraX + _rng.nextDouble() * GameConstants.worldWidth,
          y: _rng.nextDouble() * GameConstants.worldHeight * 0.6,
          vx: 0,
          vy: 10 + _rng.nextDouble() * 20,
          size: 2 + _rng.nextDouble() * 3,
          life: 1.0 + _rng.nextDouble(),
        ));
      }
    }

    // Update particles
    for (final p in _particles) {
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.life -= dt;
    }

    // Remove dead particles
    _particles.removeWhere((p) => p.life <= 0 || p.y > GameConstants.worldHeight);

    // Cap particles
    if (_particles.length > 300) {
      _particles.removeRange(0, _particles.length - 300);
    }
  }

  double _particleSpeed(WeatherType w) {
    switch (w) {
      case WeatherType.rain: return 200 + _rng.nextDouble() * 100;
      case WeatherType.snow: return 40 + _rng.nextDouble() * 30;
      case WeatherType.storm: return 300 + _rng.nextDouble() * 150;
      default: return 50;
    }
  }

  double _particleSize(WeatherType w) {
    switch (w) {
      case WeatherType.rain: return 1.0 + _rng.nextDouble();
      case WeatherType.snow: return 2.0 + _rng.nextDouble() * 2;
      case WeatherType.storm: return 1.5 + _rng.nextDouble() * 1.5;
      default: return 2;
    }
  }

  @override
  void render(Canvas canvas) {
    final weather = game.weatherManager.currentWeather;
    final cameraX = game.camera.viewfinder.position.x;

    // Position canvas relative to camera
    canvas.save();
    canvas.translate(-cameraX, 0);

    for (final p in _particles) {
      final alpha = (p.life / 3.0).clamp(0.0, 1.0);
      final paint = Paint()..color = _particleColor(weather, alpha, p);

      if (weather == WeatherType.rain || weather == WeatherType.storm) {
        // Rain = vertical lines
        canvas.drawLine(
          Offset(p.x, p.y),
          Offset(p.x + p.vx * 0.02, p.y + p.size * 4),
          paint..strokeWidth = p.size * 0.5,
        );
      } else if (weather == WeatherType.snow) {
        // Snow = circles
        canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
      } else if (weather == WeatherType.rainbow) {
        // Rainbow = colorful sparkles
        canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
      }
    }

    // Storm lightning flash (rare)
    if (weather == WeatherType.storm && _rng.nextDouble() < 0.005) {
      final flashPaint = Paint()..color = const Color(0x33FFFFFF);
      canvas.drawRect(
        Rect.fromLTWH(cameraX, 0, GameConstants.worldWidth, GameConstants.worldHeight),
        flashPaint,
      );
    }

    canvas.restore();

    // Time-of-day overlay
    _renderTimeOverlay(canvas);
  }

  Color _particleColor(WeatherType w, double alpha, _Particle p) {
    switch (w) {
      case WeatherType.rain:
        return Color.fromRGBO(150, 200, 255, 0.5 * alpha);
      case WeatherType.snow:
        return Color.fromRGBO(255, 255, 255, 0.7 * alpha);
      case WeatherType.storm:
        return Color.fromRGBO(180, 200, 220, 0.6 * alpha);
      case WeatherType.rainbow:
        final hue = (p.x * 0.5 + p.y * 0.3) % 360;
        return HSVColor.fromAHSV(alpha * 0.6, hue.abs(), 0.8, 1.0).toColor();
      default:
        return const Color(0x00000000);
    }
  }

  void _renderTimeOverlay(Canvas canvas) {
    final time = game.weatherManager.currentTime;
    Color? overlayColor;

    switch (time) {
      case TimeOfDay.evening:
        overlayColor = const Color(0x15FF6600); // orange tint
        break;
      case TimeOfDay.night:
        overlayColor = const Color(0x22000033); // dark blue tint
        break;
      case TimeOfDay.dawn:
        overlayColor = const Color(0x10AAAACC); // light purple tint
        break;
      default:
        break;
    }

    if (overlayColor != null) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, GameConstants.worldWidth, GameConstants.worldHeight),
        Paint()..color = overlayColor,
      );
    }
  }
}

class _Particle {
  double x, y, vx, vy, size, life;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.life,
  });
}
