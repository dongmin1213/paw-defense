import 'package:flutter/material.dart';
import 'game_theme.dart';
import '../game/defense_game.dart';

/// Daily reward + challenge screen overlay.
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
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(16),
          decoration: GameTheme.pixelPanelDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '📅 일일 보상',
                    style: GameTheme.pixel(
                      fontSize: 12,
                      color: GameTheme.accentGold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => widget.game.closeDaily(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        '✕',
                        style: GameTheme.pixel(
                          fontSize: 12,
                          color: GameTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Streak circles (7 days)
              Text(
                '출석 ${streak}일차',
                style: GameTheme.pixel(
                  fontSize: 9,
                  color: GameTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(7, (i) {
                  final dayNum = i + 1;
                  final isCurrent = (streak % 7 == dayNum) ||
                      (streak % 7 == 0 && dayNum == 7);
                  final isPast = dayNum < (streak % 7 == 0 ? 8 : streak % 7);
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCurrent
                          ? const Color(0xFF4FC3F7)
                          : isPast
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFF333355),
                      border: Border.all(
                        color: isCurrent
                            ? Colors.white
                            : Colors.white24,
                        width: isCurrent ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$dayNum',
                        style: TextStyle(
                          color: isCurrent || isPast
                              ? Colors.white
                              : Colors.white38,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),

              // Reward
              Text(
                '오늘의 보상: ⭐ ${daily.todayReward}',
                style: const TextStyle(
                  color: Color(0xFFFFD54F),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Claim button
              if (daily.hasUnclaimedReward)
                GameTheme.pixelButton(
                  label: '보상 받기!',
                  gradient: GameTheme.gradientGreen,
                  onTap: () {
                    final reward = daily.claimDailyReward();
                    widget.game.stars += reward;
                    widget.game.totalStarsEarned += reward;
                    widget.game.saveGame();
                    setState(() {});
                  },
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '✅ 오늘 보상 수령 완료',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ),

              const SizedBox(height: 20),
              const Divider(color: Colors.white24),
              const SizedBox(height: 12),

              // Daily Challenge
              Text(
                '🎯 오늘의 도전',
                style: GameTheme.pixel(
                  fontSize: 9,
                  color: GameTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '웨이브 ${daily.challengeTargetWave} 도달',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                daily.challengeComplete
                    ? '✅ 완료! 보너스 ⭐ 획득됨'
                    : '보너스: ⭐ ${daily.challengeBonus}',
                style: TextStyle(
                  color: daily.challengeComplete
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF4FC3F7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
