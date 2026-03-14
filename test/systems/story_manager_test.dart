import 'package:flutter_test/flutter_test.dart';
import 'package:paw_defense/systems/story_manager.dart';

void main() {
  group('StoryManager', () {
    test('has 12 story chapters', () {
      expect(StoryManager.chapters.length, 12);
    });

    test('all chapter IDs are unique', () {
      final ids = StoryManager.chapters.map((c) => c.id).toSet();
      expect(ids.length, StoryManager.chapters.length);
    });

    test('chapters are sorted by requiredWave ascending', () {
      for (int i = 1; i < StoryManager.chapters.length; i++) {
        expect(
          StoryManager.chapters[i].requiredWave,
          greaterThanOrEqualTo(StoryManager.chapters[i - 1].requiredWave),
          reason: 'Chapter ${StoryManager.chapters[i].id} should unlock after ${StoryManager.chapters[i - 1].id}',
        );
      }
    });

    test('first chapter unlocks at wave 1', () {
      expect(StoryManager.chapters.first.requiredWave, 1);
    });

    test('last chapter unlocks at wave 100', () {
      expect(StoryManager.chapters.last.requiredWave, 100);
    });

    test('all chapters have non-empty titles and descriptions', () {
      for (final ch in StoryManager.chapters) {
        expect(ch.title.isNotEmpty, true, reason: '${ch.id} title');
        expect(ch.description.isNotEmpty, true, reason: '${ch.id} description');
        expect(ch.emoji.isNotEmpty, true, reason: '${ch.id} emoji');
      }
    });

    test('some chapters have unlock rewards', () {
      final withRewards = StoryManager.chapters.where((c) => c.unlockReward != null);
      expect(withRewards.length, greaterThan(0));
    });
  });
}
