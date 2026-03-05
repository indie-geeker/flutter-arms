import 'package:interfaces/core/i_service_locator.dart';
import 'package:interfaces/core/module_registry.dart';
import 'service_locator.dart';

/// Module registry that coordinates module lifecycle.
class ModuleRegistry {
  final List<IModule> _modules = [];
  final IServiceLocator _locator;
  final List<IModule> _initializedModules = [];

  /// Creates a registry with an optional [locator].
  ///
  /// Falls back to the global [ServiceLocator] singleton when omitted,
  /// preserving backward compatibility.
  ModuleRegistry({IServiceLocator? locator})
    : _locator = locator ?? ServiceLocator();

  /// Registers a module.
  void registerModule(IModule module) {
    // Deduplicates by module name to prevent duplicate initialization
    // when retrying or double-registering the same module.
    _modules.removeWhere((m) => m.name == module.name);
    _modules.add(module);
  }

  /// Batch-registers modules.
  void registerModules(List<IModule> modules, {bool replace = false}) {
    if (replace) {
      _modules.clear();
    }
    for (final module in modules) {
      registerModule(module);
    }
  }

  /// Sorts by priority and initializes all modules.
  ///
  /// Delegates to [initializeAllWithProgress] without a progress callback.
  Future<void> initializeAll() async {
    await initializeAllWithProgress(null);
  }

  /// Initialization with progress callback (single source of truth).
  ///
  /// [onProgress] is called before each module is initialized, passing the
  /// current module, progress index, and total count.
  Future<void> initializeAllWithProgress(
    void Function(IModule module, int current, int total)? onProgress,
  ) async {
    final orderedModules = _sortModulesByDependencies();
    _initializedModules.clear();

    try {
      // Validate dependencies, register, and initialize each module in order.
      for (int i = 0; i < orderedModules.length; i++) {
        final module = orderedModules[i];
        onProgress?.call(module, i + 1, orderedModules.length);

        // Validate that the current module's dependencies are registered.
        _validateModuleDependencies(module);

        await module.register(_locator);
        _initializedModules.add(module);
        await module.init();
      }
    } catch (_) {
      await _rollbackInitializedModules();
      rethrow;
    }
  }

  /// Validates a single module's dependencies.
  ///
  /// Called before each module is registered to ensure its required
  /// services are already available.
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

  /// Queries the health status of all initialized modules.
  Map<String, bool> checkHealth() {
    return {
      for (final module in _initializedModules)
        module.name: module.isHealthy,
    };
  }

  /// Returns the list of initialized module names (for debugging/logging).
  List<String> get initializedModuleNames =>
      _initializedModules.map((m) => m.name).toList();

  /// Disposes all modules.
  Future<void> disposeAll() async {
    // Dispose in reverse order.
    final modulesToDispose = _initializedModules.isNotEmpty
        ? _initializedModules
        : _modules;
    for (final module in modulesToDispose.reversed) {
      await module.dispose();
    }
    _initializedModules.clear();
    await _locator.reset();
  }

  Future<void> _rollbackInitializedModules() async {
    for (final module in _initializedModules.reversed) {
      try {
        await module.dispose();
      } catch (_) {
        // Best-effort rollback
      }
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
            // Dependency is pre-registered externally; skip for sorting.
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
