/// Service locator interface.
///
/// Provides an abstract interface for dependency injection containers,
/// decoupling modules from concrete DI implementations (e.g. GetIt).
abstract class IServiceLocator {
  /// Registers an eager singleton.
  ///
  /// The instance is created immediately and the same instance is returned
  /// on every subsequent retrieval.
  void registerSingleton<T extends Object>(T instance);

  /// Registers a lazy singleton.
  ///
  /// The instance is created on first retrieval and the same instance is
  /// returned on every subsequent retrieval.
  void registerLazySingleton<T extends Object>(T Function() factoryFunc);

  /// Registers a factory.
  ///
  /// A new instance is created on every retrieval.
  void registerFactory<T extends Object>(T Function() factoryFunc);

  /// Retrieves the registered service instance.
  T get<T extends Object>();

  /// Checks whether a service of type [T] is registered.
  bool isRegistered<T extends Object>();

  /// Checks whether a service is registered by runtime [Type].
  ///
  /// Used in scenarios where generic type parameters are unavailable,
  /// such as module dependency validation.
  bool isRegisteredByType(Type type);

  /// Unregisters a service of type [T].
  Future<void> unregister<T extends Object>();

  /// Resets (unregisters) all services.
  Future<void> reset();
}
