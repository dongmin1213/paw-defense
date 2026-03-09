import 'dart:math';
import 'package:flutter/material.dart';
import '../game/runner_game.dart';
import '../data/soul_upgrade_data.dart';
import '../data/region_data.dart';
import 'game_theme.dart';

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
            child: SafeArea(
              child: Column(
                children: [
                  // ── 헤더 ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: GameTheme.accentPurple.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.auto_awesome,
                              color: GameTheme.accentPurple, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('스킬 트리',
                                style: GameTheme.titleMedium.copyWith(
                                    fontSize: 20,
                                    color: GameTheme.accentPurple)),
                            Text('초월 소울로 영구 강화',
                                style: GameTheme.bodySmall),
                          ],
                        ),
                        const Spacer(),
                        GameTheme.currencyDisplay(
                          value: '${manager.souls}',
                          isSoul: true,
                        ),
                        const SizedBox(width: 8),
                        GameTheme.closeButton(
                            onTap: () => game.closeSoulShop()),
                      ],
                    ),
                  ),

                  // ── 스킬 트리 + 상세 패널 ──
                  Expanded(
                    child: Row(
                      children: [
                        // 왼쪽: 스킬 트리
                        Expanded(
                          flex: 3,
                          child: _buildSkillTree(),
                        ),
                        // 오른쪽: 상세 패널
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
                // ── 코어 강화 (상단) ──
                _buildTreeSection('코어 강화', Icons.diamond, const Color(0xFF64B5F6), [
                  _TreeRow(nodes: [
                    _SkillNode(id: SoulUpgradeId.coinMultiplier, tier: 0),
                    _SkillNode(id: SoulUpgradeId.startSpeed, tier: 0),
                    _SkillNode(id: SoulUpgradeId.comboBooster, tier: 0),
                  ]),
                  _TreeRow(nodes: [
                    _SkillNode(id: SoulUpgradeId.offlineEfficiency, tier: 1),
                  ]),
                ]),

                const SizedBox(height: 12),

                // ── 장비 (중단) ──
                _buildTreeSection('장비 해금', Icons.shield, const Color(0xFFFF8A65), [
                  _TreeRow(nodes: [
                    _SkillNode(id: SoulUpgradeId.equipBow, tier: 0),
                    _SkillNode(id: SoulUpgradeId.equipGauntlet, tier: 0),
                    _SkillNode(id: SoulUpgradeId.equipCloak, tier: 0),
                  ]),
                ]),

                const SizedBox(height: 12),

                // ── 자동화 (하단) ──
                _buildTreeSection('자동화', Icons.smart_toy, const Color(0xFF81C784), [
                  _TreeRow(nodes: [
                    _SkillNode(id: SoulUpgradeId.autoAirKill, tier: 0),
                    _SkillNode(id: SoulUpgradeId.autoUpgrade, tier: 1),
                  ]),
                ]),

                const SizedBox(height: 12),

                // ── 지역 해금 (최하단) ──
                _buildTreeSection('지역 해금', Icons.map, const Color(0xFFBA68C8), [
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

  Widget _buildTreeSection(String title, IconData icon, Color color, List<_TreeRow> rows) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(title, style: GameTheme.labelBold.copyWith(
                color: color, fontSize: 12,
              )),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: row.nodes.map((node) {
          final data = SoulUpgradeDatabase.get(node.id);
          final level = manager.getSoulLevel(node.id);
          final isMaxed = manager.isSoulMaxed(node.id);
          final isSelected = _selectedNode == node.id;

          // 연결선을 위한 투명도 기반 노드 색상
          Color nodeColor;
          Color borderColor;
          if (isMaxed) {
            nodeColor = sectionColor.withValues(alpha: 0.25);
            borderColor = sectionColor;
          } else if (level > 0) {
            nodeColor = sectionColor.withValues(alpha: 0.12);
            borderColor = sectionColor.withValues(alpha: 0.6);
          } else {
            nodeColor = GameTheme.bgCard;
            borderColor = Colors.white.withValues(alpha: 0.08);
          }

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedNode = node.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                decoration: BoxDecoration(
                  color: nodeColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? GameTheme.accentGold : borderColor,
                    width: isSelected ? 2 : 1.2,
                  ),
                  boxShadow: isMaxed
                      ? [BoxShadow(color: sectionColor.withValues(alpha: 0.2), blurRadius: 8)]
                      : isSelected
                          ? [BoxShadow(color: GameTheme.accentGold.withValues(alpha: 0.3), blurRadius: 8)]
                          : null,
                ),
                child: Column(
                  children: [
                    Icon(
                      _getSoulIcon(node.id),
                      color: isMaxed ? sectionColor : (level > 0 ? sectionColor.withValues(alpha: 0.8) : GameTheme.textMuted),
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isMaxed ? sectionColor : (level > 0 ? GameTheme.textPrimary : GameTheme.textMuted),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (data.maxLevel > 1)
                      Text(
                        isMaxed ? 'MAX' : '$level/${data.maxLevel}',
                        style: TextStyle(
                          color: isMaxed ? sectionColor : GameTheme.textMuted,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isMaxed ? sectionColor : Colors.white.withValues(alpha: 0.1),
                          border: Border.all(
                            color: isMaxed ? sectionColor : Colors.white.withValues(alpha: 0.15),
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
            ),
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
      padding: const EdgeInsets.all(14),
      decoration: GameTheme.panelDecoration(
        borderColor: GameTheme.accentPurple.withValues(alpha: 0.2),
        borderRadius: 14,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아이콘 + 이름
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: GameTheme.accentPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getSoulIcon(id),
                    color: isMaxed ? GameTheme.accentPurple : GameTheme.textSecondary,
                    size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.name, style: GameTheme.labelBold),
                    if (data.maxLevel > 1)
                      Text(
                        isMaxed ? 'MAX LEVEL' : 'Lv.$level / ${data.maxLevel}',
                        style: TextStyle(
                          color: isMaxed ? GameTheme.accentPurple : GameTheme.textMuted,
                          fontSize: 10, fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 설명
          Text(data.description, style: GameTheme.bodySmall.copyWith(fontSize: 12)),

          const SizedBox(height: 8),

          // 효과
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: GameTheme.glassDecoration(opacity: 0.06),
            child: Text(
              '효과: ${data.effectUnit}',
              style: GameTheme.labelBold.copyWith(
                color: GameTheme.accentPurple, fontSize: 11,
              ),
            ),
          ),

          if (data.maxLevel > 1) ...[
            const SizedBox(height: 8),
            GameTheme.progressBar(
              value: level / data.maxLevel,
              height: 5,
              fillGradient: GameTheme.gradientPurple,
            ),
          ],

          const SizedBox(height: 14),

          // 구매 버튼
          if (!isMaxed)
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: canBuy ? () => _buySoul(id) : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: canBuy ? GameTheme.gradientPurple : null,
                    color: canBuy ? null : GameTheme.bgCard,
                    borderRadius: BorderRadius.circular(10),
                    border: canBuy ? null : Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    boxShadow: canBuy
                        ? [BoxShadow(color: GameTheme.accentPurple.withValues(alpha: 0.3), blurRadius: 6)]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome,
                          color: canBuy ? Colors.white : GameTheme.textMuted, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '$cost 소울',
                        style: TextStyle(
                          color: canBuy ? Colors.white : GameTheme.textMuted,
                          fontSize: 14, fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: GameTheme.accentGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: GameTheme.accentGreen, size: 16),
                    const SizedBox(width: 6),
                    Text('해금 완료', style: TextStyle(
                      color: GameTheme.accentGreen, fontSize: 13, fontWeight: FontWeight.w700,
                    )),
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
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Row(
        children: [
          Icon(Icons.map, color: GameTheme.textMuted, size: 14),
          const SizedBox(width: 6),
          Text('지역:', style: GameTheme.bodySmall.copyWith(fontSize: 10)),
          const SizedBox(width: 8),
          ...regions.map((id) {
            final region = RegionDatabase.getRegion(id);
            final unlocked = manager.isRegionUnlocked(id);
            final isCurrent = widget.game.currentRegionId == id;

            return GestureDetector(
              onTap: unlocked && !isCurrent ? () {
                widget.game.changeRegion(id);
                setState(() {});
              } : null,
              child: Container(
                margin: const EdgeInsets.only(right: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: isCurrent ? LinearGradient(
                    colors: [region.skyColor.withValues(alpha: 0.3), region.grassColor.withValues(alpha: 0.2)],
                  ) : null,
                  color: isCurrent ? null : (unlocked ? GameTheme.bgCard : GameTheme.bgCard.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isCurrent ? GameTheme.accentGold.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.04),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!unlocked) Icon(Icons.lock, color: GameTheme.textMuted, size: 10),
                    Text(
                      region.name,
                      style: TextStyle(
                        color: isCurrent ? GameTheme.accentGold : (unlocked ? GameTheme.textSecondary : GameTheme.textMuted),
                        fontSize: 10,
                        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 3),
                      Text('x${region.coinMultiplier.toStringAsFixed(0)}',
                          style: TextStyle(color: GameTheme.accentGold, fontSize: 9, fontWeight: FontWeight.w700)),
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
      case SoulUpgradeId.coinMultiplier: return Icons.monetization_on;
      case SoulUpgradeId.startSpeed: return Icons.speed;
      case SoulUpgradeId.offlineEfficiency: return Icons.schedule;
      case SoulUpgradeId.comboBooster: return Icons.whatshot;
      case SoulUpgradeId.autoAirKill: return Icons.flight;
      case SoulUpgradeId.autoUpgrade: return Icons.smart_toy;
      case SoulUpgradeId.regionForest: return Icons.park;
      case SoulUpgradeId.regionDesert: return Icons.wb_sunny;
      case SoulUpgradeId.regionSnowfield: return Icons.ac_unit;
      case SoulUpgradeId.regionVolcano: return Icons.local_fire_department;
      case SoulUpgradeId.equipBow: return Icons.gps_fixed;
      case SoulUpgradeId.equipGauntlet: return Icons.front_hand;
      case SoulUpgradeId.equipCloak: return Icons.air;
    }
  }

  void _buySoul(SoulUpgradeId id) {
    final cost = widget.game.ascensionManager.buySoulUpgrade(id);
    if (cost > 0) {
      widget.game.saveGame();
      setState(() {});
    }
  }
}
