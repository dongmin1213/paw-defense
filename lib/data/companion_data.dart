import 'dart:ui';

enum CompanionRarity { common, rare, epic, legendary }

class CompanionData {
  final String id;
  final String name;
  final CompanionRarity rarity;
  final double spawnChance; // out of 100
  final String buffDescription;
  final Color color;
  final Color accentColor;

  const CompanionData({
    required this.id,
    required this.name,
    required this.rarity,
    required this.spawnChance,
    required this.buffDescription,
    required this.color,
    required this.accentColor,
  });

  double get levelUpBaseCost {
    switch (rarity) {
      case CompanionRarity.common: return 100;
      case CompanionRarity.rare: return 300;
      case CompanionRarity.epic: return 800;
      case CompanionRarity.legendary: return 2000;
    }
  }

  double levelUpCost(int currentLevel) {
    return levelUpBaseCost * 1.3 * currentLevel;
  }
}

class CompanionDatabase {
  static const List<CompanionData> companions = [
    // Common (20% each)
    CompanionData(id: 'cat', name: '고양이', rarity: CompanionRarity.common, spawnChance: 20, buffDescription: '코인 +5%/lv', color: Color(0xFFFF9800), accentColor: Color(0xFFFFE0B2)),
    CompanionData(id: 'hamster', name: '햄스터', rarity: CompanionRarity.common, spawnChance: 20, buffDescription: '속도 +5%/lv', color: Color(0xFFFFCC80), accentColor: Color(0xFFFFF3E0)),
    CompanionData(id: 'rabbit', name: '토끼', rarity: CompanionRarity.common, spawnChance: 20, buffDescription: '점프력 +5%/lv', color: Color(0xFFF5F5F5), accentColor: Color(0xFFFFCDD2)),

    // Rare (10%, 10%, 8%)
    CompanionData(id: 'owl', name: '부엉이', rarity: CompanionRarity.rare, spawnChance: 10, buffDescription: '소울 +10%/lv', color: Color(0xFF8D6E63), accentColor: Color(0xFFD7CCC8)),
    CompanionData(id: 'fox', name: '여우', rarity: CompanionRarity.rare, spawnChance: 10, buffDescription: '콤보유지 +1초/lv', color: Color(0xFFFF5722), accentColor: Color(0xFFFFCCBC)),
    CompanionData(id: 'penguin', name: '펭귄', rarity: CompanionRarity.rare, spawnChance: 8, buffDescription: '장애물 무시 3%/lv', color: Color(0xFF263238), accentColor: Color(0xFFECEFF1)),

    // Epic (5%, 4%)
    CompanionData(id: 'wolf_c', name: '늑대', rarity: CompanionRarity.epic, spawnChance: 5, buffDescription: '공격력 +15%/lv', color: Color(0xFF546E7A), accentColor: Color(0xFFB0BEC5)),
    CompanionData(id: 'unicorn', name: '유니콘', rarity: CompanionRarity.epic, spawnChance: 4, buffDescription: '전체 스탯 +5%/lv', color: Color(0xFFE1BEE7), accentColor: Color(0xFFF3E5F5)),

    // Legendary (2%, 1%)
    CompanionData(id: 'dragon_c', name: '드래곤', rarity: CompanionRarity.legendary, spawnChance: 2, buffDescription: '전체 스탯 +8%/lv', color: Color(0xFFD32F2F), accentColor: Color(0xFFFFCDD2)),
    CompanionData(id: 'phoenix_c', name: '피닉스', rarity: CompanionRarity.legendary, spawnChance: 1, buffDescription: '초월 소울 +20%/lv', color: Color(0xFFFF6F00), accentColor: Color(0xFFFFE082)),
  ];

  static CompanionData get(String id) {
    return companions.firstWhere((c) => c.id == id, orElse: () => companions.first);
  }

  static Color rarityColor(CompanionRarity rarity) {
    switch (rarity) {
      case CompanionRarity.common: return const Color(0xFFBDBDBD);
      case CompanionRarity.rare: return const Color(0xFF42A5F5);
      case CompanionRarity.epic: return const Color(0xFFAB47BC);
      case CompanionRarity.legendary: return const Color(0xFFFFD600);
    }
  }

  static String rarityName(CompanionRarity rarity) {
    switch (rarity) {
      case CompanionRarity.common: return '일반';
      case CompanionRarity.rare: return '레어';
      case CompanionRarity.epic: return '에픽';
      case CompanionRarity.legendary: return '전설';
    }
  }
}
