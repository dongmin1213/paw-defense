import 'package:flutter/material.dart';
import '../game/runner_game.dart';
import '../data/companion_data.dart';
import '../systems/companion_manager.dart';
import 'game_theme.dart';
import 'ui_effects.dart';

class CompanionScreen extends StatefulWidget {
  final RunnerGame game;
  const CompanionScreen({super.key, required this.game});

  @override
  State<CompanionScreen> createState() => _CompanionScreenState();
}

class _CompanionScreenState extends State<CompanionScreen>
    with SingleTickerProviderStateMixin {
  int _tabIndex = 0;
  String? _selectedId;
  late AnimationController _entryController;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final manager = game.companionManager;

    return AnimatedBuilder(
      animation: _entryController,
      builder: (context, _) {
        final fade = _entryController.value;
        return Material(
          color: GameTheme.bgDeep.withValues(alpha: 0.94 * fade),
          child: Opacity(
            opacity: fade,
            child: RetroScanlines(
              opacity: 0.02,
              child: SafeArea(
                child: Column(
                  children: [
                    // ── 헤더 ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: GameTheme.pixelCardDecoration(
                              fillColor: GameTheme.accentOrange
                                  .withValues(alpha: 0.15),
                              borderColor: GameTheme.accentOrange
                                  .withValues(alpha: 0.3),
                            ),
                            child: const Icon(Icons.pets,
                                color: GameTheme.accentOrange, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('COMPANION',
                                  style: GameTheme.pixel(
                                      fontSize: 12,
                                      color: GameTheme.accentOrange)),
                              Row(
                                children: [
                                  Text(
                                    '${manager.ownedCount}/${manager.totalCount}',
                                    style: GameTheme.pixel(
                                        fontSize: 6,
                                        color: GameTheme.textMuted),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'SLOT ${manager.equippedIds.length}/${manager.maxSlots}',
                                    style: GameTheme.pixel(
                                        fontSize: 6,
                                        color: GameTheme.accentOrange),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),
                          GameTheme.pixelCurrency(
                            value: GameTheme.formatNumber(game.coins),
                          ),
                          const SizedBox(width: 8),
                          GameTheme.closeButton(
                              onTap: () => game.closeCompanionScreen()),
                        ],
                      ),
                    ),

                    // ── 탭 바 ──
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: GameTheme.pixelPanelDecoration(
                        fillColor: GameTheme.bgCard,
                        raised: false,
                      ),
                      child: Row(
                        children: [
                          _buildTab(0, 'EQUIP'),
                          _buildTab(1, 'CODEX'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ── 콘텐츠 ──
                    Expanded(
                      child: _tabIndex == 0
                          ? _buildEquippedView(manager)
                          : _buildCodexView(manager),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTab(int index, String label) {
    final isSelected = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? GameTheme.accentOrange.withValues(alpha: 0.2)
                : Colors.transparent,
            border: isSelected
                ? Border.all(
                    color: GameTheme.accentOrange.withValues(alpha: 0.4),
                    width: 1.5)
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GameTheme.pixel(
              fontSize: 8,
              color: isSelected
                  ? GameTheme.accentOrange
                  : GameTheme.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEquippedView(CompanionManager manager) {
    final owned = manager.allOwned;
    if (owned.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets,
                color: GameTheme.textMuted.withValues(alpha: 0.3),
                size: 48),
            const SizedBox(height: 12),
            Text(
              '아직 동료가 없습니다',
              style: GameTheme.bodyLarge
                  .copyWith(color: GameTheme.textMuted),
            ),
            const SizedBox(height: 4),
            Text(
              'RUN TO FIND COMPANIONS!',
              style: GameTheme.pixel(
                  fontSize: 6, color: GameTheme.textMuted),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 0, 6, 16),
            itemCount: owned.length,
            itemBuilder: (context, i) => StaggeredEntry(
              index: i,
              child: _buildCompanionRow(owned[i], manager),
            ),
          ),
        ),
        if (_selectedId != null && manager.owns(_selectedId!))
          Expanded(
            flex: 2,
            child: _buildDetailPanel(
              manager.getOwned(_selectedId!)!,
              manager,
            ),
          ),
      ],
    );
  }

  Widget _buildCompanionRow(
      OwnedCompanion owned, CompanionManager manager) {
    final data = CompanionDatabase.get(owned.id);
    final isEquipped = manager.isEquipped(owned.id);
    final isSelected = _selectedId == owned.id;
    final rarityColor = CompanionDatabase.rarityColor(data.rarity);

    return GestureDetector(
      onTap: () => setState(() => _selectedId = owned.id),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.all(8),
        decoration: GameTheme.pixelCardDecoration(
          fillColor: isSelected
              ? rarityColor.withValues(alpha: 0.1)
              : isEquipped
                  ? rarityColor.withValues(alpha: 0.06)
                  : GameTheme.bgCard,
          borderColor: isSelected
              ? rarityColor.withValues(alpha: 0.6)
              : isEquipped
                  ? rarityColor.withValues(alpha: 0.3)
                  : GameTheme.pixelBorder,
          selected: isSelected,
          glow: isEquipped,
          glowColor: rarityColor,
        ),
        child: Row(
          children: [
            // 아바타
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.2),
                border:
                    Border.all(color: rarityColor, width: 2),
              ),
              child: Center(
                child: Text(
                  data.name.substring(0, 1),
                  style: GameTheme.pixel(
                    fontSize: 10,
                    color: rarityColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(data.name,
                          style: GameTheme.labelBold
                              .copyWith(fontSize: 12)),
                      const SizedBox(width: 5),
                      _RarityBadge(rarity: data.rarity),
                      const SizedBox(width: 4),
                      Text('Lv.${owned.level}',
                          style: GameTheme.pixel(
                              fontSize: 5,
                              color: GameTheme.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(data.buffDescription,
                      style: GameTheme.bodySmall
                          .copyWith(fontSize: 9)),
                ],
              ),
            ),

            if (isEquipped)
              Container(
                width: 8,
                height: 8,
                color: GameTheme.accentGreen,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailPanel(
      OwnedCompanion owned, CompanionManager manager) {
    final data = CompanionDatabase.get(owned.id);
    final isEquipped = manager.isEquipped(owned.id);
    final rarityColor = CompanionDatabase.rarityColor(data.rarity);
    final cost = manager.levelUpCost(owned.id);
    final canLevelUp =
        manager.canLevelUp(owned.id, widget.game.coins);

    return Container(
      margin: const EdgeInsets.fromLTRB(6, 0, 12, 16),
      padding: const EdgeInsets.all(12),
      decoration: GameTheme.pixelPanelDecoration(
        fillColor: GameTheme.bgPanel,
        glow: isEquipped,
        glowColor: rarityColor,
      ),
      child: Column(
        children: [
          // 대형 아바타
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.2),
              border: Border.all(color: rarityColor, width: 2),
              boxShadow: [
                BoxShadow(
                    color: rarityColor.withValues(alpha: 0.3),
                    blurRadius: 12),
              ],
            ),
            child: Center(
              child: Text(
                data.name.substring(0, 1),
                style: GameTheme.pixel(
                    fontSize: 16, color: rarityColor),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(data.name, style: GameTheme.titleSmall),
          _RarityBadge(rarity: data.rarity),
          const SizedBox(height: 4),
          Text('Lv.${owned.level}',
              style: GameTheme.pixel(
                  fontSize: 7, color: rarityColor)),
          const SizedBox(height: 10),
          Text(data.buffDescription,
              style: GameTheme.bodySmall,
              textAlign: TextAlign.center),

          const Spacer(),

          // 레벨업 버튼
          SizedBox(
            width: double.infinity,
            child: GameTheme.pixelButton(
              label: '${GameTheme.formatNumber(cost)}',
              icon: Icons.arrow_upward,
              onTap: canLevelUp ? () => _levelUp(owned.id) : null,
              gradient: GameTheme.gradientGold,
              fontSize: 7,
              verticalPad: 8,
              horizontalPad: 10,
              enabled: canLevelUp,
              usePixelFont: true,
            ),
          ),
          const SizedBox(height: 5),

          // 장착/해제 버튼
          SizedBox(
            width: double.infinity,
            child: GameTheme.pixelButton(
              label: isEquipped ? 'UNEQUIP' : 'EQUIP',
              onTap: () {
                if (isEquipped) {
                  manager.unequip(owned.id);
                } else {
                  manager.equip(owned.id);
                  widget.game.soundManager.playEquip();
                  UIEffectManager.instance.spawnGlowRing(
                    center: const Offset(600, 300),
                    color: rarityColor,
                  );
                }
                widget.game.saveGame();
                setState(() {});
              },
              color: isEquipped
                  ? GameTheme.accentRed.withValues(alpha: 0.6)
                  : GameTheme.accentGreen.withValues(alpha: 0.6),
              fontSize: 7,
              verticalPad: 8,
              horizontalPad: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodexView(CompanionManager manager) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 0.75,
      ),
      itemCount: CompanionDatabase.companions.length,
      itemBuilder: (context, index) {
        final data = CompanionDatabase.companions[index];
        final owned = manager.getOwned(data.id);
        final isOwned = owned != null;
        final rarityColor = CompanionDatabase.rarityColor(data.rarity);

        final child = Container(
          decoration: GameTheme.pixelCardDecoration(
            fillColor: isOwned
                ? rarityColor.withValues(alpha: 0.1)
                : GameTheme.bgCard,
            borderColor: isOwned
                ? rarityColor.withValues(alpha: 0.4)
                : GameTheme.pixelBorder,
            glow: isOwned,
            glowColor: rarityColor,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isOwned
                      ? data.color.withValues(alpha: 0.25)
                      : GameTheme.bgPanel,
                  border: Border.all(
                    color: isOwned
                        ? rarityColor.withValues(alpha: 0.5)
                        : GameTheme.pixelBorder,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    isOwned ? data.name.substring(0, 1) : '?',
                    style: GameTheme.pixel(
                      fontSize: 9,
                      color: isOwned
                          ? rarityColor
                          : GameTheme.textMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                isOwned ? data.name : '???',
                style: TextStyle(
                  color: isOwned
                      ? GameTheme.textPrimary
                      : GameTheme.textMuted,
                  fontSize: 9,
                ),
              ),
              if (isOwned)
                Text(
                  'Lv.${owned.level}',
                  style: GameTheme.pixel(
                      fontSize: 5, color: rarityColor),
                ),
            ],
          ),
        );

        return StaggeredEntry(
          index: index,
          delay: const Duration(milliseconds: 30),
          child: child,
        );
      },
    );
  }

  void _levelUp(String id) {
    final cost =
        widget.game.companionManager.doLevelUp(id, widget.game.coins);
    if (cost > 0) {
      widget.game.coins -= cost;
      widget.game.saveGame();
      widget.game.soundManager.playLevelUp();
      UIEffectManager.instance.spawnParticleBurst(
        position: const Offset(600, 250),
        color: const Color(0xFFFF9800),
        count: 10,
        spread: 50,
      );
      setState(() {});
    }
  }
}

class _RarityBadge extends StatelessWidget {
  final CompanionRarity rarity;
  const _RarityBadge({required this.rarity});

  @override
  Widget build(BuildContext context) {
    final color = CompanionDatabase.rarityColor(rarity);
    final name = CompanionDatabase.rarityName(rarity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(name,
          style: GameTheme.pixel(fontSize: 5, color: color)),
    );
  }
}
