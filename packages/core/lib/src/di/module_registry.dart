
import 'package:interfaces/core/module_registry.dart'; // IModule 接口
import 'service_locator.dart';

/// 模块注册中心
class ModuleRegistry {
  final List<IModule> _modules = [];
  final ServiceLocator _locator = ServiceLocator();
  final List<IModule> _initializedModules = [];

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
    final orderedModules = _sortModulesByDependencies();
    _initializedModules.clear();

    // 依次验证依赖、注册和初始化每个模块
    for (int i = 0; i < orderedModules.length; i++) {
      final module = orderedModules[i];
      onProgress?.call(module, i + 1, orderedModules.length);

      // 验证当前模块的依赖是否已注册
      _validateModuleDependencies(module);

      await module.register(_locator);
      await module.init();
      _initializedModules.add(module);
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
          'Ensure a module provides this service or it is pre-registered.',
        );
      }
    }
  }

  /// 销毁所有模块
  Future<void> disposeAll() async {
    // 反向销毁
    final modulesToDispose =
        _initializedModules.isNotEmpty ? _initializedModules : _modules;
    for (final module in modulesToDispose.reversed) {
      await module.dispose();
    }
    _initializedModules.clear();
    await _locator.reset();
  }

  List<IModule> _sortModulesByDependencies() {
    if (_modules.isEmpty) return [];

    final providerMap = _buildProviderMap();
    final adjacency = <IModule, Set<IModule>>{};
    final indegree = <IModule, int>{};

    for (final module in _modules) {
      adjacency[module] = <IModule>{};
      indegree[module] = 0;
    }

    for (final module in _modules) {
      for (final dep in module.dependencies) {
        final provider = providerMap[dep];
        if (provider == null) {
          if (_locator.isRegisteredByType(dep)) {
            // 依赖由外部预注册，跳过模块排序依赖
            continue;
          }
          throw StateError(
            'No module provides $dep required by ${module.name}. '
            'Ensure the dependency is registered or provide a module that exposes it.',
          );
        }

        if (provider == module) {
          continue;
        }

        if (adjacency[provider]!.add(module)) {
          indegree[module] = indegree[module]! + 1;
        }
      }
    }

    final ready = _modules.where((m) => indegree[m] == 0).toList()
      ..sort(_compareModules);
    final ordered = <IModule>[];

    while (ready.isNotEmpty) {
      final module = ready.removeAt(0);
      ordered.add(module);

      for (final neighbor in adjacency[module]!) {
        indegree[neighbor] = indegree[neighbor]! - 1;
        if (indegree[neighbor] == 0) {
          ready.add(neighbor);
          ready.sort(_compareModules);
        }
      }
    }

    if (ordered.length != _modules.length) {
      final remaining = _modules
          .where((m) => indegree[m]! > 0)
          .map((m) => m.name)
          .toList();
      throw StateError(
        'Detected circular module dependencies: ${remaining.join(', ')}',
      );
    }

    return ordered;
  }

  Map<Type, IModule> _buildProviderMap() {
    final map = <Type, IModule>{};
    for (final module in _modules) {
      for (final provided in module.provides) {
        final existing = map[provided];
        if (existing != null && existing != module) {
          throw StateError(
            'Multiple modules provide $provided: ${existing.name} and ${module.name}.',
          );
        }
        map[provided] = module;
      }
    }
    return map;
  }

  int _compareModules(IModule a, IModule b) {
    final priorityComparison = a.priority.compareTo(b.priority);
    if (priorityComparison != 0) return priorityComparison;
    return a.name.compareTo(b.name);
  }
}
