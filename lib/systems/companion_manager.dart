import 'dart:math';

import '../data/companion_data.dart';

class OwnedCompanion {
  final String id;
  int level;

  OwnedCompanion({required this.id, this.level = 1});
}

class CompanionManager {
  final Map<String, OwnedCompanion> _owned = {};
  final List<String> _equipped = [];
  int maxSlots = 1; // upgradeable via soul shop (1→4)

  // === Collection ===

  bool owns(String id) => _owned.containsKey(id);

  OwnedCompanion? getOwned(String id) => _owned[id];

  List<OwnedCompanion> get allOwned => _owned.values.toList();

  /// Add companion. If already owned, level up instead. Returns true if new.
  bool addCompanion(String id) {
    if (_owned.containsKey(id)) {
      _owned[id]!.level++;
      return false;
    }
    _owned[id] = OwnedCompanion(id: id);
    // Auto-equip if slot available
    if (_equipped.length < maxSlots && !_equipped.contains(id)) {
      _equipped.add(id);
    }
    return true;
  }

  // === Equip ===

  List<String> get equippedIds => List.unmodifiable(_equipped);

  bool isEquipped(String id) => _equipped.contains(id);

  void equip(String id) {
    if (!owns(id) || isEquipped(id)) return;
    if (_equipped.length >= maxSlots) {
      _equipped.removeAt(0); // Remove oldest
    }
    _equipped.add(id);
  }

  void unequip(String id) {
    _equipped.remove(id);
  }

  // === Level Up ===

  double levelUpCost(String id) {
    final owned = _owned[id];
    if (owned == null) return double.infinity;
    final data = CompanionDatabase.get(id);
    return data.levelUpCost(owned.level);
  }

  bool canLevelUp(String id, double coins) {
    return coins >= levelUpCost(id);
  }

  /// Level up companion. Returns cost, or 0 if can't.
  double doLevelUp(String id, double coins) {
    final cost = levelUpCost(id);
    if (coins < cost) return 0;
    _owned[id]!.level++;
    return cost;
  }

  // === Buff Calculation ===

  /// Sum of coin multiplier from equipped companions
  double get coinMultiplier {
    double mult = 1.0;
    for (final id in _equipped) {
      final owned = _owned[id];
      if (owned == null) continue;
      final data = CompanionDatabase.get(id);
      if (data.id == 'cat') {
        mult += 0.05 * owned.level;
      } else if (data.id == 'unicorn') {
        mult += 0.05 * owned.level;
      } else if (data.id == 'dragon_c') {
        mult += 0.08 * owned.level;
      }
    }
    return mult;
  }

  /// Speed bonus from equipped companions
  double get speedMultiplier {
    double mult = 1.0;
    for (final id in _equipped) {
      final owned = _owned[id];
      if (owned == null) continue;
      if (id == 'hamster') {
        mult += 0.05 * owned.level;
      } else if (id == 'unicorn') {
        mult += 0.05 * owned.level;
      } else if (id == 'dragon_c') {
        mult += 0.08 * owned.level;
      }
    }
    return mult;
  }

  /// Jump bonus from equipped companions
  double get jumpMultiplier {
    double mult = 1.0;
    for (final id in _equipped) {
      final owned = _owned[id];
      if (owned == null) continue;
      if (id == 'rabbit') {
        mult += 0.05 * owned.level;
      } else if (id == 'unicorn') {
        mult += 0.05 * owned.level;
      } else if (id == 'dragon_c') {
        mult += 0.08 * owned.level;
      }
    }
    return mult;
  }

  /// Attack bonus from equipped companions
  double get attackMultiplier {
    double mult = 1.0;
    for (final id in _equipped) {
      final owned = _owned[id];
      if (owned == null) continue;
      if (id == 'wolf_c') {
        mult += 0.15 * owned.level;
      } else if (id == 'unicorn') {
        mult += 0.05 * owned.level;
      } else if (id == 'dragon_c') {
        mult += 0.08 * owned.level;
      }
    }
    return mult;
  }

  /// Soul bonus from equipped companions
  double get soulMultiplier {
    double mult = 1.0;
    for (final id in _equipped) {
      final owned = _owned[id];
      if (owned == null) continue;
      if (id == 'owl') {
        mult += 0.10 * owned.level;
      } else if (id == 'phoenix_c') {
        mult += 0.20 * owned.level;
      }
    }
    return mult;
  }

  /// Extra combo timer seconds from equipped companions
  double get extraComboTime {
    double extra = 0;
    for (final id in _equipped) {
      final owned = _owned[id];
      if (owned == null) continue;
      if (id == 'fox') {
        extra += 1.0 * owned.level;
      }
    }
    return extra;
  }

  /// Obstacle ignore chance from equipped companions
  double get obstacleIgnoreChance {
    double chance = 0;
    for (final id in _equipped) {
      final owned = _owned[id];
      if (owned == null) continue;
      if (id == 'penguin') {
        chance += 0.03 * owned.level;
      }
    }
    return chance.clamp(0, 1);
  }

  // === Spawn Roll ===

  /// Roll for a companion spawn. Returns companion id or null.
  String? rollCompanionSpawn(Random rng) {
    final roll = rng.nextDouble() * 100;
    double cumulative = 0;
    for (final c in CompanionDatabase.companions) {
      cumulative += c.spawnChance;
      if (roll < cumulative) return c.id;
    }
    return CompanionDatabase.companions.last.id;
  }

  // === Collection Stats ===

  int get ownedCount => _owned.length;
  int get totalCount => CompanionDatabase.companions.length;
  bool get hasAllCompanions => ownedCount >= totalCount;

  // === Save/Load ===

  Map<String, dynamic> toMap() {
    return {
      'owned': _owned.map((k, v) => MapEntry(k, v.level)),
      'equipped': _equipped.toList(),
      'maxSlots': maxSlots,
    };
  }

  void loadFromMap(Map<String, dynamic> map) {
    _owned.clear();
    _equipped.clear();

    final owned = map['owned'] as Map<String, dynamic>?;
    if (owned != null) {
      for (final entry in owned.entries) {
        _owned[entry.key] = OwnedCompanion(
          id: entry.key,
          level: (entry.value as num).toInt(),
        );
      }
    }

    final equipped = map['equipped'] as List<dynamic>?;
    if (equipped != null) {
      for (final id in equipped) {
        if (_owned.containsKey(id)) {
          _equipped.add(id as String);
        }
      }
    }

    maxSlots = (map['maxSlots'] as num?)?.toInt() ?? 1;
  }
}
