import 'package:flutter/material.dart';
import '../game/runner_game.dart';
import '../data/companion_data.dart';
import '../systems/companion_manager.dart';

class CompanionScreen extends StatefulWidget {
  final RunnerGame game;

  const CompanionScreen({super.key, required this.game});

  @override
  State<CompanionScreen> createState() => _CompanionScreenState();
}

class _CompanionScreenState extends State<CompanionScreen> {
  String _selectedTab = 'equipped';

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final manager = game.companionManager;

    return Material(
      color: Colors.black.withValues(alpha: 0.92),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        '동료',
                        style: TextStyle(
                          color: Color(0xFFFF9800),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${manager.ownedCount}/${manager.totalCount}',
                        style: const TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '슬롯 ${manager.equippedIds.length}/${manager.maxSlots}',
                        style: const TextStyle(color: Color(0xFFFF9800), fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => widget.game.closeCompanionScreen(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('닫기', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tabs
            Row(
              children: [
                _buildTab('equipped', '장착'),
                _buildTab('codex', '도감'),
              ],
            ),
            const Divider(color: Colors.white24, height: 1),

            // Content
            Expanded(
              child: _selectedTab == 'equipped'
                  ? _buildEquippedView(manager)
                  : _buildCodexView(manager),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String id, String label) {
    final isSelected = _selectedTab == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFFFF9800) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? const Color(0xFFFF9800) : Colors.white54,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEquippedView(CompanionManager manager) {
    final owned = manager.allOwned;
    if (owned.isEmpty) {
      return const Center(
        child: Text(
          '아직 동료가 없습니다.\n달리다 보면 동료를 만날 수 있어요!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: owned.length,
      itemBuilder: (context, index) => _buildCompanionRow(owned[index], manager),
    );
  }

  Widget _buildCompanionRow(OwnedCompanion owned, CompanionManager manager) {
    final data = CompanionDatabase.get(owned.id);
    final isEquipped = manager.isEquipped(owned.id);
    final rarityColor = CompanionDatabase.rarityColor(data.rarity);
    final rarityName = CompanionDatabase.rarityName(data.rarity);
    final cost = manager.levelUpCost(owned.id);
    final canLevelUp = manager.canLevelUp(owned.id, widget.game.coins);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isEquipped
            ? rarityColor.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isEquipped
              ? rarityColor.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          // Companion icon area
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(color: rarityColor, width: 1.5),
            ),
            child: Center(
              child: Text(
                data.name.substring(0, 1),
                style: TextStyle(color: rarityColor, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(data.name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: rarityColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(rarityName, style: TextStyle(color: rarityColor, fontSize: 10)),
                    ),
                    const SizedBox(width: 6),
                    Text('Lv.${owned.level}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(data.buffDescription, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),

          // Level up button
          GestureDetector(
            onTap: canLevelUp ? () => _levelUp(owned.id) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: canLevelUp
                    ? const Color(0xFFFF9800).withValues(alpha: 0.7)
                    : Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '↑ ${_formatCost(cost)}',
                style: TextStyle(
                  color: canLevelUp ? Colors.white : Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Equip/unequip button
          GestureDetector(
            onTap: () {
              if (isEquipped) {
                manager.unequip(owned.id);
              } else {
                manager.equip(owned.id);
              }
              widget.game.saveGame();
              setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isEquipped
                    ? Colors.red.withValues(alpha: 0.6)
                    : const Color(0xFF4CAF50).withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isEquipped ? '해제' : '장착',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodexView(CompanionManager manager) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: CompanionDatabase.companions.length,
      itemBuilder: (context, index) {
        final data = CompanionDatabase.companions[index];
        final owned = manager.getOwned(data.id);
        final isOwned = owned != null;
        final rarityColor = CompanionDatabase.rarityColor(data.rarity);

        return Container(
          decoration: BoxDecoration(
            color: isOwned
                ? rarityColor.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isOwned ? rarityColor.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isOwned ? data.color.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    isOwned ? data.name.substring(0, 1) : '?',
                    style: TextStyle(
                      color: isOwned ? rarityColor : Colors.white24,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isOwned ? data.name : '???',
                style: TextStyle(
                  color: isOwned ? Colors.white : Colors.white24,
                  fontSize: 10,
                ),
              ),
              if (isOwned)
                Text(
                  'Lv.${owned.level}',
                  style: TextStyle(color: rarityColor, fontSize: 9),
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatCost(double cost) {
    if (cost >= 1000000) return '${(cost / 1000000).toStringAsFixed(1)}M';
    if (cost >= 1000) return '${(cost / 1000).toStringAsFixed(1)}K';
    return cost.toStringAsFixed(0);
  }

  void _levelUp(String id) {
    final cost = widget.game.companionManager.doLevelUp(id, widget.game.coins);
    if (cost > 0) {
      widget.game.coins -= cost;
      widget.game.saveGame();
      setState(() {});
    }
  }
}
