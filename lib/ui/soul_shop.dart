import 'package:flutter/material.dart';
import '../game/runner_game.dart';
import '../data/soul_upgrade_data.dart';
import '../data/region_data.dart';

class SoulShop extends StatefulWidget {
  final RunnerGame game;

  const SoulShop({super.key, required this.game});

  @override
  State<SoulShop> createState() => _SoulShopState();
}

class _SoulShopState extends State<SoulShop> {
  String _selectedTab = 'upgrades';

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final manager = game.ascensionManager;

    return Material(
      color: Colors.black.withValues(alpha: 0.9),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '영구 업그레이드',
                    style: TextStyle(
                      color: Color(0xFF9C27B0),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Color(0xFF9C27B0), size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${manager.souls}',
                        style: const TextStyle(
                          color: Color(0xFFCE93D8),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('소울', style: TextStyle(color: Color(0xFFCE93D8), fontSize: 14)),
                      const SizedBox(width: 16),
                      _buildCloseButton(),
                    ],
                  ),
                ],
              ),
            ),

            // Tabs
            Row(
              children: [
                _buildTab('upgrades', '강화'),
                _buildTab('regions', '지역'),
                _buildTab('equipment', '장비'),
              ],
            ),
            const Divider(color: Colors.white24, height: 1),

            // Content
            Expanded(
              child: _buildContent(),
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
                color: isSelected ? const Color(0xFF9C27B0) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? const Color(0xFFCE93D8) : Colors.white54,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 'regions':
        return _buildRegionsList();
      case 'equipment':
        return _buildEquipmentList();
      default:
        return _buildUpgradesList();
    }
  }

  Widget _buildUpgradesList() {
    final upgradeIds = [
      SoulUpgradeId.coinMultiplier,
      SoulUpgradeId.startSpeed,
      SoulUpgradeId.offlineEfficiency,
      SoulUpgradeId.comboBooster,
      SoulUpgradeId.autoAirKill,
      SoulUpgradeId.autoUpgrade,
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: upgradeIds.length,
      itemBuilder: (context, index) => _buildSoulUpgradeRow(upgradeIds[index]),
    );
  }

  Widget _buildRegionsList() {
    final regionIds = [
      SoulUpgradeId.regionForest,
      SoulUpgradeId.regionDesert,
      SoulUpgradeId.regionSnowfield,
      SoulUpgradeId.regionVolcano,
    ];

    final manager = widget.game.ascensionManager;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Current region selector
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Text('현재 지역: ', style: TextStyle(color: Colors.white70, fontSize: 14)),
              Text(
                RegionDatabase.getRegion(widget.game.currentRegionId).name,
                style: const TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        // Unlocked region buttons
        ...manager.unlockedRegionIds.map((id) {
          final region = RegionDatabase.getRegion(id);
          final isCurrent = widget.game.currentRegionId == id;
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: GestureDetector(
              onTap: isCurrent ? null : () {
                widget.game.changeRegion(id);
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? Colors.amber.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCurrent ? Colors.amber.withValues(alpha: 0.5) : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(region.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('x${region.coinMultiplier.toStringAsFixed(0)}', style: const TextStyle(color: Colors.amber, fontSize: 14)),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        const Divider(color: Colors.white24),
        const SizedBox(height: 8),
        const Text('지역 해금', style: TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 8),
        // Unlock upgrades
        ...regionIds.map((id) => _buildSoulUpgradeRow(id)),
      ],
    );
  }

  Widget _buildEquipmentList() {
    final equipIds = [
      SoulUpgradeId.equipBow,
      SoulUpgradeId.equipGauntlet,
      SoulUpgradeId.equipCloak,
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: equipIds.length,
      itemBuilder: (context, index) => _buildSoulUpgradeRow(equipIds[index]),
    );
  }

  Widget _buildSoulUpgradeRow(SoulUpgradeId id) {
    final manager = widget.game.ascensionManager;
    final data = SoulUpgradeDatabase.get(id);
    final level = manager.getSoulLevel(id);
    final isMaxed = manager.isSoulMaxed(id);
    final cost = isMaxed ? 0 : manager.getSoulCost(id);
    final canBuy = manager.canAffordSoul(id);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isMaxed
              ? const Color(0xFF9C27B0).withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(data.name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    if (data.maxLevel > 1)
                      Text(
                        'Lv.$level${isMaxed ? " (MAX)" : "/${data.maxLevel}"}',
                        style: TextStyle(color: isMaxed ? const Color(0xFFCE93D8) : Colors.white70, fontSize: 12),
                      )
                    else if (isMaxed)
                      const Text('해금됨', style: TextStyle(color: Color(0xFFCE93D8), fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${data.description}  (${data.effectUnit})',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
          if (!isMaxed)
            GestureDetector(
              onTap: canBuy ? () => _buySoul(id) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: canBuy
                      ? const Color(0xFF9C27B0).withValues(alpha: 0.8)
                      : Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, color: Color(0xFFCE93D8), size: 13),
                    const SizedBox(width: 4),
                    Text(
                      '$cost',
                      style: TextStyle(
                        color: canBuy ? Colors.white : Colors.white38,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('MAX', style: TextStyle(color: Color(0xFFCE93D8), fontSize: 13, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: () => widget.game.closeSoulShop(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('닫기', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _buySoul(SoulUpgradeId id) {
    final cost = widget.game.ascensionManager.buySoulUpgrade(id);
    if (cost > 0) {
      widget.game.saveGame();
      setState(() {});
    }
  }
}
