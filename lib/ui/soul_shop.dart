import 'package:flutter/material.dart';
import '../game/runner_game.dart';
import '../data/soul_upgrade_data.dart';
import '../data/region_data.dart';
import 'game_theme.dart';

class SoulShop extends StatefulWidget {
  final RunnerGame game;
  const SoulShop({super.key, required this.game});

  @override
  State<SoulShop> createState() => _SoulShopState();
}

class _SoulShopState extends State<SoulShop>
    with SingleTickerProviderStateMixin {
  int _tabIndex = 0;
  late AnimationController _entryController;

  final _tabs = const ['강화', '지역', '장비'];

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
    final manager = game.ascensionManager;

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
                            color: GameTheme.accentPurple.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.auto_awesome,
                              color: GameTheme.accentPurple, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('영구 업그레이드',
                                style: GameTheme.titleMedium.copyWith(
                                    fontSize: 20,
                                    color: GameTheme.accentPurple)),
                            Text('초월해도 유지되는 영구 강화',
                                style: GameTheme.bodySmall),
                          ],
                        ),
                        const Spacer(),
                        GameTheme.currencyDisplay(
                          value: '${manager.souls}',
                          isSoul: true,
                        ),
                        const SizedBox(width: 8),
                        GameTheme.closeButton(
                            onTap: () => game.closeSoulShop()),
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
                      children: List.generate(_tabs.length, (i) {
                        final isSelected = _tabIndex == i;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _tabIndex = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? GameTheme.accentPurple.withValues(alpha: 0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: isSelected
                                    ? Border.all(
                                        color: GameTheme.accentPurple
                                            .withValues(alpha: 0.4))
                                    : null,
                              ),
                              child: Text(
                                _tabs[i],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected
                                      ? GameTheme.accentPurple
                                      : GameTheme.textMuted,
                                  fontSize: 13,
                                  fontWeight:
                                      isSelected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── 콘텐츠 ──
                  Expanded(child: _buildContent()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    switch (_tabIndex) {
      case 1:
        return _buildRegions();
      case 2:
        return _buildEquipment();
      default:
        return _buildUpgrades();
    }
  }

  Widget _buildUpgrades() {
    final ids = [
      SoulUpgradeId.coinMultiplier,
      SoulUpgradeId.startSpeed,
      SoulUpgradeId.offlineEfficiency,
      SoulUpgradeId.comboBooster,
      SoulUpgradeId.autoAirKill,
      SoulUpgradeId.autoUpgrade,
    ];
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      itemCount: ids.length,
      itemBuilder: (context, i) => _buildSoulCard(ids[i]),
    );
  }

  Widget _buildRegions() {
    final manager = widget.game.ascensionManager;
    final regionIds = [
      SoulUpgradeId.regionForest,
      SoulUpgradeId.regionDesert,
      SoulUpgradeId.regionSnowfield,
      SoulUpgradeId.regionVolcano,
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      children: [
        // 현재 지역 + 해금된 지역 선택
        GameTheme.sectionHeader(title: '지역 선택', color: GameTheme.accentPurple),
        ...manager.unlockedRegionIds.map((id) {
          final region = RegionDatabase.getRegion(id);
          final isCurrent = widget.game.currentRegionId == id;
          return _RegionCard(
            region: region,
            isCurrent: isCurrent,
            onTap: isCurrent
                ? null
                : () {
                    widget.game.changeRegion(id);
                    setState(() {});
                  },
          );
        }),

        const SizedBox(height: 16),
        GameTheme.sectionHeader(title: '지역 해금', color: GameTheme.accentPurple),
        ...regionIds.map((id) => _buildSoulCard(id)),
      ],
    );
  }

  Widget _buildEquipment() {
    final ids = [
      SoulUpgradeId.equipBow,
      SoulUpgradeId.equipGauntlet,
      SoulUpgradeId.equipCloak,
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      children: [
        GameTheme.sectionHeader(title: '장비', color: GameTheme.accentPurple),
        ...ids.map((id) => _buildSoulCard(id)),
      ],
    );
  }

  Widget _buildSoulCard(SoulUpgradeId id) {
    final manager = widget.game.ascensionManager;
    final data = SoulUpgradeDatabase.get(id);
    final level = manager.getSoulLevel(id);
    final isMaxed = manager.isSoulMaxed(id);
    final cost = isMaxed ? 0 : manager.getSoulCost(id);
    final canBuy = manager.canAffordSoul(id);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isMaxed
            ? GameTheme.accentPurple.withValues(alpha: 0.08)
            : GameTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMaxed
              ? GameTheme.accentPurple.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.05),
        ),
        boxShadow: isMaxed
            ? [
                BoxShadow(
                  color: GameTheme.accentPurple.withValues(alpha: 0.1),
                  blurRadius: 8,
                )
              ]
            : null,
      ),
      child: Row(
        children: [
          // 아이콘
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: GameTheme.accentPurple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getSoulIcon(id),
              color: isMaxed
                  ? GameTheme.accentPurple
                  : GameTheme.textMuted,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),

          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(data.name, style: GameTheme.labelBold.copyWith(fontSize: 13)),
                    const SizedBox(width: 6),
                    if (data.maxLevel > 1)
                      Text(
                        isMaxed ? 'MAX' : 'Lv.$level/${data.maxLevel}',
                        style: TextStyle(
                          color: isMaxed
                              ? GameTheme.accentPurple
                              : GameTheme.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else if (isMaxed)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: GameTheme.accentGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('해금됨',
                            style: TextStyle(
                                color: GameTheme.accentGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text('${data.description}  (${data.effectUnit})',
                    style: GameTheme.bodySmall.copyWith(fontSize: 11)),
              ],
            ),
          ),

          // 구매 버튼
          if (!isMaxed)
            GestureDetector(
              onTap: canBuy ? () => _buySoul(id) : null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  gradient: canBuy ? GameTheme.gradientPurple : null,
                  color: canBuy ? null : GameTheme.bgCard,
                  borderRadius: BorderRadius.circular(8),
                  border: canBuy
                      ? null
                      : Border.all(
                          color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome,
                        color: canBuy
                            ? Colors.white
                            : GameTheme.textMuted,
                        size: 13),
                    const SizedBox(width: 4),
                    Text(
                      '$cost',
                      style: TextStyle(
                        color: canBuy ? Colors.white : GameTheme.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: GameTheme.accentPurple.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.check,
                  color: GameTheme.accentPurple, size: 16),
            ),
        ],
      ),
    );
  }

  IconData _getSoulIcon(SoulUpgradeId id) {
    switch (id) {
      case SoulUpgradeId.coinMultiplier:
        return Icons.monetization_on;
      case SoulUpgradeId.startSpeed:
        return Icons.speed;
      case SoulUpgradeId.offlineEfficiency:
        return Icons.schedule;
      case SoulUpgradeId.comboBooster:
        return Icons.whatshot;
      case SoulUpgradeId.autoAirKill:
        return Icons.flight;
      case SoulUpgradeId.autoUpgrade:
        return Icons.smart_toy;
      case SoulUpgradeId.regionForest:
        return Icons.park;
      case SoulUpgradeId.regionDesert:
        return Icons.wb_sunny;
      case SoulUpgradeId.regionSnowfield:
        return Icons.ac_unit;
      case SoulUpgradeId.regionVolcano:
        return Icons.local_fire_department;
      case SoulUpgradeId.equipBow:
        return Icons.gps_fixed;
      case SoulUpgradeId.equipGauntlet:
        return Icons.front_hand;
      case SoulUpgradeId.equipCloak:
        return Icons.air;
    }
  }

  void _buySoul(SoulUpgradeId id) {
    final cost = widget.game.ascensionManager.buySoulUpgrade(id);
    if (cost > 0) {
      widget.game.saveGame();
      setState(() {});
    }
  }
}

class _RegionCard extends StatelessWidget {
  final RegionData region;
  final bool isCurrent;
  final VoidCallback? onTap;

  const _RegionCard({
    required this.region,
    required this.isCurrent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrent
              ? region.skyColor.withValues(alpha: 0.15)
              : GameTheme.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrent
                ? GameTheme.accentGold.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.05),
            width: isCurrent ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // 지역 색상 미리보기
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [region.skyColor, region.grassColor],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(region.name,
                  style: GameTheme.labelBold.copyWith(fontSize: 14)),
            ),
            if (isCurrent)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: GameTheme.accentGold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('현재',
                    style: TextStyle(
                        color: GameTheme.accentGold,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            const SizedBox(width: 8),
            Text('x${region.coinMultiplier.toStringAsFixed(0)}',
                style: TextStyle(
                    color: GameTheme.accentGold,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
