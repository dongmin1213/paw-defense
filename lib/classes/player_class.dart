import 'dart:ui';

enum PlayerClassType { knight, assassin, archer, mage, gunner }

class PlayerClassData {
  final PlayerClassType type;
  final String name;
  final String nameKo;
  final String description;
  final int maxHp;
  final double speed;
  final double attackDamage;
  final double fireRate;
  final double specialDamage;
  final Color color;
  final Color accentColor;

  const PlayerClassData({
    required this.type,
    required this.name,
    required this.nameKo,
    required this.description,
    required this.maxHp,
    required this.speed,
    required this.attackDamage,
    required this.fireRate,
    required this.specialDamage,
    required this.color,
    required this.accentColor,
  });

  static const Map<PlayerClassType, PlayerClassData> classes = {
    PlayerClassType.knight: PlayerClassData(
      type: PlayerClassType.knight,
      name: 'Knight',
      nameKo: '기사',
      description: '높은 체력과 방어력. 근거리 대검 공격.',
      maxHp: 5,
      speed: 160,
      attackDamage: 3.0,
      fireRate: 0.4,
      specialDamage: 20.0,
      color: Color(0xFFC0C0C0),
      accentColor: Color(0xFFCC3333),
    ),
    PlayerClassType.assassin: PlayerClassData(
      type: PlayerClassType.assassin,
      name: 'Assassin',
      nameKo: '암살자',
      description: '빠른 이동과 연속 공격. 그림자 텔레포트.',
      maxHp: 3,
      speed: 250,
      attackDamage: 1.5,
      fireRate: 0.1,
      specialDamage: 18.0,
      color: Color(0xFF4A4A4A),
      accentColor: Color(0xFF9B59B6),
    ),
    PlayerClassType.archer: PlayerClassData(
      type: PlayerClassType.archer,
      name: 'Archer',
      nameKo: '궁수',
      description: '원거리 화살. 차징으로 강력한 한 발.',
      maxHp: 3,
      speed: 200,
      attackDamage: 2.0,
      fireRate: 0.25,
      specialDamage: 15.0,
      color: Color(0xFF2E7D32),
      accentColor: Color(0xFF4CAF50),
    ),
    PlayerClassType.mage: PlayerClassData(
      type: PlayerClassType.mage,
      name: 'Mage',
      nameKo: '마법사',
      description: '관통 마법탄. 원소 전환 가능.',
      maxHp: 3,
      speed: 180,
      attackDamage: 2.5,
      fireRate: 0.3,
      specialDamage: 25.0,
      color: Color(0xFF5C3D99),
      accentColor: Color(0xFFE040FB),
    ),
    PlayerClassType.gunner: PlayerClassData(
      type: PlayerClassType.gunner,
      name: 'Gunner',
      nameKo: '건너',
      description: '폭발탄으로 범위 공격. 넉백 효과.',
      maxHp: 4,
      speed: 170,
      attackDamage: 4.0,
      fireRate: 0.6,
      specialDamage: 30.0,
      color: Color(0xFF8D6E63),
      accentColor: Color(0xFFFF5722),
    ),
  };

  static PlayerClassData get(PlayerClassType type) => classes[type]!;
}
