import 'dart:math';
import 'package:flutter/material.dart';
import 'game_theme.dart';
import '../game/defense_game.dart';

/// Data class for a wave reward card.
class RewardCard {
  final String name;
  final String description;
  final String rarity; // 'common', 'rare', 'epic', 'legendary'
  final String icon;
  final void Function(DefenseGame game) apply;

  const RewardCard({
    required this.name,
    required this.description,
    required this.rarity,
    required this.icon,
    required this.apply,
  });
}

/// Reward pool definition and random generation.
class RewardPool {
  static final Random _rng = Random();

  static final List<RewardCard> _commonRewards = [
    RewardCard(
      name: '공격력 +10%',
      description: '전체 유닛 공격력이 10% 증가합니다.',
      rarity: 'common',
      icon: '⚔️',
      apply: (game) => game.rewardAtkMultiplier += 0.10,
    ),
    RewardCard(
      name: '성벽 회복 10%',
      description: '성벽 HP를 10% 회복합니다.',
      rarity: 'common',
      icon: '🛡️',
      apply: (game) =>
          game.wall.heal(game.wall.maxHp * 0.10),
    ),
    RewardCard(
      name: '골드 +15%',
      description: '이번 런 골드 획득량이 15% 증가합니다.',
      rarity: 'common',
      icon: '💰',
      apply: (game) => game.rewardGoldMultiplier += 0.15,
    ),
    RewardCard(
      name: '공격 속도 +10%',
      description: '전체 유닛 공격 속도가 10% 증가합니다.',
      rarity: 'common',
      icon: '🏹',
      apply: (game) => game.rewardAtkSpeedMultiplier += 0.10,
    ),
    RewardCard(
      name: '사거리 +15%',
      description: '전체 유닛 사거리가 15% 증가합니다.',
      rarity: 'common',
      icon: '🎯',
      apply: (game) => game.rewardRangeMultiplier += 0.15,
    ),
    RewardCard(
      name: '보너스 골드',
      description: '즉시 골드 30을 획득합니다.',
      rarity: 'common',
      icon: '🪙',
      apply: (game) =>
          game.addGold(30, popupPos: game.wall.position),
    ),
  ];

  static final List<RewardCard> _rareRewards = [
    RewardCard(
      name: '유닛 비용 -20%',
      description: '유닛 뽑기 비용이 20% 감소합니다.',
      rarity: 'rare',
      icon: '🎪',
      apply: (game) => game.rewardUnitCostMultiplier *= 0.80,
    ),
    RewardCard(
      name: '성벽 방어 +20%',
      description: '성벽이 받는 피해가 20% 감소합니다.',
      rarity: 'rare',
      icon: '🏰',
      apply: (game) => game.rewardWallDefenseMultiplier *= 0.80,
    ),
    RewardCard(
      name: '골드 +30%',
      description: '이번 런 골드 획득량이 30% 증가합니다.',
      rarity: 'rare',
      icon: '💎',
      apply: (game) => game.rewardGoldMultiplier += 0.30,
    ),
    RewardCard(
      name: '성벽 대수리',
      description: '성벽 HP를 25% 회복합니다.',
      rarity: 'rare',
      icon: '🔧',
      apply: (game) =>
          game.wall.heal(game.wall.maxHp * 0.25),
    ),
  ];

  static final List<RewardCard> _epicRewards = [
    RewardCard(
      name: '전체 공격력 +25%',
      description: '모든 유닛의 공격력이 25% 증가합니다.',
      rarity: 'epic',
      icon: '🔥',
      apply: (game) => game.rewardAtkMultiplier += 0.25,
    ),
    RewardCard(
      name: '성벽 자동회복',
      description: '성벽이 매초 자동 회복됩니다.',
      rarity: 'epic',
      icon: '✨',
      apply: (game) => game.rewardWallRegenBonus += 1.0,
    ),
    RewardCard(
      name: '유닛 비용 -30%',
      description: '유닛 뽑기 비용이 30% 감소합니다.',
      rarity: 'epic',
      icon: '🎁',
      apply: (game) => game.rewardUnitCostMultiplier *= 0.70,
    ),
  ];

  static final List<RewardCard> _legendaryRewards = [
    RewardCard(
      name: '성벽 완전회복',
      description: '성벽 HP를 100% 회복합니다.',
      rarity: 'legendary',
      icon: '🌟',
      apply: (game) => game.wall.heal(game.wall.maxHp),
    ),
    RewardCard(
      name: '전체 강화',
      description: '공격력/공속/사거리/골드 모두 15% 증가.',
      rarity: 'legendary',
      icon: '☠️',
      apply: (game) {
        game.rewardAtkMultiplier += 0.15;
        game.rewardAtkSpeedMultiplier += 0.15;
        game.rewardRangeMultiplier += 0.15;
        game.rewardGoldMultiplier += 0.15;
      },
    ),
  ];

  /// Pick a rarity based on weighted probability.
  static String _rollRarity() {
    final roll = _rng.nextDouble();
    if (roll < 0.03) return 'legendary';
    if (roll < 0.15) return 'epic';
    if (roll < 0.40) return 'rare';
    return 'common';
  }

  static RewardCard _pickFromPool(List<RewardCard> pool) {
    return pool[_rng.nextInt(pool.length)];
  }

  /// Generate 3 unique reward cards with weighted rarity.
  static List<RewardCard> generate3Cards() {
    final cards = <RewardCard>[];
    final usedNames = <String>{};

    while (cards.length < 3) {
      final rarity = _rollRarity();
      final RewardCard card;
      switch (rarity) {
        case 'legendary':
          card = _pickFromPool(_legendaryRewards);
          break;
        case 'epic':
          card = _pickFromPool(_epicRewards);
          break;
        case 'rare':
          card = _pickFromPool(_rareRewards);
          break;
        default:
          card = _pickFromPool(_commonRewards);
      }
      if (!usedNames.contains(card.name)) {
        usedNames.add(card.name);
        cards.add(card);
      }
    }
    return cards;
  }
}

/// Wave reward selection screen shown every 5 waves.
class WaveRewardScreen extends StatefulWidget {
  final DefenseGame game;
  const WaveRewardScreen({super.key, required this.game});

  @override
  State<WaveRewardScreen> createState() => _WaveRewardScreenState();
}

class _WaveRewardScreenState extends State<WaveRewardScreen>
    with TickerProviderStateMixin {
  late List<RewardCard> _cards;
  late AnimationController _entryController;
  late List<Animation<double>> _cardSlides;
  late AnimationController _flashController;
  int? _selectedIndex;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _cards = RewardPool.generate3Cards();

    // Cards slide up from bottom, staggered
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _cardSlides = List.generate(3, (i) {
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

  void _selectCard(int index) {
    if (_selectedIndex != null || _dismissed) return;

    setState(() => _selectedIndex = index);
    _cards[index].apply(widget.game);

    _flashController.forward().then((_) {
      if (mounted) {
        setState(() => _dismissed = true);
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            widget.game.closeRewardSelection();
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
                  '보상 선택',
                  style: GameTheme.pixel(
                    fontSize: 14,
                    color: GameTheme.accentGold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '웨이브 ${widget.game.currentWave} 클리어!',
                  style: GameTheme.pixel(
                    fontSize: 8,
                    color: GameTheme.textSecondary,
                  ),
                ),
                const Spacer(flex: 1),
                // 3 reward cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: List.generate(3, (i) {
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: i == 0 ? 0 : 4,
                            right: i == 2 ? 0 : 4,
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
                                  opacity: _cardSlides[i].value.clamp(0.0, 1.0),
                                  child: child,
                                ),
                              );
                            },
                            child: _buildRewardCard(i),
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

  Widget _buildRewardCard(int index) {
    final card = _cards[index];
    final isSelected = _selectedIndex == index;
    final isOtherSelected = _selectedIndex != null && !isSelected;
    final borderColor = _rarityColor(card.rarity);

    return GestureDetector(
      onTap: () => _selectCard(index),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isOtherSelected ? 0.3 : 1.0,
        child: AnimatedScale(
          scale: isSelected ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: GameTheme.pixelPanelDecoration(
              fillColor: isSelected
                  ? GameTheme.bgCardHover
                  : GameTheme.bgCard,
              glow: isSelected || card.rarity == 'legendary',
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
                    gradient: _rarityGradient(card.rarity),
                    color: _rarityGradient(card.rarity) == null
                        ? borderColor.withValues(alpha: 0.3)
                        : null,
                    borderRadius: BorderRadius.circular(GameTheme.radiusSm),
                    border: Border.all(
                      color: borderColor.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Text(
                    _rarityLabel(card.rarity),
                    style: GameTheme.pixel(
                      fontSize: 6,
                      color: card.rarity == 'common'
                          ? GameTheme.textSecondary
                          : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Icon
                Text(
                  card.icon,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(height: 8),
                // Name
                Text(
                  card.name,
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
                  card.description,
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
                      borderRadius: BorderRadius.circular(GameTheme.radiusSm),
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
