enum CreationMode { flutterCreate, templateOnly }

class ModuleSelection {
  const ModuleSelection({
    required this.router,
    required this.providers,
    required this.l10n,
    required this.theme,
    required this.feature,
    required this.tests,
  });

  final bool router;
  final bool providers;
  final bool l10n;
  final bool theme;
  final bool feature;
  final bool tests;

  factory ModuleSelection.defaultBaseline() {
    return const ModuleSelection(
      router: true,
      providers: true,
      l10n: true,
      theme: true,
      feature: false,
      tests: false,
    );
  }

  ModuleSelection copyWith({
    bool? router,
    bool? providers,
    bool? l10n,
    bool? theme,
    bool? feature,
    bool? tests,
  }) {
    return ModuleSelection(
      router: router ?? this.router,
      providers: providers ?? this.providers,
      l10n: l10n ?? this.l10n,
      theme: theme ?? this.theme,
      feature: feature ?? this.feature,
      tests: tests ?? this.tests,
    );
  }

  List<String> enabledModuleIds() {
    final modules = <String>[];
    if (router) {
      modules.add('router');
    }
    if (providers) {
      modules.add('providers');
    }
    if (l10n) {
      modules.add('l10n');
    }
    if (theme) {
      modules.add('theme');
    }
    if (feature) {
      modules.add('feature');
    }
    if (tests) {
      modules.add('tests');
    }
    return modules;
  }
}

class CreateAppConfig {
  const CreateAppConfig({
    required this.appName,
    required this.organization,
    required this.platforms,
    required this.interactive,
    required this.overwrite,
    required this.creationMode,
    required this.modules,
    required this.runPostActions,
    required this.autoRegisterWorkspace,
    required this.rootDirectory,
  });

  final String appName;
  final String organization;
  final List<String> platforms;
  final bool interactive;
  final bool overwrite;
  final CreationMode creationMode;
  final ModuleSelection modules;
  final bool runPostActions;
  final bool autoRegisterWorkspace;
  final String rootDirectory;

  String get appDirectoryPath => '$rootDirectory/app/$appName';

  static String defaultOrganization(String appName) {
    final sanitized = appName.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9_]'),
      '_',
    );
    return 'com.example.$sanitized';
  }
}

class PartialCreateAppConfig {
  PartialCreateAppConfig({
    this.appName,
    this.organization,
    required this.platforms,
    required this.interactive,
    required this.overwrite,
    required this.creationMode,
    required this.modules,
    required this.runPostActions,
    required this.autoRegisterWorkspace,
    required this.rootDirectory,
  });

  String? appName;
  String? organization;
  List<String> platforms;
  bool interactive;
  bool overwrite;
  CreationMode creationMode;
  ModuleSelection modules;
  bool runPostActions;
  bool autoRegisterWorkspace;
  String rootDirectory;

  bool get needsPrompt => interactive && (appName == null || appName!.isEmpty);

  CreateAppConfig toConfig() {
    final resolvedAppName = appName?.trim();
    if (resolvedAppName == null || resolvedAppName.isEmpty) {
      throw StateError(
        'Missing app name. Provide --name or use interactive mode.',
      );
    }

    final org = (organization?.trim().isNotEmpty ?? false)
        ? organization!.trim()
        : CreateAppConfig.defaultOrganization(resolvedAppName);

    return CreateAppConfig(
      appName: resolvedAppName,
      organization: org,
      platforms: platforms,
      interactive: interactive,
      overwrite: overwrite,
      creationMode: creationMode,
      modules: modules,
      runPostActions: runPostActions,
      autoRegisterWorkspace: autoRegisterWorkspace,
      rootDirectory: rootDirectory,
    );
  }
}
