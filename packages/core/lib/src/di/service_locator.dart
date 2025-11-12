
import 'package:get_it/get_it.dart';
import 'package:interfaces/core/i_service_locator.dart';

/// 服务定位器 - 实现 IServiceLocator 接口，基于 GetIt
class ServiceLocator implements IServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  final GetIt _getIt = GetIt.instance;

  @override
  void registerSingleton<T extends Object>(T instance) {
    if (!_getIt.isRegistered<T>()) {
      _getIt.registerSingleton<T>(instance);
    }
  }

  @override
  void registerLazySingleton<T extends Object>(
      T Function() factoryFunc,
      ) {
    if (!_getIt.isRegistered<T>()) {
      _getIt.registerLazySingleton<T>(factoryFunc);
    }
  }

  @override
  void registerFactory<T extends Object>(
      T Function() factoryFunc,
      ) {
    if (!_getIt.isRegistered<T>()) {
      _getIt.registerFactory<T>(factoryFunc);
    }
  }

  @override
  T get<T extends Object>() {
    return _getIt.get<T>();
  }

  @override
  bool isRegistered<T extends Object>() {
    return _getIt.isRegistered<T>();
  }

  @override
  bool isRegisteredByType(Type type) {
    return _getIt.isRegistered(type: type);
  }

  @override
  Future<void> unregister<T extends Object>() async {
    if (_getIt.isRegistered<T>()) {
      await _getIt.unregister<T>();
    }
  }

  @override
  Future<void> reset() async {
    await _getIt.reset();
  }
}