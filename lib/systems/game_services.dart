/// Service locator for game systems — reduces tight coupling between managers.
/// All managers register here during game initialization.
/// Components can access any manager through GameServices instead of
/// holding direct references to DefenseGame.
class GameServices {
  GameServices._();

  static final GameServices _instance = GameServices._();
  static GameServices get instance => _instance;

  final Map<Type, Object> _services = {};

  /// Register a service instance.
  void register<T extends Object>(T service) {
    _services[T] = service;
  }

  /// Get a registered service. Throws if not registered.
  T get<T extends Object>() {
    final service = _services[T];
    if (service == null) {
      throw StateError('Service $T not registered in GameServices');
    }
    return service as T;
  }

  /// Try to get a service. Returns null if not registered.
  T? tryGet<T extends Object>() {
    return _services[T] as T?;
  }

  /// Check if a service is registered.
  bool has<T extends Object>() => _services.containsKey(T);

  /// Clear all registered services (for testing or reset).
  void clear() {
    _services.clear();
  }

  /// Number of registered services.
  int get serviceCount => _services.length;
}
