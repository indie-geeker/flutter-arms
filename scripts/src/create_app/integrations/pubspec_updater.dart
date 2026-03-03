import 'dart:io';

import '../modules/module_spec.dart';

const Map<String, String> _dependencyVersions = {
  'auto_route': '^11.1.0',
  'flutter_riverpod': '^3.1.0',
  'riverpod_annotation': '^4.0.0',
  'intl': '^0.20.2',
};

const Map<String, String> _devDependencyVersions = {
  'build_runner': '^2.11.1',
  'auto_route_generator': '^10.4.0',
  'riverpod_generator': '^4.0.0+1',
};

Future<void> ensureAppPubspec({
  required String appDirectory,
  required String appName,
  required DependencySet dependencies,
  required bool includeL10n,
}) async {
  final file = File('$appDirectory/pubspec.yaml');
  if (!file.existsSync()) {
    final base = _createBasePubspec(appName);
    await file.writeAsString(base);
  }

  var content = await file.readAsString();

  content = _ensureDependencySection(content);
  content = _ensureDevDependencySection(content);

  for (final dep in dependencies.dependencies) {
    if (dep == 'flutter_localizations') {
      content = _ensureFlutterSdkDependency(content, dep);
      continue;
    }

    final version = _dependencyVersions[dep] ?? 'any';
    content = _ensureSimpleDependency(
      content,
      section: 'dependencies',
      name: dep,
      version: version,
    );
  }

  for (final dep in dependencies.devDependencies) {
    final version = _devDependencyVersions[dep] ?? 'any';
    content = _ensureSimpleDependency(
      content,
      section: 'dev_dependencies',
      name: dep,
      version: version,
    );
  }

  if (includeL10n) {
    content = _ensureFlutterSdkDependency(content, 'flutter_localizations');
    content = _ensureFlutterGenerate(content);
  }

  await file.writeAsString(content);
}

String _createBasePubspec(String appName) {
  return '''name: $appName
description: Generated app scaffold
publish_to: none
version: 1.0.0+1

environment:
  sdk: ">=3.11.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
''';
}

String _ensureDependencySection(String content) {
  if (RegExp(r'^dependencies:\s*$', multiLine: true).hasMatch(content)) {
    return content;
  }
  return '$content\n\ndependencies:\n';
}

String _ensureDevDependencySection(String content) {
  if (RegExp(r'^dev_dependencies:\s*$', multiLine: true).hasMatch(content)) {
    return content;
  }
  return '$content\n\ndev_dependencies:\n';
}

String _ensureSimpleDependency(
  String content, {
  required String section,
  required String name,
  required String version,
}) {
  final exists = RegExp(
    '^  ${RegExp.escape(name)}:',
    multiLine: true,
  ).hasMatch(content);
  if (exists) {
    return content;
  }

  return _insertIntoSection(content, section, '  $name: $version\n');
}

String _ensureFlutterSdkDependency(String content, String name) {
  final exists = RegExp(
    '^  ${RegExp.escape(name)}:',
    multiLine: true,
  ).hasMatch(content);
  if (exists) {
    return content;
  }

  return _insertIntoSection(
    content,
    'dependencies',
    '  $name:\n    sdk: flutter\n',
  );
}

String _insertIntoSection(String content, String section, String block) {
  final lines = content.split('\n');
  final sectionLine = '$section:';
  final index = lines.indexOf(sectionLine);
  if (index == -1) {
    return '$content\n$section:\n$block';
  }

  var insertAt = index + 1;
  while (insertAt < lines.length) {
    final line = lines[insertAt];
    if (line.isEmpty) {
      break;
    }
    if (!line.startsWith(' ')) {
      break;
    }
    insertAt++;
  }

  lines.insert(insertAt, block.trimRight());
  return lines.join('\n');
}

String _ensureFlutterGenerate(String content) {
  final hasFlutterSection = RegExp(
    r'^flutter:\s*$',
    multiLine: true,
  ).hasMatch(content);
  if (!hasFlutterSection) {
    return '$content\nflutter:\n  generate: true\n  uses-material-design: true\n';
  }

  if (RegExp(r'^  generate:\s*true\s*$', multiLine: true).hasMatch(content)) {
    return content;
  }

  final lines = content.split('\n');
  final index = lines.indexOf('flutter:');
  lines.insert(index + 1, '  generate: true');
  return lines.join('\n');
}
