import 'package:flutter/material.dart';
import '../game/runner_game.dart';
import '../systems/daily_bonus_manager.dart';
import 'game_theme.dart';

class DailyBonusPopup extends StatefulWidget {
  final RunnerGame game;
  const DailyBonusPopup({super.key, required this.game});

  @override
  State<DailyBonusPopup> createState() => _DailyBonusPopupState();
}

class _DailyBonusPopupState extends State<DailyBonusPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;
  bool _claimed = false;
  DailyClaimResult? _result;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final daily = widget.game.dailyBonusManager;
    final reward = daily.currentReward;
    final streak = daily.streak;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Material(
          color: Colors.black.withValues(alpha: 0.7 * _fade.value),
          child: Center(
            child: Transform.scale(
              scale: _scale.value,
              child: Opacity(
                opacity: _fade.value,
                child: Container(
                  width: 340,
                  padding: const EdgeInsets.all(20),
                  decoration: GameTheme.panelDecoration(
                    borderColor: GameTheme.accentGold.withValues(alpha: 0.3),
                    borderRadius: 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 타이틀
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              color: GameTheme.accentGold, size: 24),
                          const SizedBox(width: 8),
                          Text('일일 보너스',
                              style: GameTheme.titleMedium.copyWith(
                                  color: GameTheme.accentGold)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('연속 출석: ${streak > 0 ? streak : 1}일째',
                          style: GameTheme.bodySmall),
                      const SizedBox(height: 16),

                      // 7일 캘린더
                      _buildDayCalendar(daily),

                      const SizedBox(height: 16),

                      // 보상 표시
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: GameTheme.cardDecoration(
                          borderColor: GameTheme.accentGold.withValues(alpha: 0.2),
                          glow: true,
                          glowColor: GameTheme.accentGold,
                        ),
                        child: Column(
                          children: [
                            Text(
                              _claimed ? '보상 수령 완료!' : '오늘의 보상',
                              style: GameTheme.labelBold.copyWith(
                                color: _claimed ? GameTheme.accentGreen : GameTheme.accentGold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.monetization_on,
                                    color: GameTheme.accentGold, size: 22),
                                const SizedBox(width: 6),
                                Text(
                                  _claimed
                                      ? GameTheme.formatNumber(_result!.coins)
                                      : '${reward.coins}',
                                  style: GameTheme.numberLarge.copyWith(fontSize: 24),
                                ),
                                if (reward.souls > 0) ...[
                                  const SizedBox(width: 16),
                                  Icon(Icons.auto_awesome,
                                      color: GameTheme.accentPurple, size: 20),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+${reward.souls}',
                                    style: TextStyle(
                                      color: GameTheme.accentPurple,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 버튼
                      if (!_claimed)
                        GameTheme.gameButton(
                          label: '받기',
                          icon: Icons.card_giftcard,
                          onTap: _claim,
                          gradient: GameTheme.gradientGold,
                          fontSize: 18,
                          horizontalPad: 40,
                        )
                      else
                        GameTheme.gameButton(
                          label: '확인',
                          onTap: () => widget.game.closeDailyBonus(),
                          gradient: GameTheme.gradientPrimary,
                          fontSize: 16,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayCalendar(DailyBonusManager daily) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (i) {
        final day = i + 1;
        final reward = DailyBonusManager.rewards[i];
        final isClaimed = daily.streak >= day && daily.hasClaimed;
        final isToday = !_claimed && ((daily.streak % 7) + 1 == day || (daily.streak == 0 && day == 1));

        Color bg;
        Color border;
        Color textColor;
        if (isClaimed) {
          bg = GameTheme.accentGreen.withValues(alpha: 0.2);
          border = GameTheme.accentGreen.withValues(alpha: 0.5);
          textColor = GameTheme.accentGreen;
        } else if (isToday) {
          bg = GameTheme.accentGold.withValues(alpha: 0.15);
          border = GameTheme.accentGold.withValues(alpha: 0.5);
          textColor = GameTheme.accentGold;
        } else {
          bg = GameTheme.bgCard;
          border = Colors.white.withValues(alpha: 0.04);
          textColor = GameTheme.textMuted;
        }

        return Container(
          width: 38,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: border, width: isToday ? 1.5 : 1),
          ),
          child: Column(
            children: [
              Text('$day일', style: TextStyle(
                color: textColor, fontSize: 9, fontWeight: FontWeight.w700,
              )),
              const SizedBox(height: 3),
              if (isClaimed)
                Icon(Icons.check, color: GameTheme.accentGreen, size: 14)
              else
                Icon(
                  reward.souls > 0 ? Icons.auto_awesome : Icons.monetization_on,
                  color: reward.souls > 0 ? GameTheme.accentPurple : GameTheme.accentGold,
                  size: 14,
                ),
              const SizedBox(height: 2),
              Text(
                '${reward.coins}',
                style: TextStyle(
                  color: textColor, fontSize: 8, fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _claim() {
    final result = widget.game.dailyBonusManager.claim();
    widget.game.coins += result.coins;
    if (result.souls > 0) {
      widget.game.ascensionManager.souls += result.souls;
    }
    widget.game.achievementManager.onDailyStreak(result.streak);
    widget.game.saveGame();
    setState(() {
      _claimed = true;
      _result = result;
    });
  }
}
