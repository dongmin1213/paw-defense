import 'dart:math';

enum SoulUpgradeId {
  coinMultiplier,
  startSpeed,
  offlineEfficiency,
  regionForest,
  regionDesert,
  regionSnowfield,
  regionVolcano,
  equipBow,
  equipGauntlet,
  equipCloak,
  autoAirKill,
  autoUpgrade,
  comboBooster,
}

class SoulUpgradeData {
  final SoulUpgradeId id;
  final String name;
  final String description;
  final int maxLevel;
  final String effectUnit;

  /// For fixed cost: each level costs this
  /// For scaling cost: first level costs this, then doubles
  final int baseSoulCost;
  final bool scalingCost;

  const SoulUpgradeData({
    required this.id,
    required this.name,
    required this.description,
    required this.maxLevel,
    required this.baseSoulCost,
    required this.effectUnit,
    this.scalingCost = false,
  });

  int costAt(int currentLevel) {
    if (scalingCost) {
      return baseSoulCost * pow(2, currentLevel).toInt();
    }
    return baseSoulCost;
  }
}

class SoulUpgradeDatabase {
  static const List<SoulUpgradeData> upgrades = [
    SoulUpgradeData(
      id: SoulUpgradeId.coinMultiplier,
      name: '코인 배율',
      description: '모든 코인 획득량 +25%',
      maxLevel: 999,
      baseSoulCost: 1,
      effectUnit: '+25%',
      scalingCost: true,
    ),
    SoulUpgradeData(
      id: SoulUpgradeId.startSpeed,
      name: '시작 속도',
      description: '초월 후 시작 이동속도 +10%',
      maxLevel: 10,
      baseSoulCost: 2,
      effectUnit: '+10%',
    ),
    SoulUpgradeData(
      id: SoulUpgradeId.offlineEfficiency,
      name: '오프라인 효율',
      description: '오프라인 수익 +15%',
      maxLevel: 10,
      baseSoulCost: 3,
      effectUnit: '+15%',
    ),
    SoulUpgradeData(
      id: SoulUpgradeId.regionForest,
      name: '숲 해금',
      description: '숲 지역 진입 가능 (코인 x3)',
      maxLevel: 1,
      baseSoulCost: 5,
      effectUnit: '해금',
    ),
    SoulUpgradeData(
      id: SoulUpgradeId.regionDesert,
      name: '사막 해금',
      description: '사막 지역 진입 가능 (코인 x10)',
      maxLevel: 1,
      baseSoulCost: 15,
      effectUnit: '해금',
    ),
    SoulUpgradeData(
      id: SoulUpgradeId.regionSnowfield,
      name: '설산 해금',
      description: '설산 지역 진입 가능 (코인 x30)',
      maxLevel: 1,
      baseSoulCost: 50,
      effectUnit: '해금',
    ),
    SoulUpgradeData(
      id: SoulUpgradeId.regionVolcano,
      name: '화산 해금',
      description: '화산 지역 진입 가능 (코인 x100)',
      maxLevel: 1,
      baseSoulCost: 150,
      effectUnit: '해금',
    ),
    SoulUpgradeData(
      id: SoulUpgradeId.equipBow,
      name: '활 해금',
      description: '점프 중 자동 화살 발사',
      maxLevel: 1,
      baseSoulCost: 10,
      effectUnit: '해금',
    ),
    SoulUpgradeData(
      id: SoulUpgradeId.equipGauntlet,
      name: '장갑 해금',
      description: '처치 시 추가 코인 드랍',
      maxLevel: 1,
      baseSoulCost: 30,
      effectUnit: '해금',
    ),
    SoulUpgradeData(
      id: SoulUpgradeId.equipCloak,
      name: '망토 해금',
      description: '2단 대시, 이동속도 보너스',
      maxLevel: 1,
      baseSoulCost: 80,
      effectUnit: '해금',
    ),
    SoulUpgradeData(
      id: SoulUpgradeId.autoAirKill,
      name: '자동 공중 처치',
      description: '방치 중에도 공중 적 자동 처치',
      maxLevel: 1,
      baseSoulCost: 50,
      effectUnit: '해금',
    ),
    SoulUpgradeData(
      id: SoulUpgradeId.autoUpgrade,
      name: '자동 업그레이드',
      description: '코인 충분하면 자동 구매',
      maxLevel: 1,
      baseSoulCost: 100,
      effectUnit: '해금',
    ),
    SoulUpgradeData(
      id: SoulUpgradeId.comboBooster,
      name: '콤보 부스터',
      description: '콤보당 추가 배율 +0.02',
      maxLevel: 5,
      baseSoulCost: 5,
      effectUnit: '+0.02',
    ),
  ];

  static SoulUpgradeData get(SoulUpgradeId id) {
    return upgrades.firstWhere((u) => u.id == id);
  }
}
