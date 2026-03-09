import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game_theme.dart';
import '../game/defense_game.dart';

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
    _displayedGold = (_previousGold + (targetGold - _previousGold) * t).round();

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
            // Top bar: wave | gold | pause
            _buildTopBar(),
            const SizedBox(height: 4),
            // Wall HP bar
            _buildWallHpBar(),
            const Spacer(),
            // Bottom unit shop panel
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
                Icon(Icons.waves, color: GameTheme.accent, size: 14),
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
            onTap: () => widget.game.pauseGame(),
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
                style: GameTheme.pixel(fontSize: 6, color: GameTheme.textSecondary),
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

  Widget _buildBottomPanel() {
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
                '유닛 배치',
                style: GameTheme.pixel(
                  fontSize: 8,
                  color: GameTheme.textSecondary,
                ),
              ),
              const Spacer(),
              GameTheme.pixelChip(
                value: '슬롯 ${widget.game.unitSlots.length}',
                color: GameTheme.accentGold,
                fontSize: 6,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Action buttons row
          Row(
            children: [
              // Gacha / draw unit button
              Expanded(
                flex: 3,
                child: GameTheme.pixelButton(
                  label: '뽑기',
                  onTap: () => widget.game.buyUnit(),
                  gradient: GameTheme.gradientPrimary,
                  fontSize: 9,
                  verticalPad: 10,
                  horizontalPad: 8,
                  icon: Icons.add_circle_outline,
                ),
              ),
              const SizedBox(width: 8),
              // Sell button
              Expanded(
                flex: 2,
                child: GameTheme.pixelButton(
                  label: '판매',
                  onTap: () {},
                  color: GameTheme.accentRed,
                  fontSize: 8,
                  verticalPad: 10,
                  horizontalPad: 8,
                  icon: Icons.sell,
                ),
              ),
              const SizedBox(width: 8),
              // Reroll button
              Expanded(
                flex: 2,
                child: GameTheme.pixelButton(
                  label: '리롤',
                  onTap: () {},
                  color: GameTheme.accentPurple,
                  fontSize: 8,
                  verticalPad: 10,
                  horizontalPad: 8,
                  icon: Icons.refresh,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Owned units display row
          SizedBox(
            height: 48,
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
    return GestureDetector(
      onTap: () {
        // Tap to select unit for placement
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: GameTheme.pixelCardDecoration(
          fillColor: isOccupied ? GameTheme.bgCard : GameTheme.bgDeep,
          borderColor: isOccupied
              ? GameTheme.accent.withValues(alpha: 0.6)
              : GameTheme.pixelBorder,
          selected: slot.isSelected,
          glow: slot.isSelected,
          glowColor: GameTheme.accentGold,
        ),
        child: Center(
          child: isOccupied
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      slot.icon,
                      style: const TextStyle(fontSize: 18),
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
              : Icon(
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
