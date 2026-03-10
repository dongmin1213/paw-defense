import 'package:flutter_test/flutter_test.dart';
import 'package:paw_defense/systems/achievement_manager.dart';

void main() {
  late AchievementManager manager;

  setUp(() {
    manager = AchievementManager();
  });

  group('AchievementDatabase', () {
    test('has achievements defined', () {
      expect(AchievementDatabase.all, isNotEmpty);
    });

    test('all IDs are unique', () {
      final ids = AchievementDatabase.all.map((a) => a.id).toSet();
      expect(ids.length, AchievementDatabase.all.length);
    });

    test('get() returns correct achievement', () {
      final a = AchievementDatabase.get('kill_100');
      expect(a, isNotNull);
      expect(a!.target, 100);
      expect(a.type, AchievementType.kills);
    });

    test('all achievements have positive targets', () {
      for (final a in AchievementDatabase.all) {
        expect(a.target, greaterThan(0), reason: '${a.id} target');
        expect(a.starReward, greaterThan(0), reason: '${a.id} starReward');
      }
    });
  });

  group('Progress tracking', () {
    test('starts with no progress', () {
      expect(manager.getProgress('kill_100'), 0);
      expect(manager.isCompleted('kill_100'), false);
    });

    test('updateProgress sets value and returns newly completed', () {
      final completed = manager.updateProgress(AchievementType.kills, 100);
      expect(completed, contains('kill_100'));
      expect(manager.isCompleted('kill_100'), true);
      expect(manager.getProgress('kill_100'), 100);
    });

    test('value below target does not complete', () {
      final completed = manager.updateProgress(AchievementType.kills, 50);
      expect(completed, isEmpty);
      expect(manager.isCompleted('kill_100'), false);
    });

    test('high value completes multiple tiers', () {
      final completed = manager.updateProgress(AchievementType.kills, 1000);
      expect(completed, contains('kill_100'));
      expect(completed, contains('kill_500'));
      expect(completed, contains('kill_1000'));
      expect(completed.contains('kill_5000'), false); // 5000 > 1000
    });

    test('already completed achievements not returned again', () {
      manager.updateProgress(AchievementType.kills, 100);
      final second = manager.updateProgress(AchievementType.kills, 200);
      expect(second.contains('kill_100'), false);
    });

    test('different types tracked independently', () {
      manager.updateProgress(AchievementType.kills, 100);
      final waveResult = manager.updateProgress(AchievementType.waves, 10);
      expect(waveResult, contains('wave_10'));
      expect(manager.isCompleted('kill_100'), true);
      expect(manager.isCompleted('wave_10'), true);
    });
  });

  group('Star rewards', () {
    test('totalStarReward starts at 0', () {
      expect(manager.totalStarReward, 0);
    });

    test('totalStarReward accumulates', () {
      manager.updateProgress(AchievementType.kills, 100); // 5 stars
      expect(manager.totalStarReward, 5);

      manager.updateProgress(AchievementType.waves, 10); // 5 stars
      expect(manager.totalStarReward, 10);
    });
  });

  group('Completion percent', () {
    test('starts at 0%', () {
      expect(manager.completionPercent, 0.0);
    });

    test('increases with completions', () {
      manager.updateProgress(AchievementType.kills, 100);
      expect(manager.completionPercent, greaterThan(0.0));
      expect(manager.completionPercent, lessThanOrEqualTo(1.0));
    });
  });

  group('Achievement lists', () {
    test('completedAchievements starts empty', () {
      expect(manager.completedAchievements, isEmpty);
    });

    test('uncompletedAchievements starts with all', () {
      expect(manager.uncompletedAchievements.length,
          AchievementDatabase.all.length);
    });

    test('completing moves between lists', () {
      final totalBefore = manager.uncompletedAchievements.length;
      manager.updateProgress(AchievementType.kills, 100);
      expect(manager.completedAchievements.length, 1);
      expect(manager.uncompletedAchievements.length, totalBefore - 1);
    });
  });
}
