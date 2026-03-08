import 'package:flutter/material.dart';
import '../game/runner_game.dart';
import '../data/upgrade_data.dart';

class UpgradeShop extends StatefulWidget {
  final RunnerGame game;

  const UpgradeShop({super.key, required this.game});

  @override
  State<UpgradeShop> createState() => _UpgradeShopState();
}

class _UpgradeShopState extends State<UpgradeShop> {
  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final manager = game.upgradeManager;

    return Material(
      color: Colors.black.withValues(alpha: 0.85),
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
                    '업그레이드',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.amber, size: 22),
                      const SizedBox(width: 4),
                      Text(
                        _formatNumber(game.coins),
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildCloseButton(),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),

            // Upgrade list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: UpgradeDatabase.upgrades.length,
                itemBuilder: (context, index) {
                  final data = UpgradeDatabase.upgrades[index];
                  final level = manager.getLevel(data.id);
                  final isMaxed = manager.isMaxed(data.id);
                  final cost = isMaxed ? 0.0 : manager.getCost(data.id);
                  final canBuy = manager.canAfford(data.id, game.coins);

                  return _buildUpgradeRow(data, level, isMaxed, cost, canBuy);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeRow(
    UpgradeData data,
    int level,
    bool isMaxed,
    double cost,
    bool canBuy,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isMaxed
              ? Colors.amber.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      data.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Lv.$level${isMaxed ? " (MAX)" : "/${data.maxLevel}"}',
                      style: TextStyle(
                        color: isMaxed ? Colors.amber : Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${data.description}  (${data.effectUnit}/lv)',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),

          // Buy button
          if (!isMaxed)
            GestureDetector(
              onTap: canBuy ? () => _buy(data.id) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: canBuy
                      ? Colors.green.withValues(alpha: 0.8)
                      : Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      _formatNumber(cost),
                      style: TextStyle(
                        color: canBuy ? Colors.white : Colors.white38,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'MAX',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: () {
        widget.game.toggleShop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          '닫기',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _buy(UpgradeId id) {
    final game = widget.game;
    final cost = game.upgradeManager.buy(id, game.coins);
    if (cost > 0) {
      game.coins -= cost;
      game.applyUpgrades();
      game.saveGame();
      setState(() {});
    }
  }

  String _formatNumber(double n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toInt().toString();
  }
}
