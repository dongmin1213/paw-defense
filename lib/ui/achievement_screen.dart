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

  void _animatedClose() {
    _entryController.reverse().then((_) {
      if (mounted) widget.game.closeAchievementScreen();
    });
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
                              fillColor: GameTheme.accentGold
                                  .withValues(alpha: 0.15),
                              borderColor: GameTheme.accentGold
                                  .withValues(alpha: 0.3),
                            ),
                            child: const Icon(
                                Icons.emoji_events_rounded,
                                color: GameTheme.accentGold,
                                size: 20),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ACHIEVEMENT',
                                  style: GameTheme.pixel(
                                      fontSize: 12,
                                      color: GameTheme.accentGold)),
                              Text(
                                '${manager.completedCount}/${manager.totalCount} (${(manager.completionPercent * 100).toStringAsFixed(0)}%)',
                                style: GameTheme.pixel(
                                    fontSize: 6,
                                    color: GameTheme.textMuted),
                              ),
                            ],
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 100,
                            child: Column(
                              children: [
                                GameTheme.pixelProgressBar(
                                  value: manager.completionPercent,
                                  height: 8,
                                  fillGradient: GameTheme.gradientGold,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${manager.completedCount}/${manager.totalCount}',
                                  style: GameTheme.pixel(
                                      fontSize: 5,
                                      color: GameTheme.textMuted),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          GameTheme.closeButton(
                            onTap: () =>
                                _animatedClose(),
                          ),
                        ],
                      ),
                    ),

                    // ── 카테고리 탭 ──
                    SizedBox(
                      height: 36,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        children:
                            AchievementCategory.values.map((cat) {
                          final isSelected = _selectedCategory == cat;
                          final count = AchievementDatabase.getByCategory(
                                  cat)
                              .length;
                          final done = AchievementDatabase.getByCategory(
                                  cat)
                              .where(
                                  (a) => manager.isCompleted(a.id))
                              .length;
                          return Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: GestureDetector(
                              onTap: () => setState(
                                  () => _selectedCategory = cat),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 5),
                                decoration:
                                    GameTheme.pixelCardDecoration(
                                  fillColor: isSelected
                                      ? GameTheme.accentGold
                                          .withValues(alpha: 0.2)
                                      : GameTheme.bgCard,
                                  borderColor: isSelected
                                      ? GameTheme.accentGold
                                          .withValues(alpha: 0.5)
                                      : GameTheme.pixelBorder,
                                  selected: isSelected,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(_categoryIcon(cat),
                                        color: isSelected
                                            ? GameTheme.accentGold
                                            : GameTheme.textMuted,
                                        size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${_categoryName(cat)} $done/$count',
                                      style: GameTheme.pixel(
                                        fontSize: 6,
                                        color: isSelected
                                            ? GameTheme.accentGold
                                            : GameTheme.textMuted,
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
                        padding:
                            const EdgeInsets.fromLTRB(12, 4, 12, 16),
                        itemCount: AchievementDatabase.getByCategory(
                                _selectedCategory)
                            .length,
                        itemBuilder: (context, index) {
                          final achievement =
                              AchievementDatabase.getByCategory(
                                  _selectedCategory)[index];
                          final isCompleted =
                              manager.isCompleted(achievement.id);
                          return StaggeredEntry(
                            index: index,
                            child: _AchievementCard(
                              data: achievement,
                              isCompleted: isCompleted,
                            ),
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

  const _AchievementCard(
      {required this.data, required this.isCompleted});

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
    final accentColor = isCompleted
        ? (hasSoul ? GameTheme.accentPurple : GameTheme.accentGold)
        : GameTheme.pixelBorder;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.all(8),
      decoration: GameTheme.pixelCardDecoration(
        fillColor: isCompleted
            ? (hasSoul
                ? GameTheme.accentPurple.withValues(alpha: 0.08)
                : GameTheme.accentGold.withValues(alpha: 0.06))
            : GameTheme.bgCard,
        borderColor: accentColor,
        glow: isCompleted,
        glowColor: accentColor,
      ),
      child: Row(
        children: [
          // 아이콘
          Container(
            width: 34,
            height: 34,
            decoration: GameTheme.pixelCardDecoration(
              fillColor: isCompleted
                  ? GameTheme.accentGold.withValues(alpha: 0.2)
                  : GameTheme.bgDeep,
              borderColor: isCompleted
                  ? GameTheme.accentGold.withValues(alpha: 0.4)
                  : GameTheme.pixelBorder,
            ),
            child: Icon(
              _getIcon(data.iconType),
              color: isCompleted
                  ? GameTheme.accentGold
                  : GameTheme.textMuted,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),

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
                        fontSize: 12,
                        color: isCompleted
                            ? GameTheme.textPrimary
                            : GameTheme.textSecondary,
                      ),
                    ),
                    if (isCompleted) ...[
                      const SizedBox(width: 5),
                      Container(
                        width: 12,
                        height: 12,
                        color: GameTheme.accentGreen,
                        child: const Icon(Icons.check,
                            color: Colors.white, size: 10),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  data.description,
                  style: GameTheme.bodySmall.copyWith(
                    fontSize: 9,
                    color: isCompleted
                        ? GameTheme.textSecondary
                        : GameTheme.textMuted,
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
                        color: isCompleted
                            ? GameTheme.accentGold
                                .withValues(alpha: 0.5)
                            : GameTheme.accentGold,
                        size: 11),
                    const SizedBox(width: 3),
                    Text(
                      GameTheme.formatNumber(data.coinReward),
                      style: GameTheme.pixel(
                        fontSize: 6,
                        color: isCompleted
                            ? GameTheme.textMuted
                            : GameTheme.accentGold,
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
                          color: isCompleted
                              ? GameTheme.accentPurple
                                  .withValues(alpha: 0.5)
                              : GameTheme.accentPurple,
                          size: 11),
                      const SizedBox(width: 3),
                      Text(
                        '${data.soulReward}',
                        style: GameTheme.pixel(
                          fontSize: 6,
                          color: isCompleted
                              ? GameTheme.textMuted
                              : GameTheme.accentPurple,
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
