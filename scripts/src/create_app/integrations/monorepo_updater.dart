import 'dart:io';

Future<void> ensureWorkspaceRegistration({
  required String rootDirectory,
  required String appName,
}) async {
  final rootPubspec = File('$rootDirectory/pubspec.yaml');
  if (!rootPubspec.existsSync()) {
    throw StateError('Root pubspec.yaml not found at $rootDirectory');
  }

  final appPath = 'app/$appName';
  final content = await rootPubspec.readAsString();
  final updated = registerAppWorkspace(content, appPath: appPath);

  if (updated != content) {
    await rootPubspec.writeAsString(updated);
  }
}

String registerAppWorkspace(String yamlContent, {required String appPath}) {
  final itemLine = '  - $appPath';
  if (yamlContent.contains(itemLine)) {
    return yamlContent;
  }

  final lines = yamlContent.split('\n');
  final workspaceIndex = lines.indexOf('workspace:');

  if (workspaceIndex == -1) {
    final suffix = yamlContent.endsWith('\n') ? '' : '\n';
    return '$yamlContent${suffix}workspace:\n$itemLine\n';
  }

  var insertAt = workspaceIndex + 1;
  while (insertAt < lines.length && lines[insertAt].startsWith('  - ')) {
    insertAt++;
  }

  lines.insert(insertAt, itemLine);
  return lines.join('\n');
}
