/// Handles unit merging logic for castle defense.
/// 3 same units (same type + same level) = 1 unit of level+1.
/// Max unit level is 5. Level 5 units can evolve with a matching relic.
class MergeManager {
  /// Maximum unit level before evolution.
  static const int maxLevel = 5;

  /// Check if two units can be merged (same type, same level, under max).
  static bool canMerge(DefenseUnit a, DefenseUnit b) {
    return a.unitTypeId == b.unitTypeId &&
        a.level == b.level &&
        a.level < maxLevel;
  }

  /// Attempt to find and perform a merge from a list of units.
  /// Looks for 3 units of the same type and level.
  /// Returns the merged (leveled-up) unit, or null if no merge is possible.
  /// The 3 source units are removed from the list and replaced by the result.
  static DefenseUnit? tryMerge(List<DefenseUnit> units) {
    // Group units by (typeId, level)
    final groups = <String, List<int>>{};
    for (int i = 0; i < units.length; i++) {
      final unit = units[i];
      if (unit.level >= maxLevel) continue;
      final key = '${unit.unitTypeId}_${unit.level}';
      groups.putIfAbsent(key, () => []);
      groups[key]!.add(i);
    }

    // Find first group with 3+ units
    for (final entry in groups.entries) {
      if (entry.value.length >= 3) {
        final indices = entry.value.sublist(0, 3);
        final sourceUnit = units[indices[0]];
        final mergedUnit = DefenseUnit(
          unitTypeId: sourceUnit.unitTypeId,
          level: sourceUnit.level + 1,
        );

        // Remove source units in reverse index order to avoid shifting
        final sortedIndices = List<int>.from(indices)
          ..sort((a, b) => b.compareTo(a));
        for (final idx in sortedIndices) {
          units.removeAt(idx);
        }

        // Add merged unit
        units.add(mergedUnit);
        return mergedUnit;
      }
    }
    return null;
  }

  /// Find all possible merges in the given slot list.
  /// Returns a list of index triplets (each list has 3 slot indices).
  static List<List<int>> findPossibleMerges(List<UnitSlot> slots) {
    final result = <List<int>>[];
    final groups = <String, List<int>>{};

    for (int i = 0; i < slots.length; i++) {
      final slot = slots[i];
      if (slot.unit == null) continue;
      final unit = slot.unit!;
      if (unit.level >= maxLevel) continue;
      final key = '${unit.unitTypeId}_${unit.level}';
      groups.putIfAbsent(key, () => []);
      groups[key]!.add(i);
    }

    for (final entry in groups.entries) {
      final indices = entry.value;
      // Extract all possible triplets from the group
      for (int start = 0; start + 2 < indices.length; start += 3) {
        result.add([indices[start], indices[start + 1], indices[start + 2]]);
      }
    }

    return result;
  }

  /// Check if a unit can evolve (Lv5 + matching relic in owned list).
  /// Relic naming convention: the relic id matches 'evolve_<unitTypeId>'.
  static bool canEvolve(DefenseUnit unit, List<String> ownedRelics) {
    if (unit.level < maxLevel) return false;
    final requiredRelic = 'evolve_${unit.unitTypeId}';
    return ownedRelics.contains(requiredRelic);
  }

  /// Perform evolution: returns evolved unit (level 6 = evolved form).
  /// Returns null if evolution conditions are not met.
  static DefenseUnit? tryEvolve(DefenseUnit unit, List<String> ownedRelics) {
    if (!canEvolve(unit, ownedRelics)) return null;
    return DefenseUnit(
      unitTypeId: unit.unitTypeId,
      level: unit.level + 1,
      isEvolved: true,
    );
  }
}

/// Lightweight data class representing a defense unit.
/// The actual Flame component would reference this data.
class DefenseUnit {
  final String unitTypeId;
  final int level;
  final bool isEvolved;

  const DefenseUnit({
    required this.unitTypeId,
    required this.level,
    this.isEvolved = false,
  });

  DefenseUnit copyWith({
    String? unitTypeId,
    int? level,
    bool? isEvolved,
  }) {
    return DefenseUnit(
      unitTypeId: unitTypeId ?? this.unitTypeId,
      level: level ?? this.level,
      isEvolved: isEvolved ?? this.isEvolved,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'unitTypeId': unitTypeId,
      'level': level,
      'isEvolved': isEvolved,
    };
  }

  factory DefenseUnit.fromMap(Map<String, dynamic> map) {
    return DefenseUnit(
      unitTypeId: map['unitTypeId'] as String,
      level: (map['level'] as num).toInt(),
      isEvolved: (map['isEvolved'] as bool?) ?? false,
    );
  }

  @override
  String toString() => 'DefenseUnit($unitTypeId, Lv$level${isEvolved ? ' E' : ''})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DefenseUnit &&
          unitTypeId == other.unitTypeId &&
          level == other.level &&
          isEvolved == other.isEvolved;

  @override
  int get hashCode => Object.hash(unitTypeId, level, isEvolved);
}

/// Represents a slot on the field that can hold a unit.
class UnitSlot {
  DefenseUnit? unit;
  final int slotIndex;

  UnitSlot({this.unit, required this.slotIndex});

  bool get isEmpty => unit == null;
  bool get isOccupied => unit != null;

  void clear() => unit = null;
  void place(DefenseUnit u) => unit = u;

  Map<String, dynamic> toMap() {
    return {
      'slotIndex': slotIndex,
      'unit': unit?.toMap(),
    };
  }

  factory UnitSlot.fromMap(Map<String, dynamic> map) {
    final unitMap = map['unit'] as Map<String, dynamic>?;
    return UnitSlot(
      slotIndex: (map['slotIndex'] as num).toInt(),
      unit: unitMap != null ? DefenseUnit.fromMap(unitMap) : null,
    );
  }
}
