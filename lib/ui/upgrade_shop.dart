import 'package:flutter/material.dart';
import '../game/runner_game.dart';
import '../data/upgrade_data.dart';
import 'game_theme.dart';

class UpgradeShop extends StatefulWidget {
  final RunnerGame game;
  const UpgradeShop({super.key, required this.game});

  @override
  State<UpgradeShop> createState() => _UpgradeShopState();
}

class _UpgradeShopState extends State<UpgradeShop>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _slideUp;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideUp = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final manager = game.upgradeManager;

    return AnimatedBuilder(
      animation: _entryController,
      builder: (context, _) {
        return Material(
          color: GameTheme.bgDeep.withValues(alpha: 0.92 * _fade.value),
          child: Transform.translate(
            offset: Offset(0, _slideUp.value),
            child: Opacity(
              opacity: _fade.value,
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
                              color: GameTheme.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.shopping_bag_rounded,
                                color: GameTheme.accent, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('업그레이드',
                                  style: GameTheme.titleMedium
                                      .copyWith(fontSize: 20)),
                              Text(
                                '능력을 강화하여 더 빠르게 성장하세요',
                                style: GameTheme.bodySmall,
                              ),
                            ],
                          ),
                          const Spacer(),
                          GameTheme.currencyDisplay(
                            value: GameTheme.formatNumber(game.coins),
                          ),
                          const SizedBox(width: 8),
                          GameTheme.closeButton(
                              onTap: () => game.toggleShop()),
                        ],
                      ),
                    ),

                    // 구분선
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      color: GameTheme.accent.withValues(alpha: 0.1),
                    ),

                    // ── 업그레이드 리스트 ──
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                        itemCount: UpgradeDatabase.upgrades.length,
                        itemBuilder: (context, index) {
                          final data = UpgradeDatabase.upgrades[index];
                          final level = manager.getLevel(data.id);
                          final isMaxed = manager.isMaxed(data.id);
                          final cost =
                              isMaxed ? 0.0 : manager.getCost(data.id);
                          final canBuy =
                              manager.canAfford(data.id, game.coins);

                          return _UpgradeCard(
                            data: data,
                            level: level,
                            isMaxed: isMaxed,
                            cost: cost,
                            canBuy: canBuy,
                            onBuy: () => _buy(data.id),
                            delayMs: index * 50,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
}

class _UpgradeCard extends StatelessWidget {
  final UpgradeData data;
  final int level;
  final bool isMaxed;
  final double cost;
  final bool canBuy;
  final VoidCallback onBuy;
  final int delayMs;

  const _UpgradeCard({
    required this.data,
    required this.level,
    required this.isMaxed,
    required this.cost,
    required this.canBuy,
    required this.onBuy,
    this.delayMs = 0,
  });

  IconData get _upgradeIcon {
    switch (data.id) {
      case UpgradeId.moveSpeed:
        return Icons.speed;
      case UpgradeId.coinGain:
        return Icons.monetization_on;
      case UpgradeId.attackPower:
        return Icons.flash_on;
      case UpgradeId.jumpPower:
        return Icons.arrow_upward;
      case UpgradeId.doubleJump:
        return Icons.flip;
      case UpgradeId.coinMagnet:
        return Icons.magnet_outlined;
      case UpgradeId.comboRetain:
        return Icons.whatshot;
    }
  }

  Color get _upgradeColor {
    switch (data.id) {
      case UpgradeId.moveSpeed:
        return const Color(0xFF4FC3F7);
      case UpgradeId.coinGain:
        return const Color(0xFFFFD54F);
      case UpgradeId.attackPower:
        return const Color(0xFFEF5350);
      case UpgradeId.jumpPower:
        return const Color(0xFF66BB6A);
      case UpgradeId.doubleJump:
        return const Color(0xFF81C784);
      case UpgradeId.coinMagnet:
        return const Color(0xFFBA68C8);
      case UpgradeId.comboRetain:
        return const Color(0xFFFF9800);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = data.maxLevel > 1 ? level / data.maxLevel : (isMaxed ? 1.0 : 0.0);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isMaxed
            ? _upgradeColor.withValues(alpha: 0.08)
            : GameTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMaxed
              ? _upgradeColor.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          // 아이콘
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _upgradeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_upgradeIcon, color: _upgradeColor, size: 20),
          ),
          const SizedBox(width: 10),

          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(data.name,
                        style: GameTheme.labelBold.copyWith(fontSize: 14)),
                    const SizedBox(width: 6),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: isMaxed
                            ? _upgradeColor.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isMaxed ? 'MAX' : 'Lv.$level/${data.maxLevel}',
                        style: TextStyle(
                          color: isMaxed ? _upgradeColor : GameTheme.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${data.description}  (${data.effectUnit}/lv)',
                  style: GameTheme.bodySmall.copyWith(fontSize: 11),
                ),
                if (data.maxLevel > 1) ...[
                  const SizedBox(height: 4),
                  GameTheme.progressBar(
                    value: progress,
                    height: 3,
                    fillColor: _upgradeColor,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),

          // 구매 버튼
          if (!isMaxed)
            GestureDetector(
              onTap: canBuy ? onBuy : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: canBuy ? GameTheme.gradientGreen : null,
                  color: canBuy ? null : GameTheme.bgCard,
                  borderRadius: BorderRadius.circular(10),
                  border: canBuy
                      ? null
                      : Border.all(
                          color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.monetization_on,
                        color: canBuy
                            ? GameTheme.accentGold
                            : GameTheme.textMuted,
                        size: 14),
                    const SizedBox(width: 4),
                    Text(
                      GameTheme.formatNumber(cost),
                      style: TextStyle(
                        color: canBuy ? Colors.white : GameTheme.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _upgradeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: _upgradeColor.withValues(alpha: 0.3)),
              ),
              child: Icon(Icons.check, color: _upgradeColor, size: 18),
            ),
        ],
      ),
    );
  }
}
