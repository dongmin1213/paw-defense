import 'package:flutter/material.dart';
import '../game/runner_game.dart';
import '../systems/offline_reward.dart';
import 'game_theme.dart';
import 'ui_effects.dart';

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
      padding: const EdgeInsets.all(24),
      decoration: GameTheme.pixelPanelDecoration(
        fillColor: GameTheme.bgPanel,
        glow: true,
        glowColor: GameTheme.accent,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 환영 아이콘
          Container(
            width: 50,
            height: 50,
            decoration: GameTheme.pixelCardDecoration(
              fillColor: GameTheme.accentGold.withValues(alpha: 0.15),
              borderColor: GameTheme.accentGold.withValues(alpha: 0.4),
            ),
            child: const Icon(Icons.wb_sunny_rounded,
                color: GameTheme.accentGold, size: 24),
          ),
          const SizedBox(height: 12),

          Text('WELCOME BACK!',
              style: GameTheme.pixel(fontSize: 10, color: GameTheme.textPrimary)),
          const SizedBox(height: 6),
          Text(
            '${OfflineReward.formatDuration(reward.elapsedSeconds)} 동안\n비숏이 열심히 달렸습니다',
            textAlign: TextAlign.center,
            style: GameTheme.bodyLarge.copyWith(height: 1.4, fontSize: 12),
          ),

          const SizedBox(height: 18),

          // 코인 보상 디스플레이
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: GameTheme.pixelPanelDecoration(
              fillColor: GameTheme.accentGold.withValues(alpha: 0.08),
              glow: true,
              glowColor: GameTheme.accentGold,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.monetization_on,
                    color: GameTheme.accentGold, size: 26),
                const SizedBox(width: 10),
                Text(
                  '+${GameTheme.formatNumber(displayCoins)}',
                  style: GameTheme.pixel(
                    fontSize: 16,
                    color: GameTheme.accentGold,
                    shadows: [
                      Shadow(
                          color: GameTheme.accentGold.withValues(alpha: 0.5),
                          blurRadius: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'CpS: ${reward.cps.toStringAsFixed(1)}',
            style: GameTheme.pixel(fontSize: 6, color: GameTheme.textMuted),
          ),

          const SizedBox(height: 20),

          // 버튼들
          Row(
            children: [
              Expanded(
                child: GameTheme.pixelButton(
                  label: 'COLLECT',
                  onTap: () => _collect(1.0),
                  gradient: GameTheme.gradientPrimary,
                  fontSize: 8,
                  verticalPad: 10,
                  horizontalPad: 12,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ShimmerGlow(
                  glowColor: GameTheme.accentGold,
                  intensity: 0.2,
                  child: GameTheme.pixelButton(
                    label: 'x2',
                    icon: Icons.play_circle_filled,
                    onTap: _collectWithAd,
                    gradient: GameTheme.gradientGold,
                    fontSize: 8,
                    verticalPad: 10,
                    horizontalPad: 12,
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
    widget.game.soundManager.playCoinCollect(isBig: true);
    UIEffectManager.instance.spawnParticleBurst(
      relX: 0.5, relY: 0.5,
      color: const Color(0xFFFFD54F),
      count: 16,
      spread: 60,
    );
    UIEffectManager.instance.spawnCoinFly(
      fromRelX: 0.5, fromRelY: 0.45,
      toRelX: 0.85, toRelY: 0.03,
      count: 8,
    );
    _controller.reverse().then((_) {
      if (mounted) widget.game.closeOfflinePopup();
    });
  }

  void _collectWithAd() {
    widget.game.adManager.showRewardedAd(onReward: () {
      _collect(2.0);
    });
  }
}
