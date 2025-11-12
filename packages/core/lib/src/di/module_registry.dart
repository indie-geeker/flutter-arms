
import 'package:interfaces/core/i_service_locator.dart';
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
  Future<void> initializeAll() async {
    // 按优先级排序
    _modules.sort((a, b) => a.priority.compareTo(b.priority));

    // 检查依赖关系
    _validateDependencies();

    // 依次注册和初始化
    for (final module in _modules) {
      await module.register(_locator);
      await module.init();
    }
  }

  /// 验证模块依赖关系
  void _validateDependencies() {
    for (final module in _modules) {
      for (final dep in module.dependencies) {
        if (!_locator.isRegisteredByType(dep)) {
          throw StateError(
            'Module ${module.name} depends on $dep, but it is not registered',
          );
        }
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