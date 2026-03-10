import 'dart:async';
import 'package:flutter/material.dart';
import 'game_theme.dart';
import '../game/defense_game.dart';
import '../data/relic_data.dart';
import '../systems/combo_manager.dart';

/// In-game HUD for the castle defense game.
/// Shows wave info, gold, wall HP, and unit shop area.
class DefenseHud extends StatefulWidget {
  final DefenseGame game;
  const DefenseHud({super.key, required this.game});

  @override
  State<DefenseHud> createState() => _DefenseHudState();
}

class _DefenseHudState extends State<DefenseHud>
    with TickerProviderStateMixin {
  Timer? _refreshTimer;
  int _displayedGold = 0;
  late AnimationController _goldRollController;
  int _previousGold = 0;
  bool _isGoldAnimating = false;
  int? _selectedSlotIndex;
  bool _sellMode = false;

  @override
  void initState() {
    super.initState();
    _displayedGold = widget.game.gold;
    _previousGold = _displayedGold;

    _goldRollController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _goldRollController.addListener(_onGoldRoll);

    // Periodic refresh at 10 fps for HUD updates
    _refreshTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) {
        final currentGold = widget.game.gold;
        if (currentGold != _previousGold && !_isGoldAnimating) {
          _previousGold = _displayedGold;
          _isGoldAnimating = true;
          _goldRollController.forward(from: 0.0);
        }
        setState(() {});
      }
    });
  }

  void _onGoldRoll() {
    final targetGold = widget.game.gold;
    final t = Curves.easeOut.transform(_goldRollController.value);
    _displayedGold =
        (_previousGold + (targetGold - _previousGold) * t).round();

    if (_goldRollController.isCompleted) {
      _displayedGold = targetGold;
      _previousGold = targetGold;
      _isGoldAnimating = false;
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _goldRollController.removeListener(_onGoldRoll);
    _goldRollController.dispose();
    super.dispose();
  }

  Color _hpColor(double percent) {
    if (percent > 0.6) return GameTheme.accentGreen;
    if (percent > 0.3) return GameTheme.accentOrange;
    return GameTheme.accentRed;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            const SizedBox(height: 4),
            _buildWallHpBar(),
            // Relic display
            if (widget.game.relicManager.relicCount > 0) _buildRelicBar(),
            // Wave progress indicator
            if (widget.game.waveManager.waveActive) _buildWaveProgress(),
            // Combo counter
            if (widget.game.comboManager.isActive) _buildComboCounter(),
            // Wave clear banner
            if (widget.game.showWaveClearBanner) _buildWaveClearBanner(),
            const Spacer(),
            _buildBottomPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: GameTheme.pixelPanelDecoration(
        fillColor: GameTheme.bgDeep.withValues(alpha: 0.85),
      ),
      child: Row(
        children: [
          // Wave number
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: GameTheme.pixelCardDecoration(
              fillColor: GameTheme.bgCard,
              borderColor: GameTheme.accent.withValues(alpha: 0.4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.waves, color: GameTheme.accent, size: 14),
                const SizedBox(width: 4),
                Text(
                  'W${widget.game.currentWave}',
                  style: GameTheme.pixel(
                    fontSize: 10,
                    color: GameTheme.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Kill count
          Text(
            '${widget.game.runKills}',
            style: GameTheme.pixel(
              fontSize: 7,
              color: GameTheme.accentRed,
            ),
          ),
          const Icon(Icons.dangerous, color: GameTheme.accentRed, size: 10),
          const Spacer(),
          // Gold display with rolling animation
          AnimatedBuilder(
            animation: _goldRollController,
            builder: (context, _) {
              return GameTheme.pixelCurrency(
                value: GameTheme.formatInt(_displayedGold),
                fontSize: 10,
              );
            },
          ),
          const Spacer(),
          // Pause button
          GestureDetector(
            onTap: () {
              widget.game.pauseGame();
              widget.game.overlays.add('Pause');
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: GameTheme.pixelCardDecoration(
                fillColor: GameTheme.bgCard,
                borderColor: GameTheme.textMuted.withValues(alpha: 0.5),
              ),
              child: const Icon(
                Icons.pause,
                color: GameTheme.textSecondary,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWallHpBar() {
    final hpPercent = widget.game.wall.hpPercent;
    final hpColor = _hpColor(hpPercent);
    final currentHp = widget.game.wall.currentHp;
    final maxHp = widget.game.wall.maxHp;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.shield, color: hpColor, size: 12),
              const SizedBox(width: 4),
              Text(
                '성벽',
                style: GameTheme.pixel(
                    fontSize: 6, color: GameTheme.textSecondary),
              ),
              const Spacer(),
              Text(
                '${currentHp.toInt()} / ${maxHp.toInt()}',
                style: GameTheme.pixel(fontSize: 6, color: hpColor),
              ),
            ],
          ),
          const SizedBox(height: 2),
          GameTheme.pixelProgressBar(
            value: hpPercent,
            height: 12,
            fillColor: hpColor,
          ),
        ],
      ),
    );
  }

  Widget _buildRelicBar() {
    final relics = widget.game.relicManager.ownedRelics;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Text(
            '유물',
            style: GameTheme.pixel(
                fontSize: 6, color: GameTheme.textMuted),
          ),
          const SizedBox(width: 6),
          ...relics.map((id) {
            final emoji = _relicEmoji(id);
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: GameTheme.pixelCardDecoration(
                  fillColor: GameTheme.bgCard,
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 12)),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _relicEmoji(String relicId) {
    final def = RelicDatabase.get(relicId);
    return def?.icon ?? '🔮';
  }

  Widget _buildWaveProgress() {
    final wm = widget.game.waveManager;
    final progress = wm.totalEnemiesInWave > 0
        ? 1.0 - (wm.enemiesRemaining / wm.totalEnemiesInWave)
        : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Text(
            '적',
            style: GameTheme.pixel(
                fontSize: 6, color: GameTheme.textMuted),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: GameTheme.pixelProgressBar(
              value: progress,
              height: 6,
              fillColor: GameTheme.accentRed,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${wm.enemiesRemaining}',
            style: GameTheme.pixel(
              fontSize: 6,
              color: GameTheme.accentRed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveClearBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: GameTheme.pixelPanelDecoration(
          fillColor: GameTheme.accentGreen.withValues(alpha: 0.15),
          glow: true,
          glowColor: GameTheme.accentGreen,
        ),
        child: Text(
          'WAVE ${widget.game.waveClearNumber} CLEAR!',
          style: GameTheme.pixel(
            fontSize: 12,
            color: GameTheme.accentGreen,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildComboCounter() {
    final combo = widget.game.comboManager;
    final tier = combo.currentTier;
    final tierColor = Color(tier.color);
    final isBigTier = tier.index >= ComboTier.amazing.index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            scale: combo.tierJustChanged ? 1.3 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Text(
              'x${combo.comboCount}',
              style: GameTheme.pixel(
                fontSize: isBigTier ? 16 : 12,
                color: tierColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ),
          if (tier != ComboTier.none)
            AnimatedScale(
              scale: combo.tierJustChanged ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Text(
                tier.label,
                style: GameTheme.pixel(
                  fontSize: isBigTier ? 10 : 8,
                  color: tierColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    final unitCost = widget.game.getUnitCost();
    final canBuy = widget.game.gold >= unitCost;

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(10),
      decoration: GameTheme.pixelPanelDecoration(
        fillColor: GameTheme.bgDeep.withValues(alpha: 0.9),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Unit shop header
          Row(
            children: [
              Text(
                _sellMode ? '판매할 유닛 선택' : '유닛 배치',
                style: GameTheme.pixel(
                  fontSize: 8,
                  color: _sellMode ? GameTheme.accentRed : GameTheme.textSecondary,
                ),
              ),
              const Spacer(),
              // Occupied / total slots
              GameTheme.pixelChip(
                value: '${widget.game.unitSlots.where((s) => s.isOccupied).length}/${widget.game.unitSlots.length}',
                color: GameTheme.accentGold,
                fontSize: 6,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Action buttons row
          Row(
            children: [
              // Gacha / draw unit button with cost
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    GameTheme.pixelButton(
                      label: '뽑기',
                      onTap: canBuy
                          ? () {
                              widget.game.buyUnit();
                              setState(() => _sellMode = false);
                            }
                          : null,
                      gradient:
                          canBuy ? GameTheme.gradientPrimary : null,
                      fontSize: 9,
                      verticalPad: 10,
                      horizontalPad: 8,
                      icon: Icons.add_circle_outline,
                      enabled: canBuy,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${GameTheme.formatInt(unitCost)}G',
                      style: GameTheme.pixel(
                        fontSize: 5,
                        color: canBuy
                            ? GameTheme.accentGold
                            : GameTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Sell button (toggles sell mode)
              Expanded(
                flex: 2,
                child: GameTheme.pixelButton(
                  label: _sellMode ? '취소' : '판매',
                  onTap: () => setState(() => _sellMode = !_sellMode),
                  color: _sellMode
                      ? GameTheme.accentOrange
                      : GameTheme.accentRed,
                  fontSize: 8,
                  verticalPad: 10,
                  horizontalPad: 8,
                  icon: _sellMode ? Icons.close : Icons.sell,
                ),
              ),
              const SizedBox(width: 8),
              // Reroll button
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    GameTheme.pixelButton(
                      label: '리롤',
                      onTap: widget.game.gold >= 20
                          ? () {
                              widget.game.rerollUnits();
                              setState(() => _sellMode = false);
                            }
                          : null,
                      color: GameTheme.accentPurple,
                      fontSize: 8,
                      verticalPad: 10,
                      horizontalPad: 8,
                      icon: Icons.refresh,
                      enabled: widget.game.gold >= 20,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '20G',
                      style: GameTheme.pixel(
                        fontSize: 5,
                        color: widget.game.gold >= 20
                            ? GameTheme.accentPurple
                            : GameTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Owned units display row
          SizedBox(
            height: 50,
            child: widget.game.unitSlots.isEmpty
                ? Center(
                    child: Text(
                      '유닛을 뽑아 배치하세요',
                      style: GameTheme.pixel(
                        fontSize: 7,
                        color: GameTheme.textMuted,
                      ),
                    ),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.game.unitSlots.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                      final slot = widget.game.unitSlots[index];
                      return _buildUnitSlot(slot, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitSlot(UnitSlot slot, int index) {
    final isOccupied = slot.isOccupied;
    final isSelected = _selectedSlotIndex == index;
    final showSellHighlight = _sellMode && isOccupied;

    return GestureDetector(
      onTap: () {
        if (_sellMode && isOccupied) {
          widget.game.sellUnit(index);
          setState(() {
            _selectedSlotIndex = null;
            _sellMode = false;
          });
        } else if (isOccupied) {
          setState(() {
            _selectedSlotIndex = isSelected ? null : index;
          });
        }
      },
      child: Container(
        width: 46,
        height: 46,
        decoration: GameTheme.pixelCardDecoration(
          fillColor: showSellHighlight
              ? GameTheme.accentRed.withValues(alpha: 0.15)
              : isOccupied
                  ? GameTheme.bgCard
                  : GameTheme.bgDeep,
          borderColor: showSellHighlight
              ? GameTheme.accentRed
              : isOccupied
                  ? GameTheme.accent.withValues(alpha: 0.6)
                  : GameTheme.pixelBorder,
          selected: isSelected,
          glow: isSelected || showSellHighlight,
          glowColor:
              showSellHighlight ? GameTheme.accentRed : GameTheme.accentGold,
        ),
        child: Center(
          child: isOccupied
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showSellHighlight)
                      const Icon(Icons.sell,
                          color: GameTheme.accentRed, size: 10),
                    Text(
                      slot.icon,
                      style: TextStyle(
                          fontSize: showSellHighlight ? 14 : 18),
                    ),
                    Text(
                      'Lv${slot.level}',
                      style: GameTheme.pixel(
                        fontSize: 5,
                        color: GameTheme.textSecondary,
                      ),
                    ),
                  ],
                )
              : const Icon(
                  Icons.add,
                  color: GameTheme.textMuted,
                  size: 16,
                ),
        ),
      ),
    );
  }
}

/// Represents a unit placement slot exposed by DefenseGame.
class UnitSlot {
  final String icon;
  final int level;
  final bool isOccupied;
  final bool isSelected;
  final String unitType;

  const UnitSlot({
    this.icon = '🐶',
    this.level = 1,
    this.isOccupied = false,
    this.isSelected = false,
    this.unitType = '',
  });

  static const empty = UnitSlot();
}
