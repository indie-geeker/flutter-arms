
/// 服务定位器接口
///
/// 提供依赖注入容器的抽象接口，解耦具体的 DI 实现（如 GetIt）。
/// 这样 modules 模块只需要依赖接口，不需要依赖具体实现。
abstract class IServiceLocator {
  /// 注册单例
  ///
  /// 立即创建实例并注册，每次获取时返回同一个实例
  void registerSingleton<T extends Object>(T instance);

  /// 注册懒加载单例
  ///
  /// 延迟创建实例（首次获取时才创建），后续获取返回同一个实例
  void registerLazySingleton<T extends Object>(T Function() factoryFunc);

  /// 注册工厂
  ///
  /// 每次获取时都会创建新实例
  void registerFactory<T extends Object>(T Function() factoryFunc);

  /// 获取服务实例
  T get<T extends Object>();

  /// 检查服务是否已注册
  bool isRegistered<T extends Object>();

  /// 检查服务是否已注册（通过运行时 Type）
  ///
  /// 用于在无法使用泛型类型参数的场景，如模块依赖验证
  bool isRegisteredByType(Type type);

  /// 注销服务
  Future<void> unregister<T extends Object>();

  /// 重置所有服务
  Future<void> reset();
}