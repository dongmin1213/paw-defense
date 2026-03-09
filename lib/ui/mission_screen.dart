import 'package:flutter/material.dart';
import '../game/runner_game.dart';
import '../data/mission_data.dart';
import '../systems/mission_manager.dart';
import 'game_theme.dart';

class MissionScreen extends StatefulWidget {
  final RunnerGame game;
  const MissionScreen({super.key, required this.game});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 520,
        height: 340,
        decoration: GameTheme.pixelPanelDecoration(
          fillColor: GameTheme.bgDark,
          glow: true,
          glowColor: GameTheme.accent,
        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDailyTab(),
                  _buildChallengeTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final mm = widget.game.missionManager;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: GameTheme.bgPanel,
        border: Border(
          bottom: BorderSide(
            color: GameTheme.pixelBorder,
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.assignment, color: GameTheme.accent, size: 18),
          const SizedBox(width: 8),
          Text('MISSIONS', style: GameTheme.pixel(
            fontSize: 10, color: GameTheme.accent, letterSpacing: 2,
          )),
          const Spacer(),
          Text(
            'Daily: ${mm.completedDailyCount}/3',
            style: GameTheme.pixel(fontSize: 7, color: GameTheme.accentGold),
          ),
          const SizedBox(width: 12),
          GameTheme.closeButton(onTap: () => widget.game.closeMissionScreen()),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: GameTheme.bgDeep,
        border: Border(
          bottom: BorderSide(color: GameTheme.pixelBorder, width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: GameTheme.accent,
        indicatorWeight: 3,
        labelStyle: GameTheme.pixel(fontSize: 7),
        unselectedLabelStyle: GameTheme.pixel(fontSize: 7, color: GameTheme.textMuted),
        labelColor: GameTheme.accent,
        unselectedLabelColor: GameTheme.textMuted,
        tabs: const [
          Tab(text: 'DAILY', height: 30),
          Tab(text: 'CHALLENGE', height: 30),
        ],
      ),
    );
  }

  Widget _buildDailyTab() {
    final missions = widget.game.missionManager.dailyMissions;
    if (missions.isEmpty) {
      return Center(
        child: Text('No missions yet', style: GameTheme.pixel(
          fontSize: 8, color: GameTheme.textMuted,
        )),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: missions.length,
      itemBuilder: (ctx, i) => _buildMissionCard(missions[i]),
    );
  }

  Widget _buildChallengeTab() {
    final challenges = MissionDatabase.challenges;
    final mm = widget.game.missionManager;
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: challenges.length,
      itemBuilder: (ctx, i) {
        final c = challenges[i];
        final progress = mm.challengeProgress(c.id);
        final completed = mm.isChallengeCompleted(c.id);
        return _buildChallengeCard(c, progress, completed);
      },
    );
  }

  Widget _buildMissionCard(ActiveMission mission) {
    final data = mission.data;
    final percent = data.target > 0
        ? (mission.progress / data.target).clamp(0.0, 1.0)
        : 0.0;
    final completed = mission.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: GameTheme.pixelCardDecoration(
        fillColor: completed
            ? GameTheme.accentGreen.withValues(alpha: 0.08)
            : GameTheme.bgCard,
        borderColor: completed
            ? GameTheme.accentGreen.withValues(alpha: 0.4)
            : GameTheme.pixelBorder,
        glow: completed,
        glowColor: GameTheme.accentGreen,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: completed
                  ? GameTheme.accentGreen.withValues(alpha: 0.2)
                  : GameTheme.bgDeep,
              border: Border.all(
                color: completed
                    ? GameTheme.accentGreen.withValues(alpha: 0.5)
                    : GameTheme.pixelBorder,
                width: 1.5,
              ),
            ),
            child: Icon(
              completed ? Icons.check : _missionIcon(data.type),
              color: completed ? GameTheme.accentGreen : GameTheme.accent,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.name, style: GameTheme.pixel(
                  fontSize: 7,
                  color: completed ? GameTheme.accentGreen : GameTheme.textPrimary,
                )),
                const SizedBox(height: 2),
                Text(data.description, style: GameTheme.pixel(
                  fontSize: 5, color: GameTheme.textMuted,
                )),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: GameTheme.pixelProgressBar(
                        value: percent,
                        height: 6,
                        fillColor: completed ? GameTheme.accentGreen : GameTheme.accent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${mission.progress}/${data.target}',
                      style: GameTheme.pixel(fontSize: 5, color: GameTheme.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Reward
          Column(
            children: [
              if (data.coinReward > 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on, color: GameTheme.accentGold, size: 10),
                    const SizedBox(width: 3),
                    Text(GameTheme.formatNumber(data.coinReward),
                      style: GameTheme.pixel(fontSize: 6, color: GameTheme.accentGold)),
                  ],
                ),
              if (data.soulReward > 0) ...[
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, color: GameTheme.accentPurple, size: 10),
                    const SizedBox(width: 3),
                    Text('${data.soulReward}',
                      style: GameTheme.pixel(fontSize: 6, color: GameTheme.accentPurple)),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(MissionData data, int progress, bool completed) {
    final percent = data.target > 0
        ? (progress / data.target).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: GameTheme.pixelCardDecoration(
        fillColor: completed
            ? GameTheme.accentGold.withValues(alpha: 0.08)
            : GameTheme.bgCard,
        borderColor: completed
            ? GameTheme.accentGold.withValues(alpha: 0.4)
            : GameTheme.pixelBorder,
        glow: completed,
        glowColor: GameTheme.accentGold,
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: completed
                  ? GameTheme.accentGold.withValues(alpha: 0.2)
                  : GameTheme.bgDeep,
              border: Border.all(
                color: completed
                    ? GameTheme.accentGold.withValues(alpha: 0.5)
                    : GameTheme.pixelBorder,
                width: 1.5,
              ),
            ),
            child: Icon(
              completed ? Icons.emoji_events : _missionIcon(data.type),
              color: completed ? GameTheme.accentGold : GameTheme.accentPurple,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.name, style: GameTheme.pixel(
                  fontSize: 7,
                  color: completed ? GameTheme.accentGold : GameTheme.textPrimary,
                )),
                const SizedBox(height: 2),
                Text(data.description, style: GameTheme.pixel(
                  fontSize: 5, color: GameTheme.textMuted,
                )),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: GameTheme.pixelProgressBar(
                        value: percent,
                        height: 6,
                        fillColor: completed
                            ? GameTheme.accentGold
                            : GameTheme.accentPurple,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$progress/${data.target}',
                      style: GameTheme.pixel(fontSize: 5, color: GameTheme.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              if (data.coinReward > 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on, color: GameTheme.accentGold, size: 10),
                    const SizedBox(width: 3),
                    Text(GameTheme.formatNumber(data.coinReward),
                      style: GameTheme.pixel(fontSize: 6, color: GameTheme.accentGold)),
                  ],
                ),
              if (data.soulReward > 0) ...[
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, color: GameTheme.accentPurple, size: 10),
                    const SizedBox(width: 3),
                    Text('${data.soulReward}',
                      style: GameTheme.pixel(fontSize: 6, color: GameTheme.accentPurple)),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  IconData _missionIcon(MissionType type) {
    switch (type) {
      case MissionType.killEnemies:
        return Icons.sports_martial_arts;
      case MissionType.killAirEnemies:
        return Icons.flight;
      case MissionType.killGoldenEnemies:
        return Icons.star;
      case MissionType.reachCombo:
        return Icons.whatshot;
      case MissionType.reachDistance:
        return Icons.near_me;
      case MissionType.collectCoins:
        return Icons.monetization_on;
      case MissionType.killBoss:
        return Icons.dangerous;
      case MissionType.noObstacleRun:
        return Icons.shield;
      case MissionType.openTreasure:
        return Icons.inventory_2;
      case MissionType.killBossFast:
        return Icons.timer;
    }
  }
}
