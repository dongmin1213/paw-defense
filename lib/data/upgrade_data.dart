import '../data/balance_config.dart';

enum UpgradeId {
  moveSpeed,
  coinGain,
  attackPower,
  jumpPower,
  doubleJump,
  coinMagnet,
  comboRetain,
}

class UpgradeData {
  final UpgradeId id;
  final String name;
  final String description;
  final int maxLevel;
  final double baseCost;
  final double effectPerLevel;
  final String effectUnit;

  const UpgradeData({
    required this.id,
    required this.name,
    required this.description,
    required this.maxLevel,
    required this.baseCost,
    required this.effectPerLevel,
    required this.effectUnit,
  });

  double costAt(int level) {
    return BalanceConfig.upgradeCost(baseCost, level);
  }
}

class UpgradeDatabase {
  static const List<UpgradeData> upgrades = [
    UpgradeData(
      id: UpgradeId.moveSpeed,
      name: '이동속도',
      description: '달리기 속도 증가',
      maxLevel: 25,
      baseCost: 10,
      effectPerLevel: 0.05,
      effectUnit: '+5%',
    ),
    UpgradeData(
      id: UpgradeId.coinGain,
      name: '코인 획득',
      description: '코인 획득량 증가',
      maxLevel: 25,
      baseCost: 15,
      effectPerLevel: 0.08,
      effectUnit: '+8%',
    ),
    UpgradeData(
      id: UpgradeId.attackPower,
      name: '공격력',
      description: '적에게 주는 데미지 증가',
      maxLevel: 20,
      baseCost: 20,
      effectPerLevel: 0.10,
      effectUnit: '+10%',
    ),
    UpgradeData(
      id: UpgradeId.jumpPower,
      name: '점프력',
      description: '점프 높이 증가',
      maxLevel: 15,
      baseCost: 25,
      effectPerLevel: 0.05,
      effectUnit: '+5%',
    ),
    UpgradeData(
      id: UpgradeId.doubleJump,
      name: '더블점프',
      description: '공중에서 한 번 더 점프',
      maxLevel: 1,
      baseCost: 500,
      effectPerLevel: 1.0,
      effectUnit: '해금',
    ),
    UpgradeData(
      id: UpgradeId.coinMagnet,
      name: '코인 자석',
      description: '코인 흡수 반경 증가',
      maxLevel: 10,
      baseCost: 30,
      effectPerLevel: 20.0,
      effectUnit: '+20px',
    ),
    UpgradeData(
      id: UpgradeId.comboRetain,
      name: '콤보 유지',
      description: '콤보 리셋 대신 감소',
      maxLevel: 5,
      baseCost: 100,
      effectPerLevel: 0.10,
      effectUnit: '-10%',
    ),
  ];

  static UpgradeData get(UpgradeId id) {
    return upgrades.firstWhere((u) => u.id == id);
  }
}
