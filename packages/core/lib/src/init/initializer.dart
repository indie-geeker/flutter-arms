
import 'package:interfaces/core/module_registry.dart';

import '../di/module_registry.dart';

/// 应用初始化器 (纯 Dart 场景)
///
/// 适用于 CLI 工具、后端服务、单元测试等非 UI 场景
class AppInitializer {
  final ModuleRegistry _registry = ModuleRegistry();

  /// 初始化应用
  ///
  /// [modules] 需要初始化的模块列表
  /// [onProgress] 可选的进度回调
  Future<void> initialize({
    required List<IModule> modules,
    void Function(String)? onProgress,
  }) async {
    _registry.registerModules(modules);
    await _registry.initializeAllWithProgress((module, current, total) {
      onProgress?.call('Initializing ${module.name}... ($current/$total)');
    });
  }

  /// 销毁应用
  Future<void> dispose() async {
    await _registry.disposeAll();
  }
}