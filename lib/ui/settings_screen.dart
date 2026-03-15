import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.game.overlays.remove('Settings');
      },
      child: Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _entryController,
        builder: (context, child) {
          return Container(
            color: Colors.black.withValues(alpha: 0.95 * _entryAnim.value),
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
                  // Header
                  Row(
                    children: [
                      const Icon(Icons.settings, color: GameTheme.accent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '설정',
                        style: GameTheme.pixel(
                          fontSize: 14,
                          color: GameTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      GameTheme.closeButton(
                        onTap: () => widget.game.overlays.remove('Settings'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Divider
                  Container(
                    height: 1,
                    color: GameTheme.pixelBorder.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 16),
                  // Divider
                  Container(
                    height: 1,
                    color: GameTheme.pixelBorder.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  // Divider
                  Container(
                    height: 1,
                    color: GameTheme.pixelBorder.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  // Color-blind mode
                  _buildDropdownRow(
                    icon: Icons.accessibility_new,
                    label: '색각 보정',
                    value: GameTheme.colorBlindMode,
                    items: const [
                      DropdownMenuItem(
                        value: ColorBlindMode.none,
                        child: Text('없음', style: TextStyle(fontSize: 12)),
                      ),
                      DropdownMenuItem(
                        value: ColorBlindMode.protanopia,
                        child: Text('적색맹', style: TextStyle(fontSize: 12)),
                      ),
                      DropdownMenuItem(
                        value: ColorBlindMode.deuteranopia,
                        child: Text('녹색맹', style: TextStyle(fontSize: 12)),
                      ),
                      DropdownMenuItem(
                        value: ColorBlindMode.tritanopia,
                        child: Text('청색맹', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => GameTheme.setColorBlindMode(v));
                        _saveAccessibility();
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  // UI Scale
                  _buildSliderRow(
                    label: 'UI 크기',
                    value: (GameTheme.uiScale - 0.8) / 0.7, // normalize 0.8-1.5 to 0-1
                    enabled: true,
                    onChanged: (v) {
                      setState(() => GameTheme.setUiScale(0.8 + v * 0.7));
                      _saveAccessibility();
                    },
                  ),
                  const SizedBox(height: 16),
                  // Data reset button
                  GameTheme.pixelButton(
                    label: '데이터 초기화',
                    onTap: () => _showResetDialog(context),
                    color: GameTheme.accentRed.withValues(alpha: 0.6),
                    fontSize: 7,
                    verticalPad: 8,
                    horizontalPad: 16,
                    icon: Icons.delete_forever,
                  ),
                  const SizedBox(height: 16),
                  // Version & credits
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: GameTheme.bgDeep.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(GameTheme.radiusSm),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Paw Defense v1.0.0',
                          style: GameTheme.pixel(
                            fontSize: 6,
                            color: GameTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Made with Flutter + Flame',
                          style: GameTheme.pixel(
                            fontSize: 5,
                            color: GameTheme.textMuted.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: GameTheme.bgPanel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GameTheme.radiusMd),
            side: BorderSide(
              color: GameTheme.accentRed.withValues(alpha: 0.3),
            ),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber, color: GameTheme.accentRed, size: 20),
              const SizedBox(width: 8),
              Text(
                '데이터 초기화',
                style: GameTheme.pixel(
                  fontSize: 10,
                  color: GameTheme.accentRed,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Text(
            '모든 진행 데이터가 삭제됩니다.\n(별, 업그레이드, 업적 등)\n\n이 작업은 되돌릴 수 없습니다.',
            style: TextStyle(
              color: GameTheme.textPrimary,
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                '취소',
                style: GameTheme.pixel(
                  fontSize: 8,
                  color: GameTheme.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await widget.game.saveManager.resetAll();
                await widget.game.achievementManager.save();
                // Reload state
                widget.game.stars = 0;
                widget.game.souls = 0;
                widget.game.highestWave = 0;
                widget.game.totalRuns = 0;
                widget.game.totalKills = 0;
                widget.game.totalStarsEarned = 0;
                widget.game.totalBossKills = 0;
                widget.game.upgradeManager.resetAll();
                widget.game.overlays.remove('Settings');
              },
              child: Text(
                '초기화',
                style: GameTheme.pixel(
                  fontSize: 8,
                  color: GameTheme.accentRed,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: GameTheme.bgDeep.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(GameTheme.radiusSm),
      ),
      child: Row(
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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
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
                    boxShadow: value
                        ? [
                            BoxShadow(
                              color: GameTheme.accentGreen.withValues(alpha: 0.3),
                              blurRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAccessibility() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('accessibility_colorBlind', GameTheme.colorBlindMode.index);
    prefs.setDouble('accessibility_uiScale', GameTheme.uiScale);
  }

  Widget _buildDropdownRow<T>({
    required IconData icon,
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: GameTheme.bgDeep.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(GameTheme.radiusSm),
      ),
      child: Row(
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
          Theme(
            data: ThemeData.dark().copyWith(
              canvasColor: GameTheme.bgCard,
            ),
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              underline: const SizedBox(),
              isDense: true,
              style: GameTheme.pixel(
                fontSize: 7,
                color: GameTheme.accent,
              ),
              dropdownColor: GameTheme.bgCard,
            ),
          ),
        ],
      ),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: GameTheme.bgDeep.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${(value * 100).round()}%',
                style: GameTheme.pixel(
                  fontSize: 6,
                  color: enabled
                      ? GameTheme.accentGold
                      : GameTheme.textMuted,
                ),
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
