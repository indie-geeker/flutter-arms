
import 'package:interfaces/core/i_service_locator.dart';
import 'package:interfaces/core/module_registry.dart';

import '../di/module_registry.dart';

/// Application initializer for non-UI scenarios (CLI, tests, backend).
class AppInitializer {
  final ModuleRegistry _registry;

  /// Creates an initializer with an optional [locator] for DI.
  ///
  /// When omitted, defaults to the global [ServiceLocator] singleton.
  AppInitializer({IServiceLocator? locator})
      : _registry = ModuleRegistry(locator: locator);

  /// Initializes the application with the given [modules].
  Future<void> initialize({
    required List<IModule> modules,
    void Function(String)? onProgress,
  }) async {
    _registry.registerModules(modules, replace: true);
    await _registry.initializeAllWithProgress((module, current, total) {
      onProgress?.call('Initializing ${module.name}... ($current/$total)');
    });
  }

  /// Disposes all modules.
  Future<void> dispose() async {
    await _registry.disposeAll();
  }
}
