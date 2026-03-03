import '../models/create_app_config.dart';

class ParseResult {
  const ParseResult({required this.showHelp, required this.partial});

  final bool showHelp;
  final PartialCreateAppConfig partial;
}

ParseResult parseArgs(List<String> args, {String rootDirectory = '.'}) {
  var showHelp = false;
  var appName = '';
  String? organization;
  var platforms = <String>['android', 'ios'];
  var interactive = true;
  var overwrite = false;
  var creationMode = CreationMode.flutterCreate;
  var modules = ModuleSelection.defaultBaseline();
  var runPostActions = true;
  var autoRegisterWorkspace = true;

  for (var i = 0; i < args.length; i++) {
    final arg = args[i];

    switch (arg) {
      case '--help':
      case '-h':
        showHelp = true;
        break;
      case '--name':
      case '-n':
        appName = _nextValue(args, ++i, arg);
        break;
      case '--org':
        organization = _nextValue(args, ++i, arg);
        break;
      case '--platforms':
        final raw = _nextValue(args, ++i, arg);
        platforms = raw
            .split(',')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList(growable: false);
        break;
      case '--interactive':
        interactive = true;
        break;
      case '--no-interactive':
        interactive = false;
        break;
      case '--overwrite':
        overwrite = true;
        break;
      case '--use-flutter-create':
        creationMode = CreationMode.flutterCreate;
        break;
      case '--template-only':
        creationMode = CreationMode.templateOnly;
        break;
      case '--no-post-actions':
        runPostActions = false;
        break;
      case '--no-workspace-registration':
        autoRegisterWorkspace = false;
        break;
      case '--with-router':
        modules = modules.copyWith(router: true);
        break;
      case '--no-router':
        modules = modules.copyWith(router: false);
        break;
      case '--with-providers':
        modules = modules.copyWith(providers: true);
        break;
      case '--no-providers':
        modules = modules.copyWith(providers: false);
        break;
      case '--with-l10n':
        modules = modules.copyWith(l10n: true);
        break;
      case '--no-l10n':
        modules = modules.copyWith(l10n: false);
        break;
      case '--with-theme':
        modules = modules.copyWith(theme: true);
        break;
      case '--no-theme':
        modules = modules.copyWith(theme: false);
        break;
      case '--with-feature':
        modules = modules.copyWith(feature: true);
        break;
      case '--no-feature':
        modules = modules.copyWith(feature: false);
        break;
      case '--with-tests':
        modules = modules.copyWith(tests: true);
        break;
      case '--no-tests':
        modules = modules.copyWith(tests: false);
        break;
      default:
        throw FormatException('Unknown argument: $arg');
    }
  }

  if (!interactive && appName.isNotEmpty && organization == null) {
    organization = CreateAppConfig.defaultOrganization(appName);
  }

  return ParseResult(
    showHelp: showHelp,
    partial: PartialCreateAppConfig(
      appName: appName.isEmpty ? null : appName,
      organization: organization,
      platforms: platforms,
      interactive: interactive,
      overwrite: overwrite,
      creationMode: creationMode,
      modules: modules,
      runPostActions: runPostActions,
      autoRegisterWorkspace: autoRegisterWorkspace,
      rootDirectory: rootDirectory,
    ),
  );
}

String _nextValue(List<String> args, int index, String flag) {
  if (index >= args.length) {
    throw FormatException('Missing value for $flag');
  }
  return args[index];
}
