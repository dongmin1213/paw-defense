import 'dart:async';
import 'package:flutter/material.dart';
import 'game_theme.dart';
import '../game/defense_game.dart';
import '../data/relic_data.dart';
import '../data/hybrid_unit_data.dart';
import '../data/enemy_data.dart';
import '../systems/combo_manager.dart';
import '../systems/merge_manager.dart' as merge;
import '../systems/skill_manager.dart';
import '../systems/synergy_manager.dart';

/// In-game HUD — professional layout with clear visual hierarchy.
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
  int? _unitInfoSlot;
  String? _achievementText;
  double _achievementTimer = 0;
  Color? _tierFlashColor;
  double _tierFlashTimer = 0;

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

    _refreshTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) {
        final currentGold = widget.game.gold;
        if (currentGold != _previousGold && !_isGoldAnimating) {
          _previousGold = _displayedGold;
          _isGoldAnimating = true;
          _goldRollController.forward(from: 0.0);
        }
        if (_achievementText != null) {
          _achievementTimer -= 0.1;
          if (_achievementTimer <= 0) _achievementText = null;
        } else {
          final notif = widget.game.popAchievementNotification();
          if (notif != null) {
            _achievementText = notif;
            _achievementTimer = 2.5;
          }
        }
        if (_tierFlashTimer > 0) {
          _tierFlashTimer -= 0.1;
          if (_tierFlashTimer <= 0) _tierFlashColor = null;
        }
        if (widget.game.comboManager.tierJustChanged) {
          _tierFlashColor = Color(widget.game.comboManager.currentTier.color);
          _tierFlashTimer = 0.5;
        }
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
        if (currentMod == null) _lastModifierId = null;
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
          // Combo tier flash
          if (_tierFlashColor != null)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: (_tierFlashTimer / 0.5).clamp(0.0, 0.12),
                  child: Container(color: _tierFlashColor),
                ),
              ),
            ),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                const SizedBox(height: 2),
                _buildWallHpBar(),
                if (widget.game.relicManager.relicCount > 0) _buildRelicBar(),
                if (widget.game.waveManager.waveActive) _buildWaveProgress(),
                if (_modifierText != null) _buildModifierBanner(),
                if (widget.game.comboManager.isActive &&
                    widget.game.isSystemUnlocked(DefenseGame.unlockCombo))
                  _buildComboCounter(),
                if (widget.game.showWaveClearBanner) _buildWaveClearBanner(),
                if (_achievementText != null) _buildAchievementBanner(),
                if (widget.game.waveManager.betweenWaves && !widget.game.showWaveClearBanner)
                  _buildWaveRushPanel(),
                if (widget.game.healCooldown > 0) _buildHealCooldown(),
                if (widget.game.synergyManager.hasAnySynergy) _buildSynergyBar(),
                const Spacer(),
                _buildSkillGauge(),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: GameTheme.bgDeep.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(GameTheme.radiusMd),
        border: Border.all(
          color: GameTheme.pixelBorder.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          // Wave badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: GameTheme.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(GameTheme.radiusSm),
              border: Border.all(
                color: GameTheme.accent.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.waves, color: GameTheme.accent, size: 12),
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
            style: GameTheme.pixel(fontSize: 7, color: GameTheme.accentRed),
          ),
          const Icon(Icons.dangerous, color: GameTheme.accentRed, size: 10),
          const Spacer(),
          // Gold
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
          // Speed toggle
          _buildHudIconButton(
            icon: widget.game.gameSpeed >= 2.0 ? Icons.fast_forward : Icons.play_arrow,
            label: widget.game.gameSpeed >= 2.0 ? '2x' : '1x',
            isActive: widget.game.gameSpeed >= 2.0,
            activeColor: GameTheme.accentGold,
            onTap: () {
              widget.game.toggleGameSpeed();
              setState(() {});
            },
          ),
          const SizedBox(width: 6),
          // Pause
          _buildHudIconButton(
            icon: Icons.pause,
            onTap: () {
              widget.game.pauseGame();
              widget.game.overlays.add('Pause');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHudIconButton({
    required IconData icon,
    String? label,
    bool isActive = false,
    Color? activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isActive
              ? (activeColor ?? GameTheme.accent).withValues(alpha: 0.12)
              : GameTheme.bgCard.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(GameTheme.radiusSm),
          border: Border.all(
            color: isActive
                ? (activeColor ?? GameTheme.accent).withValues(alpha: 0.4)
                : GameTheme.pixelBorder.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: label != null
              ? Text(
                  label,
                  style: GameTheme.pixel(
                    fontSize: 8,
                    color: isActive ? activeColor ?? GameTheme.accent : GameTheme.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : Icon(
                  icon,
                  color: GameTheme.textSecondary,
                  size: 18,
                ),
        ),
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
              Icon(Icons.shield, color: hpColor, size: 11),
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
            height: 10,
            fillColor: hpColor,
          ),
        ],
      ),
    );
  }

  Widget _buildRelicBar() {
    final relics = widget.game.relicManager.ownedRelics;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Row(
        children: [
          Text('유물', style: GameTheme.pixel(fontSize: 5, color: GameTheme.textMuted)),
          const SizedBox(width: 6),
          ...relics.map((id) {
            final emoji = _relicEmoji(id);
            return Padding(
              padding: const EdgeInsets.only(right: 3),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: GameTheme.bgCard.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: GameTheme.pixelBorder.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 11)),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Row(
        children: [
          Text('적', style: GameTheme.pixel(fontSize: 5, color: GameTheme.textMuted)),
          const SizedBox(width: 6),
          Expanded(
            child: GameTheme.pixelProgressBar(
              value: progress,
              height: 5,
              fillColor: GameTheme.accentRed,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${wm.enemiesRemaining}',
            style: GameTheme.pixel(fontSize: 6, color: GameTheme.accentRed),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveClearBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: GameTheme.accentGreen.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(GameTheme.radiusSm),
          border: Border.all(color: GameTheme.accentGreen.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: GameTheme.accentGreen.withValues(alpha: 0.15),
              blurRadius: 12,
            ),
          ],
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
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: GameTheme.accentGold.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(GameTheme.radiusSm),
            border: Border.all(color: GameTheme.accentGold.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: GameTheme.accentGold.withValues(alpha: 0.15),
                blurRadius: 10,
              ),
            ],
          ),
          child: Text(
            _achievementText ?? '',
            style: GameTheme.pixel(
              fontSize: 8,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: GameTheme.accentPurple.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(GameTheme.radiusSm),
            border: Border.all(color: GameTheme.accentPurple.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_modifierIcon ?? '', style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _modifierText ?? '',
                  style: GameTheme.pixel(
                    fontSize: 7,
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
      padding: const EdgeInsets.symmetric(vertical: 3),
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
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: GameTheme.accent.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(GameTheme.radiusMd),
          border: Border.all(color: GameTheme.accent.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: GameTheme.accent.withValues(alpha: 0.08),
              blurRadius: 10,
            ),
          ],
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
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => widget.game.rushWave(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: GameTheme.accentGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(GameTheme.radiusSm),
                  border: Border.all(color: GameTheme.accentGreen.withValues(alpha: 0.4)),
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
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: GameTheme.bgDeep.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(GameTheme.radiusMd),
        border: Border.all(
          color: (isHybridUnit ? GameTheme.accentPurple : GameTheme.accent)
              .withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isHybridUnit ? GameTheme.accentPurple : GameTheme.accent)
                .withValues(alpha: 0.15),
            blurRadius: 12,
          ),
        ],
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
          if (slot.level >= 5 && !isHybridUnit) ...[
            const SizedBox(height: 4),
            Text(
              '★ 진화 가능! 유물에서 진화석을 획득하세요',
              style: GameTheme.pixel(fontSize: 5, color: GameTheme.accentGold),
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

  Widget _buildSkillGauge() {
    final sm = widget.game.skillManager;
    final skill = sm.currentSkill;
    if (skill == null) return const SizedBox.shrink();

    final isReady = sm.isReady;
    final hasEffect = sm.hasActiveEffect;
    final barColor = isReady
        ? GameTheme.accentGold
        : hasEffect
            ? GameTheme.accentGreen
            : GameTheme.accent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: GestureDetector(
        onTap: isReady
            ? () {
                widget.game.activateSkill();
                setState(() {});
              }
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: isReady
                ? GameTheme.accentGold.withValues(alpha: 0.08)
                : GameTheme.bgCard.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(GameTheme.radiusSm),
            border: Border.all(
              color: barColor.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: isReady
                ? [BoxShadow(color: GameTheme.accentGold.withValues(alpha: 0.15), blurRadius: 8)]
                : null,
          ),
          child: Row(
            children: [
              Text(skill.icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isReady ? '${skill.name} — 탭하여 발동!' : skill.name,
                      style: GameTheme.pixel(
                        fontSize: 6,
                        color: isReady ? GameTheme.accentGold : GameTheme.textSecondary,
                        fontWeight: isReady ? FontWeight.w700 : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    GameTheme.pixelProgressBar(
                      value: hasEffect ? (sm.effectTimer / sm.effectMaxDuration).clamp(0.0, 1.0) : sm.chargePercent,
                      height: 5,
                      fillColor: barColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                hasEffect
                    ? '${sm.effectTimer.toStringAsFixed(1)}s'
                    : '${sm.currentCharge}/${sm.maxCharge}',
                style: GameTheme.pixel(
                  fontSize: 6,
                  color: isReady ? GameTheme.accentGold : GameTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSynergyBar() {
    final synergies = widget.game.synergyManager.activeSynergies;
    if (synergies.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: GameTheme.accentPurple.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(GameTheme.radiusSm),
          border: Border.all(color: GameTheme.accentPurple.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Text(
              '시너지',
              style: GameTheme.pixel(fontSize: 5, color: GameTheme.accentPurple),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Wrap(
                spacing: 4,
                runSpacing: 2,
                children: synergies.map((s) {
                  final tierColor = s.tier >= 2
                      ? GameTheme.accentGold
                      : GameTheme.accentPurple;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: tierColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: tierColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '${s.bonus.icon} ${s.bonus.name}',
                      style: GameTheme.pixel(fontSize: 5, color: tierColor),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    final unitCost = widget.game.getUnitCost();
    final canBuy = widget.game.gold >= unitCost;
    final canReroll = widget.game.gold >= 20;

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: GameTheme.bgDeep.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(GameTheme.radiusMd),
        border: Border.all(
          color: GameTheme.pixelBorder.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_sellMode)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: GameTheme.accentRed.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '판매할 유닛을 선택하세요',
                  style: GameTheme.pixel(
                    fontSize: 7,
                    color: GameTheme.accentRed,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          // Unit slots row
          SizedBox(
            height: 52,
            child: widget.game.unitSlots.isEmpty
                ? Center(
                    child: Text(
                      '유닛을 뽑아 배치하세요',
                      style: GameTheme.pixel(fontSize: 7, color: GameTheme.textMuted),
                    ),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.game.unitSlots.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 5),
                    itemBuilder: (context, index) {
                      final slot = widget.game.unitSlots[index];
                      return _buildUnitSlot(slot, index);
                    },
                  ),
          ),
          if (_unitInfoSlot != null &&
              _unitInfoSlot! < widget.game.unitSlots.length &&
              widget.game.unitSlots[_unitInfoSlot!].isOccupied)
            _buildUnitInfoPopup(widget.game.unitSlots[_unitInfoSlot!], _unitInfoSlot!),
          const SizedBox(height: 6),
          // Action buttons — equal sizing
          Row(
            children: [
              Expanded(
                flex: 3,
                child: GameTheme.pixelButton(
                  label: '뽑기 ${GameTheme.formatInt(unitCost)}G',
                  onTap: canBuy
                      ? () {
                          widget.game.buyUnit();
                          setState(() => _sellMode = false);
                        }
                      : null,
                  gradient: canBuy ? GameTheme.gradientPrimary : null,
                  fontSize: 8,
                  verticalPad: 10,
                  horizontalPad: 4,
                  icon: Icons.add_circle_outline,
                  enabled: canBuy,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                flex: 2,
                child: GameTheme.pixelButton(
                  label: _sellMode ? '취소' : '판매',
                  onTap: () => setState(() => _sellMode = !_sellMode),
                  color: _sellMode ? GameTheme.accentOrange : GameTheme.accentRed.withValues(alpha: 0.7),
                  fontSize: 8,
                  verticalPad: 10,
                  horizontalPad: 4,
                  icon: _sellMode ? Icons.close : Icons.sell,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                flex: 2,
                child: GameTheme.pixelButton(
                  label: '리롤 20G',
                  onTap: canReroll
                      ? () {
                          widget.game.rerollUnits();
                          setState(() => _sellMode = false);
                        }
                      : null,
                  color: GameTheme.accentPurple.withValues(alpha: 0.7),
                  fontSize: 8,
                  verticalPad: 10,
                  horizontalPad: 4,
                  icon: Icons.refresh,
                  enabled: canReroll,
                ),
              ),
              const SizedBox(width: 5),
              // Slot count
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: GameTheme.bgCard.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(GameTheme.radiusSm),
                  border: Border.all(
                    color: GameTheme.accentGold.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${widget.game.unitSlots.where((s) => s.isOccupied).length}/${widget.game.unitSlots.length}',
                  style: GameTheme.pixel(fontSize: 7, color: GameTheme.accentGold),
                ),
              ),
            ],
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
      borderColor = GameTheme.accent.withValues(alpha: 0.3);
      glowColor = GameTheme.accent;
    } else {
      borderColor = GameTheme.pixelBorder.withValues(alpha: 0.2);
      glowColor = null;
    }

    return GestureDetector(
      onTap: () {
        if (_sellMode && isOccupied) {
          widget.game.sellUnit(index);
          setState(() {
            _selectedSlotIndex = null;
            _unitInfoSlot = null;
            _sellMode = false;
          });
        } else if (isOccupied) {
          setState(() {
            if (isSelected) {
              _selectedSlotIndex = null;
              _unitInfoSlot = null;
            } else {
              _selectedSlotIndex = index;
              _unitInfoSlot = index;
            }
          });
        }
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: showSellHighlight
              ? GameTheme.accentRed.withValues(alpha: 0.10)
              : showHybridHint
                  ? GameTheme.accentPurple.withValues(alpha: 0.08)
                  : showMergeHint
                      ? GameTheme.accentGreen.withValues(alpha: 0.08)
                      : isOccupied
                          ? GameTheme.bgCard.withValues(alpha: 0.8)
                          : GameTheme.bgDeep.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(GameTheme.radiusSm),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: glow
              ? [BoxShadow(color: (glowColor ?? GameTheme.accent).withValues(alpha: 0.15), blurRadius: 6)]
              : null,
        ),
        child: Center(
          child: isOccupied
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showSellHighlight)
                      const Icon(Icons.sell, color: GameTheme.accentRed, size: 10),
                    if (showHybridHint && !showSellHighlight)
                      Text('🧬', style: const TextStyle(fontSize: 8)),
                    Text(
                      slot.icon,
                      style: TextStyle(
                          fontSize: showSellHighlight ? 14 : (showHybridHint ? 14 : 18)),
                    ),
                    Text(
                      slot.level >= 5 ? 'Lv${slot.level} ★' : 'Lv${slot.level}',
                      style: GameTheme.pixel(
                        fontSize: 5,
                        color: slot.level >= 5
                            ? GameTheme.accentGold
                            : showMergeHint
                                ? GameTheme.accentGreen
                                : showHybridHint
                                    ? GameTheme.accentPurple
                                    : GameTheme.textSecondary,
                      ),
                    ),
                  ],
                )
              : Icon(
                  Icons.add,
                  color: GameTheme.textMuted.withValues(alpha: 0.5),
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
