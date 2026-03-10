import '../systems/merge_manager.dart' as merge;

/// Synergy bonus definition.
class SynergyBonus {
  final String id;
  final String name;
  final String icon;
  final String description;
  final int requiredCount;
  final double atkMultiplier;
  final double atkSpeedMultiplier;
  final double rangeMultiplier;
  final double goldMultiplier;
  final double critBonus;
  final double wallDefenseBonus;
  final double healBonus;
  final double splashBonus;

  const SynergyBonus({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    this.requiredCount = 2,
    this.atkMultiplier = 1.0,
    this.atkSpeedMultiplier = 1.0,
    this.rangeMultiplier = 1.0,
    this.goldMultiplier = 1.0,
    this.critBonus = 0.0,
    this.wallDefenseBonus = 0.0,
    this.healBonus = 0.0,
    this.splashBonus = 0.0,
  });
}

/// Active synergy with its current tier.
class ActiveSynergy {
  final SynergyBonus bonus;
  final int currentCount;
  final int tier; // 1 = basic (2units), 2 = advanced (3+ units)

  const ActiveSynergy({
    required this.bonus,
    required this.currentCount,
    required this.tier,
  });
}

/// Manages unit synergy (set bonus) system.
/// Checks current unit composition and calculates passive buffs.
class SynergyManager {
  // ── Tribe synergies: same unit type bonuses ──
  static const Map<String, List<SynergyBonus>> tribeSynergies = {
    'cat_archer': [
      SynergyBonus(
        id: 'cat_2', name: '궁수단', icon: '🐱',
        description: '공속 +15%',
        requiredCount: 2,
        atkSpeedMultiplier: 1.15,
      ),
      SynergyBonus(
        id: 'cat_3', name: '궁수 군단', icon: '🐱',
        description: '공속 +30%, 관통 확률',
        requiredCount: 3,
        atkSpeedMultiplier: 1.30,
      ),
    ],
    'dog_warrior': [
      SynergyBonus(
        id: 'dog_2', name: '전사조', icon: '🐶',
        description: '스플래시 +20%',
        requiredCount: 2,
        splashBonus: 0.20,
        atkMultiplier: 1.10,
      ),
      SynergyBonus(
        id: 'dog_3', name: '전사 군단', icon: '🐶',
        description: '스플래시 +40%, ATK +20%',
        requiredCount: 3,
        splashBonus: 0.40,
        atkMultiplier: 1.20,
      ),
    ],
    'rabbit_mage': [
      SynergyBonus(
        id: 'rabbit_2', name: '마법진', icon: '🐰',
        description: 'ATK +20%',
        requiredCount: 2,
        atkMultiplier: 1.20,
      ),
      SynergyBonus(
        id: 'rabbit_3', name: '대마법진', icon: '🐰',
        description: 'ATK +40%',
        requiredCount: 3,
        atkMultiplier: 1.40,
      ),
    ],
    'bear_tanker': [
      SynergyBonus(
        id: 'bear_2', name: '수비대', icon: '🐻',
        description: '성벽 방어 +10%',
        requiredCount: 2,
        wallDefenseBonus: 0.10,
      ),
      SynergyBonus(
        id: 'bear_3', name: '철벽 수비대', icon: '🐻',
        description: '성벽 방어 +20%, ATK +15%',
        requiredCount: 3,
        wallDefenseBonus: 0.20,
        atkMultiplier: 1.15,
      ),
    ],
    'fox_assassin': [
      SynergyBonus(
        id: 'fox_2', name: '암살단', icon: '🦊',
        description: '크리 +10%',
        requiredCount: 2,
        critBonus: 0.10,
      ),
      SynergyBonus(
        id: 'fox_3', name: '암살 길드', icon: '🦊',
        description: '크리 +20%, ATK +15%',
        requiredCount: 3,
        critBonus: 0.20,
        atkMultiplier: 1.15,
      ),
    ],
    'bird_scout': [
      SynergyBonus(
        id: 'bird_2', name: '정찰대', icon: '🐦',
        description: '사거리 +15%',
        requiredCount: 2,
        rangeMultiplier: 1.15,
      ),
      SynergyBonus(
        id: 'bird_3', name: '공군', icon: '🐦',
        description: '사거리 +30%, 공속 +10%',
        requiredCount: 3,
        rangeMultiplier: 1.30,
        atkSpeedMultiplier: 1.10,
      ),
    ],
    'turtle_healer': [
      SynergyBonus(
        id: 'turtle_2', name: '치유소', icon: '🐢',
        description: '힐량 +20%',
        requiredCount: 2,
        healBonus: 0.20,
      ),
      SynergyBonus(
        id: 'turtle_3', name: '성소', icon: '🐢',
        description: '힐량 +40%, 성벽 방어 +10%',
        requiredCount: 3,
        healBonus: 0.40,
        wallDefenseBonus: 0.10,
      ),
    ],
    'owl_wizard': [
      SynergyBonus(
        id: 'owl_2', name: '현자회', icon: '🦉',
        description: 'AoE +15%, ATK +10%',
        requiredCount: 2,
        splashBonus: 0.15,
        atkMultiplier: 1.10,
      ),
      SynergyBonus(
        id: 'owl_3', name: '대현자회', icon: '🦉',
        description: 'AoE +30%, ATK +25%',
        requiredCount: 3,
        splashBonus: 0.30,
        atkMultiplier: 1.25,
      ),
    ],
  };

  // ── Diversity synergies: different unit types ──
  static const List<SynergyBonus> diversitySynergies = [
    SynergyBonus(
      id: 'diverse_4', name: '혼성 부대', icon: '🎭',
      description: '4종: ATK +10%',
      requiredCount: 4,
      atkMultiplier: 1.10,
    ),
    SynergyBonus(
      id: 'diverse_6', name: '연합군', icon: '🏳️',
      description: '6종: ATK +20%, 골드 +15%',
      requiredCount: 6,
      atkMultiplier: 1.20,
      goldMultiplier: 1.15,
    ),
    SynergyBonus(
      id: 'diverse_8', name: '올스타', icon: '⭐',
      description: '8종: ATK +30%, 골드 +20%, 공속 +15%',
      requiredCount: 8,
      atkMultiplier: 1.30,
      goldMultiplier: 1.20,
      atkSpeedMultiplier: 1.15,
    ),
  ];

  // ── State ──
  List<ActiveSynergy> _activeSynergies = [];
  List<ActiveSynergy> get activeSynergies => _activeSynergies;

  // ── Cached multipliers ──
  double _atkMult = 1.0;
  double _atkSpeedMult = 1.0;
  double _rangeMult = 1.0;
  double _goldMult = 1.0;
  double _critBonus = 0.0;
  double _wallDefBonus = 0.0;
  double _healBonus = 0.0;
  double _splashBonus = 0.0;

  double get atkMultiplier => _atkMult;
  double get atkSpeedMultiplier => _atkSpeedMult;
  double get rangeMultiplier => _rangeMult;
  double get goldMultiplier => _goldMult;
  double get critBonus => _critBonus;
  double get wallDefenseBonus => _wallDefBonus;
  double get healBonus => _healBonus;
  double get splashBonus => _splashBonus;

  bool get hasAnySynergy => _activeSynergies.isNotEmpty;

  /// Recalculate synergies based on current unit composition.
  /// Call this whenever units change (buy, sell, merge, evolve).
  void recalculate(List<merge.UnitSlot> slots) {
    _activeSynergies = [];
    _atkMult = 1.0;
    _atkSpeedMult = 1.0;
    _rangeMult = 1.0;
    _goldMult = 1.0;
    _critBonus = 0.0;
    _wallDefBonus = 0.0;
    _healBonus = 0.0;
    _splashBonus = 0.0;

    // Count units per base type (hybrids count for both parents)
    final typeCounts = <String, int>{};
    final uniqueTypes = <String>{};

    for (final slot in slots) {
      final u = slot.unit;
      if (u == null) continue;

      // Check if hybrid — count toward both parent types
      final parentA = _getParentA(u.unitTypeId);
      final parentB = _getParentB(u.unitTypeId);
      if (parentA != null && parentB != null) {
        typeCounts[parentA] = (typeCounts[parentA] ?? 0) + 1;
        typeCounts[parentB] = (typeCounts[parentB] ?? 0) + 1;
        uniqueTypes.add(parentA);
        uniqueTypes.add(parentB);
      } else {
        typeCounts[u.unitTypeId] = (typeCounts[u.unitTypeId] ?? 0) + 1;
        uniqueTypes.add(u.unitTypeId);
      }
    }

    // Check tribe synergies
    for (final entry in tribeSynergies.entries) {
      final typeId = entry.key;
      final count = typeCounts[typeId] ?? 0;
      if (count < 2) continue;

      // Find highest applicable tier
      final bonuses = entry.value;
      SynergyBonus? best;
      int tier = 0;
      for (int i = bonuses.length - 1; i >= 0; i--) {
        if (count >= bonuses[i].requiredCount) {
          best = bonuses[i];
          tier = i + 1;
          break;
        }
      }
      if (best != null) {
        _activeSynergies.add(ActiveSynergy(
          bonus: best,
          currentCount: count,
          tier: tier,
        ));
        _applyBonus(best);
      }
    }

    // Check diversity synergies
    final diverseCount = uniqueTypes.length;
    SynergyBonus? bestDiversity;
    for (int i = diversitySynergies.length - 1; i >= 0; i--) {
      if (diverseCount >= diversitySynergies[i].requiredCount) {
        bestDiversity = diversitySynergies[i];
        break;
      }
    }
    if (bestDiversity != null) {
      _activeSynergies.add(ActiveSynergy(
        bonus: bestDiversity,
        currentCount: diverseCount,
        tier: diverseCount >= 8 ? 3 : (diverseCount >= 6 ? 2 : 1),
      ));
      _applyBonus(bestDiversity);
    }
  }

  void _applyBonus(SynergyBonus bonus) {
    _atkMult *= bonus.atkMultiplier;
    _atkSpeedMult *= bonus.atkSpeedMultiplier;
    _rangeMult *= bonus.rangeMultiplier;
    _goldMult *= bonus.goldMultiplier;
    _critBonus += bonus.critBonus;
    _wallDefBonus += bonus.wallDefenseBonus;
    _healBonus += bonus.healBonus;
    _splashBonus += bonus.splashBonus;
  }

  /// Get parent A type ID for a hybrid unit. Returns null if not hybrid.
  String? _getParentA(String unitTypeId) {
    // Import from hybrid database would create circular dep,
    // so use the static naming convention: hybrid IDs contain '_'
    // and are looked up from HybridDatabase in the game code.
    // Here we store a lookup built at recalculate time.
    return _hybridParents[unitTypeId]?.$1;
  }

  String? _getParentB(String unitTypeId) {
    return _hybridParents[unitTypeId]?.$2;
  }

  // Hybrid parent cache — set by the game before recalculation
  Map<String, (String, String)> _hybridParents = {};

  /// Set hybrid parent mapping. Call before recalculate().
  void setHybridParents(Map<String, (String, String)> parents) {
    _hybridParents = parents;
  }

  /// Reset synergies (new run).
  void reset() {
    _activeSynergies = [];
    _atkMult = 1.0;
    _atkSpeedMult = 1.0;
    _rangeMult = 1.0;
    _goldMult = 1.0;
    _critBonus = 0.0;
    _wallDefBonus = 0.0;
    _healBonus = 0.0;
    _splashBonus = 0.0;
  }
}
