import 'package:flutter/material.dart';
import 'game_theme.dart';
import '../game/defense_game.dart';

/// Run result screen shown when the wall is destroyed.
class RunResultScreen extends StatefulWidget {
  final DefenseGame game;
  final int wavesCleared;
  final int goldEarned;
  final int starsEarned;
  final int killCount;

  const RunResultScreen({
    super.key,
    required this.game,
    required this.wavesCleared,
    required this.goldEarned,
    required this.starsEarned,
    required this.killCount,
  });

  @override
  State<RunResultScreen> createState() => _RunResultScreenState();
}

class _RunResultScreenState extends State<RunResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _entryFade;
  late Animation<double> _entryScale;

  late AnimationController _starCountController;
  int _displayedStars = 0;

  late AnimationController _statsRevealController;
  late List<Animation<double>> _statAnimations;

  bool _showButtons = false;

  @override
  void initState() {
    super.initState();

    // Entry animation
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _entryFade = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
    _entryScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );

    // Star count-up animation
    _starCountController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _starCountController.addListener(() {
      setState(() {
        _displayedStars =
            (widget.starsEarned * Curves.easeOut.transform(_starCountController.value))
                .round();
      });
    });

    // Stats reveal (staggered)
    _statsRevealController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _statAnimations = List.generate(4, (i) {
      final start = i * 0.2;
      final end = (start + 0.4).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _statsRevealController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );
    });

    // Sequence: entry -> stats -> star count -> buttons
    _entryController.forward().then((_) {
      if (!mounted) return;
      _statsRevealController.forward().then((_) {
        if (!mounted) return;
        _starCountController.forward().then((_) {
          if (!mounted) return;
          setState(() => _showButtons = true);
        });
      });
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _starCountController.dispose();
    _statsRevealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _entryController,
        builder: (context, child) {
          return Opacity(
            opacity: _entryFade.value.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: _entryScale.value,
              child: child,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF0A0A18).withValues(alpha: 0.95),
                const Color(0xFF1A0A0A).withValues(alpha: 0.95),
                const Color(0xFF0A0A18).withValues(alpha: 0.95),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  _buildTitle(),
                  const SizedBox(height: 24),
                  _buildStatsPanel(),
                  const SizedBox(height: 12),
                  _buildBuildSummary(),
                  const SizedBox(height: 12),
                  _buildStarReward(),
                  const Spacer(flex: 1),
                  if (_showButtons) _buildButtons(),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) {
            return GameTheme.gradientRed.createShader(bounds);
          },
          child: Text(
            '방어 실패!',
            style: GameTheme.pixel(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '성벽이 무너졌습니다',
          style: GameTheme.pixel(
            fontSize: 8,
            color: GameTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsPanel() {
    final stats = [
      _StatEntry(icon: Icons.waves, label: '클리어 웨이브', value: '${widget.wavesCleared}'),
      _StatEntry(icon: Icons.dangerous, label: '처치 수', value: GameTheme.formatInt(widget.killCount)),
      _StatEntry(icon: Icons.monetization_on, label: '획득 골드', value: GameTheme.formatInt(widget.goldEarned)),
      _StatEntry(icon: Icons.timer, label: '최고 기록', value: '${widget.game.highestWave}'),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: GameTheme.pixelPanelDecoration(
        fillColor: GameTheme.bgCard,
      ),
      child: Column(
        children: [
          Text(
            '런 결과',
            style: GameTheme.pixel(
              fontSize: 9,
              color: GameTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(stats.length, (i) {
            return AnimatedBuilder(
              animation: _statAnimations[i],
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    30 * (1 - _statAnimations[i].value),
                    0,
                  ),
                  child: Opacity(
                    opacity: _statAnimations[i].value.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: _buildStatRow(stats[i]),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatRow(_StatEntry stat) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(stat.icon, color: GameTheme.textSecondary, size: 16),
          const SizedBox(width: 8),
          Text(
            stat.label,
            style: GameTheme.pixel(
              fontSize: 7,
              color: GameTheme.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            stat.value,
            style: GameTheme.pixel(
              fontSize: 9,
              color: GameTheme.accentGold,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarReward() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: GameTheme.pixelPanelDecoration(
        fillColor: GameTheme.bgDeep,
        glow: true,
        glowColor: GameTheme.accentPurple,
      ),
      child: Column(
        children: [
          Text(
            '획득 별',
            style: GameTheme.pixel(
              fontSize: 7,
              color: GameTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome,
                color: GameTheme.accentPurple,
                size: 22,
              ),
              const SizedBox(width: 8),
              AnimatedBuilder(
                animation: _starCountController,
                builder: (context, _) {
                  return Text(
                    '+$_displayedStars',
                    style: GameTheme.pixel(
                      fontSize: 18,
                      color: GameTheme.accentPurple,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBuildSummary() {
    final summary = widget.game.runSummary;
    final unitCounts = summary['unitCounts'] as Map<String, int>;
    final relicIcons = summary['relicIcons'] as List<String>;
    final maxCombo = summary['maxCombo'] as int;
    final bossKills = summary['bossKills'] as int;
    final hybridCount = summary['hybridCount'] as int;
    final highestLevel = summary['highestLevel'] as int;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: GameTheme.pixelCardDecoration(
        fillColor: GameTheme.bgDeep.withValues(alpha: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '빌드 요약',
            style: GameTheme.pixel(
              fontSize: 8,
              color: GameTheme.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          // Unit composition
          if (unitCounts.isNotEmpty)
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: unitCounts.entries.map((e) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: GameTheme.pixelCardDecoration(fillColor: GameTheme.bgCard),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(e.key, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 2),
                      Text('x${e.value}',
                          style: GameTheme.pixel(fontSize: 6, color: GameTheme.textSecondary)),
                    ],
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 6),
          // Extra stats row
          Row(
            children: [
              if (highestLevel > 0)
                _miniStat('최고 Lv', '$highestLevel', GameTheme.accentGold),
              if (maxCombo > 0)
                _miniStat('최대 콤보', '$maxCombo', GameTheme.accentOrange),
              if (bossKills > 0)
                _miniStat('보스 처치', '$bossKills', GameTheme.accentRed),
              if (hybridCount > 0)
                _miniStat('하이브리드', '$hybridCount', GameTheme.accentPurple),
            ],
          ),
          // Relics
          if (relicIcons.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Text('유물 ', style: GameTheme.pixel(fontSize: 6, color: GameTheme.textMuted)),
                ...relicIcons.map((icon) => Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Text(icon, style: const TextStyle(fontSize: 12)),
                    )),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: GameTheme.pixel(fontSize: 8, color: color, fontWeight: FontWeight.w700)),
          Text(label, style: GameTheme.pixel(fontSize: 5, color: GameTheme.textMuted)),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return AnimatedOpacity(
      opacity: _showButtons ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Column(
        children: [
          // Ad bonus button (placeholder)
          GameTheme.pixelButton(
            label: '광고 시청 x2',
            onTap: () {
              // Placeholder: would show ad then double stars
            },
            gradient: GameTheme.gradientGold,
            fontSize: 9,
            verticalPad: 12,
            horizontalPad: 28,
            icon: Icons.play_circle_outline,
          ),
          const SizedBox(height: 12),
          // Restart button
          GameTheme.pixelButton(
            label: '바로 재시작',
            onTap: () => widget.game.startGame(),
            gradient: GameTheme.gradientPrimary,
            fontSize: 10,
            verticalPad: 14,
            horizontalPad: 32,
            icon: Icons.replay,
          ),
          const SizedBox(height: 10),
          // Main menu button
          GameTheme.pixelButton(
            label: '메인 메뉴',
            onTap: () => widget.game.goToMainMenu(),
            color: GameTheme.bgPanel,
            fontSize: 8,
            verticalPad: 10,
            horizontalPad: 24,
            icon: Icons.home,
          ),
        ],
      ),
    );
  }
}

class _StatEntry {
  final IconData icon;
  final String label;
  final String value;

  const _StatEntry({
    required this.icon,
    required this.label,
    required this.value,
  });
}
