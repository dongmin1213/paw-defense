import 'package:flutter/material.dart';
import '../game/runner_game.dart';
import '../systems/offline_reward.dart';
import 'game_theme.dart';

class OfflinePopup extends StatefulWidget {
  final RunnerGame game;
  final OfflineRewardResult reward;

  const OfflinePopup({
    super.key,
    required this.game,
    required this.reward,
  });

  @override
  State<OfflinePopup> createState() => _OfflinePopupState();
}

class _OfflinePopupState extends State<OfflinePopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bgFade;
  late Animation<double> _cardScale;
  late Animation<double> _cardFade;
  late Animation<double> _coinRoll;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _bgFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0, 0.3, curve: Curves.easeOut)),
    );
    _cardScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.1, 0.5, curve: Curves.easeOutBack)),
    );
    _cardFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.1, 0.4, curve: Curves.easeOut)),
    );
    _coinRoll = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic)),
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          color: Colors.black.withValues(alpha: 0.6 * _bgFade.value),
          child: Center(
            child: Transform.scale(
              scale: _cardScale.value,
              child: Opacity(
                opacity: _cardFade.value,
                child: _buildCard(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard() {
    final reward = widget.reward;
    final displayCoins = reward.coins * _coinRoll.value;

    return Container(
      width: 360,
      padding: const EdgeInsets.all(28),
      decoration: GameTheme.panelDecoration(
        borderColor: GameTheme.accent.withValues(alpha: 0.2),
        shadows: [
          BoxShadow(
            color: GameTheme.accent.withValues(alpha: 0.1),
            blurRadius: 30,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 환영 아이콘
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: GameTheme.accentGold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                  color: GameTheme.accentGold.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.wb_sunny_rounded,
                color: GameTheme.accentGold, size: 28),
          ),
          const SizedBox(height: 14),

          Text('다시 오셨군요!',
              style: GameTheme.titleMedium.copyWith(fontSize: 20)),
          const SizedBox(height: 6),
          Text(
            '${OfflineReward.formatDuration(reward.elapsedSeconds)} 동안\n비숏이 열심히 달렸습니다',
            textAlign: TextAlign.center,
            style: GameTheme.bodyLarge.copyWith(height: 1.4),
          ),

          const SizedBox(height: 20),

          // 코인 보상 디스플레이
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  GameTheme.accentGold.withValues(alpha: 0.1),
                  GameTheme.accentGold.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: GameTheme.accentGold.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.monetization_on,
                    color: GameTheme.accentGold, size: 30),
                const SizedBox(width: 10),
                Text(
                  '+${GameTheme.formatNumber(displayCoins)}',
                  style: TextStyle(
                    color: GameTheme.accentGold,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'CpS: ${reward.cps.toStringAsFixed(1)}',
            style: GameTheme.bodySmall,
          ),

          const SizedBox(height: 24),

          // 버튼들
          Row(
            children: [
              // 수령
              Expanded(
                child: GestureDetector(
                  onTap: () => _collect(1.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: GameTheme.gradientPrimary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('수령',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // x2 광고
              Expanded(
                child: GestureDetector(
                  onTap: _collectWithAd,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: GameTheme.gradientGold,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: GameTheme.accentGold.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_circle_filled,
                              color: Colors.white, size: 18),
                          SizedBox(width: 4),
                          Text('x2 수령',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _collect(double multiplier) {
    widget.game.coins += widget.reward.coins * multiplier;
    widget.game.totalCoinsEarned += widget.reward.coins * multiplier;
    widget.game.closeOfflinePopup();
  }

  void _collectWithAd() {
    widget.game.adManager.showRewardedAd(onReward: () {
      _collect(2.0);
    });
  }
}
