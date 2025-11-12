
import 'package:interfaces/core/module_registry.dart';

import '../di/module_registry.dart';

/// 应用初始化器
class AppInitializer {
  final ModuleRegistry _registry = ModuleRegistry();

  /// 初始化应用
  Future<void> initialize({
    required List<IModule> modules,
    void Function(String)? onProgress,
  }) async {
    try {
      // 1. 注册所有模块
      onProgress?.call('Registering modules...');
      _registry.registerModules(modules);

      // 2. 初始化所有模块
      onProgress?.call('Initializing modules...');
      await _registry.initializeAll();

      // 3. 完成
      onProgress?.call('Initialization completed');
    } catch (e, stackTrace) {
      onProgress?.call('Initialization failed: $e');
      rethrow;
    }
  }

  /// 销毁应用
  Future<void> dispose() async {
    await _registry.disposeAll();
  }
}