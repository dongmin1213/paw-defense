import 'package:flutter/material.dart';
import '../game/runner_game.dart';
import '../data/soul_upgrade_data.dart';
import '../data/region_data.dart';
import 'game_theme.dart';
import 'ui_effects.dart';

class SoulShop extends StatefulWidget {
  final RunnerGame game;
  const SoulShop({super.key, required this.game});

  @override
  State<SoulShop> createState() => _SoulShopState();
}

class _SoulShopState extends State<SoulShop>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  SoulUpgradeId? _selectedNode;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..forward();
  }

  void _animatedClose() {
    _entryController.reverse().then((_) {
      if (mounted) widget.game.closeSoulShop();
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final manager = game.ascensionManager;

    return AnimatedBuilder(
      animation: _entryController,
      builder: (context, _) {
        final fade = _entryController.value;
        return Material(
          color: GameTheme.bgDeep.withValues(alpha: 0.94 * fade),
          child: Opacity(
            opacity: fade,
            child: RetroScanlines(
              opacity: 0.02,
              child: SafeArea(
                child: Column(
                  children: [
                    // ── 헤더 ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: GameTheme.pixelCardDecoration(
                              fillColor: GameTheme.accentPurple
                                  .withValues(alpha: 0.15),
                              borderColor: GameTheme.accentPurple
                                  .withValues(alpha: 0.3),
                            ),
                            child: const Icon(Icons.auto_awesome,
                                color: GameTheme.accentPurple, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('SKILL TREE',
                                  style: GameTheme.pixel(
                                      fontSize: 12,
                                      color: GameTheme.accentPurple)),
                              Text('초월 소울로 영구 강화',
                                  style: GameTheme.bodySmall),
                            ],
                          ),
                          const Spacer(),
                          GameTheme.pixelCurrency(
                            value: '${manager.souls}',
                            isSoul: true,
                          ),
                          const SizedBox(width: 8),
                          GameTheme.closeButton(
                              onTap: _animatedClose),
                        ],
                      ),
                    ),

                    // ── 스킬 트리 + 상세 패널 ──
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildSkillTree(),
                          ),
                          if (_selectedNode != null)
                            SizedBox(
                              width: 220,
                              child: _buildDetailPanel(),
                            ),
                        ],
                      ),
                    ),

                    // ── 지역 선택 바 ──
                    _buildRegionBar(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkillTree() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: constraints.maxWidth,
            child: Column(
              children: [
                _buildTreeSection(
                    'CORE', Icons.diamond, const Color(0xFF64B5F6), [
                  _TreeRow(nodes: [
                    _SkillNode(id: SoulUpgradeId.coinMultiplier, tier: 0),
                    _SkillNode(id: SoulUpgradeId.startSpeed, tier: 0),
                    _SkillNode(id: SoulUpgradeId.comboBooster, tier: 0),
                  ]),
                  _TreeRow(nodes: [
                    _SkillNode(id: SoulUpgradeId.offlineEfficiency, tier: 1),
                  ]),
                ]),
                const SizedBox(height: 10),
                _buildTreeSection(
                    'EQUIP', Icons.shield, const Color(0xFFFF8A65), [
                  _TreeRow(nodes: [
                    _SkillNode(id: SoulUpgradeId.equipBow, tier: 0),
                    _SkillNode(id: SoulUpgradeId.equipGauntlet, tier: 0),
                    _SkillNode(id: SoulUpgradeId.equipCloak, tier: 0),
                  ]),
                ]),
                const SizedBox(height: 10),
                _buildTreeSection(
                    'AUTO', Icons.smart_toy, const Color(0xFF81C784), [
                  _TreeRow(nodes: [
                    _SkillNode(id: SoulUpgradeId.autoAirKill, tier: 0),
                    _SkillNode(id: SoulUpgradeId.autoUpgrade, tier: 1),
                  ]),
                ]),
                const SizedBox(height: 10),
                _buildTreeSection(
                    'REGION', Icons.map, const Color(0xFFBA68C8), [
                  _TreeRow(nodes: [
                    _SkillNode(id: SoulUpgradeId.regionForest, tier: 0),
                    _SkillNode(id: SoulUpgradeId.regionDesert, tier: 1),
                    _SkillNode(id: SoulUpgradeId.regionSnowfield, tier: 2),
                    _SkillNode(id: SoulUpgradeId.regionVolcano, tier: 3),
                  ]),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTreeSection(
      String title, IconData icon, Color color, List<_TreeRow> rows) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: GameTheme.pixelPanelDecoration(
        fillColor: color.withValues(alpha: 0.04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 6),
              Text(title,
                  style:
                      GameTheme.pixel(fontSize: 8, color: color, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 8),
          ...rows.map((row) => _buildTreeRow(row, color)),
        ],
      ),
    );
  }

  Widget _buildTreeRow(_TreeRow row, Color sectionColor) {
    final manager = widget.game.ascensionManager;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: row.nodes.map((node) {
          final data = SoulUpgradeDatabase.get(node.id);
          final level = manager.getSoulLevel(node.id);
          final isMaxed = manager.isSoulMaxed(node.id);
          final isSelected = _selectedNode == node.id;

          Color nodeColor;
          Color borderColor;
          if (isMaxed) {
            nodeColor = sectionColor.withValues(alpha: 0.2);
            borderColor = sectionColor;
          } else if (level > 0) {
            nodeColor = sectionColor.withValues(alpha: 0.1);
            borderColor = sectionColor.withValues(alpha: 0.5);
          } else {
            nodeColor = GameTheme.bgCard;
            borderColor = GameTheme.pixelBorder;
          }

          final child = GestureDetector(
            onTap: () => setState(() => _selectedNode = node.id),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 5),
              decoration: GameTheme.pixelCardDecoration(
                fillColor: nodeColor,
                borderColor: isSelected ? GameTheme.accentGold : borderColor,
                selected: isSelected,
                glow: isMaxed,
                glowColor: sectionColor,
              ),
              child: Column(
                children: [
                  Icon(
                    _getSoulIcon(node.id),
                    color: isMaxed
                        ? sectionColor
                        : (level > 0
                            ? sectionColor.withValues(alpha: 0.8)
                            : GameTheme.textMuted),
                    size: 18,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isMaxed
                          ? sectionColor
                          : (level > 0
                              ? GameTheme.textPrimary
                              : GameTheme.textMuted),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (data.maxLevel > 1)
                    Text(
                      isMaxed ? 'MAX' : '$level/${data.maxLevel}',
                      style: GameTheme.pixel(
                        fontSize: 5,
                        color:
                            isMaxed ? sectionColor : GameTheme.textMuted,
                      ),
                    )
                  else
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isMaxed
                            ? sectionColor
                            : Colors.white.withValues(alpha: 0.1),
                        border: Border.all(
                          color: isMaxed
                              ? sectionColor
                              : Colors.white.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                      child: isMaxed
                          ? Icon(Icons.check, size: 6, color: Colors.white)
                          : null,
                    ),
                ],
              ),
            ),
          );

          return Expanded(
            child: isMaxed
                ? PixelSparkle(color: sectionColor, sparkleCount: 3, child: child)
                : child,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDetailPanel() {
    final manager = widget.game.ascensionManager;
    final id = _selectedNode!;
    final data = SoulUpgradeDatabase.get(id);
    final level = manager.getSoulLevel(id);
    final isMaxed = manager.isSoulMaxed(id);
    final cost = isMaxed ? 0 : manager.getSoulCost(id);
    final canBuy = manager.canAffordSoul(id);

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 12, 12),
      padding: const EdgeInsets.all(12),
      decoration: GameTheme.pixelPanelDecoration(
        fillColor: GameTheme.bgPanel,
        glow: isMaxed,
        glowColor: GameTheme.accentPurple,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: GameTheme.pixelCardDecoration(
                  fillColor:
                      GameTheme.accentPurple.withValues(alpha: 0.15),
                  borderColor:
                      GameTheme.accentPurple.withValues(alpha: 0.3),
                ),
                child: Icon(_getSoulIcon(id),
                    color: isMaxed
                        ? GameTheme.accentPurple
                        : GameTheme.textSecondary,
                    size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.name, style: GameTheme.labelBold),
                    if (data.maxLevel > 1)
                      Text(
                        isMaxed ? 'MAX' : 'Lv.$level/${data.maxLevel}',
                        style: GameTheme.pixel(
                          fontSize: 6,
                          color: isMaxed
                              ? GameTheme.accentPurple
                              : GameTheme.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(data.description,
              style: GameTheme.bodySmall.copyWith(fontSize: 11)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(6),
            decoration: GameTheme.pixelCardDecoration(
              fillColor: GameTheme.accentPurple.withValues(alpha: 0.06),
              borderColor: GameTheme.accentPurple.withValues(alpha: 0.2),
            ),
            child: Text(
              '${data.effectUnit}',
              style: GameTheme.pixel(
                  fontSize: 6, color: GameTheme.accentPurple),
            ),
          ),
          if (data.maxLevel > 1) ...[
            const SizedBox(height: 8),
            GameTheme.pixelProgressBar(
              value: level / data.maxLevel,
              height: 6,
              fillGradient: GameTheme.gradientPurple,
            ),
          ],
          const SizedBox(height: 12),
          if (!isMaxed)
            SizedBox(
              width: double.infinity,
              child: GameTheme.pixelButton(
                label: '$cost SOUL',
                icon: Icons.auto_awesome,
                onTap: canBuy ? () => _buySoul(id) : null,
                gradient: GameTheme.gradientPurple,
                fontSize: 8,
                verticalPad: 8,
                horizontalPad: 12,
                enabled: canBuy,
              ),
            )
          else
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: GameTheme.pixelCardDecoration(
                  fillColor:
                      GameTheme.accentGreen.withValues(alpha: 0.15),
                  borderColor:
                      GameTheme.accentGreen.withValues(alpha: 0.4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle,
                        color: GameTheme.accentGreen, size: 14),
                    const SizedBox(width: 4),
                    Text('DONE',
                        style: GameTheme.pixel(
                            fontSize: 7, color: GameTheme.accentGreen)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRegionBar() {
    final manager = widget.game.ascensionManager;
    final regions = ['meadow', 'forest', 'desert', 'snowfield', 'volcano'];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      decoration: BoxDecoration(
        color: GameTheme.bgPanel.withValues(alpha: 0.5),
        border: Border(
            top: BorderSide(color: GameTheme.pixelBorder, width: 2)),
      ),
      child: Row(
        children: [
          Icon(Icons.map, color: GameTheme.textMuted, size: 14),
          const SizedBox(width: 6),
          Text('REGION:',
              style: GameTheme.pixel(
                  fontSize: 6, color: GameTheme.textMuted)),
          const SizedBox(width: 8),
          ...regions.map((id) {
            final region = RegionDatabase.getRegion(id);
            final unlocked = manager.isRegionUnlocked(id);
            final isCurrent = widget.game.currentRegionId == id;

            return GestureDetector(
              onTap: unlocked && !isCurrent
                  ? () {
                      widget.game.changeRegion(id);
                      setState(() {});
                    }
                  : null,
              child: Container(
                margin: const EdgeInsets.only(right: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: GameTheme.pixelCardDecoration(
                  fillColor: isCurrent
                      ? region.skyColor.withValues(alpha: 0.2)
                      : (unlocked
                          ? GameTheme.bgCard
                          : GameTheme.bgCard.withValues(alpha: 0.3)),
                  borderColor: isCurrent
                      ? GameTheme.accentGold.withValues(alpha: 0.6)
                      : GameTheme.pixelBorder,
                  selected: isCurrent,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!unlocked)
                      Icon(Icons.lock, color: GameTheme.textMuted, size: 9),
                    Text(
                      region.name,
                      style: TextStyle(
                        color: isCurrent
                            ? GameTheme.accentGold
                            : (unlocked
                                ? GameTheme.textSecondary
                                : GameTheme.textMuted),
                        fontSize: 9,
                        fontWeight:
                            isCurrent ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 3),
                      Text(
                          'x${region.coinMultiplier.toStringAsFixed(0)}',
                          style: GameTheme.pixel(
                              fontSize: 6, color: GameTheme.accentGold)),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _getSoulIcon(SoulUpgradeId id) {
    switch (id) {
      case SoulUpgradeId.coinMultiplier:
        return Icons.monetization_on;
      case SoulUpgradeId.startSpeed:
        return Icons.speed;
      case SoulUpgradeId.offlineEfficiency:
        return Icons.schedule;
      case SoulUpgradeId.comboBooster:
        return Icons.whatshot;
      case SoulUpgradeId.autoAirKill:
        return Icons.flight;
      case SoulUpgradeId.autoUpgrade:
        return Icons.smart_toy;
      case SoulUpgradeId.regionForest:
        return Icons.park;
      case SoulUpgradeId.regionDesert:
        return Icons.wb_sunny;
      case SoulUpgradeId.regionSnowfield:
        return Icons.ac_unit;
      case SoulUpgradeId.regionVolcano:
        return Icons.local_fire_department;
      case SoulUpgradeId.equipBow:
        return Icons.gps_fixed;
      case SoulUpgradeId.equipGauntlet:
        return Icons.front_hand;
      case SoulUpgradeId.equipCloak:
        return Icons.air;
    }
  }

  void _buySoul(SoulUpgradeId id) {
    final cost = widget.game.ascensionManager.buySoulUpgrade(id);
    if (cost > 0) {
      widget.game.saveGame();
      widget.game.soundManager.playPurchase();
      UIEffectManager.instance.spawnParticleBurst(
        relX: 0.5, relY: 0.5,
        color: const Color(0xFFCE93D8),
        count: 12,
        spread: 50,
      );
      UIEffectManager.instance.spawnGlowRing(
        relX: 0.5, relY: 0.5,
        color: const Color(0xFFCE93D8),
      );
      setState(() {});
    }
  }
}

class _TreeRow {
  final List<_SkillNode> nodes;
  const _TreeRow({required this.nodes});
}

class _SkillNode {
  final SoulUpgradeId id;
  final int tier;
  const _SkillNode({required this.id, required this.tier});
}
