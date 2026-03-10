import 'package:flutter/material.dart';
import 'game_theme.dart';
import '../game/defense_game.dart';

/// Tutorial overlay shown on first play.
/// 4-step slide guide explaining core mechanics.
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
      description: '적들이 사방에서 몰려옵니다.\n성벽 HP가 0이 되면 게임 오버!',
      hint: '성벽 HP를 항상 주시하세요',
    ),
    _TutorialStep(
      icon: '🐱',
      title: '유닛을 배치하세요',
      description: '하단의 [뽑기] 버튼으로 유닛을 소환합니다.\n유닛은 자동으로 적을 공격합니다.',
      hint: '골드를 모아 강한 유닛을 뽑으세요',
    ),
    _TutorialStep(
      icon: '🔀',
      title: '같은 유닛 3개 = 합체!',
      description: '동일 종류 + 동일 레벨 유닛 3개가\n모이면 자동으로 레벨업 합체됩니다.',
      hint: 'Lv5 도달 시 진화합니다',
    ),
    _TutorialStep(
      icon: '🎴',
      title: '보상과 유물',
      description: '5웨이브마다 보상 카드를 선택하고\n보스를 잡으면 유물을 획득합니다.',
      hint: '유물은 런 동안 영구 버프를 줍니다',
    ),
    _TutorialStep(
      icon: '🧬',
      title: '하이브리드 유닛',
      description: '서로 다른 종류의 Lv3+ 유닛 2개가\n있으면 이종 합체가 발동됩니다!\n특수 능력을 가진 강력한 유닛이 탄생합니다.',
      hint: '12종의 하이브리드를 발견하세요',
    ),
    _TutorialStep(
      icon: '🔥',
      title: '콤보 시스템',
      description: '적을 연속으로 처치하면 콤보가 쌓입니다.\n콤보가 높을수록 보너스 골드와\n화려한 이펙트가 발생합니다!',
      hint: '2초 안에 다음 적을 처치하세요',
    ),
    _TutorialStep(
      icon: '⭐',
      title: '진화 & 업그레이드',
      description: 'Lv5 유닛은 자동 진화하여\n공격력이 크게 증가합니다.\n별을 모아 영구 업그레이드를 구매하세요!',
      hint: '메인 메뉴에서 업그레이드 상점을 열 수 있어요',
    ),
    _TutorialStep(
      icon: '💰',
      title: '판매 & 리롤',
      description: '필요 없는 유닛은 판매하여 골드를 회수하고\n리롤로 모든 유닛을 새로 뽑을 수 있습니다.\n슬롯 관리가 승리의 핵심!',
      hint: '같은 유닛을 모아야 합체가 가능합니다',
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
                    return Container(
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
                  child: Text(
                    '건너뛰기',
                    style: GameTheme.pixel(
                      fontSize: 7,
                      color: GameTheme.textMuted,
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
