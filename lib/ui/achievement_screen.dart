import 'package:flutter/material.dart';
import '../game/runner_game.dart';
import '../data/achievement_data.dart';
import 'game_theme.dart';

class AchievementScreen extends StatefulWidget {
  final RunnerGame game;
  const AchievementScreen({super.key, required this.game});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  AchievementCategory _selectedCategory = AchievementCategory.combat;

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
    final manager = widget.game.achievementManager;

    return AnimatedBuilder(
      animation: _entryController,
      builder: (context, _) {
        final fade = _entryController.value;
        return Material(
          color: GameTheme.bgDeep.withValues(alpha: 0.95 * fade),
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
                            color: GameTheme.accentGold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.emoji_events_rounded,
                              color: GameTheme.accentGold, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('업적',
                                style: GameTheme.titleMedium
                                    .copyWith(fontSize: 20, color: GameTheme.accentGold)),
                            Text(
                              '${manager.completedCount}/${manager.totalCount} 달성 (${(manager.completionPercent * 100).toStringAsFixed(0)}%)',
                              style: GameTheme.bodySmall,
                            ),
                          ],
                        ),
                        const Spacer(),
                        // 진행률 바
                        SizedBox(
                          width: 100,
                          child: Column(
                            children: [
                              GameTheme.progressBar(
                                value: manager.completionPercent,
                                height: 6,
                                fillGradient: GameTheme.gradientGold,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${manager.completedCount}/${manager.totalCount}',
                                style: GameTheme.bodySmall.copyWith(fontSize: 9),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        GameTheme.closeButton(
                          onTap: () => widget.game.closeAchievementScreen(),
                        ),
                      ],
                    ),
                  ),

                  // ── 카테고리 탭 ──
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: AchievementCategory.values.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        final count = AchievementDatabase.getByCategory(cat).length;
                        final done = AchievementDatabase.getByCategory(cat)
                            .where((a) => manager.isCompleted(a.id))
                            .length;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedCategory = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? GameTheme.accentGold.withValues(alpha: 0.2)
                                    : GameTheme.bgCard,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? GameTheme.accentGold.withValues(alpha: 0.5)
                                      : Colors.white.withValues(alpha: 0.05),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_categoryIcon(cat),
                                      color: isSelected ? GameTheme.accentGold : GameTheme.textMuted,
                                      size: 14),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${_categoryName(cat)} $done/$count',
                                    style: TextStyle(
                                      color: isSelected ? GameTheme.accentGold : GameTheme.textMuted,
                                      fontSize: 11,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // ── 업적 리스트 ──
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                      itemCount: AchievementDatabase.getByCategory(_selectedCategory).length,
                      itemBuilder: (context, index) {
                        final achievement = AchievementDatabase.getByCategory(_selectedCategory)[index];
                        final isCompleted = manager.isCompleted(achievement.id);
                        return _AchievementCard(
                          data: achievement,
                          isCompleted: isCompleted,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _categoryName(AchievementCategory cat) {
    switch (cat) {
      case AchievementCategory.combat:
        return '전투';
      case AchievementCategory.economy:
        return '경제';
      case AchievementCategory.progress:
        return '진행';
      case AchievementCategory.collection:
        return '수집';
      case AchievementCategory.special:
        return '특수';
    }
  }

  IconData _categoryIcon(AchievementCategory cat) {
    switch (cat) {
      case AchievementCategory.combat:
        return Icons.flash_on;
      case AchievementCategory.economy:
        return Icons.monetization_on;
      case AchievementCategory.progress:
        return Icons.trending_up;
      case AchievementCategory.collection:
        return Icons.collections_bookmark;
      case AchievementCategory.special:
        return Icons.star;
    }
  }
}

class _AchievementCard extends StatelessWidget {
  final AchievementData data;
  final bool isCompleted;

  const _AchievementCard({required this.data, required this.isCompleted});

  IconData _getIcon(IconType type) {
    switch (type) {
      case IconType.star:
        return Icons.star;
      case IconType.sword:
        return Icons.flash_on;
      case IconType.coin:
        return Icons.monetization_on;
      case IconType.run:
        return Icons.directions_run;
      case IconType.trophy:
        return Icons.emoji_events;
      case IconType.fire:
        return Icons.whatshot;
      case IconType.pet:
        return Icons.pets;
      case IconType.crown:
        return Icons.workspace_premium;
      case IconType.magic:
        return Icons.auto_awesome;
      case IconType.shield:
        return Icons.shield;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSoul = data.soulReward > 0;
    final borderColor = isCompleted
        ? (hasSoul ? GameTheme.accentPurple : GameTheme.accentGold)
        : Colors.white.withValues(alpha: 0.04);
    final bgColor = isCompleted
        ? (hasSoul
            ? GameTheme.accentPurple.withValues(alpha: 0.08)
            : GameTheme.accentGold.withValues(alpha: 0.06))
        : GameTheme.bgCard;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: isCompleted ? 1.2 : 0.8),
      ),
      child: Row(
        children: [
          // 아이콘
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isCompleted
                  ? GameTheme.accentGold.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getIcon(data.iconType),
              color: isCompleted ? GameTheme.accentGold : GameTheme.textMuted,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),

          // 텍스트
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      data.name,
                      style: GameTheme.labelBold.copyWith(
                        fontSize: 13,
                        color: isCompleted ? GameTheme.textPrimary : GameTheme.textSecondary,
                      ),
                    ),
                    if (isCompleted) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.check_circle, color: GameTheme.accentGreen, size: 14),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  data.description,
                  style: GameTheme.bodySmall.copyWith(
                    fontSize: 10,
                    color: isCompleted ? GameTheme.textSecondary : GameTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // 보상
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (data.coinReward > 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.monetization_on,
                        color: isCompleted ? GameTheme.accentGold.withValues(alpha: 0.5) : GameTheme.accentGold,
                        size: 12),
                    const SizedBox(width: 3),
                    Text(
                      GameTheme.formatNumber(data.coinReward),
                      style: TextStyle(
                        color: isCompleted ? GameTheme.textMuted : GameTheme.accentGold,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              if (hasSoul)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome,
                          color: isCompleted ? GameTheme.accentPurple.withValues(alpha: 0.5) : GameTheme.accentPurple,
                          size: 12),
                      const SizedBox(width: 3),
                      Text(
                        '${data.soulReward}',
                        style: TextStyle(
                          color: isCompleted ? GameTheme.textMuted : GameTheme.accentPurple,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
