import 'package:interfaces/core/i_service_locator.dart';

/// Mock implementation of IServiceLocator for testing
class MockServiceLocator implements IServiceLocator {
  final Map<Type, dynamic> _services = {};

  @override
  void registerSingleton<T extends Object>(T instance) {
    _services[T] = instance;
  }

  @override
  void registerLazySingleton<T extends Object>(T Function() factoryFunc) {
    _services[T] = factoryFunc;
  }

  @override
  void registerFactory<T extends Object>(T Function() factory) {
    _services[T] = factory;
  }

  @override
  T get<T extends Object>() {
    final service = _services[T];
    if (service == null) {
      throw Exception('Service of type $T not found');
    }
    if (service is Function) {
      return service() as T;
    }
    return service as T;
  }

  @override
  bool isRegistered<T extends Object>() {
    return _services.containsKey(T);
  }

  @override
  Future<void> unregister<T extends Object>() async {
    _services.remove(T);
  }

  @override
  Future<void> reset() async {
    _services.clear();
  }

  @override
  bool isRegisteredByType(Type type) {
    return _services.containsKey(type);
  }
}
