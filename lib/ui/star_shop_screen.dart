import 'package:flutter/material.dart';
import 'game_theme.dart';
import '../game/defense_game.dart';
import '../systems/defense_upgrade_manager.dart';

/// Star shop screen for between-run permanent upgrades.
/// Uses the real DefenseUpgradeManager for purchase logic.
class StarShopScreen extends StatefulWidget {
  final DefenseGame game;
  const StarShopScreen({super.key, required this.game});

  @override
  State<StarShopScreen> createState() => _StarShopScreenState();
}

class _StarShopScreenState extends State<StarShopScreen>
    with SingleTickerProviderStateMixin {
  static const _categories = ['성벽', '유닛', '경제', '특수'];
  int _selectedCategory = 0;

  late AnimationController _entryController;
  late Animation<double> _entryAnim;

  DefenseUpgradeManager get _mgr => widget.game.upgradeManager;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _entryAnim = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    );
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  bool _canAfford(DefenseUpgradeData data) {
    return _mgr.canAfford(data.id, widget.game.stars);
  }

  void _buyUpgrade(DefenseUpgradeData data) {
    final cost = _mgr.buy(data.id, widget.game.stars);
    if (cost > 0) {
      setState(() {
        widget.game.stars -= cost;
        widget.game.saveGame();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _entryController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 40 * (1 - _entryAnim.value)),
            child: Opacity(
              opacity: _entryAnim.value.clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: GameTheme.gradientDark,
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 8),
                _buildCategoryTabs(),
                const SizedBox(height: 8),
                Expanded(child: _buildUpgradeList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Text(
            '영구 업그레이드',
            style: GameTheme.pixel(
              fontSize: 12,
              color: GameTheme.accentGold,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          GameTheme.pixelCurrency(
            value: GameTheme.formatInt(widget.game.stars),
            isSoul: true,
          ),
          const SizedBox(width: 8),
          GameTheme.closeButton(
            onTap: () => widget.game.closeStarShop(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: List.generate(_categories.length, (i) {
          final isSelected = _selectedCategory == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = i),
              child: Container(
                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                decoration: GameTheme.pixelCardDecoration(
                  fillColor: isSelected
                      ? GameTheme.accent.withValues(alpha: 0.2)
                      : GameTheme.bgDeep,
                  borderColor: isSelected
                      ? GameTheme.accent
                      : GameTheme.pixelBorder,
                  selected: isSelected,
                ),
                child: Center(
                  child: Text(
                    _categories[i],
                    style: GameTheme.pixel(
                      fontSize: 7,
                      color: isSelected
                          ? GameTheme.accent
                          : GameTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildUpgradeList() {
    final category = _categories[_selectedCategory];
    final upgrades = DefenseUpgradeDatabase.byCategory(category);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      itemCount: upgrades.length,
      itemBuilder: (context, index) {
        return StaggeredEntry(
          index: index,
          child: _buildUpgradeCard(upgrades[index]),
        );
      },
    );
  }

  Widget _buildUpgradeCard(DefenseUpgradeData data) {
    final level = _mgr.getLevel(data.id);
    final isMaxed = _mgr.isMaxed(data.id);
    final cost = isMaxed ? 0 : _mgr.getCost(data.id);
    final canAfford = _canAfford(data);
    final progress = level / data.maxLevel;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: GameTheme.pixelCardDecoration(
        fillColor: GameTheme.bgCard,
        glow: isMaxed,
        glowColor: GameTheme.accentGold,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: GameTheme.pixelCardDecoration(
              fillColor: GameTheme.bgDeep,
            ),
            child: Center(
              child: Text(
                data.icon,
                style: const TextStyle(fontSize: 20),
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
                    Text(
                      data.name,
                      style: GameTheme.pixel(
                        fontSize: 8,
                        color: GameTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Lv.$level/${data.maxLevel}',
                      style: GameTheme.pixel(
                        fontSize: 6,
                        color: isMaxed
                            ? GameTheme.accentGold
                            : GameTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  data.description,
                  style: TextStyle(
                    color: GameTheme.textMuted,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                GameTheme.pixelProgressBar(
                  value: progress,
                  height: 6,
                  fillColor: isMaxed
                      ? GameTheme.accentGold
                      : GameTheme.accentGreen,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Buy button
          isMaxed
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: GameTheme.gradientGold,
                  ),
                  child: Text(
                    'MAX',
                    style: GameTheme.pixel(
                      fontSize: 7,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GameTheme.pixelButton(
                      label: '구매',
                      onTap: canAfford ? () => _buyUpgrade(data) : null,
                      gradient: canAfford ? GameTheme.gradientPrimary : null,
                      fontSize: 7,
                      verticalPad: 6,
                      horizontalPad: 12,
                      enabled: canAfford,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: canAfford
                              ? GameTheme.accentPurple
                              : GameTheme.textMuted,
                          size: 10,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          GameTheme.formatInt(cost),
                          style: GameTheme.pixel(
                            fontSize: 6,
                            color: canAfford
                                ? GameTheme.accentPurple
                                : GameTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
