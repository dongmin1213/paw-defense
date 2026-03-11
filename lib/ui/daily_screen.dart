import 'package:flutter/material.dart';
import 'game_theme.dart';
import '../game/defense_game.dart';

/// Daily reward + challenge screen — clean centered popup design.
class DailyScreen extends StatefulWidget {
  final DefenseGame game;
  const DailyScreen({super.key, required this.game});

  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  @override
  Widget build(BuildContext context) {
    final daily = widget.game.dailyManager;
    final streak = daily.streak;

    return Material(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Container(
          width: 340,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(20),
          decoration: GameTheme.pixelPanelDecoration(
            fillColor: GameTheme.bgPanel,
            glow: true,
            glowColor: GameTheme.accentGold.withValues(alpha: 0.2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('📅', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        '일일 보상',
                        style: GameTheme.pixel(
                          fontSize: 11,
                          color: GameTheme.accentGold,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  GameTheme.closeButton(onTap: () => widget.game.closeDaily()),
                ],
              ),
              const SizedBox(height: 20),

              // Streak
              Text(
                '출석 ${streak}일차',
                style: GameTheme.pixel(
                  fontSize: 9,
                  color: GameTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              // 7-day circles
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(7, (i) {
                  final dayNum = i + 1;
                  final dayInCycle = streak > 0 ? ((streak - 1) % 7) + 1 : 0;
                  final isCurrent = streak > 0 && dayNum == dayInCycle;
                  final isPast = streak > 0 && dayNum < dayInCycle;
                  return Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCurrent
                          ? GameTheme.accent
                          : isPast
                              ? GameTheme.accentGreenDark.withValues(alpha: 0.6)
                              : GameTheme.bgDeep,
                      border: Border.all(
                        color: isCurrent
                            ? Colors.white.withValues(alpha: 0.6)
                            : isPast
                                ? GameTheme.accentGreen.withValues(alpha: 0.4)
                                : GameTheme.pixelBorder.withValues(alpha: 0.3),
                        width: isCurrent ? 2 : 1,
                      ),
                      boxShadow: isCurrent
                          ? [BoxShadow(color: GameTheme.accent.withValues(alpha: 0.3), blurRadius: 8)]
                          : null,
                    ),
                    child: Center(
                      child: isPast && !isCurrent
                          ? const Icon(Icons.check, color: GameTheme.accentGreen, size: 14)
                          : Text(
                              '$dayNum',
                              style: TextStyle(
                                color: isCurrent ? Colors.white : GameTheme.textMuted,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Reward amount
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: GameTheme.accentGold.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(GameTheme.radiusSm),
                  border: Border.all(color: GameTheme.accentGold.withValues(alpha: 0.2)),
                ),
                child: Text(
                  '오늘의 보상: ⭐ ${daily.todayReward}',
                  style: GameTheme.pixel(
                    fontSize: 10,
                    color: GameTheme.accentGold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Claim button
              if (daily.hasUnclaimedReward)
                SizedBox(
                  width: double.infinity,
                  child: GameTheme.pixelButton(
                    label: '보상 받기!',
                    gradient: GameTheme.gradientGreen,
                    fontSize: 10,
                    verticalPad: 12,
                    onTap: () {
                      final reward = daily.claimDailyReward();
                      widget.game.stars += reward;
                      widget.game.totalStarsEarned += reward;
                      widget.game.saveGame();
                      setState(() {});
                    },
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: GameTheme.accentGreen.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(GameTheme.radiusSm),
                    border: Border.all(color: GameTheme.accentGreen.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: GameTheme.accentGreen, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '오늘 보상 수령 완료',
                        style: GameTheme.pixel(fontSize: 8, color: GameTheme.accentGreen),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),
              Container(height: 1, color: GameTheme.pixelBorder.withValues(alpha: 0.2)),
              const SizedBox(height: 14),

              // Daily Challenge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🎯', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    '오늘의 도전',
                    style: GameTheme.pixel(fontSize: 9, color: GameTheme.textPrimary, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '웨이브 ${daily.challengeTargetWave} 도달',
                style: GameTheme.pixel(fontSize: 10, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: (daily.challengeComplete ? GameTheme.accentGreen : GameTheme.accent)
                      .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  daily.challengeComplete
                      ? '✅ 완료! 보너스 ⭐ 획득됨'
                      : '보너스: ⭐ ${daily.challengeBonus}',
                  style: GameTheme.pixel(
                    fontSize: 7,
                    color: daily.challengeComplete ? GameTheme.accentGreen : GameTheme.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
