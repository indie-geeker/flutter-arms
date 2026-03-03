import 'dart:io';

import '../models/create_app_config.dart';
import '../prompt/interactive_prompt.dart';

const Set<String> _supportedPlatforms = {
  'android',
  'ios',
  'web',
  'macos',
  'windows',
  'linux',
};

Future<CreateAppConfig> runPreflight(
  CreateAppConfig config,
  PromptIO prompt,
) async {
  _validateAppName(config.appName);
  _validatePlatforms(config.platforms);

  var overwrite = config.overwrite;
  final target = Directory(config.appDirectoryPath);
  if (target.existsSync() && !overwrite) {
    if (!config.interactive) {
      throw StateError(
        'Target directory already exists: ${config.appDirectoryPath}. Use --overwrite or interactive mode.',
      );
    }

    final shouldOverwrite = prompt.askYesNo(
      'Target app directory already exists. Overwrite scaffold-managed files?',
      defaultValue: false,
    );

    if (!shouldOverwrite) {
      throw StateError('Creation canceled by user.');
    }

    overwrite = true;
  }

  var modules = config.modules;
  if (!modules.providers && (modules.theme || modules.l10n)) {
    modules = modules.copyWith(providers: true);
  }

  return CreateAppConfig(
    appName: config.appName,
    organization: config.organization,
    platforms: config.platforms,
    interactive: config.interactive,
    overwrite: overwrite,
    creationMode: config.creationMode,
    modules: modules,
    runPostActions: config.runPostActions,
    autoRegisterWorkspace: config.autoRegisterWorkspace,
    rootDirectory: config.rootDirectory,
  );
}

void _validateAppName(String appName) {
  final valid = RegExp(r'^[a-z][a-z0-9_]*$');
  if (!valid.hasMatch(appName)) {
    throw FormatException(
      'Invalid app name "$appName". Use snake_case, start with a letter, and only [a-z0-9_].',
    );
  }
}

void _validatePlatforms(List<String> platforms) {
  if (platforms.isEmpty) {
    throw FormatException('At least one platform is required.');
  }

  for (final platform in platforms) {
    if (!_supportedPlatforms.contains(platform)) {
      throw FormatException(
        'Unsupported platform "$platform". Supported: ${_supportedPlatforms.join(', ')}.',
      );
    }
  }
}
