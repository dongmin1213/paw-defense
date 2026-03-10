import 'dart:math';

/// Wave modifier system — adds variety to each run.
/// Starting from wave 10, every 5 waves gets a random modifier.
class WaveModifier {
  static const List<ModifierDef> allModifiers = [
    ModifierDef('sky_threat', '하늘의 위협', '🦇', '이번 웨이브 적 전원 비행!'),
    ModifierDef('speed_run', '스피드 런', '💨', '적 속도 x2, 골드 x1.5'),
    ModifierDef('shield_march', '철벽 행군', '🛡️', '방패병 50% 비율'),
    ModifierDef('elite', '엘리트', '💀', '적 수 -50%, HP x3'),
    ModifierDef('swarm', '물량 공세', '🌊', '적 수 x3, HP -50%'),
    ModifierDef('burning', '불타는 땅', '🔥', '모든 적에게 자동 화상'),
    ModifierDef('golden', '황금 웨이브', '💰', '골드 드랍 x3'),
    ModifierDef('chain', '번개 웨이브', '⚡', '모든 처치 시 연쇄번개 발동'),
    ModifierDef('fog', '안개', '🌑', '유닛 사거리 -40%'),
    ModifierDef('chaos', '카오스', '🎲', '웨이브 무관 전체 적 풀 랜덤'),
  ];

  static final _rng = Random();

  ModifierDef? currentModifier;

  /// Check if this wave should have a modifier and pick one.
  /// Returns the modifier, or null if no modifier this wave.
  /// Rules: wave >= 10, every 5 waves, NOT on boss waves (multiples of 10).
  ModifierDef? rollModifier(int wave) {
    // No modifiers before wave 10
    if (wave < 10) {
      currentModifier = null;
      return null;
    }
    // Boss waves (exact multiples of bossInterval=10) get no modifier
    if (wave % 10 == 0) {
      currentModifier = null;
      return null;
    }
    // Apply on waves 15, 25, 35, etc. (every 5 waves, skip boss)
    if (wave % 5 != 0) {
      currentModifier = null;
      return null;
    }

    currentModifier = allModifiers[_rng.nextInt(allModifiers.length)];
    return currentModifier;
  }

  /// Get enemy count multiplier for current modifier
  double get enemyCountMultiplier {
    if (currentModifier == null) return 1.0;
    switch (currentModifier!.id) {
      case 'elite': return 0.5;
      case 'swarm': return 3.0;
      default: return 1.0;
    }
  }

  /// Get enemy HP multiplier for current modifier
  double get enemyHpMultiplier {
    if (currentModifier == null) return 1.0;
    switch (currentModifier!.id) {
      case 'elite': return 3.0;
      case 'swarm': return 0.5;
      default: return 1.0;
    }
  }

  /// Get enemy speed multiplier for current modifier
  double get enemySpeedMultiplier {
    if (currentModifier == null) return 1.0;
    switch (currentModifier!.id) {
      case 'speed_run': return 2.0;
      default: return 1.0;
    }
  }

  /// Get gold multiplier for current modifier
  double get goldMultiplier {
    if (currentModifier == null) return 1.0;
    switch (currentModifier!.id) {
      case 'golden': return 3.0;
      case 'speed_run': return 1.5;
      default: return 1.0;
    }
  }

  /// Get range multiplier for units (fog effect)
  double get unitRangeMultiplier {
    if (currentModifier == null) return 1.0;
    switch (currentModifier!.id) {
      case 'fog': return 0.6;
      default: return 1.0;
    }
  }

  /// Should all enemies be flying this wave?
  bool get allFlying => currentModifier?.id == 'sky_threat';

  /// Should chain lightning trigger on all kills?
  bool get alwaysChain => currentModifier?.id == 'chain';

  /// Should all enemies get automatic burn DOT?
  bool get autoBurn => currentModifier?.id == 'burning';

  /// Is shield march active? (50% enemies become shielded)
  bool get shieldMarch => currentModifier?.id == 'shield_march';

  /// Is chaos mode? (ignore wave unlock restrictions for enemy types)
  bool get chaosSpawn => currentModifier?.id == 'chaos';

  /// Reset for new run
  void reset() {
    currentModifier = null;
  }
}

class ModifierDef {
  final String id;
  final String name;
  final String icon;
  final String description;
  const ModifierDef(this.id, this.name, this.icon, this.description);
}
