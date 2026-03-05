import 'dart:io';

import '../io/file_writer.dart';
import '../models/create_app_config.dart';
import '../modules/dependency_resolver.dart';
import '../template/template_renderer.dart';

class GenerationResult {
  const GenerationResult({required this.written, required this.skipped});

  final List<String> written;
  final List<String> skipped;
}

Future<GenerationResult> renderSelectedTemplates({
  required CreateAppConfig config,
}) async {
  final templateRoots = <String>['templates/app_base'];
  for (final spec in resolveModuleSpecs(config.modules)) {
    templateRoots.add('templates/modules/${spec.templateDirectory}');
  }

  final variables = <String, String>{
    'app_name': config.appName,
    'org_id': config.organization,
  };

  final written = <String>[];
  final skipped = <String>[];

  for (final root in templateRoots) {
    final dir = Directory(root);
    if (!dir.existsSync()) {
      continue;
    }

    final entities = dir.listSync(recursive: true).whereType<File>();
    for (final file in entities) {
      final templatePath = file.path.replaceAll('\\', '/');
      if (!templatePath.endsWith('.tmpl')) {
        continue;
      }

      final targetRelative = _toTargetPath(templatePath);
      final targetPath = '${config.appDirectoryPath}/$targetRelative';
      final raw = await file.readAsString();
      final rendered = renderTemplate(raw, variables);
      final result = await writeFile(
        targetPath,
        rendered,
        overwrite: config.overwrite,
      );

      if (result.written) {
        written.add(targetRelative);
      } else {
        skipped.add(targetRelative);
      }
    }
  }

  final generatedEntrypoints = await _writeEntrypoints(
    config: config,
    overwrite: config.overwrite,
  );
  written.addAll(generatedEntrypoints.written);
  skipped.addAll(generatedEntrypoints.skipped);

  return GenerationResult(written: written, skipped: skipped);
}

String _toTargetPath(String templatePath) {
  const basePrefix = 'templates/app_base/';
  const modulePrefix = 'templates/modules/';
  var relative = templatePath;

  if (relative.startsWith(basePrefix)) {
    relative = relative.substring(basePrefix.length);
  } else if (relative.startsWith(modulePrefix)) {
    final remaining = relative.substring(modulePrefix.length);
    final slashIndex = remaining.indexOf('/');
    relative = slashIndex == -1
        ? remaining
        : remaining.substring(slashIndex + 1);
  }

  if (relative.endsWith('.tmpl')) {
    relative = relative.substring(0, relative.length - '.tmpl'.length);
  }

  return relative;
}

Future<GenerationResult> _writeEntrypoints({
  required CreateAppConfig config,
  required bool overwrite,
}) async {
  final written = <String>[];
  final skipped = <String>[];

  Future<void> writeManaged(String path, String content) async {
    final result = await writeFile(path, content, overwrite: overwrite);
    final relative = path.substring(config.appDirectoryPath.length + 1);
    if (result.written) {
      written.add(relative);
    } else {
      skipped.add(relative);
    }
  }

  final mainPath = '${config.appDirectoryPath}/lib/main.dart';
  final appPath = '${config.appDirectoryPath}/lib/src/app/app.dart';
  final homePath =
      '${config.appDirectoryPath}/lib/src/features/home/presentation/screens/home_screen.dart';

  final mainContent = _buildMainDart(config);
  await writeManaged(mainPath, mainContent);

  final appContent = _buildAppDart(config);
  await writeManaged(appPath, appContent);

  final homeContent = _buildHomeScreenDart(config);
  await writeManaged(homePath, homeContent);

  return GenerationResult(written: written, skipped: skipped);
}

String _buildMainDart(CreateAppConfig config) {
  if (config.modules.providers) {
    return '''import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: ArmsApp()));
}
''';
  }

  return '''import 'package:flutter/material.dart';

import 'src/app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ArmsApp());
}
''';
}

String _buildAppDart(CreateAppConfig config) {
  final usesProviders = config.modules.providers;
  final usesRouter = config.modules.router;
  final usesL10n = config.modules.l10n;
  final usesTheme = config.modules.theme;
  final usesProviderState = usesProviders && (usesTheme || usesL10n);

  final imports = <String>{"import 'package:flutter/material.dart';"};
  if (usesRouter) {
    imports.add("import '../router/app_router.dart';");
  } else {
    imports.add(
      "import '../features/home/presentation/screens/home_screen.dart';",
    );
  }

  if (usesProviderState) {
    imports.add("import 'package:flutter_riverpod/flutter_riverpod.dart';");
    imports.add("import '../di/providers.dart';");
  }
  if (usesL10n) {
    imports.add(
      "import 'package:flutter_localizations/flutter_localizations.dart';",
    );
    imports.add("import '../../l10n/app_localizations.dart';");
  }

  final className = usesProviderState
      ? 'class ArmsApp extends ConsumerWidget {'
      : 'class ArmsApp extends StatelessWidget {';
  final buildSignature = usesProviderState
      ? '@override\n  Widget build(BuildContext context, WidgetRef ref) {'
      : '@override\n  Widget build(BuildContext context) {';

  final lines = <String>[];
  lines.addAll(imports.toList()..sort());
  lines.add('');
  lines.add(className);
  lines.add('  const ArmsApp({super.key});');
  lines.add('');
  lines.add('  $buildSignature');

  if (usesProviderState && usesTheme) {
    lines.add('    final themeMode = ref.watch(themeModeProvider);');
  }
  if (usesProviderState && usesL10n) {
    lines.add('    final locale = ref.watch(localeProvider);');
  }

  if (usesRouter) {
    lines.add('    return MaterialApp.router(');
  } else {
    lines.add('    return MaterialApp(');
  }

  lines.add("      title: '${_displayName(config.appName)}',");
  lines.add('      debugShowCheckedModeBanner: false,');
  lines.add(
    '      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),',
  );
  lines.add(
    '      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),',
  );

  if (usesTheme && usesProviderState) {
    lines.add('      themeMode: themeMode,');
  }

  if (usesL10n) {
    if (usesProviderState) {
      lines.add('      locale: locale,');
    }
    lines.add('      localizationsDelegates: const [');
    lines.add('        AppLocalizations.delegate,');
    lines.add('        GlobalMaterialLocalizations.delegate,');
    lines.add('        GlobalWidgetsLocalizations.delegate,');
    lines.add('        GlobalCupertinoLocalizations.delegate,');
    lines.add('      ],');
    lines.add('      supportedLocales: AppLocalizations.supportedLocales,');
  }

  if (usesRouter) {
    lines.add('      routerConfig: AppRouter().config(),');
  } else {
    lines.add('      home: const HomeScreen(),');
  }

  lines.add('    );');
  lines.add('  }');
  lines.add('}');

  return '${lines.join('\n')}\n';
}

String _buildHomeScreenDart(CreateAppConfig config) {
  final usesRouter = config.modules.router;
  final lines = <String>[
    if (usesRouter) "import 'package:auto_route/auto_route.dart';",
    "import 'package:flutter/material.dart';",
    '',
    if (usesRouter) '@RoutePage()',
    'class HomeScreen extends StatelessWidget {',
    '  const HomeScreen({super.key});',
    '',
    '  @override',
    '  Widget build(BuildContext context) {',
    '    return Scaffold(',
    '      appBar: AppBar(title: const Text(\'Home\')),',
    '      body: Center(',
    '        child: Column(',
    '          mainAxisAlignment: MainAxisAlignment.center,',
    '          children: const [',
    '            Text(\'Welcome to ${_displayName(config.appName)}\'),',
    '            SizedBox(height: 8),',
    '            Text(\'Generated by flutter-arms create_app\'),',
    '          ],',
    '        ),',
    '      ),',
    '    );',
    '  }',
    '}',
  ];

  return '${lines.join('\n')}\n';
}

String _displayName(String appName) {
  return appName
      .split('_')
      .where((segment) => segment.isNotEmpty)
      .map(
        (segment) =>
            segment[0].toUpperCase() +
            (segment.length > 1 ? segment.substring(1) : ''),
      )
      .join(' ');
}
