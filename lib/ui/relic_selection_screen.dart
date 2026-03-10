import 'package:flutter/material.dart';
import 'game_theme.dart';
import '../game/defense_game.dart';
import '../data/relic_data.dart';

/// Relic selection screen shown when a boss is killed.
/// Lets the player choose 1 of 3 relics with weighted rarity.
class RelicSelectionScreen extends StatefulWidget {
  final DefenseGame game;
  final List<String> relicChoices;

  RelicSelectionScreen({
    super.key,
    required this.game,
    List<String>? relicChoices,
  }) : relicChoices = relicChoices ?? game.relicChoices;

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

  Color _rarityColor(RelicRarity rarity) {
    switch (rarity) {
      case RelicRarity.common:
        return GameTheme.rarityCommon;
      case RelicRarity.rare:
        return GameTheme.rarityRare;
      case RelicRarity.epic:
        return GameTheme.rarityEpic;
      case RelicRarity.legendary:
        return GameTheme.rarityLegendary;
      case RelicRarity.mythic:
        return GameTheme.rarityMythic;
    }
  }

  LinearGradient? _rarityGradient(RelicRarity rarity) {
    switch (rarity) {
      case RelicRarity.legendary:
        return GameTheme.gradientGold;
      case RelicRarity.epic:
        return GameTheme.gradientPurple;
      case RelicRarity.mythic:
        return LinearGradient(
          colors: [
            GameTheme.rarityMythic,
            GameTheme.accentOrange,
            GameTheme.rarityMythic,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case RelicRarity.rare:
        return LinearGradient(
          colors: [
            GameTheme.rarityRare,
            GameTheme.accentDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return null;
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
                const SizedBox(height: 4),
                // Owned relics indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: GameTheme.bgCard.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(GameTheme.radiusSm),
                    border: Border.all(
                      color: GameTheme.pixelBorder.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '보유: ${widget.game.relicManager.relicCount}/${widget.game.relicManager.maxRelics}',
                    style: GameTheme.pixel(
                      fontSize: 6,
                      color: GameTheme.textMuted,
                    ),
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
    final def = RelicDatabase.get(relicId);
    if (def == null) return const SizedBox.shrink();

    final isSelected = _selectedIndex == index;
    final isOtherSelected = _selectedIndex != null && !isSelected;
    final borderColor = _rarityColor(def.rarity);

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
              glow: isSelected ||
                  def.rarity == RelicRarity.legendary ||
                  def.rarity == RelicRarity.mythic,
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
                    gradient: _rarityGradient(def.rarity),
                    color: _rarityGradient(def.rarity) == null
                        ? borderColor.withValues(alpha: 0.3)
                        : null,
                    borderRadius: BorderRadius.circular(GameTheme.radiusSm),
                    border: Border.all(
                      color: borderColor.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Text(
                    def.rarity.label,
                    style: GameTheme.pixel(
                      fontSize: 6,
                      color: def.rarity == RelicRarity.common
                          ? GameTheme.textSecondary
                          : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Icon
                Text(
                  def.icon,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(height: 8),
                // Name
                Text(
                  def.name,
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
                  def.description,
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
