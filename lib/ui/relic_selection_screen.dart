import 'package:flutter/material.dart';
import 'game_theme.dart';
import '../game/defense_game.dart';

/// Relic data derived from relicId.
class _RelicInfo {
  final String name;
  final String icon;
  final String description;
  final String rarity;

  const _RelicInfo({
    required this.name,
    required this.icon,
    required this.description,
    required this.rarity,
  });
}

/// Maps relicId → display data.
const Map<String, _RelicInfo> _relicDatabase = {
  // Evolution relics (epic rarity)
  'evolve_knight': _RelicInfo(
    name: '기사 진화석',
    icon: '🗡️',
    description: '전사 유닛을 진화시킵니다',
    rarity: 'epic',
  ),
  'evolve_archer': _RelicInfo(
    name: '궁수 진화석',
    icon: '🏹',
    description: '궁수 유닛을 진화시킵니다',
    rarity: 'epic',
  ),
  'evolve_mage': _RelicInfo(
    name: '마법사 진화석',
    icon: '🔮',
    description: '마법사 유닛을 진화시킵니다',
    rarity: 'epic',
  ),
  'evolve_healer': _RelicInfo(
    name: '힐러 진화석',
    icon: '💚',
    description: '힐러 유닛을 진화시킵니다',
    rarity: 'epic',
  ),
  'evolve_assassin': _RelicInfo(
    name: '암살자 진화석',
    icon: '🗡️',
    description: '암살자 유닛을 진화시킵니다',
    rarity: 'epic',
  ),
  // Passive bonus relics
  'relic_atk_boost': _RelicInfo(
    name: '분노의 부적',
    icon: '⚔️',
    description: '전체 유닛 공격력 +15%',
    rarity: 'rare',
  ),
  'relic_speed_boost': _RelicInfo(
    name: '신속의 부적',
    icon: '⚡',
    description: '전체 유닛 공격속도 +15%',
    rarity: 'rare',
  ),
  'relic_gold_boost': _RelicInfo(
    name: '황금 나침반',
    icon: '💰',
    description: '골드 획득량 +30%',
    rarity: 'rare',
  ),
  'relic_wall_shield': _RelicInfo(
    name: '수호의 방패',
    icon: '🛡️',
    description: '성벽 피해 -20%',
    rarity: 'rare',
  ),
  'relic_crit_chance': _RelicInfo(
    name: '치명의 반지',
    icon: '💥',
    description: '치명타 확률 +10%',
    rarity: 'rare',
  ),
  'relic_splash': _RelicInfo(
    name: '폭발의 룬',
    icon: '💫',
    description: '원거리 유닛 범위 공격',
    rarity: 'epic',
  ),
  'relic_slow_aura': _RelicInfo(
    name: '빙결의 오라',
    icon: '❄️',
    description: '성벽 근처 적 둔화 -20%',
    rarity: 'rare',
  ),
  'relic_lifesteal': _RelicInfo(
    name: '흡혈의 보석',
    icon: '🩸',
    description: '유닛 데미지의 2% 성벽 회복',
    rarity: 'epic',
  ),
  'relic_double_merge': _RelicInfo(
    name: '합성의 서',
    icon: '📖',
    description: '2마리만으로 합성 가능',
    rarity: 'legendary',
  ),
  'relic_star_magnet': _RelicInfo(
    name: '별의 나침반',
    icon: '⭐',
    description: '런 종료 시 별 +20%',
    rarity: 'rare',
  ),
};

/// Relic selection screen shown when a boss is killed.
/// Lets the player choose 1 of 2-3 relics.
class RelicSelectionScreen extends StatefulWidget {
  final DefenseGame game;
  final List<String> relicChoices;

  const RelicSelectionScreen({
    super.key,
    required this.game,
    required this.relicChoices,
  });

  @override
  State<RelicSelectionScreen> createState() => _RelicSelectionScreenState();
}

class _RelicSelectionScreenState extends State<RelicSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late List<Animation<double>> _cardSlides;
  late AnimationController _flashController;
  int? _selectedIndex;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();

    final count = widget.relicChoices.length;

    // Cards slide up from bottom, staggered
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _cardSlides = List.generate(count, (i) {
      final start = i * 0.15;
      final end = (start + 0.6).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _entryController,
        curve: Interval(start, end, curve: Curves.easeOutBack),
      );
    });

    _entryController.forward();

    // Flash effect on selection
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _flashController.dispose();
    super.dispose();
  }

  void _selectRelic(int index) {
    if (_selectedIndex != null || _dismissed) return;

    setState(() => _selectedIndex = index);

    final relicId = widget.relicChoices[index];
    widget.game.onRelicSelected(relicId);

    _flashController.forward().then((_) {
      if (mounted) {
        setState(() => _dismissed = true);
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            widget.game.overlays.remove('RelicSelection');
            widget.game.resumeGame();
          }
        });
      }
    });
  }

  Color _rarityColor(String rarity) => GameTheme.rarityToColor(rarity);

  LinearGradient? _rarityGradient(String rarity) {
    switch (rarity) {
      case 'legendary':
        return GameTheme.gradientGold;
      case 'epic':
        return GameTheme.gradientPurple;
      case 'rare':
        return const LinearGradient(
          colors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return null;
    }
  }

  String _rarityLabel(String rarity) {
    switch (rarity) {
      case 'legendary':
        return '전설';
      case 'epic':
        return '에픽';
      case 'rare':
        return '레어';
      default:
        return '일반';
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.relicChoices.length;

    return Material(
      color: Colors.transparent,
      child: AnimatedOpacity(
        opacity: _dismissed ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          color: Colors.black.withValues(alpha: 0.7),
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Title
                Text(
                  '유물 선택',
                  style: GameTheme.pixel(
                    fontSize: 14,
                    color: GameTheme.accentGold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '보스 처치 보상!',
                  style: GameTheme.pixel(
                    fontSize: 8,
                    color: GameTheme.textSecondary,
                  ),
                ),
                const Spacer(flex: 1),
                // Relic cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: List.generate(count, (i) {
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: i == 0 ? 0 : 4,
                            right: i == count - 1 ? 0 : 4,
                          ),
                          child: AnimatedBuilder(
                            animation: _cardSlides[i],
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(
                                  0,
                                  100 * (1 - _cardSlides[i].value),
                                ),
                                child: Opacity(
                                  opacity:
                                      _cardSlides[i].value.clamp(0.0, 1.0),
                                  child: child,
                                ),
                              );
                            },
                            child: _buildRelicCard(i),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRelicCard(int index) {
    final relicId = widget.relicChoices[index];
    final info = _relicDatabase[relicId];
    if (info == null) return const SizedBox.shrink();

    final isSelected = _selectedIndex == index;
    final isOtherSelected = _selectedIndex != null && !isSelected;
    final borderColor = _rarityColor(info.rarity);

    return GestureDetector(
      onTap: () => _selectRelic(index),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isOtherSelected ? 0.3 : 1.0,
        child: AnimatedScale(
          scale: isSelected ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: GameTheme.pixelPanelDecoration(
              fillColor: isSelected ? GameTheme.bgCardHover : GameTheme.bgCard,
              glow: isSelected || info.rarity == 'legendary',
              glowColor: borderColor,
            ).copyWith(
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Rarity label
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: _rarityGradient(info.rarity),
                    color: _rarityGradient(info.rarity) == null
                        ? borderColor.withValues(alpha: 0.3)
                        : null,
                    border: Border.all(
                      color: borderColor.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Text(
                    _rarityLabel(info.rarity),
                    style: GameTheme.pixel(
                      fontSize: 6,
                      color: info.rarity == 'common'
                          ? GameTheme.textSecondary
                          : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Icon
                Text(
                  info.icon,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(height: 8),
                // Name
                Text(
                  info.name,
                  textAlign: TextAlign.center,
                  style: GameTheme.pixel(
                    fontSize: 7,
                    color: GameTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                // Description
                Text(
                  info.description,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: GameTheme.textSecondary,
                    fontSize: 10,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                // Select indicator
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      gradient: GameTheme.gradientGreen,
                    ),
                    child: Text(
                      '선택!',
                      style: GameTheme.pixel(
                        fontSize: 7,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
