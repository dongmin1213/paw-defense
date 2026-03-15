import 'package:flutter/material.dart';
import 'game_theme.dart';
import '../game/defense_game.dart';

/// Tutorial overlay shown on first play.
/// 4-step concise guide — covers essentials without overwhelming new players.
class TutorialScreen extends StatefulWidget {
  final DefenseGame game;
  const TutorialScreen({super.key, required this.game});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  static const _steps = [
    _TutorialStep(
      icon: '🏰',
      title: '성벽을 지켜라!',
      description: '적들이 몰려옵니다.\n[뽑기]로 유닛을 소환하고,\n성벽 HP가 0이 되면 게임 오버!',
      hint: '유닛은 자동으로 적을 공격합니다',
    ),
    _TutorialStep(
      icon: '🔀',
      title: '합체 & 진화',
      description: '같은 유닛 3개 → 레벨업 합체!\n다른 종 Lv3+ 2개 → 하이브리드 탄생!\nLv5 도달 시 자동 진화합니다.',
      hint: '초록 글로우 = 합체 가능, 보라 글로우 = 하이브리드',
    ),
    _TutorialStep(
      icon: '🎴',
      title: '보상 & 유물 & 콤보',
      description: '5웨이브마다 보상 카드를 선택하고\n보스 처치 시 유물을 획득합니다.\n연속 처치로 콤보 보너스 골드!',
      hint: '유물은 런 내 영구 버프, 별은 영구 업그레이드',
    ),
    _TutorialStep(
      icon: '💡',
      title: '전략 팁',
      description: '불필요한 유닛은 판매하여 골드를 회수하고\n리롤로 새 유닛을 뽑을 수 있습니다.\n같은 유닛을 모으는 것이 핵심 전략!',
      hint: '배속(2x)과 판매 버튼을 잘 활용하세요',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      _fadeController.reverse().then((_) {
        setState(() => _currentStep++);
        _fadeController.forward();
      });
    } else {
      // Close tutorial and start game
      widget.game.overlays.remove('Tutorial');
      widget.game.startGame();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _fadeController.reverse().then((_) {
        setState(() => _currentStep--);
        _fadeController.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    final isLast = _currentStep == _steps.length - 1;

    return Material(
      color: Colors.transparent,
      child: Container(
        color: Colors.black.withValues(alpha: 0.85),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Step indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_steps.length, (i) {
                    final isActive = i == _currentStep;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isActive ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: isActive
                            ? GameTheme.accentGold
                            : GameTheme.textMuted.withValues(alpha: 0.3),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                // Content
                AnimatedBuilder(
                  animation: _fadeController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnim.value.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - _fadeAnim.value)),
                        child: child,
                      ),
                    );
                  },
                  child: _buildStepContent(step),
                ),
                const Spacer(flex: 1),
                // Navigation buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_currentStep > 0) ...[
                      GameTheme.pixelButton(
                        label: '이전',
                        onTap: _prevStep,
                        color: GameTheme.bgCard,
                        fontSize: 9,
                        verticalPad: 12,
                        horizontalPad: 24,
                        icon: Icons.arrow_back,
                      ),
                      const SizedBox(width: 16),
                    ],
                    GameTheme.pixelButton(
                      label: isLast ? '시작!' : '다음',
                      onTap: _nextStep,
                      gradient: isLast
                          ? GameTheme.gradientGreen
                          : GameTheme.gradientPrimary,
                      fontSize: 11,
                      verticalPad: 14,
                      horizontalPad: 32,
                      icon: isLast ? Icons.play_arrow : Icons.arrow_forward,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Skip button
                GestureDetector(
                  onTap: () {
                    widget.game.overlays.remove('Tutorial');
                    widget.game.startGame();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(GameTheme.radiusSm),
                    ),
                    child: Text(
                      '건너뛰기',
                      style: GameTheme.pixel(
                        fontSize: 7,
                        color: GameTheme.textMuted,
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(_TutorialStep step) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: GameTheme.pixelPanelDecoration(
        fillColor: GameTheme.bgPanel,
        glow: true,
        glowColor: GameTheme.accentGold,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Text(step.icon, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          // Title
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: GameTheme.pixel(
              fontSize: 14,
              color: GameTheme.accentGold,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            step.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: GameTheme.textPrimary,
              fontSize: 13,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          // Hint
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: GameTheme.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(GameTheme.radiusSm),
              border: Border.all(
                color: GameTheme.accent.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lightbulb_outline,
                    color: GameTheme.accentGold, size: 14),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    step.hint,
                    style: GameTheme.pixel(
                      fontSize: 7,
                      color: GameTheme.accentGold,
                    ),
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

class _TutorialStep {
  final String icon;
  final String title;
  final String description;
  final String hint;

  const _TutorialStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.hint,
  });
}
