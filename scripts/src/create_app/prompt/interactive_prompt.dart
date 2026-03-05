import 'dart:io';

import '../models/create_app_config.dart';

abstract class PromptIO {
  String ask(String question, {String? defaultValue});

  bool askYesNo(String question, {bool defaultValue = false});
}

class StdioPromptIO implements PromptIO {
  @override
  String ask(String question, {String? defaultValue}) {
    final suffix = defaultValue == null ? '' : ' [$defaultValue]';
    stdout.writeln('$question$suffix:');
    final value = stdin.readLineSync()?.trim();
    if (value == null || value.isEmpty) {
      return defaultValue ?? '';
    }
    return value;
  }

  @override
  bool askYesNo(String question, {bool defaultValue = false}) {
    final suffix = defaultValue ? '[Y/n]' : '[y/N]';
    stdout.writeln('$question $suffix:');
    final value = stdin.readLineSync()?.trim().toLowerCase();

    if (value == null || value.isEmpty) {
      return defaultValue;
    }

    return value == 'y' || value == 'yes';
  }
}

CreateAppConfig collectMissingConfig({
  required PartialCreateAppConfig partial,
  required PromptIO io,
}) {
  var name = partial.appName?.trim() ?? '';
  if (name.isEmpty) {
    name = io.ask('App name (snake_case)');
  }

  final defaultOrg = CreateAppConfig.defaultOrganization(name);
  final org = (partial.organization?.trim().isNotEmpty ?? false)
      ? partial.organization!.trim()
      : io.ask(
          'Organization (bundle/application id)',
          defaultValue: defaultOrg,
        );

  final configureModules = io.askYesNo(
    'Customize modules?',
    defaultValue: false,
  );

  var modules = partial.modules;
  if (configureModules) {
    modules = ModuleSelection(
      router: io.askYesNo(
        'Include router module?',
        defaultValue: modules.router,
      ),
      providers: io.askYesNo(
        'Include providers module?',
        defaultValue: modules.providers,
      ),
      l10n: io.askYesNo('Include l10n module?', defaultValue: modules.l10n),
      theme: io.askYesNo('Include theme module?', defaultValue: modules.theme),
      feature: io.askYesNo(
        'Include feature skeleton module?',
        defaultValue: modules.feature,
      ),
      tests: io.askYesNo(
        'Include tests skeleton module?',
        defaultValue: modules.tests,
      ),
    );
  }

  final configurePlatforms = io.askYesNo(
    'Customize platforms?',
    defaultValue: false,
  );
  var platforms = partial.platforms;
  if (configurePlatforms) {
    final defaultPlatforms = partial.platforms.join(',');
    final raw = io.ask(
      'Platforms (comma separated)',
      defaultValue: defaultPlatforms,
    );
    platforms = raw
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  final mode =
      io.askYesNo(
        'Run flutter create before applying templates?',
        defaultValue: partial.creationMode == CreationMode.flutterCreate,
      )
      ? CreationMode.flutterCreate
      : CreationMode.templateOnly;

  return CreateAppConfig(
    appName: name,
    organization: org,
    platforms: platforms,
    interactive: partial.interactive,
    overwrite: partial.overwrite,
    creationMode: mode,
    modules: modules,
    runPostActions: partial.runPostActions,
    autoRegisterWorkspace: partial.autoRegisterWorkspace,
    rootDirectory: partial.rootDirectory,
  );
}
