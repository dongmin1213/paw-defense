import 'dart:async';
import 'package:flutter/material.dart';
import 'game_theme.dart';
import '../game/defense_game.dart';
import '../data/relic_data.dart';
import '../data/hybrid_unit_data.dart';
import '../data/enemy_data.dart';
import '../systems/combo_manager.dart';
import '../systems/merge_manager.dart' as merge;

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
  int? _unitInfoSlot; // For unit info popup on tap
  String? _achievementText;
  double _achievementTimer = 0;
  Color? _tierFlashColor;
  double _tierFlashTimer = 0;

  // Wave modifier banner state
  String? _modifierText;
  String? _modifierIcon;
  double _modifierTimer = 0;
  String? _lastModifierId;

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
        // Achievement notification polling
        if (_achievementText != null) {
          _achievementTimer -= 0.1;
          if (_achievementTimer <= 0) {
            _achievementText = null;
          }
        } else {
          final notif = widget.game.popAchievementNotification();
          if (notif != null) {
            _achievementText = notif;
            _achievementTimer = 2.5;
          }
        }
        // Combo tier-up flash
        if (_tierFlashTimer > 0) {
          _tierFlashTimer -= 0.1;
          if (_tierFlashTimer <= 0) _tierFlashColor = null;
        }
        if (widget.game.comboManager.tierJustChanged) {
          _tierFlashColor = Color(widget.game.comboManager.currentTier.color);
          _tierFlashTimer = 0.5;
        }
        // Wave modifier banner polling
        final currentMod = widget.game.waveManager.waveModifier.currentModifier;
        if (currentMod != null && currentMod.id != _lastModifierId) {
          _lastModifierId = currentMod.id;
          _modifierIcon = currentMod.icon;
          _modifierText = '${currentMod.name} — ${currentMod.description}';
          _modifierTimer = 3.0;
        }
        if (_modifierTimer > 0) {
          _modifierTimer -= 0.1;
          if (_modifierTimer <= 0) {
            _modifierText = null;
            _modifierIcon = null;
          }
        }
        // Reset modifier tracking when modifier clears
        if (currentMod == null) {
          _lastModifierId = null;
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
      child: Stack(
        children: [
          // Combo tier-up flash overlay
          if (_tierFlashColor != null)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: (_tierFlashTimer / 0.5).clamp(0.0, 0.15),
                  child: Container(color: _tierFlashColor),
                ),
              ),
            ),
          SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            const SizedBox(height: 4),
            _buildWallHpBar(),
            // Relic display
            if (widget.game.relicManager.relicCount > 0) _buildRelicBar(),
            // Wave progress indicator
            if (widget.game.waveManager.waveActive) _buildWaveProgress(),
            // Wave modifier banner
            if (_modifierText != null) _buildModifierBanner(),
            // Combo counter (only if combo system unlocked)
            if (widget.game.comboManager.isActive &&
                widget.game.isSystemUnlocked(DefenseGame.unlockCombo))
              _buildComboCounter(),
            // Wave clear banner
            if (widget.game.showWaveClearBanner) _buildWaveClearBanner(),
            // Achievement notification banner
            if (_achievementText != null) _buildAchievementBanner(),
            // Between-wave: wave preview + rush button
            if (widget.game.waveManager.betweenWaves && !widget.game.showWaveClearBanner)
              _buildWaveRushPanel(),
            // Heal cooldown indicator
            if (widget.game.healCooldown > 0) _buildHealCooldown(),
            const Spacer(),
            _buildBottomPanel(),
          ],
        ),
      ),
        ],
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
          // Speed toggle button
          GestureDetector(
            onTap: () {
              widget.game.toggleGameSpeed();
              setState(() {});
            },
            child: Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 6),
              decoration: GameTheme.pixelCardDecoration(
                fillColor: widget.game.gameSpeed >= 2.0
                    ? GameTheme.accentGold.withValues(alpha: 0.2)
                    : GameTheme.bgCard,
                borderColor: widget.game.gameSpeed >= 2.0
                    ? GameTheme.accentGold
                    : GameTheme.textMuted.withValues(alpha: 0.5),
                glow: widget.game.gameSpeed >= 2.0,
                glowColor: GameTheme.accentGold,
              ),
              child: Center(
                child: Text(
                  widget.game.gameSpeed >= 2.0 ? '2x' : '1x',
                  style: GameTheme.pixel(
                    fontSize: 9,
                    color: widget.game.gameSpeed >= 2.0
                        ? GameTheme.accentGold
                        : GameTheme.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
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

  Widget _buildAchievementBanner() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _achievementTimer > 0.3 ? 1.0 : _achievementTimer / 0.3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: GameTheme.pixelPanelDecoration(
            fillColor: GameTheme.accentGold.withValues(alpha: 0.15),
            glow: true,
            glowColor: GameTheme.accentGold,
          ),
          child: Text(
            _achievementText ?? '',
            style: GameTheme.pixel(
              fontSize: 9,
              color: GameTheme.accentGold,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModifierBanner() {
    final opacity = _modifierTimer > 0.5 ? 1.0 : (_modifierTimer / 0.5).clamp(0.0, 1.0);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: opacity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: GameTheme.pixelPanelDecoration(
            fillColor: GameTheme.accentPurple.withValues(alpha: 0.15),
            glow: true,
            glowColor: GameTheme.accentPurple,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _modifierIcon ?? '',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _modifierText ?? '',
                  style: GameTheme.pixel(
                    fontSize: 8,
                    color: GameTheme.accentPurple,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
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

  Widget _buildWaveRushPanel() {
    final wm = widget.game.waveManager;
    final nextWave = wm.currentWave + 1;
    final enemyTypes = wm.previewNextWaveEnemyTypes();
    final enemyNames = enemyTypes.take(3).map((id) {
      final data = DefenseEnemyDatabase.get(id);
      return data?.id ?? id;
    }).join(', ');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: GameTheme.pixelPanelDecoration(
          fillColor: GameTheme.accent.withValues(alpha: 0.1),
          glow: true,
          glowColor: GameTheme.accent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Wave $nextWave 준비',
              style: GameTheme.pixel(
                fontSize: 8,
                color: GameTheme.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              enemyNames,
              style: GameTheme.pixel(fontSize: 5, color: GameTheme.textSecondary),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => widget.game.rushWave(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: GameTheme.pixelCardDecoration(
                  fillColor: GameTheme.accentGreen.withValues(alpha: 0.2),
                  borderColor: GameTheme.accentGreen,
                  glow: true,
                  glowColor: GameTheme.accentGreen,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.fast_forward, color: GameTheme.accentGreen, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'RUSH +5G',
                      style: GameTheme.pixel(
                        fontSize: 8,
                        color: GameTheme.accentGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealCooldown() {
    final cd = widget.game.healCooldown;
    final progress = 1.0 - (cd / DefenseGame.healCooldownDuration).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.healing, color: GameTheme.accentGreen, size: 10),
          const SizedBox(width: 4),
          Text(
            '회복 ${cd.toStringAsFixed(1)}s',
            style: GameTheme.pixel(fontSize: 5, color: GameTheme.accentGreen),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GameTheme.pixelProgressBar(
              value: progress,
              height: 4,
              fillColor: GameTheme.accentGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitInfoPopup(UnitSlot slot, int index) {
    final hybrid = HybridDatabase.get(slot.unitType);
    final isHybridUnit = hybrid != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: GameTheme.pixelPanelDecoration(
        fillColor: GameTheme.bgDeep.withValues(alpha: 0.95),
        glow: true,
        glowColor: isHybridUnit ? GameTheme.accentPurple : GameTheme.accent,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(slot.icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slot.unitType.replaceAll('_', ' '),
                      style: GameTheme.pixel(fontSize: 8, color: Colors.white),
                    ),
                    Text(
                      'Lv${slot.level}',
                      style: GameTheme.pixel(
                        fontSize: 6,
                        color: isHybridUnit ? GameTheme.accentPurple : GameTheme.accent,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _unitInfoSlot = null),
                child: const Icon(Icons.close, color: GameTheme.textMuted, size: 16),
              ),
            ],
          ),
          if (isHybridUnit) ...[
            const SizedBox(height: 4),
            Text(
              '🧬 ${hybrid.specialAbilityDesc}',
              style: GameTheme.pixel(fontSize: 6, color: GameTheme.accentPurple),
            ),
            Text(
              '부모: ${hybrid.parentA} + ${hybrid.parentB}',
              style: GameTheme.pixel(fontSize: 5, color: GameTheme.textMuted),
            ),
          ],
          if (slot.canMerge)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '✅ 동종 머지 가능 (드래그로 합성)',
                style: GameTheme.pixel(fontSize: 5, color: GameTheme.accentGreen),
              ),
            ),
          if (slot.canHybrid)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '🧬 하이브리드 가능 (다른 종에 드래그)',
                style: GameTheme.pixel(fontSize: 5, color: GameTheme.accentPurple),
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
    final showMergeHint = !_sellMode && slot.canMerge &&
        widget.game.isSystemUnlocked(DefenseGame.unlockMergeHint);
    final showHybridHint = !_sellMode && slot.canHybrid &&
        widget.game.isSystemUnlocked(DefenseGame.unlockHybrid);

    Color borderColor;
    Color? glowColor;
    bool glow = isSelected || showSellHighlight || showMergeHint || showHybridHint;
    if (showSellHighlight) {
      borderColor = GameTheme.accentRed;
      glowColor = GameTheme.accentRed;
    } else if (showHybridHint) {
      borderColor = GameTheme.accentPurple;
      glowColor = GameTheme.accentPurple;
    } else if (showMergeHint) {
      borderColor = GameTheme.accentGreen;
      glowColor = GameTheme.accentGreen;
    } else if (isOccupied) {
      borderColor = GameTheme.accent.withValues(alpha: 0.6);
      glowColor = GameTheme.accentGold;
    } else {
      borderColor = GameTheme.pixelBorder;
      glowColor = null;
    }

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
              : showHybridHint
                  ? GameTheme.accentPurple.withValues(alpha: 0.1)
                  : showMergeHint
                      ? GameTheme.accentGreen.withValues(alpha: 0.1)
                      : isOccupied
                          ? GameTheme.bgCard
                          : GameTheme.bgDeep,
          borderColor: borderColor,
          selected: isSelected,
          glow: glow,
          glowColor: glowColor ?? GameTheme.accentGold,
        ),
        child: Center(
          child: isOccupied
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showSellHighlight)
                      const Icon(Icons.sell,
                          color: GameTheme.accentRed, size: 10),
                    if (showHybridHint && !showSellHighlight)
                      Text('🧬',
                          style: const TextStyle(fontSize: 8)),
                    Text(
                      slot.icon,
                      style: TextStyle(
                          fontSize: showSellHighlight ? 14 : (showHybridHint ? 14 : 18)),
                    ),
                    Text(
                      'Lv${slot.level}',
                      style: GameTheme.pixel(
                        fontSize: 5,
                        color: showMergeHint
                            ? GameTheme.accentGreen
                            : showHybridHint
                                ? GameTheme.accentPurple
                                : GameTheme.textSecondary,
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
  final bool canMerge;
  final bool canHybrid;

  const UnitSlot({
    this.icon = '🐶',
    this.level = 1,
    this.isOccupied = false,
    this.isSelected = false,
    this.unitType = '',
    this.canMerge = false,
    this.canHybrid = false,
  });

  static const empty = UnitSlot();
}
