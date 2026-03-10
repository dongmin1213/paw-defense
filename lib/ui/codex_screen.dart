import 'package:flutter/material.dart';
import 'game_theme.dart';
import '../game/defense_game.dart';
import '../data/unit_data.dart';
import '../data/hybrid_unit_data.dart';
import '../data/enemy_data.dart';
import '../data/relic_data.dart';

/// Codex / Encyclopedia overlay — shows all discovered units, enemies, relics, hybrids.
class CodexScreen extends StatefulWidget {
  final DefenseGame game;
  const CodexScreen({super.key, required this.game});

  @override
  State<CodexScreen> createState() => _CodexScreenState();
}

class _CodexScreenState extends State<CodexScreen> {
  int _selectedTab = 0;

  static const List<String> _tabLabels = [
    '\u{1F43E}유닛',
    '\u{1F479}적',
    '\u{1F52E}유물',
    '\u{1F4CA}통계',
  ];

  int get _totalItems => widget.game.codexManager.totalItems;
  int get _discoveredCount => widget.game.codexManager.totalDiscovered;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.85),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // -- Header --
              _buildHeader(),
              const SizedBox(height: 10),
              // -- Tabs --
              _buildTabs(),
              const SizedBox(height: 10),
              // -- Content --
              Expanded(child: _buildTabContent()),
              const SizedBox(height: 12),
              // -- Close Button --
              GameTheme.pixelButton(
                label: '\uB2EB\uAE30',
                onTap: () => widget.game.closeCodex(),
                color: GameTheme.bgPanel,
                fontSize: 9,
                verticalPad: 10,
                horizontalPad: 24,
                icon: Icons.close,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════
  // Header
  // ══════════════════════════════════════

  Widget _buildHeader() {
    final total = _totalItems;
    final discovered = _discoveredCount;
    final percent = total > 0 ? (discovered / total * 100).toInt() : 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: GameTheme.pixelPanelDecoration(
        fillColor: GameTheme.bgCard,
        glow: true,
        glowColor: GameTheme.accent,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('\u{1F4D6}', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\uB3C4\uAC10',
                      style: GameTheme.pixel(
                        fontSize: 12,
                        color: GameTheme.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$discovered / $total \uBC1C\uACAC ($percent%)',
                      style: GameTheme.pixel(
                        fontSize: 7,
                        color: GameTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GameTheme.pixelProgressBar(
            value: total > 0 ? discovered / total : 0.0,
            height: 8,
            fillGradient: GameTheme.gradientPrimary,
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════
  // Tabs
  // ══════════════════════════════════════

  Widget _buildTabs() {
    return Row(
      children: List.generate(_tabLabels.length, (i) {
        final isSelected = _selectedTab == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedTab = i),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              margin: EdgeInsets.only(right: i < _tabLabels.length - 1 ? 4 : 0),
              decoration: GameTheme.pixelCardDecoration(
                fillColor:
                    isSelected ? GameTheme.accent.withValues(alpha: 0.2) : GameTheme.bgDeep,
                borderColor:
                    isSelected ? GameTheme.accent : GameTheme.pixelBorder,
                selected: isSelected,
              ),
              alignment: Alignment.center,
              child: Text(
                _tabLabels[i],
                style: GameTheme.pixel(
                  fontSize: 7,
                  color: isSelected ? GameTheme.accent : GameTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ══════════════════════════════════════
  // Tab Content
  // ══════════════════════════════════════

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildUnitsTab();
      case 1:
        return _buildEnemiesTab();
      case 2:
        return _buildRelicsTab();
      case 3:
        return _buildStatsTab();
      default:
        return const SizedBox.shrink();
    }
  }

  // ══════════════════════════════════════
  // Units Tab (base units + evolved + hybrids)
  // ══════════════════════════════════════

  Widget _buildUnitsTab() {
    final codex = widget.game.codexManager;

    return ListView(
      children: [
        // -- Base Units Section --
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '\uAE30\uBCF8 \uC720\uB2DB',
            style: GameTheme.pixel(
              fontSize: 8,
              color: GameTheme.accentGold,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 0.75,
          ),
          itemCount: UnitDatabase.all.length,
          itemBuilder: (context, index) {
            final unit = UnitDatabase.all[index];
            final snakeId = _toSnakeCase(unit.id);
            final discovered = codex.isUnitDiscovered(snakeId);
            return _buildItemCard(
              emoji: unit.emoji,
              name: unit.name,
              description: unit.description,
              discovered: discovered,
            );
          },
        ),
        const SizedBox(height: 16),
        // -- Evolved Units Section --
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '\uC9C4\uD654 \uC720\uB2DB',
            style: GameTheme.pixel(
              fontSize: 8,
              color: GameTheme.accentOrange,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 0.75,
          ),
          itemCount: UnitDatabase.evolutions.length,
          itemBuilder: (context, index) {
            final evo = UnitDatabase.evolutions[index];
            final discovered = codex.isUnitDiscovered(evo.id);
            // Use the base unit emoji for the evolved form
            final baseUnit = UnitDatabase.get(evo.baseType);
            return _buildItemCard(
              emoji: baseUnit.emoji,
              name: evo.name,
              description: evo.specialEffect,
              discovered: discovered,
              borderColor: discovered
                  ? GameTheme.accentOrange.withValues(alpha: 0.5)
                  : null,
            );
          },
        ),
        const SizedBox(height: 16),
        // -- Hybrid Units Section --
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '\uD558\uC774\uBE0C\uB9AC\uB4DC \uC720\uB2DB',
            style: GameTheme.pixel(
              fontSize: 8,
              color: GameTheme.accentPurple,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 0.65,
          ),
          itemCount: HybridDatabase.all.length,
          itemBuilder: (context, index) {
            final hybrid = HybridDatabase.all[index];
            final discovered = codex.isHybridDiscovered(hybrid.id);
            // Find parent emojis
            final parentAData = _findUnitEmoji(hybrid.parentA);
            final parentBData = _findUnitEmoji(hybrid.parentB);
            return _buildHybridCard(
              emoji: hybrid.emoji,
              name: hybrid.name,
              description: hybrid.specialAbilityDesc,
              parentAEmoji: parentAData,
              parentBEmoji: parentBData,
              discovered: discovered,
            );
          },
        ),
      ],
    );
  }

  // ══════════════════════════════════════
  // Enemies Tab
  // ══════════════════════════════════════

  Widget _buildEnemiesTab() {
    final codex = widget.game.codexManager;

    // Build list of enemies including boss
    final allEnemies = <_EnemyEntry>[
      for (final e in DefenseEnemyDatabase.all)
        _EnemyEntry(
          id: e.id,
          name: e.name,
          emoji: _enemyEmoji(e.id),
          description: _enemyDescription(e),
          discovered: codex.isEnemyDiscovered(e.id),
        ),
      _EnemyEntry(
        id: 'boss',
        name: '\uBCF4\uC2A4',
        emoji: '\u{1F480}',
        description: '\uAC15\uB825\uD55C \uBCF4\uC2A4 \uBAAC\uC2A4\uD130',
        discovered: codex.isEnemyDiscovered('boss'),
      ),
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 0.85,
      ),
      itemCount: allEnemies.length,
      itemBuilder: (context, index) {
        final entry = allEnemies[index];
        return _buildItemCard(
          emoji: entry.emoji,
          name: entry.name,
          description: entry.description,
          discovered: entry.discovered,
        );
      },
    );
  }

  // ══════════════════════════════════════
  // Relics Tab
  // ══════════════════════════════════════

  Widget _buildRelicsTab() {
    final codex = widget.game.codexManager;

    // Group relics by rarity
    final groupedRelics = <RelicRarity, List<RelicDef>>{};
    for (final r in RelicDatabase.all) {
      groupedRelics.putIfAbsent(r.rarity, () => []).add(r);
    }

    final rarityOrder = [
      RelicRarity.common,
      RelicRarity.rare,
      RelicRarity.epic,
      RelicRarity.legendary,
      RelicRarity.mythic,
    ];

    return ListView(
      children: [
        for (final rarity in rarityOrder)
          if (groupedRelics.containsKey(rarity)) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 6, top: 8),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _rarityColor(rarity),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    rarity.label,
                    style: GameTheme.pixel(
                      fontSize: 8,
                      color: _rarityColor(rarity),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${groupedRelics[rarity]!.where((r) => codex.isRelicDiscovered(r.id)).length}/${groupedRelics[rarity]!.length})',
                    style: GameTheme.pixel(
                      fontSize: 6,
                      color: GameTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 0.75,
              ),
              itemCount: groupedRelics[rarity]!.length,
              itemBuilder: (context, index) {
                final relic = groupedRelics[rarity]![index];
                final discovered = codex.isRelicDiscovered(relic.id);
                return _buildItemCard(
                  emoji: relic.icon,
                  name: relic.name,
                  description: relic.description,
                  discovered: discovered,
                  borderColor: discovered ? _rarityColor(rarity).withValues(alpha: 0.5) : null,
                );
              },
            ),
          ],
      ],
    );
  }

  // ══════════════════════════════════════
  // Stats Tab
  // ══════════════════════════════════════

  Widget _buildStatsTab() {
    final game = widget.game;

    final stats = <_StatEntry>[
      _StatEntry('\u{2694}\uFE0F', '\uCD1D \uCC98\uCE58 \uC218', GameTheme.formatInt(game.totalKills)),
      _StatEntry('\u{1F3C3}', '\uCD1D \uB7F0 \uD69F\uC218', GameTheme.formatInt(game.totalRuns)),
      _StatEntry('\u{1F30A}', '\uCD5C\uACE0 \uC6E8\uC774\uBE0C', GameTheme.formatInt(game.highestWave)),
      _StatEntry('\u{1F300}', '\uCD1D \uD569\uC131 \uD69F\uC218', GameTheme.formatInt(game.totalMerges)),
      _StatEntry('\u{1F480}', '\uCD1D \uBCF4\uC2A4 \uCC98\uCE58', GameTheme.formatInt(game.totalBossKills)),
      _StatEntry('\u{1F43E}', '\uBC1C\uACAC\uD55C \uC720\uB2DB', '${game.codexManager.discoveredUnits.length} / ${UnitDatabase.all.length + UnitDatabase.evolutions.length}'),
      _StatEntry('\u{1F479}', '\uBC1C\uACAC\uD55C \uC801', '${game.codexManager.discoveredEnemies.length} / ${DefenseEnemyDatabase.all.length + 1}'),
      _StatEntry('\u{1F52E}', '\uBC1C\uACAC\uD55C \uC720\uBB3C', '${game.codexManager.discoveredRelics.length} / ${RelicDatabase.all.length}'),
      _StatEntry('\u{1F9EC}', '\uBC1C\uACAC\uD55C \uD558\uC774\uBE0C\uB9AC\uB4DC', '${game.codexManager.discoveredHybrids.length} / ${HybridDatabase.all.length}'),
    ];

    return ListView.builder(
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return StaggeredEntry(
          index: index,
          child: Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: GameTheme.pixelCardDecoration(
              fillColor: GameTheme.bgCard,
            ),
            child: Row(
              children: [
                Text(stat.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    stat.label,
                    style: GameTheme.pixel(
                      fontSize: 7,
                      color: GameTheme.textSecondary,
                    ),
                  ),
                ),
                Text(
                  stat.value,
                  style: GameTheme.pixel(
                    fontSize: 9,
                    color: GameTheme.accentGold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════
  // Shared card builders
  // ══════════════════════════════════════

  Widget _buildItemCard({
    required String emoji,
    required String name,
    required String description,
    required bool discovered,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: GameTheme.pixelCardDecoration(
        fillColor: discovered
            ? GameTheme.bgCard.withValues(alpha: 0.9)
            : GameTheme.bgDeep.withValues(alpha: 0.7),
        borderColor: borderColor ??
            (discovered
                ? GameTheme.pixelBorder
                : GameTheme.pixelBorder.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            discovered ? emoji : '\u2753',
            style: TextStyle(
              fontSize: 22,
              color: discovered ? null : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            discovered ? name : '???',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GameTheme.pixel(
              fontSize: 5,
              color: discovered ? GameTheme.textPrimary : GameTheme.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (discovered) ...[
            const SizedBox(height: 2),
            Text(
              description,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GameTheme.pixel(
                fontSize: 4,
                color: GameTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHybridCard({
    required String emoji,
    required String name,
    required String description,
    required String parentAEmoji,
    required String parentBEmoji,
    required bool discovered,
  }) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: GameTheme.pixelCardDecoration(
        fillColor: discovered
            ? GameTheme.bgCard.withValues(alpha: 0.9)
            : GameTheme.bgDeep.withValues(alpha: 0.7),
        borderColor: discovered
            ? GameTheme.accentPurple.withValues(alpha: 0.5)
            : GameTheme.pixelBorder.withValues(alpha: 0.5),
        glow: discovered,
        glowColor: GameTheme.accentPurple,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Recipe line
          Text(
            discovered
                ? '$parentAEmoji + $parentBEmoji'
                : '? + ?',
            style: GameTheme.pixel(
              fontSize: 5,
              color: discovered ? GameTheme.textSecondary : GameTheme.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            discovered ? emoji : '\u2753',
            style: TextStyle(
              fontSize: 22,
              color: discovered ? null : Colors.grey,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            discovered ? name : '???',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GameTheme.pixel(
              fontSize: 5,
              color: discovered ? GameTheme.accentPurple : GameTheme.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (discovered) ...[
            const SizedBox(height: 2),
            Text(
              description,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GameTheme.pixel(
                fontSize: 4,
                color: GameTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ══════════════════════════════════════
  // Helpers
  // ══════════════════════════════════════

  /// Convert camelCase to snake_case (matching DefenseGame._toSnakeCase).
  static String _toSnakeCase(String s) =>
      s.replaceAllMapped(RegExp(r'[A-Z]'), (m) => '_${m[0]!.toLowerCase()}');

  /// Find emoji for a unit by snake_case ID.
  String _findUnitEmoji(String snakeId) {
    for (final u in UnitDatabase.all) {
      if (_toSnakeCase(u.id) == snakeId) return u.emoji;
    }
    return '\u2753';
  }

  /// Get emoji for an enemy type.
  String _enemyEmoji(String id) {
    switch (id) {
      case 'slime':
        return '\u{1F7E2}';
      case 'goblin':
        return '\u{1F47A}';
      case 'bat':
        return '\u{1F987}';
      case 'orc':
        return '\u{1F9CC}';
      case 'shielded':
        return '\u{1F6E1}\uFE0F';
      case 'bomber':
        return '\u{1F4A3}';
      case 'healer':
        return '\u{1FA79}';
      case 'skeleton':
        return '\u{1F480}';
      case 'mushroom':
        return '\u{1F344}';
      case 'golem':
        return '\u{1FAA8}';
      case 'boss':
        return '\u{1F451}';
      default:
        return '\u{1F47E}';
    }
  }

  /// Brief description for an enemy.
  String _enemyDescription(DefenseEnemyData e) {
    final parts = <String>[];
    if (e.isFlying) parts.add('\uBE44\uD589');
    parts.add('HP ${e.baseHp.toInt()}');
    parts.add('DMG ${e.baseDamage.toInt()}');
    parts.add('W${e.unlockWave}+');
    return parts.join(' | ');
  }

  /// Rarity color mapping.
  Color _rarityColor(RelicRarity rarity) {
    switch (rarity) {
      case RelicRarity.common:
        return GameTheme.rarityCommon;
      case RelicRarity.rare:
        return GameTheme.rarityRare;
      case RelicRarity.epic:
        return GameTheme.rarityEpic;
      case RelicRarity.legendary:
        return GameTheme.rarityLegendary;
      case RelicRarity.mythic:
        return const Color(0xFFFF4081);
    }
  }
}

// ══════════════════════════════════════
// Helper data classes
// ══════════════════════════════════════

class _EnemyEntry {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final bool discovered;

  const _EnemyEntry({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.discovered,
  });
}

class _StatEntry {
  final String emoji;
  final String label;
  final String value;

  const _StatEntry(this.emoji, this.label, this.value);
}
