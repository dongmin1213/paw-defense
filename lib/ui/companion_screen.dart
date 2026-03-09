import 'package:flutter/material.dart';
import '../game/runner_game.dart';
import '../data/companion_data.dart';
import '../systems/companion_manager.dart';
import 'game_theme.dart';

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
            child: SafeArea(
              child: Column(
                children: [
                  // ── 헤더 ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: GameTheme.accentOrange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.pets,
                              color: GameTheme.accentOrange, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('동료',
                                style: GameTheme.titleMedium.copyWith(
                                    fontSize: 20,
                                    color: GameTheme.accentOrange)),
                            Row(
                              children: [
                                Text(
                                  '보유 ${manager.ownedCount}/${manager.totalCount}',
                                  style: GameTheme.bodySmall,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '장착 ${manager.equippedIds.length}/${manager.maxSlots}',
                                  style: GameTheme.bodySmall.copyWith(
                                      color: GameTheme.accentOrange),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        GameTheme.currencyDisplay(
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
                    decoration: BoxDecoration(
                      color: GameTheme.bgCard,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        _buildTab(0, '장착'),
                        _buildTab(1, '도감'),
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
        );
      },
    );
  }

  Widget _buildTab(int index, String label) {
    final isSelected = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? GameTheme.accentOrange.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(
                    color: GameTheme.accentOrange.withValues(alpha: 0.4))
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? GameTheme.accentOrange
                  : GameTheme.textMuted,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
            Icon(Icons.pets, color: GameTheme.textMuted.withValues(alpha: 0.3), size: 48),
            const SizedBox(height: 12),
            Text(
              '아직 동료가 없습니다',
              style: GameTheme.bodyLarge.copyWith(color: GameTheme.textMuted),
            ),
            const SizedBox(height: 4),
            Text(
              '달리다 보면 동료를 만날 수 있어요!',
              style: GameTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        // 동료 리스트
        Expanded(
          flex: 3,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 0, 6, 16),
            itemCount: owned.length,
            itemBuilder: (context, i) =>
                _buildCompanionRow(owned[i], manager),
          ),
        ),

        // 상세 패널
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

  Widget _buildCompanionRow(OwnedCompanion owned, CompanionManager manager) {
    final data = CompanionDatabase.get(owned.id);
    final isEquipped = manager.isEquipped(owned.id);
    final isSelected = _selectedId == owned.id;
    final rarityColor = CompanionDatabase.rarityColor(data.rarity);

    return GestureDetector(
      onTap: () => setState(() => _selectedId = owned.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? rarityColor.withValues(alpha: 0.1)
              : isEquipped
                  ? rarityColor.withValues(alpha: 0.06)
                  : GameTheme.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? rarityColor.withValues(alpha: 0.5)
                : isEquipped
                    ? rarityColor.withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.05),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // 아바타
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: rarityColor, width: 1.5),
                boxShadow: isEquipped
                    ? [BoxShadow(color: rarityColor.withValues(alpha: 0.2), blurRadius: 6)]
                    : null,
              ),
              child: Center(
                child: Text(
                  data.name.substring(0, 1),
                  style: TextStyle(
                    color: rarityColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // 이름 + 레어도
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(data.name,
                          style: GameTheme.labelBold.copyWith(fontSize: 13)),
                      const SizedBox(width: 6),
                      _RarityBadge(rarity: data.rarity),
                      const SizedBox(width: 4),
                      Text('Lv.${owned.level}',
                          style: GameTheme.bodySmall
                              .copyWith(fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(data.buffDescription,
                      style: GameTheme.bodySmall.copyWith(fontSize: 10)),
                ],
              ),
            ),

            // 장착 인디케이터
            if (isEquipped)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: GameTheme.accentGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: GameTheme.accentGreen.withValues(alpha: 0.4),
                        blurRadius: 4),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailPanel(OwnedCompanion owned, CompanionManager manager) {
    final data = CompanionDatabase.get(owned.id);
    final isEquipped = manager.isEquipped(owned.id);
    final rarityColor = CompanionDatabase.rarityColor(data.rarity);
    final cost = manager.levelUpCost(owned.id);
    final canLevelUp = manager.canLevelUp(owned.id, widget.game.coins);

    return Container(
      margin: const EdgeInsets.fromLTRB(6, 0, 12, 16),
      padding: const EdgeInsets.all(14),
      decoration: GameTheme.panelDecoration(
        borderColor: rarityColor.withValues(alpha: 0.3),
      ),
      child: Column(
        children: [
          // 대형 아바타
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
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
                style: TextStyle(
                    color: rarityColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(data.name, style: GameTheme.titleSmall),
          _RarityBadge(rarity: data.rarity),
          const SizedBox(height: 4),
          Text('레벨 ${owned.level}',
              style: GameTheme.bodySmall.copyWith(
                  color: rarityColor, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Text(data.buffDescription,
              style: GameTheme.bodySmall,
              textAlign: TextAlign.center),

          const Spacer(),

          // 레벨업 버튼
          GestureDetector(
            onTap: canLevelUp ? () => _levelUp(owned.id) : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: canLevelUp ? GameTheme.gradientGold : null,
                color: canLevelUp ? null : GameTheme.bgCard,
                borderRadius: BorderRadius.circular(10),
                border: canLevelUp
                    ? null
                    : Border.all(
                        color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_upward,
                      color: canLevelUp ? Colors.white : GameTheme.textMuted,
                      size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '레벨업  ${GameTheme.formatNumber(cost)}',
                    style: TextStyle(
                      color: canLevelUp ? Colors.white : GameTheme.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),

          // 장착/해제 버튼
          GestureDetector(
            onTap: () {
              if (isEquipped) {
                manager.unequip(owned.id);
              } else {
                manager.equip(owned.id);
              }
              widget.game.saveGame();
              setState(() {});
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isEquipped
                    ? GameTheme.accentRed.withValues(alpha: 0.15)
                    : GameTheme.accentGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isEquipped
                      ? GameTheme.accentRed.withValues(alpha: 0.3)
                      : GameTheme.accentGreen.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                isEquipped ? '해제' : '장착',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isEquipped
                      ? GameTheme.accentRed
                      : GameTheme.accentGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
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
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: CompanionDatabase.companions.length,
      itemBuilder: (context, index) {
        final data = CompanionDatabase.companions[index];
        final owned = manager.getOwned(data.id);
        final isOwned = owned != null;
        final rarityColor = CompanionDatabase.rarityColor(data.rarity);

        return Container(
          decoration: BoxDecoration(
            color: isOwned
                ? rarityColor.withValues(alpha: 0.1)
                : GameTheme.bgCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isOwned
                  ? rarityColor.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.05),
            ),
            boxShadow: isOwned
                ? [
                    BoxShadow(
                        color: rarityColor.withValues(alpha: 0.15),
                        blurRadius: 6)
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isOwned
                      ? data.color.withValues(alpha: 0.25)
                      : GameTheme.bgPanel,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isOwned
                        ? rarityColor.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: Center(
                  child: Text(
                    isOwned ? data.name.substring(0, 1) : '?',
                    style: TextStyle(
                      color: isOwned ? rarityColor : GameTheme.textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isOwned ? data.name : '???',
                style: TextStyle(
                  color: isOwned
                      ? GameTheme.textPrimary
                      : GameTheme.textMuted,
                  fontSize: 10,
                ),
              ),
              if (isOwned)
                Text(
                  'Lv.${owned.level}',
                  style: TextStyle(
                      color: rarityColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w600),
                ),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(name,
          style: TextStyle(
              color: color, fontSize: 9, fontWeight: FontWeight.w700)),
    );
  }
}
