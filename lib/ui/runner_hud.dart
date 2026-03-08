import 'dart:async';
import 'package:flutter/material.dart';
import '../game/runner_game.dart';

class RunnerHud extends StatefulWidget {
  final RunnerGame game;

  const RunnerHud({super.key, required this.game});

  @override
  State<RunnerHud> createState() => _RunnerHudState();
}

class _RunnerHudState extends State<RunnerHud> {
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _updateTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    return SafeArea(
      child: Stack(
        children: [
          // Top bar: distance + coins
          Positioned(
            top: 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Distance
                _buildInfoBox(
                  icon: Icons.straighten,
                  value: '${game.distanceInMeters.toStringAsFixed(0)}m',
                  color: Colors.white,
                ),
                // Coins
                _buildInfoBox(
                  icon: Icons.monetization_on,
                  value: _formatNumber(game.coins),
                  color: Colors.amber,
                ),
              ],
            ),
          ),

          // Combo counter (center)
          if (game.combo > 0)
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  children: [
                    Text(
                      '${game.combo}',
                      style: TextStyle(
                        fontSize: game.combo > 10 ? 48 : 36,
                        fontWeight: FontWeight.bold,
                        color: _comboColor(game.combo),
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'COMBO x${game.comboMultiplier.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _comboColor(game.combo).withValues(alpha: 0.8),
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 2,
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Mode indicator
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: game.isActiveMode
                      ? Colors.green.withValues(alpha: 0.7)
                      : Colors.grey.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  game.isActiveMode ? 'ACTIVE' : 'IDLE',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Shop button (bottom right)
          Positioned(
            bottom: 12,
            right: 16,
            child: GestureDetector(
              onTap: () => game.toggleShop(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.indigo.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shopping_cart, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text(
                      '상점',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _comboColor(int combo) {
    if (combo >= 20) return Colors.red;
    if (combo >= 10) return Colors.orange;
    if (combo >= 5) return Colors.yellow;
    return Colors.white;
  }

  String _formatNumber(double n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toInt().toString();
  }
}
