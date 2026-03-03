import '../models/create_app_config.dart';
import 'manifest.dart';
import 'module_spec.dart';

DependencySet resolveDependencies(ModuleSelection modules) {
  final dependencies = <String>{};
  final devDependencies = <String>{'build_runner'};

  for (final id in modules.enabledModuleIds()) {
    final spec = moduleManifest[id];
    if (spec == null) {
      continue;
    }
    dependencies.addAll(spec.dependencies);
    devDependencies.addAll(spec.devDependencies);
  }

  return DependencySet(
    dependencies: dependencies.toList()..sort(),
    devDependencies: devDependencies.toList()..sort(),
  );
}

List<ModuleSpec> resolveModuleSpecs(ModuleSelection modules) {
  final specs = <ModuleSpec>[];
  for (final id in modules.enabledModuleIds()) {
    final spec = moduleManifest[id];
    if (spec != null) {
      specs.add(spec);
    }
  }
  return specs;
}
