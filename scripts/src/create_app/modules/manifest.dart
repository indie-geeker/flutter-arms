import 'module_spec.dart';

const Map<String, ModuleSpec> moduleManifest = {
  'router': ModuleSpec(
    id: 'router',
    templateDirectory: 'router',
    dependencies: ['auto_route'],
    devDependencies: ['auto_route_generator'],
  ),
  'providers': ModuleSpec(
    id: 'providers',
    templateDirectory: 'providers',
    dependencies: ['flutter_riverpod', 'riverpod_annotation'],
    devDependencies: ['riverpod_generator'],
  ),
  'l10n': ModuleSpec(
    id: 'l10n',
    templateDirectory: 'l10n',
    dependencies: ['intl'],
    devDependencies: [],
  ),
  'theme': ModuleSpec(
    id: 'theme',
    templateDirectory: 'theme',
    dependencies: ['flutter_riverpod'],
    devDependencies: [],
  ),
  'feature': ModuleSpec(
    id: 'feature',
    templateDirectory: 'feature',
    dependencies: [],
    devDependencies: [],
  ),
  'tests': ModuleSpec(
    id: 'tests',
    templateDirectory: 'tests',
    dependencies: [],
    devDependencies: [],
  ),
};
