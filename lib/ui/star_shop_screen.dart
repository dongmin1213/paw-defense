import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game_theme.dart';
import '../game/defense_game.dart';

/// Permanent upgrade IDs for the star shop.
enum DefenseUpgradeId {
  wallHp,
  wallArmor,
  wallRegen,
  unitDamage,
  unitSpeed,
  unitRange,
  goldBonus,
  startGold,
  unitSlot,
  critChance,
  critDamage,
  waveBonus,
}

/// Data definition for a permanent upgrade.
class DefenseUpgradeData {
  final DefenseUpgradeId id;
  final String name;
  final String description;
  final String icon;
  final String category; // '성벽', '유닛', '경제', '특수'
  final int maxLevel;
  final int baseCost;
  final double costMultiplier;

  const DefenseUpgradeData({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.maxLevel,
    required this.baseCost,
    this.costMultiplier = 1.5,
  });

  int costAt(int level) {
    if (level >= maxLevel) return 0;
    return (baseCost * (costMultiplier * level + 1)).round();
  }
}

/// Database of all permanent upgrades.
class DefenseUpgradeDatabase {
  static const List<DefenseUpgradeData> all = [
    DefenseUpgradeData(
      id: DefenseUpgradeId.wallHp,
      name: '성벽 체력',
      description: '성벽 최대 HP +10%',
      icon: '🏰',
      category: '성벽',
      maxLevel: 20,
      baseCost: 5,
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.wallArmor,
      name: '성벽 방어',
      description: '받는 피해 -5%',
      icon: '🛡️',
      category: '성벽',
      maxLevel: 15,
      baseCost: 8,
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.wallRegen,
      name: '성벽 재생',
      description: '성벽 자동 회복 +1/s',
      icon: '💚',
      category: '성벽',
      maxLevel: 10,
      baseCost: 12,
      costMultiplier: 2.0,
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.unitDamage,
      name: '유닛 공격력',
      description: '전체 유닛 공격력 +8%',
      icon: '⚔️',
      category: '유닛',
      maxLevel: 25,
      baseCost: 5,
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.unitSpeed,
      name: '공격 속도',
      description: '전체 유닛 공격 속도 +5%',
      icon: '⚡',
      category: '유닛',
      maxLevel: 20,
      baseCost: 6,
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.unitRange,
      name: '사거리',
      description: '전체 유닛 사거리 +10%',
      icon: '🎯',
      category: '유닛',
      maxLevel: 15,
      baseCost: 7,
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.goldBonus,
      name: '골드 보너스',
      description: '골드 획득량 +10%',
      icon: '💰',
      category: '경제',
      maxLevel: 20,
      baseCost: 4,
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.startGold,
      name: '시작 골드',
      description: '게임 시작 시 +50 골드',
      icon: '🪙',
      category: '경제',
      maxLevel: 10,
      baseCost: 10,
      costMultiplier: 1.8,
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.unitSlot,
      name: '유닛 슬롯',
      description: '배치 가능 유닛 +1',
      icon: '📦',
      category: '특수',
      maxLevel: 5,
      baseCost: 20,
      costMultiplier: 3.0,
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.critChance,
      name: '치명타 확률',
      description: '치명타 확률 +3%',
      icon: '💥',
      category: '특수',
      maxLevel: 15,
      baseCost: 8,
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.critDamage,
      name: '치명타 피해',
      description: '치명타 피해 +15%',
      icon: '🔥',
      category: '특수',
      maxLevel: 10,
      baseCost: 10,
      costMultiplier: 2.0,
    ),
    DefenseUpgradeData(
      id: DefenseUpgradeId.waveBonus,
      name: '웨이브 보너스',
      description: '웨이브 클리어 시 추가 별 +1',
      icon: '⭐',
      category: '경제',
      maxLevel: 5,
      baseCost: 15,
      costMultiplier: 2.5,
    ),
  ];

  static List<DefenseUpgradeData> byCategory(String category) {
    return all.where((u) => u.category == category).toList();
  }
}

/// Star shop screen for between-run permanent upgrades.
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

  // Simulated upgrade levels (in real game, read from DefenseUpgradeManager)
  final Map<DefenseUpgradeId, int> _levels = {
    for (final id in DefenseUpgradeId.values) id: 0,
  };

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

  int _getLevel(DefenseUpgradeId id) => _levels[id] ?? 0;

  bool _canAfford(DefenseUpgradeData data) {
    final level = _getLevel(data.id);
    if (level >= data.maxLevel) return false;
    return widget.game.stars >= data.costAt(level);
  }

  void _buyUpgrade(DefenseUpgradeData data) {
    final level = _getLevel(data.id);
    if (level >= data.maxLevel) return;
    final cost = data.costAt(level);
    if (widget.game.stars < cost) return;

    setState(() {
      _levels[data.id] = level + 1;
      // In real implementation: widget.game.spendStars(cost);
    });
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
    final level = _getLevel(data.id);
    final isMaxed = level >= data.maxLevel;
    final cost = isMaxed ? 0 : data.costAt(level);
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
