
import 'package:interfaces/core/module_registry.dart'; // IModule 接口
import 'service_locator.dart';

/// 模块注册中心
class ModuleRegistry {
  final List<IModule> _modules = [];
  final ServiceLocator _locator = ServiceLocator();

  /// 注册模块
  void registerModule(IModule module) {
    _modules.add(module);
  }

  /// 批量注册模块
  void registerModules(List<IModule> modules) {
    _modules.addAll(modules);
  }

  /// 按优先级排序并初始化所有模块
  /// 
  /// 此方法委托给 [initializeAllWithProgress]，不带进度回调
  Future<void> initializeAll() async {
    await initializeAllWithProgress(null);
  }

  /// 带进度回调的初始化 (核心逻辑唯一来源)
  ///
  /// [onProgress] 回调在每个模块初始化前调用，传入当前模块、进度和总数
  Future<void> initializeAllWithProgress(
    void Function(IModule module, int current, int total)? onProgress,
  ) async {
    // 按优先级排序
    _modules.sort((a, b) => a.priority.compareTo(b.priority));

    // 依次验证依赖、注册和初始化每个模块
    for (int i = 0; i < _modules.length; i++) {
      final module = _modules[i];
      onProgress?.call(module, i + 1, _modules.length);

      // 验证当前模块的依赖是否已注册
      _validateModuleDependencies(module);

      await module.register(_locator);
      await module.init();
    }
  }

  /// 验证单个模块的依赖关系
  ///
  /// 在每个模块注册之前调用，确保其依赖的服务已被注册
  void _validateModuleDependencies(IModule module) {
    for (final dep in module.dependencies) {
      if (!_locator.isRegisteredByType(dep)) {
        throw StateError(
          'Module ${module.name} depends on $dep, but it is not registered. '
          'Ensure dependent module has lower priority number.',
        );
      }
    }
  }

  /// 销毁所有模块
  Future<void> disposeAll() async {
    // 反向销毁
    for (final module in _modules.reversed) {
      await module.dispose();
    }
    await _locator.reset();
  }
}