import 'package:flame/components.dart';
import '../data/balance_config.dart';
import '../game/defense_game.dart';

/// Combo tier definitions.
enum ComboTier {
  none(threshold: 0, label: '', color: 0xFF888888, effectScale: 1.0),
  nice(threshold: 5, label: 'NICE!', color: 0xFF66BB6A, effectScale: 1.2),
  great(threshold: 10, label: 'GREAT!', color: 0xFF42A5F5, effectScale: 1.5),
  amazing(threshold: 25, label: 'AMAZING!', color: 0xFFAB47BC, effectScale: 2.0),
  unstoppable(threshold: 50, label: 'UNSTOPPABLE!', color: 0xFFFFD54F, effectScale: 2.5),
  godlike(threshold: 100, label: 'GODLIKE!', color: 0xFFFF1744, effectScale: 3.0);

  final int threshold;
  final String label;
  final int color;
  final double effectScale;

  const ComboTier({
    required this.threshold,
    required this.label,
    required this.color,
    required this.effectScale,
  });
}

/// Manages combo counting, tiers, and rewards.
/// Killing enemies in quick succession increases the combo counter.
/// Higher combos = larger visual effects + gold bonuses.
class ComboManager extends Component with HasGameReference<DefenseGame> {
  int _comboCount = 0;
  double _comboTimer = 0;
  int _maxCombo = 0;
  ComboTier _currentTier = ComboTier.none;
  bool _tierJustChanged = false;
  double _tierChangeTimer = 0;

  /// Base time window to maintain combo (seconds).
  /// Extended by comboDurationBonus from permanent upgrades.
  double get comboWindow =>
      BalanceConfig.comboWindowBase + game.upgradeManager.comboDurationBonus;

  // ── Public getters ──
  int get comboCount => _comboCount;
  int get maxCombo => _maxCombo;
  ComboTier get currentTier => _currentTier;
  bool get isActive => _comboCount > 0;
  bool get tierJustChanged => _tierJustChanged;
  double get effectSizeMultiplier => _currentTier.effectScale;

  /// Called when an enemy is killed. Increments combo.
  void onEnemyKilled() {
    _comboCount++;
    _comboTimer = comboWindow;

    if (_comboCount > _maxCombo) {
      _maxCombo = _comboCount;
    }

    final newTier = _calculateTier();
    if (newTier != _currentTier) {
      _currentTier = newTier;
      _tierJustChanged = true;
      _tierChangeTimer = BalanceConfig.comboTierChangeDisplayTime;
    }

    // Gold bonus at combo intervals
    if (_comboCount > 0 && _comboCount % BalanceConfig.comboGoldBonusInterval == 0) {
      final bonusGold = (_comboCount ~/ BalanceConfig.comboGoldBonusInterval) * BalanceConfig.comboGoldPerInterval;
      game.addGold(bonusGold, popupPos: game.wall.position);
    }
  }

  @override
  void update(double dt) {
    if (_comboCount > 0) {
      _comboTimer -= dt;
      if (_comboTimer <= 0) {
        _reset();
      }
    }

    if (_tierJustChanged) {
      _tierChangeTimer -= dt;
      if (_tierChangeTimer <= 0) {
        _tierJustChanged = false;
      }
    }
  }

  ComboTier _calculateTier() {
    if (_comboCount >= ComboTier.godlike.threshold) return ComboTier.godlike;
    if (_comboCount >= ComboTier.unstoppable.threshold) return ComboTier.unstoppable;
    if (_comboCount >= ComboTier.amazing.threshold) return ComboTier.amazing;
    if (_comboCount >= ComboTier.great.threshold) return ComboTier.great;
    if (_comboCount >= ComboTier.nice.threshold) return ComboTier.nice;
    return ComboTier.none;
  }

  void _reset() {
    _comboCount = 0;
    _comboTimer = 0;
    _currentTier = ComboTier.none;
    _tierJustChanged = false;
  }

  /// Reset all combo state (new run).
  void resetAll() {
    _reset();
    _maxCombo = 0;
  }
}
