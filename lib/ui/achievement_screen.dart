import 'package:flutter/material.dart';
import 'game_theme.dart';
import '../game/defense_game.dart';
import '../systems/achievement_manager.dart';

/// Achievement list overlay — shows all achievements with progress.
class AchievementScreen extends StatelessWidget {
  final DefenseGame game;
  const AchievementScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final mgr = game.achievementManager;
    const allAchievements = AchievementDatabase.all;
    final completedCount = mgr.completedAchievements.length;

    return Material(
      color: GameTheme.bgDeep,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // ── Header ──
              _buildHeader(completedCount, allAchievements.length, mgr),
              const SizedBox(height: 12),
              // ── Achievement List ──
              Expanded(
                child: ListView.builder(
                  itemCount: allAchievements.length,
                  itemBuilder: (context, index) {
                    return StaggeredEntry(
                      index: index,
                      child: _buildAchievementCard(allAchievements[index], mgr),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              // ── Close Button ──
              GameTheme.pixelButton(
                label: '닫기',
                onTap: () => game.overlays.remove('Achievement'),
                color: GameTheme.bgPanel,
                fontSize: 9,
                verticalPad: 10,
                horizontalPad: 24,
                icon: Icons.close,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int completed, int total, AchievementManager mgr) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: GameTheme.pixelPanelDecoration(
        fillColor: GameTheme.bgCard,
        glow: true,
        glowColor: GameTheme.accentGold,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: GameTheme.accentGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(GameTheme.radiusSm),
                  border: Border.all(
                    color: GameTheme.accentGold.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: GameTheme.accentGold,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '업적',
                      style: GameTheme.pixel(
                        fontSize: 12,
                        color: GameTheme.accentGold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completed / $total 완료',
                      style: GameTheme.pixel(
                        fontSize: 7,
                        color: GameTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Total star reward earned
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: GameTheme.bgDeep.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(GameTheme.radiusSm),
                  border: Border.all(
                    color: GameTheme.accentGold.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '획득 보상',
                      style: GameTheme.pixel(
                        fontSize: 6,
                        color: GameTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: GameTheme.accentGold,
                          size: 12,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${mgr.totalStarReward}',
                          style: GameTheme.pixel(
                            fontSize: 9,
                            color: GameTheme.accentGold,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GameTheme.pixelProgressBar(
            value: mgr.completionPercent,
            height: 8,
            fillGradient: GameTheme.gradientGold,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(AchievementDef def, AchievementManager mgr) {
    final isComplete = mgr.isCompleted(def.id);
    final progress = mgr.getProgress(def.id);
    final progressFraction = (progress / def.target).clamp(0.0, 1.0);

    final cardColor = isComplete
        ? GameTheme.bgCard.withValues(alpha: 0.9)
        : GameTheme.bgDeep.withValues(alpha: 0.7);
    final borderColor = isComplete
        ? GameTheme.accentGold.withValues(alpha: 0.5)
        : GameTheme.pixelBorder;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: GameTheme.pixelCardDecoration(
        fillColor: cardColor,
        borderColor: borderColor,
        glow: isComplete,
        glowColor: GameTheme.accentGold,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: GameTheme.pixelCardDecoration(
              fillColor: isComplete
                  ? GameTheme.accentGold.withValues(alpha: 0.15)
                  : GameTheme.bgPanel,
            ),
            child: Text(
              def.icon,
              style: TextStyle(
                fontSize: 18,
                color: isComplete ? null : Colors.grey,
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
                    Expanded(
                      child: Text(
                        def.name,
                        style: GameTheme.pixel(
                          fontSize: 7,
                          color: isComplete
                              ? GameTheme.accentGold
                              : GameTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (isComplete)
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: GameTheme.accentGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: GameTheme.accentGreen,
                          size: 14,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  def.description,
                  style: GameTheme.pixel(
                    fontSize: 6,
                    color: GameTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: GameTheme.pixelProgressBar(
                        value: progressFraction,
                        height: 6,
                        fillColor: isComplete
                            ? GameTheme.accentGold
                            : GameTheme.accent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$progress / ${def.target}',
                      style: GameTheme.pixel(
                        fontSize: 5,
                        color: GameTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Reward
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: GameTheme.pixelCardDecoration(
              fillColor: isComplete
                  ? GameTheme.accentGold.withValues(alpha: 0.1)
                  : GameTheme.bgDeep,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: isComplete ? GameTheme.accentGold : GameTheme.textMuted,
                  size: 10,
                ),
                const SizedBox(width: 2),
                Text(
                  '${def.starReward}',
                  style: GameTheme.pixel(
                    fontSize: 6,
                    color: isComplete ? GameTheme.accentGold : GameTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
