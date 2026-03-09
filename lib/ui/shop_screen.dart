import 'package:flutter/material.dart';
import '../data/game_data.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  @override
  Widget build(BuildContext context) {
    final data = GameData.instance;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'SHOP',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.monetization_on, color: Colors.amber, size: 22),
                  const SizedBox(width: 6),
                  Text(
                    '${data.totalCoins}',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
            // Upgrade grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ListView(
                  children: GameData.upgrades.entries.map((entry) {
                    return _UpgradeCard(
                      upgradeKey: entry.key,
                      def: entry.value,
                      currentLevel: data.getUpgradeLevel(entry.key),
                      cost: data.getUpgradeCost(entry.key),
                      canAfford: data.canAffordUpgrade(entry.key),
                      onBuy: () async {
                        final success = await data.buyUpgrade(entry.key);
                        if (success) setState(() {});
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpgradeCard extends StatelessWidget {
  final String upgradeKey;
  final UpgradeDef def;
  final int currentLevel;
  final int cost;
  final bool canAfford;
  final VoidCallback onBuy;

  const _UpgradeCard({
    required this.upgradeKey,
    required this.def,
    required this.currentLevel,
    required this.cost,
    required this.canAfford,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final isMaxed = currentLevel >= def.maxLevel;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMaxed ? Colors.amber.withValues(alpha: 0.3) : Colors.white12,
        ),
      ),
      child: Row(
        children: [
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  def.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  def.description,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 6),
                // Level pips
                Row(
                  children: List.generate(def.maxLevel, (i) {
                    return Container(
                      width: 16,
                      height: 6,
                      margin: const EdgeInsets.only(right: 3),
                      decoration: BoxDecoration(
                        color: i < currentLevel ? Colors.amber : Colors.white12,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          // Buy button
          if (isMaxed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'MAX',
                style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
              ),
            )
          else
            GestureDetector(
              onTap: canAfford ? onBuy : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: canAfford
                      ? Colors.amber.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: canAfford ? Colors.amber : Colors.white12,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: canAfford ? Colors.amber : Colors.white30,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$cost',
                      style: TextStyle(
                        color: canAfford ? Colors.amber : Colors.white30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
