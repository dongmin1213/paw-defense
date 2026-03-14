import 'package:flutter_test/flutter_test.dart';
import 'package:paw_defense/systems/game_services.dart';

void main() {
  group('GameServices', () {
    setUp(() {
      GameServices.instance.clear();
    });

    test('register and get a service', () {
      GameServices.instance.register<String>('test');
      expect(GameServices.instance.get<String>(), 'test');
    });

    test('tryGet returns null for unregistered', () {
      expect(GameServices.instance.tryGet<int>(), isNull);
    });

    test('has returns correct state', () {
      expect(GameServices.instance.has<String>(), false);
      GameServices.instance.register<String>('test');
      expect(GameServices.instance.has<String>(), true);
    });

    test('get throws for unregistered service', () {
      expect(
        () => GameServices.instance.get<int>(),
        throwsA(isA<StateError>()),
      );
    });

    test('clear removes all services', () {
      GameServices.instance.register<String>('test');
      GameServices.instance.register<int>(42);
      expect(GameServices.instance.serviceCount, 2);
      GameServices.instance.clear();
      expect(GameServices.instance.serviceCount, 0);
    });

    test('serviceCount tracks registrations', () {
      expect(GameServices.instance.serviceCount, 0);
      GameServices.instance.register<String>('a');
      expect(GameServices.instance.serviceCount, 1);
      GameServices.instance.register<int>(1);
      expect(GameServices.instance.serviceCount, 2);
    });
  });
}
