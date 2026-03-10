import 'package:flutter/material.dart';
import 'game_theme.dart';
import '../game/defense_game.dart';
import '../data/unit_data.dart';
import '../data/hybrid_unit_data.dart';
import '../data/enemy_data.dart';
import '../data/relic_data.dart';

/// Codex / Encyclopedia — professional grid layout with better card design.
class CodexScreen extends StatefulWidget {
  final DefenseGame game;
  const CodexScreen({super.key, required this.game});

  @override
  State<CodexScreen> createState() => _CodexScreenState();
}

class _CodexScreenState extends State<CodexScreen> {
  int _selectedTab = 0;

  static const List<String> _tabLabels = ['유닛', '적', '유물', '통계'];
  static const List<IconData> _tabIcons = [
    Icons.pets,
    Icons.pest_control,
    Icons.diamond,
    Icons.bar_chart,
  ];

  int get _totalItems => widget.game.codexManager.totalItems;
  int get _discoveredCount => widget.game.codexManager.totalDiscovered;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: GameTheme.bgDeep.withValues(alpha: 0.95),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 10),
              _buildTabs(),
              const SizedBox(height: 10),
              Expanded(child: _buildTabContent()),
              const SizedBox(height: 10),
              _buildCloseButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final total = _totalItems;
    final discovered = _discoveredCount;
    final percent = total > 0 ? (discovered / total * 100).toInt() : 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: GameTheme.pixelPanelDecoration(
        fillColor: GameTheme.bgCard,
        glow: true,
        glowColor: GameTheme.accent.withValues(alpha: 0.3),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: GameTheme.accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(GameTheme.radiusSm),
                ),
                child: const Center(
                  child: Text('📖', style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '도감',
                      style: GameTheme.pixel(
                        fontSize: 12,
                        color: GameTheme.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$discovered / $total 발견 ($percent%)',
                      style: GameTheme.pixel(fontSize: 7, color: GameTheme.textSecondary),
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

  Widget _buildTabs() {
    return Row(
      children: List.generate(_tabLabels.length, (i) {
        final isSelected = _selectedTab == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedTab = i),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              margin: EdgeInsets.only(right: i < _tabLabels.length - 1 ? 4 : 0),
              decoration: BoxDecoration(
                color: isSelected
                    ? GameTheme.accent.withValues(alpha: 0.12)
                    : GameTheme.bgDeep,
                borderRadius: BorderRadius.circular(GameTheme.radiusSm),
                border: Border.all(
                  color: isSelected
                      ? GameTheme.accent.withValues(alpha: 0.4)
                      : GameTheme.pixelBorder.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _tabIcons[i],
                    size: 14,
                    color: isSelected ? GameTheme.accent : GameTheme.textMuted,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _tabLabels[i],
                    style: GameTheme.pixel(
                      fontSize: 6,
                      color: isSelected ? GameTheme.accent : GameTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCloseButton() {
    return SizedBox(
      width: double.infinity,
      child: GameTheme.pixelButton(
        label: '닫기',
        onTap: () => widget.game.closeCodex(),
        color: GameTheme.bgPanel,
        fontSize: 9,
        verticalPad: 10,
        horizontalPad: 24,
        icon: Icons.close,
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0: return _buildUnitsTab();
      case 1: return _buildEnemiesTab();
      case 2: return _buildRelicsTab();
      case 3: return _buildStatsTab();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildUnitsTab() {
    final codex = widget.game.codexManager;

    return ListView(
      children: [
        _sectionTitle('기본 유닛', GameTheme.accentGold),
        _buildGrid(
          items: UnitDatabase.all,
          builder: (unit) {
            final snakeId = _toSnakeCase(unit.id);
            final discovered = codex.isUnitDiscovered(snakeId);
            return _buildItemCard(
              emoji: unit.emoji, name: unit.name,
              description: unit.description, discovered: discovered,
            );
          },
        ),
        const SizedBox(height: 14),
        _sectionTitle('진화 유닛', GameTheme.accentOrange),
        _buildGrid(
          items: UnitDatabase.evolutions,
          builder: (evo) {
            final discovered = codex.isUnitDiscovered(evo.id);
            final baseUnit = UnitDatabase.get(evo.baseType);
            return _buildItemCard(
              emoji: baseUnit.emoji, name: evo.name,
              description: evo.specialEffect, discovered: discovered,
              accentColor: discovered ? GameTheme.accentOrange : null,
            );
          },
        ),
        const SizedBox(height: 14),
        _sectionTitle('하이브리드 유닛', GameTheme.accentPurple),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, mainAxisSpacing: 6, crossAxisSpacing: 6,
            childAspectRatio: 0.60,
          ),
          itemCount: HybridDatabase.all.length,
          itemBuilder: (context, index) {
            final hybrid = HybridDatabase.all[index];
            final discovered = codex.isHybridDiscovered(hybrid.id);
            final parentAData = _findUnitEmoji(hybrid.parentA);
            final parentBData = _findUnitEmoji(hybrid.parentB);
            return _buildHybridCard(
              emoji: hybrid.emoji, name: hybrid.name,
              description: hybrid.specialAbilityDesc,
              parentAEmoji: parentAData, parentBEmoji: parentBData,
              discovered: discovered,
            );
          },
        ),
      ],
    );
  }

  Widget _buildEnemiesTab() {
    final codex = widget.game.codexManager;
    final allEnemies = <_EnemyEntry>[
      for (final e in DefenseEnemyDatabase.all)
        _EnemyEntry(id: e.id, name: e.name, emoji: _enemyEmoji(e.id),
          description: _enemyDescription(e), discovered: codex.isEnemyDiscovered(e.id)),
      _EnemyEntry(id: 'boss', name: '보스', emoji: '💀',
        description: '강력한 보스 몬스터', discovered: codex.isEnemyDiscovered('boss')),
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, mainAxisSpacing: 6, crossAxisSpacing: 6,
        childAspectRatio: 0.85,
      ),
      itemCount: allEnemies.length,
      itemBuilder: (context, index) {
        final entry = allEnemies[index];
        return _buildItemCard(
          emoji: entry.emoji, name: entry.name,
          description: entry.description, discovered: entry.discovered,
        );
      },
    );
  }

  Widget _buildRelicsTab() {
    final codex = widget.game.codexManager;
    final groupedRelics = <RelicRarity, List<RelicDef>>{};
    for (final r in RelicDatabase.all) {
      groupedRelics.putIfAbsent(r.rarity, () => []).add(r);
    }

    final rarityOrder = [
      RelicRarity.common, RelicRarity.rare, RelicRarity.epic,
      RelicRarity.legendary, RelicRarity.mythic,
    ];

    return ListView(
      children: [
        for (final rarity in rarityOrder)
          if (groupedRelics.containsKey(rarity)) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 6, top: 10),
              child: Row(
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      color: _rarityColor(rarity),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(rarity.label, style: GameTheme.pixel(
                    fontSize: 8, color: _rarityColor(rarity), fontWeight: FontWeight.w700,
                  )),
                  const SizedBox(width: 8),
                  Text(
                    '(${groupedRelics[rarity]!.where((r) => codex.isRelicDiscovered(r.id)).length}/${groupedRelics[rarity]!.length})',
                    style: GameTheme.pixel(fontSize: 6, color: GameTheme.textMuted),
                  ),
                ],
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, mainAxisSpacing: 6, crossAxisSpacing: 6,
                childAspectRatio: 0.75,
              ),
              itemCount: groupedRelics[rarity]!.length,
              itemBuilder: (context, index) {
                final relic = groupedRelics[rarity]![index];
                final discovered = codex.isRelicDiscovered(relic.id);
                return _buildItemCard(
                  emoji: relic.icon, name: relic.name,
                  description: relic.description, discovered: discovered,
                  accentColor: discovered ? _rarityColor(rarity) : null,
                );
              },
            ),
          ],
      ],
    );
  }

  Widget _buildStatsTab() {
    final game = widget.game;
    final stats = <_StatEntry>[
      _StatEntry('⚔️', '총 처치 수', GameTheme.formatInt(game.totalKills)),
      _StatEntry('🏃', '총 런 횟수', GameTheme.formatInt(game.totalRuns)),
      _StatEntry('🌊', '최고 웨이브', GameTheme.formatInt(game.highestWave)),
      _StatEntry('🌀', '총 합성 횟수', GameTheme.formatInt(game.totalMerges)),
      _StatEntry('💀', '총 보스 처치', GameTheme.formatInt(game.totalBossKills)),
      _StatEntry('🐾', '발견한 유닛', '${game.codexManager.discoveredUnits.length} / ${UnitDatabase.all.length + UnitDatabase.evolutions.length}'),
      _StatEntry('👹', '발견한 적', '${game.codexManager.discoveredEnemies.length} / ${DefenseEnemyDatabase.all.length + 1}'),
      _StatEntry('🔮', '발견한 유물', '${game.codexManager.discoveredRelics.length} / ${RelicDatabase.all.length}'),
      _StatEntry('🧬', '발견한 하이브리드', '${game.codexManager.discoveredHybrids.length} / ${HybridDatabase.all.length}'),
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
            decoration: GameTheme.pixelCardDecoration(fillColor: GameTheme.bgCard),
            child: Row(
              children: [
                Text(stat.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(child: Text(stat.label, style: GameTheme.pixel(fontSize: 7, color: GameTheme.textSecondary))),
                Text(stat.value, style: GameTheme.pixel(fontSize: 9, color: GameTheme.accentGold, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Shared builders ──

  Widget _sectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(width: 3, height: 14, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(title, style: GameTheme.pixel(fontSize: 8, color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildGrid<T>({required List<T> items, required Widget Function(T item) builder}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, mainAxisSpacing: 6, crossAxisSpacing: 6, childAspectRatio: 0.75,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => builder(items[index]),
    );
  }

  Widget _buildItemCard({
    required String emoji, required String name, required String description,
    required bool discovered, Color? accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: discovered ? GameTheme.bgCard.withValues(alpha: 0.9) : GameTheme.bgDeep.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(GameTheme.radiusSm),
        border: Border.all(
          color: discovered
              ? (accentColor ?? GameTheme.pixelBorder).withValues(alpha: 0.4)
              : GameTheme.pixelBorder.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            discovered ? emoji : '?',
            style: TextStyle(
              fontSize: discovered ? 24 : 20,
              color: discovered ? null : GameTheme.textMuted.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            discovered ? name : '???',
            textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: GameTheme.pixel(
              fontSize: 5,
              color: discovered ? GameTheme.textPrimary : GameTheme.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (discovered) ...[
            const SizedBox(height: 2),
            Text(description, textAlign: TextAlign.center, maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GameTheme.pixel(fontSize: 4, color: GameTheme.textSecondary)),
          ],
        ],
      ),
    );
  }

  Widget _buildHybridCard({
    required String emoji, required String name, required String description,
    required String parentAEmoji, required String parentBEmoji, required bool discovered,
  }) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: discovered ? GameTheme.bgCard.withValues(alpha: 0.9) : GameTheme.bgDeep.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(GameTheme.radiusSm),
        border: Border.all(
          color: discovered ? GameTheme.accentPurple.withValues(alpha: 0.3) : GameTheme.pixelBorder.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: discovered
            ? [BoxShadow(color: GameTheme.accentPurple.withValues(alpha: 0.08), blurRadius: 6)]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            discovered ? '$parentAEmoji + $parentBEmoji' : '? + ?',
            style: GameTheme.pixel(fontSize: 5, color: discovered ? GameTheme.textSecondary : GameTheme.textMuted),
          ),
          const SizedBox(height: 2),
          Text(
            discovered ? emoji : '?',
            style: TextStyle(fontSize: discovered ? 22 : 18, color: discovered ? null : GameTheme.textMuted.withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 3),
          Text(
            discovered ? name : '???',
            textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: GameTheme.pixel(fontSize: 5, color: discovered ? GameTheme.accentPurple : GameTheme.textMuted, fontWeight: FontWeight.w700),
          ),
          if (discovered) ...[
            const SizedBox(height: 2),
            Text(description, textAlign: TextAlign.center, maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GameTheme.pixel(fontSize: 4, color: GameTheme.textSecondary)),
          ],
        ],
      ),
    );
  }

  // ── Helpers ──

  static String _toSnakeCase(String s) =>
      s.replaceAllMapped(RegExp(r'[A-Z]'), (m) => '_${m[0]!.toLowerCase()}');

  String _findUnitEmoji(String snakeId) {
    for (final u in UnitDatabase.all) {
      if (_toSnakeCase(u.id) == snakeId) return u.emoji;
    }
    return '❓';
  }

  String _enemyEmoji(String id) {
    switch (id) {
      case 'slime': return '🟢';
      case 'goblin': return '👺';
      case 'bat': return '🦇';
      case 'orc': return '🧌';
      case 'shielded': return '🛡️';
      case 'bomber': return '💣';
      case 'healer': return '🩹';
      case 'skeleton': return '💀';
      case 'mushroom': return '🍄';
      case 'golem': return '🪨';
      case 'boss': return '👑';
      default: return '👾';
    }
  }

  String _enemyDescription(DefenseEnemyData e) {
    final parts = <String>[];
    if (e.isFlying) parts.add('비행');
    parts.add('HP ${e.baseHp.toInt()}');
    parts.add('DMG ${e.baseDamage.toInt()}');
    parts.add('W${e.unlockWave}+');
    return parts.join(' | ');
  }

  Color _rarityColor(RelicRarity rarity) {
    switch (rarity) {
      case RelicRarity.common: return GameTheme.rarityCommon;
      case RelicRarity.rare: return GameTheme.rarityRare;
      case RelicRarity.epic: return GameTheme.rarityEpic;
      case RelicRarity.legendary: return GameTheme.rarityLegendary;
      case RelicRarity.mythic: return GameTheme.rarityMythic;
    }
  }
}

class _EnemyEntry {
  final String id, name, emoji, description;
  final bool discovered;
  const _EnemyEntry({required this.id, required this.name, required this.emoji, required this.description, required this.discovered});
}

class _StatEntry {
  final String emoji, label, value;
  const _StatEntry(this.emoji, this.label, this.value);
}
