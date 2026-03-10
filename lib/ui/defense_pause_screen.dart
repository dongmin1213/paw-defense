import 'package:flutter/material.dart';
import 'game_theme.dart';
import '../game/defense_game.dart';

/// Pause overlay for castle defense game.
class DefensePauseScreen extends StatefulWidget {
  final DefenseGame game;
  const DefensePauseScreen({super.key, required this.game});

  @override
  State<DefensePauseScreen> createState() => _DefensePauseScreenState();
}

class _DefensePauseScreenState extends State<DefensePauseScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _entryAnim;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _entryAnim = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    );
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _entryController,
        builder: (context, child) {
          return Container(
            color: Colors.black.withValues(alpha: 0.7 * _entryAnim.value),
            child: Opacity(
              opacity: _entryAnim.value.clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: SafeArea(
          child: Center(
            child: Container(
              width: 280,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: GameTheme.pixelPanelDecoration(
                fillColor: GameTheme.bgPanel,
                glow: true,
                glowColor: GameTheme.accent,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '일시 정지',
                    style: GameTheme.pixel(
                      fontSize: 14,
                      color: GameTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '웨이브 ${widget.game.currentWave}',
                    style: GameTheme.pixel(
                      fontSize: 8,
                      color: GameTheme.accent,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Stats summary
                  _buildStatRow('처치 수', '${widget.game.runKills}'),
                  const SizedBox(height: 6),
                  _buildStatRow(
                      '획득 골드', GameTheme.formatInt(widget.game.runGoldEarned)),
                  const SizedBox(height: 6),
                  _buildStatRow(
                      '유물', '${widget.game.relicManager.relicCount}/3'),
                  const SizedBox(height: 24),
                  // Resume button
                  GameTheme.pixelButton(
                    label: '계속하기',
                    onTap: () {
                      widget.game.overlays.remove('Pause');
                      widget.game.resumeGame();
                    },
                    gradient: GameTheme.gradientPrimary,
                    fontSize: 10,
                    verticalPad: 14,
                    horizontalPad: 32,
                    icon: Icons.play_arrow,
                  ),
                  const SizedBox(height: 12),
                  // Settings
                  GameTheme.pixelButton(
                    label: '설정',
                    onTap: () => widget.game.overlays.add('Settings'),
                    color: GameTheme.bgCard,
                    fontSize: 8,
                    verticalPad: 10,
                    horizontalPad: 24,
                    icon: Icons.settings,
                  ),
                  const SizedBox(height: 12),
                  // Quit to menu
                  GameTheme.pixelButton(
                    label: '포기하기',
                    onTap: () {
                      widget.game.overlays.remove('Pause');
                      widget.game.onWallDestroyed();
                    },
                    color: GameTheme.accentRed.withValues(alpha: 0.3),
                    fontSize: 8,
                    verticalPad: 10,
                    horizontalPad: 24,
                    icon: Icons.exit_to_app,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GameTheme.pixel(
            fontSize: 7,
            color: GameTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: GameTheme.pixel(
            fontSize: 8,
            color: GameTheme.accentGold,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
