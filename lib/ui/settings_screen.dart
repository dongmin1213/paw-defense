import 'package:flutter/material.dart';
import 'game_theme.dart';
import '../game/defense_game.dart';

/// Settings overlay accessible from main menu and pause screen.
class SettingsScreen extends StatefulWidget {
  final DefenseGame game;
  const SettingsScreen({super.key, required this.game});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
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
    final sound = widget.game.soundManager;

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
              width: 300,
              padding:
                  const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: GameTheme.pixelPanelDecoration(
                fillColor: GameTheme.bgPanel,
                glow: true,
                glowColor: GameTheme.accent,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '설정',
                    style: GameTheme.pixel(
                      fontSize: 14,
                      color: GameTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // BGM toggle
                  _buildToggleRow(
                    icon: Icons.music_note,
                    label: 'BGM',
                    value: sound.bgmEnabled,
                    onChanged: (v) {
                      setState(() => sound.setBgmEnabled(v));
                    },
                  ),
                  const SizedBox(height: 12),
                  // SFX toggle
                  _buildToggleRow(
                    icon: Icons.volume_up,
                    label: '효과음',
                    value: sound.sfxEnabled,
                    onChanged: (v) {
                      setState(() => sound.setSfxEnabled(v));
                    },
                  ),
                  const SizedBox(height: 12),
                  // Vibration toggle
                  _buildToggleRow(
                    icon: Icons.vibration,
                    label: '진동',
                    value: sound.vibrationEnabled,
                    onChanged: (v) {
                      setState(() => sound.setVibrationEnabled(v));
                    },
                  ),
                  const SizedBox(height: 24),
                  // BGM Volume
                  _buildSliderRow(
                    label: 'BGM 볼륨',
                    value: sound.bgmVolume,
                    enabled: sound.bgmEnabled,
                    onChanged: (v) {
                      setState(() => sound.setBgmVolume(v));
                    },
                  ),
                  const SizedBox(height: 8),
                  // SFX Volume
                  _buildSliderRow(
                    label: '효과음 볼륨',
                    value: sound.sfxVolume,
                    enabled: sound.sfxEnabled,
                    onChanged: (v) {
                      setState(() => sound.setSfxVolume(v));
                    },
                  ),
                  const SizedBox(height: 24),
                  // Close button
                  GameTheme.pixelButton(
                    label: '닫기',
                    onTap: () {
                      widget.game.overlays.remove('Settings');
                    },
                    gradient: GameTheme.gradientPrimary,
                    fontSize: 10,
                    verticalPad: 12,
                    horizontalPad: 32,
                    icon: Icons.close,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: GameTheme.textSecondary, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: GameTheme.pixel(
            fontSize: 8,
            color: GameTheme.textPrimary,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: Container(
            width: 44,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: value
                  ? GameTheme.accentGreen.withValues(alpha: 0.6)
                  : GameTheme.bgDeep,
              border: Border.all(
                color: value ? GameTheme.accentGreen : GameTheme.pixelBorder,
              ),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 150),
              alignment:
                  value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 18,
                height: 18,
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: value ? GameTheme.accentGreen : GameTheme.textMuted,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliderRow({
    required String label,
    required double value,
    required bool enabled,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GameTheme.pixel(
                fontSize: 6,
                color: enabled
                    ? GameTheme.textSecondary
                    : GameTheme.textMuted,
              ),
            ),
            const Spacer(),
            Text(
              '${(value * 100).round()}%',
              style: GameTheme.pixel(
                fontSize: 6,
                color: enabled
                    ? GameTheme.accentGold
                    : GameTheme.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            activeTrackColor:
                enabled ? GameTheme.accent : GameTheme.textMuted,
            inactiveTrackColor: GameTheme.bgDeep,
            thumbColor:
                enabled ? GameTheme.accent : GameTheme.textMuted,
            overlayColor: GameTheme.accent.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: value,
            onChanged: enabled ? onChanged : null,
          ),
        ),
      ],
    );
  }
}
