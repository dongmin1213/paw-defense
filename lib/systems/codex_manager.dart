import 'package:shared_preferences/shared_preferences.dart';
import '../data/unit_data.dart';
import '../data/hybrid_unit_data.dart';
import '../data/relic_data.dart';
import '../data/enemy_data.dart';

/// Codex (도감) manager — tracks which units, enemies, relics have been discovered.
/// Persisted via SharedPreferences.
class CodexManager {
  static const String _prefix = 'codex_';
  static const String _keyUnits = '${_prefix}units';
  static const String _keyHybrids = '${_prefix}hybrids';
  static const String _keyEnemies = '${_prefix}enemies';
  static const String _keyRelics = '${_prefix}relics';

  late SharedPreferences _prefs;

  final Set<String> _discoveredUnits = {};
  final Set<String> _discoveredHybrids = {};
  final Set<String> _discoveredEnemies = {};
  final Set<String> _discoveredRelics = {};

  // Public unmodifiable getters
  Set<String> get discoveredUnits => Set.unmodifiable(_discoveredUnits);
  Set<String> get discoveredHybrids => Set.unmodifiable(_discoveredHybrids);
  Set<String> get discoveredEnemies => Set.unmodifiable(_discoveredEnemies);
  Set<String> get discoveredRelics => Set.unmodifiable(_discoveredRelics);

  Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
    _load();
  }

  void _load() {
    _discoveredUnits.addAll(_loadSet(_keyUnits));
    _discoveredHybrids.addAll(_loadSet(_keyHybrids));
    _discoveredEnemies.addAll(_loadSet(_keyEnemies));
    _discoveredRelics.addAll(_loadSet(_keyRelics));
  }

  Set<String> _loadSet(String key) {
    final raw = _prefs.getString(key) ?? '';
    if (raw.isEmpty) return {};
    return raw.split(',').toSet();
  }

  void _saveSet(String key, Set<String> set) {
    _prefs.setString(key, set.join(','));
  }

  // === Discovery methods ===

  /// Discover a base unit. Returns true if newly discovered.
  bool discoverUnit(String unitTypeId) {
    if (_discoveredUnits.contains(unitTypeId)) return false;
    _discoveredUnits.add(unitTypeId);
    _saveSet(_keyUnits, _discoveredUnits);
    return true;
  }

  /// Discover a hybrid unit. Returns true if newly discovered.
  bool discoverHybrid(String hybridId) {
    if (_discoveredHybrids.contains(hybridId)) return false;
    _discoveredHybrids.add(hybridId);
    _saveSet(_keyHybrids, _discoveredHybrids);
    return true;
  }

  /// Discover an enemy type. Returns true if newly discovered.
  bool discoverEnemy(String enemyId) {
    if (_discoveredEnemies.contains(enemyId)) return false;
    _discoveredEnemies.add(enemyId);
    _saveSet(_keyEnemies, _discoveredEnemies);
    return true;
  }

  /// Discover a relic. Returns true if newly discovered.
  bool discoverRelic(String relicId) {
    if (_discoveredRelics.contains(relicId)) return false;
    _discoveredRelics.add(relicId);
    _saveSet(_keyRelics, _discoveredRelics);
    return true;
  }

  // === Query methods ===

  bool isUnitDiscovered(String id) => _discoveredUnits.contains(id);
  bool isHybridDiscovered(String id) => _discoveredHybrids.contains(id);
  bool isEnemyDiscovered(String id) => _discoveredEnemies.contains(id);
  bool isRelicDiscovered(String id) => _discoveredRelics.contains(id);

  int get discoveredUnitCount => _discoveredUnits.length;
  int get discoveredHybridCount => _discoveredHybrids.length;
  int get discoveredEnemyCount => _discoveredEnemies.length;
  int get discoveredRelicCount => _discoveredRelics.length;

  int get totalUnitCount => UnitDatabase.all.length + UnitDatabase.evolutions.length; // 8 + 8
  int get totalHybridCount => HybridDatabase.all.length; // 28
  int get totalEnemyCount => DefenseEnemyDatabase.all.length + 1; // 10 + boss
  int get totalRelicCount => RelicDatabase.all.length; // ~60

  int get totalDiscovered => discoveredUnitCount + discoveredHybridCount +
      discoveredEnemyCount + discoveredRelicCount;
  int get totalItems => totalUnitCount + totalHybridCount +
      totalEnemyCount + totalRelicCount;

  double get completionPercent =>
      totalItems > 0 ? totalDiscovered / totalItems : 0.0;

  /// Save discovered items to SharedPreferences.
  Future<void> save() async {
    _saveSet(_keyUnits, _discoveredUnits);
    _saveSet(_keyHybrids, _discoveredHybrids);
    _saveSet(_keyEnemies, _discoveredEnemies);
    _saveSet(_keyRelics, _discoveredRelics);
  }

  /// Reset all codex data.
  void reset() {
    _discoveredUnits.clear();
    _discoveredHybrids.clear();
    _discoveredEnemies.clear();
    _discoveredRelics.clear();
    _prefs.remove(_keyUnits);
    _prefs.remove(_keyHybrids);
    _prefs.remove(_keyEnemies);
    _prefs.remove(_keyRelics);
  }
}
