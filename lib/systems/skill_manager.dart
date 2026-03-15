import 'package:flame/components.dart';
import '../data/balance_config.dart';

/// Manages active skill system.
/// Player charges skill gauge by killing enemies, then taps to activate.
/// The available skill corresponds to the player's most common unit type.
class SkillManager extends Component {
  // Skill definitions for each of the 8 base unit types
  static const Map<String, SkillDef> skills = {
    'cat_archer': SkillDef('화살비', '🏹', 20, 'arrow_rain'),
    'dog_warrior': SkillDef('전투의 함성', '📯', 25, 'war_cry'),
    'rabbit_mage': SkillDef('메테오', '☄️', 30, 'meteor'),
    'bear_tanker': SkillDef('얼음 벽', '🧊', 25, 'ice_wall'),
    'fox_assassin': SkillDef('암살 표식', '🎯', 30, 'assassin_mark'),
    'bird_scout': SkillDef('폭풍 소환', '🌪️', 35, 'storm_call'),
    'turtle_healer': SkillDef('성벽 회복', '💚', 40, 'wall_heal'),
    'owl_wizard': SkillDef('마력 폭발', '💥', 35, 'mana_burst'),
  };

  int _currentCharge = 0;
  int _maxCharge = BalanceConfig.skillDefaultMaxCharge;
  String _activeUnitType = 'cat_archer';
  bool _isReady = false;
  double _cooldownTimer = 0;
  double _effectTimer = 0;
  double _effectMaxDuration = BalanceConfig.skillEffectDuration;
  String? _activeEffect; // currently active effect ID

  // Getters for HUD
  int get currentCharge => _currentCharge;
  int get maxCharge => _maxCharge;
  bool get isReady => _isReady;
  bool get hasActiveEffect => _effectTimer > 0;
  String get activeUnitType => _activeUnitType;
  SkillDef? get currentSkill => skills[_activeUnitType];
  double get chargePercent =>
      _maxCharge > 0 ? (_currentCharge / _maxCharge).clamp(0.0, 1.0) : 0.0;
  double get effectTimer => _effectTimer;
  double get effectMaxDuration => _effectMaxDuration;

  /// Update dominant unit type based on current unit composition.
  /// The skill that's available = the type of unit the player has the most of.
  void updateDominantType(Map<String, int> unitCounts) {
    if (unitCounts.isEmpty) return;
    String? best;
    int bestCount = 0;
    for (final entry in unitCounts.entries) {
      if (entry.value > bestCount) {
        bestCount = entry.value;
        best = entry.key;
      }
    }
    if (best != null && skills.containsKey(best)) {
      _activeUnitType = best;
      _maxCharge = skills[best]!.chargeNeeded;
    }
  }

  /// Called when an enemy is killed. Charges the gauge.
  void onEnemyKilled() {
    if (_cooldownTimer > 0) return;
    _currentCharge++;
    if (_currentCharge >= _maxCharge) {
      _isReady = true;
    }
  }

  /// Activate the skill. Returns the skill effect ID or null if not ready.
  String? activate() {
    if (!_isReady) return null;
    final skill = skills[_activeUnitType];
    if (skill == null) return null;

    _currentCharge = 0;
    _isReady = false;
    _cooldownTimer = BalanceConfig.skillCooldown;
    _activeEffect = skill.effectId;
    _effectTimer = BalanceConfig.skillEffectDuration;
    _effectMaxDuration = BalanceConfig.skillEffectDuration;

    return skill.effectId;
  }

  /// Public setter for effect duration (used by specific skills that override default).
  void setEffectDuration(double duration) {
    _effectTimer = duration;
    _effectMaxDuration = duration;
  }

  /// Reset for new run.
  void reset() {
    _currentCharge = 0;
    _isReady = false;
    _cooldownTimer = 0;
    _effectTimer = 0;
    _activeEffect = null;
    _activeUnitType = 'cat_archer';
    _maxCharge = BalanceConfig.skillDefaultMaxCharge;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_cooldownTimer > 0) _cooldownTimer -= dt;
    if (_effectTimer > 0) {
      _effectTimer -= dt;
      if (_effectTimer <= 0) _activeEffect = null;
    }
  }

  /// Check if a specific effect is currently active.
  bool isEffectActive(String effectId) =>
      _activeEffect == effectId && _effectTimer > 0;
}

/// Immutable definition for a skill.
class SkillDef {
  final String name;
  final String icon;
  final int chargeNeeded;
  final String effectId;
  const SkillDef(this.name, this.icon, this.chargeNeeded, this.effectId);
}
