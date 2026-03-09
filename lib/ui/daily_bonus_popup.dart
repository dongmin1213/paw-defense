import 'package:flutter/material.dart';
import '../game/runner_game.dart';
import '../systems/daily_bonus_manager.dart';
import 'game_theme.dart';
import 'ui_effects.dart';

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
                  padding: const EdgeInsets.all(18),
                  decoration: GameTheme.pixelPanelDecoration(
                    fillColor: GameTheme.bgPanel,
                    glow: true,
                    glowColor: GameTheme.accentGold,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 타이틀
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              color: GameTheme.accentGold, size: 20),
                          const SizedBox(width: 8),
                          Text('DAILY BONUS',
                              style: GameTheme.pixel(
                                  fontSize: 12,
                                  color: GameTheme.accentGold)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'STREAK: ${streak > 0 ? streak : 1}',
                        style: GameTheme.pixel(
                            fontSize: 7, color: GameTheme.textMuted),
                      ),
                      const SizedBox(height: 14),

                      // 7일 캘린더
                      _buildDayCalendar(daily),

                      const SizedBox(height: 14),

                      // 보상 표시
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: GameTheme.pixelPanelDecoration(
                          fillColor: GameTheme.accentGold
                              .withValues(alpha: 0.06),
                          glow: !_claimed,
                          glowColor: GameTheme.accentGold,
                        ),
                        child: Column(
                          children: [
                            Text(
                              _claimed ? 'CLAIMED!' : 'TODAY',
                              style: GameTheme.pixel(
                                fontSize: 8,
                                color: _claimed
                                    ? GameTheme.accentGreen
                                    : GameTheme.accentGold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(Icons.monetization_on,
                                    color: GameTheme.accentGold,
                                    size: 20),
                                const SizedBox(width: 6),
                                Text(
                                  _claimed
                                      ? GameTheme.formatNumber(
                                          _result!.coins)
                                      : '${reward.coins}',
                                  style: GameTheme.pixel(
                                      fontSize: 14,
                                      color: GameTheme.accentGold),
                                ),
                                if (reward.souls > 0) ...[
                                  const SizedBox(width: 14),
                                  Icon(Icons.auto_awesome,
                                      color: GameTheme.accentPurple,
                                      size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+${reward.souls}',
                                    style: GameTheme.pixel(
                                        fontSize: 12,
                                        color:
                                            GameTheme.accentPurple),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // 버튼
                      if (!_claimed)
                        ShimmerGlow(
                          glowColor: GameTheme.accentGold,
                          intensity: 0.2,
                          child: GameTheme.pixelButton(
                            label: 'CLAIM',
                            icon: Icons.card_giftcard,
                            onTap: _claim,
                            gradient: GameTheme.gradientGold,
                            fontSize: 10,
                            horizontalPad: 32,
                            verticalPad: 10,
                          ),
                        )
                      else
                        GameTheme.pixelButton(
                          label: 'OK',
                          onTap: () {
                            _controller.reverse().then((_) {
                              if (mounted) widget.game.closeDailyBonus();
                            });
                          },
                          gradient: GameTheme.gradientPrimary,
                          fontSize: 10,
                          horizontalPad: 32,
                          verticalPad: 10,
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
        final isToday = !_claimed &&
            ((daily.streak % 7) + 1 == day ||
                (daily.streak == 0 && day == 1));

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
          border = GameTheme.pixelBorder;
          textColor = GameTheme.textMuted;
        }

        return Container(
          width: 36,
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(
                color: border, width: isToday ? 2 : 1.5),
            boxShadow: [
              BoxShadow(
                color: GameTheme.pixelShadow.withValues(alpha: 0.5),
                offset: const Offset(1, 1),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              Text('D$day',
                  style: GameTheme.pixel(
                      fontSize: 5, color: textColor)),
              const SizedBox(height: 3),
              if (isClaimed)
                Container(
                  width: 12,
                  height: 12,
                  color: GameTheme.accentGreen,
                  child: const Icon(Icons.check,
                      color: Colors.white, size: 10),
                )
              else
                Icon(
                  reward.souls > 0
                      ? Icons.auto_awesome
                      : Icons.monetization_on,
                  color: reward.souls > 0
                      ? GameTheme.accentPurple
                      : GameTheme.accentGold,
                  size: 12,
                ),
              const SizedBox(height: 2),
              Text(
                '${reward.coins}',
                style: GameTheme.pixel(
                    fontSize: 5, color: textColor),
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

    // 사운드 + UI 이펙트
    widget.game.soundManager.playDailyClaim();
    UIEffectManager.instance.spawnParticleBurst(
      relX: 0.5, relY: 0.5,
      color: const Color(0xFFFFD54F),
      count: 16,
      spread: 60,
    );
    UIEffectManager.instance.screenFlash(
      color: const Color(0xFFFFD54F),
      duration: 0.25,
      maxAlpha: 0.3,
    );

    setState(() {
      _claimed = true;
      _result = result;
    });
  }
}
