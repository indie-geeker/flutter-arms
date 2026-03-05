import 'dart:io';

import 'src/create_app/cli/arg_parser.dart';
import 'src/create_app/prompt/interactive_prompt.dart';
import 'src/create_app/workflow/create_app_workflow.dart';

const _usage = '''Usage:
  dart run scripts/create_app.dart --name <app_name> [options]

Options:
  --name, -n <value>           App name in snake_case
  --org <value>                Organization id (e.g. com.example.my_app)
  --platforms <list>           Comma-separated platforms (default: android,ios)
  --interactive                Enable interactive prompts (default)
  --no-interactive             Disable interactive prompts
  --overwrite                  Overwrite scaffold-managed files in existing app dir
  --use-flutter-create         Run flutter create before templating (default)
  --template-only              Skip flutter create and only apply templates
  --with-router / --no-router
  --with-providers / --no-providers
  --with-l10n / --no-l10n
  --with-theme / --no-theme
  --with-feature / --no-feature
  --with-tests / --no-tests
  --no-post-actions            Skip pub get and build_runner
  --no-workspace-registration  Skip root workspace update
  --help, -h                   Show help

Examples:
  dart run scripts/create_app.dart --name shop_app
  dart run scripts/create_app.dart --name shop_app --template-only --with-feature --with-tests
''';

Future<void> main(List<String> args) async {
  try {
    final parsed = parseArgs(args);
    if (parsed.showHelp) {
      stdout.write(_usage);
      return;
    }

    final config = parsed.partial.needsPrompt
        ? collectMissingConfig(partial: parsed.partial, io: StdioPromptIO())
        : parsed.partial.toConfig();

    final workflow = CreateAppWorkflow();
    final result = await workflow.run(config);

    stdout.writeln('Created app: app/${result.config.appName}');
    stdout.writeln(
      'Enabled modules: ${result.config.modules.enabledModuleIds().join(', ')}',
    );
    stdout.writeln('Generated files: ${result.generated.written.length}');
    if (result.generated.skipped.isNotEmpty) {
      stdout.writeln(
        'Skipped existing files: ${result.generated.skipped.length}',
      );
    }
  } on FormatException catch (error) {
    stderr.writeln('Argument error: ${error.message}');
    stderr.writeln('Run with --help for usage.');
    exitCode = 64;
  } on StateError catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  } catch (error) {
    stderr.writeln('Unexpected error: $error');
    exitCode = 1;
  }
}
