import 'package:flutter/material.dart';
import 'game_theme.dart';
import '../game/defense_game.dart';

/// Performance rank based on wave cleared.
enum RunRank {
  f('F', 'Beginner', 0xFF888888, 0),
  d('D', 'Novice', 0xFF8888FF, 5),
  c('C', 'Fighter', 0xFF88FF88, 10),
  b('B', 'Warrior', 0xFF88FFFF, 15),
  a('A', 'Champion', 0xFFFFCC44, 25),
  s('S', 'Master', 0xFFFF8844, 35),
  ss('SS', 'Legend', 0xFFFF44FF, 50);

  final String label;
  final String title;
  final int color;
  final int minWave;

  const RunRank(this.label, this.title, this.color, this.minWave);

  static RunRank fromWave(int wave) {
    final ranks = RunRank.values.reversed;
    for (final r in ranks) {
      if (wave >= r.minWave) return r;
    }
    return RunRank.f;
  }
}

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

  late AnimationController _rankRevealController;
  late Animation<double> _rankScale;

  bool _showButtons = false;
  bool _isNewRecord = false;
  late RunRank _rank;

  @override
  void initState() {
    super.initState();

    _rank = RunRank.fromWave(widget.wavesCleared);
    _isNewRecord = widget.wavesCleared >= widget.game.highestWave &&
        widget.wavesCleared > 0;

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

    // Stats reveal (staggered) - 5 stats now
    _statsRevealController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _statAnimations = List.generate(5, (i) {
      final start = i * 0.15;
      final end = (start + 0.35).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _statsRevealController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );
    });

    // Rank reveal animation
    _rankRevealController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _rankScale = Tween<double>(begin: 3.0, end: 1.0).animate(
      CurvedAnimation(parent: _rankRevealController, curve: Curves.elasticOut),
    );

    // Sequence: entry -> rank -> stats -> star count -> buttons
    _entryController.forward().then((_) {
      if (!mounted) return;
      _rankRevealController.forward().then((_) {
        if (!mounted) return;
        _statsRevealController.forward().then((_) {
          if (!mounted) return;
          _starCountController.forward().then((_) {
            if (!mounted) return;
            setState(() => _showButtons = true);
          });
        });
      });
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _starCountController.dispose();
    _statsRevealController.dispose();
    _rankRevealController.dispose();
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildTitle(),
                  const SizedBox(height: 16),
                  _buildRankBadge(),
                  const SizedBox(height: 16),
                  _buildStatsPanel(),
                  const SizedBox(height: 10),
                  _buildBuildSummary(),
                  const SizedBox(height: 10),
                  _buildStarReward(),
                  const SizedBox(height: 20),
                  if (_showButtons) _buildButtons(),
                  const SizedBox(height: 16),
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
        const SizedBox(height: 6),
        Text(
          '성벽이 무너졌습니다',
          style: GameTheme.pixel(
            fontSize: 8,
            color: GameTheme.textSecondary,
          ),
        ),
        if (_isNewRecord) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: GameTheme.pixelCardDecoration(
              fillColor: GameTheme.accentGold.withValues(alpha: 0.15),
              borderColor: GameTheme.accentGold,
              glow: true,
              glowColor: GameTheme.accentGold,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, color: GameTheme.accentGold, size: 16),
                const SizedBox(width: 6),
                Text(
                  'NEW RECORD!',
                  style: GameTheme.pixel(
                    fontSize: 10,
                    color: GameTheme.accentGold,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRankBadge() {
    final rankColor = Color(_rank.color);

    return AnimatedBuilder(
      animation: _rankRevealController,
      builder: (context, child) {
        return Opacity(
          opacity: _rankRevealController.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: _rankScale.value,
            child: child,
          ),
        );
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: rankColor, width: 3),
          boxShadow: [
            BoxShadow(
              color: rankColor.withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
          gradient: RadialGradient(
            colors: [
              rankColor.withValues(alpha: 0.25),
              rankColor.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _rank.label,
              style: GameTheme.pixel(
                fontSize: 24,
                color: rankColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              _rank.title,
              style: GameTheme.pixel(
                fontSize: 6,
                color: rankColor.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsPanel() {
    final dps = widget.killCount > 0 && widget.wavesCleared > 0
        ? (widget.killCount / (widget.wavesCleared * 10)).toStringAsFixed(1)
        : '0.0';

    final stats = [
      _StatEntry(
        icon: Icons.waves,
        label: '클리어 웨이브',
        value: '${widget.wavesCleared}',
        valueColor: GameTheme.accent,
      ),
      _StatEntry(
        icon: Icons.dangerous,
        label: '처치 수',
        value: GameTheme.formatInt(widget.killCount),
        valueColor: GameTheme.accentRed,
      ),
      _StatEntry(
        icon: Icons.speed,
        label: '초당 처치',
        value: '$dps/s',
        valueColor: GameTheme.accentOrange,
      ),
      _StatEntry(
        icon: Icons.monetization_on,
        label: '획득 골드',
        value: GameTheme.formatInt(widget.goldEarned),
        valueColor: GameTheme.accentGold,
      ),
      _StatEntry(
        icon: Icons.emoji_events,
        label: '최고 기록',
        value: '${widget.game.highestWave}',
        valueColor: _isNewRecord ? GameTheme.accentGold : GameTheme.textSecondary,
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(stat.icon, color: stat.valueColor.withValues(alpha: 0.7), size: 14),
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
              color: stat.valueColor,
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
              const Icon(
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
          const SizedBox(height: 4),
          Text(
            '보유: ${GameTheme.formatInt(widget.game.stars)}',
            style: GameTheme.pixel(
              fontSize: 6,
              color: GameTheme.textMuted,
            ),
          ),
          // Soul reward display
          if (widget.game.lastRunSouls > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('👻', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  '+${widget.game.lastRunSouls} 소울',
                  style: GameTheme.pixel(
                    fontSize: 12,
                    color: const Color(0xFF80CBC4),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Text(
              '보유: ${GameTheme.formatInt(widget.game.souls)} 소울',
              style: GameTheme.pixel(
                fontSize: 6,
                color: GameTheme.textMuted,
              ),
            ),
          ],
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
  final Color valueColor;

  const _StatEntry({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor = GameTheme.accentGold,
  });
}
