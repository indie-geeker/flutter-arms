import 'dart:io';

import '../integrations/monorepo_updater.dart';
import '../integrations/pubspec_updater.dart';
import '../models/create_app_config.dart';
import '../modules/dependency_resolver.dart';
import '../process/command_runner.dart';
import '../prompt/interactive_prompt.dart';
import 'preflight.dart';
import 'render_step.dart';

class CreateAppWorkflowResult {
  const CreateAppWorkflowResult({
    required this.config,
    required this.generated,
  });

  final CreateAppConfig config;
  final GenerationResult generated;
}

class CreateAppWorkflow {
  CreateAppWorkflow({CommandRunner? commandRunner, PromptIO? prompt})
    : _commandRunner = commandRunner ?? const ProcessCommandRunner(),
      _prompt = prompt ?? StdioPromptIO();

  final CommandRunner _commandRunner;
  final PromptIO _prompt;

  Future<CreateAppWorkflowResult> run(CreateAppConfig config) async {
    final checked = await runPreflight(config, _prompt);

    if (checked.creationMode == CreationMode.flutterCreate) {
      await _runFlutterCreate(checked);
    } else {
      await Directory(checked.appDirectoryPath).create(recursive: true);
    }

    final generation = await renderSelectedTemplates(config: checked);

    final dependencies = resolveDependencies(checked.modules);
    await ensureAppPubspec(
      appDirectory: checked.appDirectoryPath,
      appName: checked.appName,
      dependencies: dependencies,
      includeL10n: checked.modules.l10n,
    );

    if (checked.autoRegisterWorkspace) {
      await ensureWorkspaceRegistration(
        rootDirectory: checked.rootDirectory,
        appName: checked.appName,
      );
    }

    if (checked.runPostActions) {
      await _runPostActions(checked);
    }

    return CreateAppWorkflowResult(config: checked, generated: generation);
  }

  Future<void> _runFlutterCreate(CreateAppConfig config) async {
    final appDir = Directory('${config.rootDirectory}/app');
    await appDir.create(recursive: true);

    final command = <String>[
      'flutter',
      'create',
      '--org',
      config.organization,
      '--platforms=${config.platforms.join(',')}',
      config.appName,
    ];

    final result = await _commandRunner.run(
      command,
      workingDirectory: appDir.path,
    );

    if (!result.isSuccess) {
      throw StateError(
        'flutter create failed (${result.exitCode}).\n${result.stderr}\n${result.stdout}',
      );
    }
  }

  Future<void> _runPostActions(CreateAppConfig config) async {
    final appDirectory = config.appDirectoryPath;

    final pubGet = await _commandRunner.run([
      'flutter',
      'pub',
      'get',
    ], workingDirectory: appDirectory);
    if (!pubGet.isSuccess) {
      throw StateError(
        'flutter pub get failed (${pubGet.exitCode}).\n${pubGet.stderr}',
      );
    }

    if (config.modules.l10n) {
      final genL10n = await _commandRunner.run([
        'flutter',
        'gen-l10n',
      ], workingDirectory: appDirectory);
      if (!genL10n.isSuccess) {
        throw StateError(
          'flutter gen-l10n failed (${genL10n.exitCode}).\n${genL10n.stderr}\n${genL10n.stdout}',
        );
      }
    }

    final buildRunner = await _commandRunner.run([
      'dart',
      'run',
      'build_runner',
      'build',
      '--delete-conflicting-outputs',
    ], workingDirectory: appDirectory);
    if (!buildRunner.isSuccess) {
      throw StateError(
        'build_runner failed (${buildRunner.exitCode}).\n${buildRunner.stderr}\n${buildRunner.stdout}',
      );
    }
  }
}
