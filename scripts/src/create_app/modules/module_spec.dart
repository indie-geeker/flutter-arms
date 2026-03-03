class ModuleSpec {
  const ModuleSpec({
    required this.id,
    required this.templateDirectory,
    required this.dependencies,
    required this.devDependencies,
  });

  final String id;
  final String templateDirectory;
  final List<String> dependencies;
  final List<String> devDependencies;
}

class DependencySet {
  const DependencySet({
    required this.dependencies,
    required this.devDependencies,
  });

  final List<String> dependencies;
  final List<String> devDependencies;
}
