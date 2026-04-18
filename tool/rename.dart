// Rename this Flutter template to a new project.
//
// Usage:
//   dart tool/rename.dart \
//     --name my_app \
//     --package com.example.my_app \
//     [--display "My App"] \
//     [--ios-bundle-id com.example.myApp]
//
// Omit flags to be prompted interactively.
// Cross-platform: runs on macOS / Linux / Windows with just the Dart SDK.
// Idempotent: rerunning with the same arguments is a no-op.
// Safe: never deletes a non-empty directory, so overlapping package prefixes
//       (e.g. renaming com.indiegeeker.flutter_arms → com.indiegeeker.my_app)
//       will not remove the freshly created folder.

import 'dart:io';

const _oldName = 'flutter_arms';
const _oldPackage = 'com.indiegeeker.flutter_arms';
const _oldIosId = 'com.indiegeeker.flutterArms';
const _oldDisplay = 'Flutter Arms';
const _oldCompany = 'com.indiegeeker';

late final Directory _root;

void main(List<String> argv) {
  final flags = _parseFlags(argv);
  _root = _projectRoot();

  final name = flags['name'] ?? _ask('Project name (snake_case)', _validateName);
  final pkg = flags['package'] ?? _ask('Android package (e.g. com.example.my_app)', _validatePackage);
  final display = flags['display'] ?? _titleCase(name);
  final iosId = flags['ios-bundle-id'] ?? _toCamelPackage(pkg);

  _validateName(name);
  _validatePackage(pkg);
  _validatePackage(iosId);
  _guardAlreadyRenamed(name);

  stdout
    ..writeln('')
    ..writeln('[rename] Dart name:        $_oldName -> $name')
    ..writeln('[rename] Android package:  $_oldPackage -> $pkg')
    ..writeln('[rename] iOS/macOS bundle: $_oldIosId -> $iosId')
    ..writeln('[rename] Display name:     $_oldDisplay -> $display')
    ..writeln('');

  _renamePubspec(name);
  _renameDartImports(name);
  _renameAndroid(pkg, display);
  _renameIos(iosId, display, name);
  _renameMacos(iosId, display, name, pkg);
  _renameLinux(name, pkg);
  _renameWindows(name, display, pkg);
  _renameWeb(name, display);

  stdout
    ..writeln('')
    ..writeln('[rename] Done. Next:')
    ..writeln('  1) git status                     # review changes')
    ..writeln('  2) flutter clean && flutter pub get')
    ..writeln('  3) tool/gen.sh                    # build_runner + slang')
    ..writeln('  4) Replace assets/icon/app_icon.png and assets/splash/logo.png, then:')
    ..writeln('     dart run flutter_launcher_icons')
    ..writeln('     dart run flutter_native_splash:create');
}

// ---------------------------------------------------------------------------
// Per-platform steps
// ---------------------------------------------------------------------------

void _renamePubspec(String name) {
  _editFile(_path('pubspec.yaml'), (s) => s.replaceFirst(
        RegExp(r'^name:\s*' + RegExp.escape(_oldName), multiLine: true),
        'name: $name',
      ));
}

void _renameDartImports(String name) {
  for (final d in ['lib', 'test']) {
    final dir = Directory(_path(d));
    if (!dir.existsSync()) continue;
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        _editFile(entity.path, (s) => s.replaceAll(
              'package:$_oldName/',
              'package:$name/',
            ));
      }
    }
  }
}

void _renameAndroid(String pkg, String display) {
  _editFile(_path('android/app/build.gradle.kts'),
      (s) => s.replaceAll(_oldPackage, pkg));
  _editFile(_path('android/app/src/main/AndroidManifest.xml'),
      (s) => s.replaceFirst(
            'android:label="$_oldName"',
            'android:label="$display"',
          ));

  final kotlinRoot = Directory(_path('android/app/src/main/kotlin'));
  final oldDir = Directory('${kotlinRoot.path}/${_oldPackage.replaceAll('.', Platform.pathSeparator)}');
  final newDir = Directory('${kotlinRoot.path}/${pkg.replaceAll('.', Platform.pathSeparator)}');

  if (oldDir.existsSync() && oldDir.path != newDir.path) {
    newDir.createSync(recursive: true);
    for (final entity in oldDir.listSync()) {
      final target = '${newDir.path}${Platform.pathSeparator}${_basename(entity.path)}';
      entity.renameSync(target);
    }
    _rmdirUpwards(oldDir, stopAt: kotlinRoot);
  }

  final mainActivity = File('${newDir.path}${Platform.pathSeparator}MainActivity.kt');
  if (mainActivity.existsSync()) {
    _editFile(mainActivity.path, (s) => s.replaceFirst(
          'package $_oldPackage',
          'package $pkg',
        ));
  }
}

void _renameIos(String iosId, String display, String snakeName) {
  _editFile(_path('ios/Runner.xcodeproj/project.pbxproj'),
      (s) => s.replaceAll(_oldIosId, iosId));
  _editPlist(_path('ios/Runner/Info.plist'), {
    'CFBundleDisplayName': display,
    'CFBundleName': snakeName,
  });
}

void _renameMacos(String iosId, String display, String snakeName, String pkg) {
  _editFile(_path('macos/Runner/Configs/AppInfo.xcconfig'), (s) => s
      .replaceAll('PRODUCT_NAME = $_oldName', 'PRODUCT_NAME = $snakeName')
      .replaceAll(
        'PRODUCT_BUNDLE_IDENTIFIER = $_oldIosId',
        'PRODUCT_BUNDLE_IDENTIFIER = $iosId',
      )
      .replaceAll(_oldCompany, _companyFromPackage(pkg)));
  _editFile(_path('macos/Runner.xcodeproj/project.pbxproj'),
      (s) => s.replaceAll(_oldIosId, iosId));
  _editPlist(_path('macos/Runner/Info.plist'), {
    'CFBundleDisplayName': display,
    'CFBundleName': snakeName,
  });
}

void _renameLinux(String snakeName, String pkg) {
  _editFile(_path('linux/CMakeLists.txt'), (s) => s
      .replaceAll(
        'set(BINARY_NAME "$_oldName")',
        'set(BINARY_NAME "$snakeName")',
      )
      .replaceAll(
        'set(APPLICATION_ID "$_oldPackage")',
        'set(APPLICATION_ID "$pkg")',
      ));
}

void _renameWindows(String snakeName, String display, String pkg) {
  _editFile(_path('windows/CMakeLists.txt'), (s) => s
      .replaceAll(
        'project($_oldName LANGUAGES CXX)',
        'project($snakeName LANGUAGES CXX)',
      )
      .replaceAll(
        'set(BINARY_NAME "$_oldName")',
        'set(BINARY_NAME "$snakeName")',
      ));
  _editFile(_path('windows/runner/main.cpp'),
      (s) => s.replaceAll('L"$_oldName"', 'L"$display"'));

  final company = _companyFromPackage(pkg);
  final year = DateTime.now().year;
  _editFile(_path('windows/runner/Runner.rc'), (s) => s
      .replaceFirst(
        'VALUE "CompanyName", "$_oldCompany"',
        'VALUE "CompanyName", "$company"',
      )
      .replaceFirst(
        'VALUE "FileDescription", "$_oldName"',
        'VALUE "FileDescription", "$display"',
      )
      .replaceFirst(
        'VALUE "InternalName", "$_oldName"',
        'VALUE "InternalName", "$snakeName"',
      )
      .replaceFirst(
        RegExp(r'Copyright \(C\) \d{4} ' + RegExp.escape(_oldCompany)),
        'Copyright (C) $year $company',
      )
      .replaceFirst(
        'VALUE "OriginalFilename", "$_oldName.exe"',
        'VALUE "OriginalFilename", "$snakeName.exe"',
      )
      .replaceFirst(
        'VALUE "ProductName", "$_oldName"',
        'VALUE "ProductName", "$display"',
      ));
}

void _renameWeb(String snakeName, String display) {
  _editFile(_path('web/index.html'), (s) => s
      .replaceAll('<title>$_oldName</title>', '<title>$display</title>')
      .replaceAll(
        'name="apple-mobile-web-app-title" content="$_oldName"',
        'name="apple-mobile-web-app-title" content="$display"',
      ));
  _editFile(_path('web/manifest.json'), (s) => s
      .replaceAll('"name": "$_oldName"', '"name": "$display"')
      .replaceAll('"short_name": "$_oldName"', '"short_name": "$display"'));
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Map<String, String> _parseFlags(List<String> argv) {
  final out = <String, String>{};
  for (var i = 0; i < argv.length; i++) {
    final a = argv[i];
    if (!a.startsWith('--')) continue;
    final key = a.substring(2);
    if (i + 1 < argv.length && !argv[i + 1].startsWith('--')) {
      out[key] = argv[++i];
    }
  }
  return out;
}

class _RenameException implements Exception {
  _RenameException(this.message);
  final String message;
  @override
  String toString() => message;
}

String _ask(String prompt, void Function(String) validator) {
  while (true) {
    stdout.write('$prompt: ');
    final v = stdin.readLineSync()?.trim() ?? '';
    try {
      validator(v);
      return v;
    } on _RenameException catch (e) {
      stdout.writeln('  ! ${e.message}');
    }
  }
}

void _validateName(String n) {
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(n)) {
    throw _RenameException('Name must be snake_case lowercase (got "$n")');
  }
}

void _validatePackage(String p) {
  if (!RegExp(r'^[a-z][a-zA-Z0-9_]*(\.[a-z][a-zA-Z0-9_]*)+$').hasMatch(p)) {
    throw _RenameException('Package must look like com.example.my_app (got "$p")');
  }
}

String _titleCase(String snake) => snake
    .split('_')
    .where((s) => s.isNotEmpty)
    .map((s) => '${s[0].toUpperCase()}${s.substring(1)}')
    .join(' ');

String _toCamelPackage(String pkg) => pkg.split('.').map((seg) {
      if (!seg.contains('_')) return seg;
      final parts = seg.split('_').where((p) => p.isNotEmpty).toList();
      if (parts.isEmpty) return seg;
      return parts.first +
          parts
              .skip(1)
              .map((p) => '${p[0].toUpperCase()}${p.substring(1)}')
              .join();
    }).join('.');

String _companyFromPackage(String pkg) {
  final parts = pkg.split('.');
  return parts.length >= 2 ? '${parts[0]}.${parts[1]}' : pkg;
}

Directory _projectRoot() {
  var dir = Directory.fromUri(Platform.script).absolute.parent;
  while (!File('${dir.path}${Platform.pathSeparator}pubspec.yaml').existsSync()) {
    if (dir.parent.path == dir.path) {
      stderr.writeln('[rename] Could not locate project root (no pubspec.yaml found)');
      exit(1);
    }
    dir = dir.parent;
  }
  return dir;
}

void _guardAlreadyRenamed(String newName) {
  final pubspec = File(_path('pubspec.yaml')).readAsStringSync();
  final m = RegExp(r'^name:\s*(\S+)', multiLine: true).firstMatch(pubspec);
  final current = m?.group(1);
  if (current == newName) {
    stdout.writeln('[rename] pubspec already shows name=$newName; running in idempotent mode.');
    return;
  }
  if (current != _oldName) {
    stderr.writeln(
      '[rename] Refusing to run: pubspec.yaml has name="$current" '
      '(expected "$_oldName" or "$newName"). Did you already rename this project?',
    );
    exit(1);
  }
}

void _editFile(String path, String Function(String) transform) {
  final f = File(path);
  if (!f.existsSync()) return;
  final before = f.readAsStringSync();
  final after = transform(before);
  if (before == after) return;
  f.writeAsStringSync(after);
  stdout.writeln('  edit  ${_rel(path)}');
}

void _editPlist(String path, Map<String, String> kv) {
  _editFile(path, (s) {
    var out = s;
    for (final entry in kv.entries) {
      final key = RegExp.escape(entry.key);
      final re = RegExp('<key>$key</key>\\s*<string>[^<]*</string>');
      out = out.replaceFirst(
        re,
        '<key>${entry.key}</key>\n\t<string>${entry.value}</string>',
      );
    }
    return out;
  });
}

void _rmdirUpwards(Directory leaf, {required Directory stopAt}) {
  var d = leaf;
  while (d.path != stopAt.path) {
    if (!d.existsSync()) break;
    if (d.listSync().isNotEmpty) break;
    d.deleteSync();
    d = d.parent;
  }
}

String _path(String rel) =>
    '${_root.path}${Platform.pathSeparator}${rel.replaceAll('/', Platform.pathSeparator)}';

String _rel(String path) =>
    path.startsWith(_root.path) ? path.substring(_root.path.length + 1) : path;

String _basename(String path) {
  final sep = Platform.pathSeparator;
  final i = path.lastIndexOf(sep);
  return i == -1 ? path : path.substring(i + 1);
}
