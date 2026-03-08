import 'dart:ui';

class RegionData {
  final String id;
  final String name;
  final double coinMultiplier;
  final Color skyColor;
  final Color groundColor;
  final Color groundAccentColor;
  final Color farBgColor;
  final Color midBgColor;
  final Color nearBgColor;
  final int soulUnlockCost;

  const RegionData({
    required this.id,
    required this.name,
    required this.coinMultiplier,
    required this.skyColor,
    required this.groundColor,
    required this.groundAccentColor,
    required this.farBgColor,
    required this.midBgColor,
    required this.nearBgColor,
    this.soulUnlockCost = 0,
  });
}

class RegionDatabase {
  static const List<RegionData> regions = [
    RegionData(
      id: 'meadow',
      name: '초원',
      coinMultiplier: 1.0,
      skyColor: Color(0xFF87CEEB),
      groundColor: Color(0xFF4A7C3F),
      groundAccentColor: Color(0xFF3A6230),
      farBgColor: Color(0xFF6EB5D6),
      midBgColor: Color(0xFF5A9E4B),
      nearBgColor: Color(0xFF4A8C3B),
      soulUnlockCost: 0,
    ),
    RegionData(
      id: 'forest',
      name: '숲',
      coinMultiplier: 3.0,
      skyColor: Color(0xFF4A6741),
      groundColor: Color(0xFF2E4B28),
      groundAccentColor: Color(0xFF1E3A18),
      farBgColor: Color(0xFF3A5A35),
      midBgColor: Color(0xFF2D4D26),
      nearBgColor: Color(0xFF1F3F18),
      soulUnlockCost: 5,
    ),
    RegionData(
      id: 'desert',
      name: '사막',
      coinMultiplier: 10.0,
      skyColor: Color(0xFFF4D03F),
      groundColor: Color(0xFFD4A843),
      groundAccentColor: Color(0xFFC49833),
      farBgColor: Color(0xFFE8C84A),
      midBgColor: Color(0xFFCCB040),
      nearBgColor: Color(0xFFB89830),
      soulUnlockCost: 15,
    ),
    RegionData(
      id: 'snowfield',
      name: '설산',
      coinMultiplier: 30.0,
      skyColor: Color(0xFFB0C4DE),
      groundColor: Color(0xFFE8E8E8),
      groundAccentColor: Color(0xFFD0D0D0),
      farBgColor: Color(0xFFA0B8D0),
      midBgColor: Color(0xFFC0D0E0),
      nearBgColor: Color(0xFFD8E0E8),
      soulUnlockCost: 50,
    ),
    RegionData(
      id: 'volcano',
      name: '화산',
      coinMultiplier: 100.0,
      skyColor: Color(0xFF4A1A1A),
      groundColor: Color(0xFF3A2A2A),
      groundAccentColor: Color(0xFF2A1A1A),
      farBgColor: Color(0xFF5A2020),
      midBgColor: Color(0xFF4A1818),
      nearBgColor: Color(0xFF3A1010),
      soulUnlockCost: 150,
    ),
  ];

  static RegionData getRegion(String id) {
    return regions.firstWhere(
      (r) => r.id == id,
      orElse: () => regions.first,
    );
  }
}
