import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// 架构层级约束测试。
///
/// 规则（对应 IMPROVEMENT_PLAN.md §7）：
/// 1. `lib/features/**/domain/**` 不得 import `dio` / `hive` / `retrofit`。
/// 2. `lib/features/**/domain/**` 与 `lib/features/**/presentation/**` 不得 import `AppException` 及其子类。
/// 3. `lib/core/**` 不得 import `lib/features/**`（允许例外在源文件标注 `// arch-exempt`）。
/// 4. 任意 `features/<X>` 不得 import 其他 `features/<Y>`。
void main() {
  final libDir = Directory(p.normalize(p.join(Directory.current.path, 'lib')));

  List<File> dartFiles(Directory dir) {
    if (!dir.existsSync()) return const <File>[];
    return dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();
  }

  bool fileHas(File file, Pattern pattern) =>
      file.readAsStringSync().contains(pattern);

  String rel(File file) => p.relative(file.path, from: libDir.path);

  group('architecture', () {
    test('domain layer must not import Data-layer transport packages', () {
      final domainDirs = Directory(p.join(libDir.path, 'features'))
          .listSync()
          .whereType<Directory>()
          .map((d) => Directory(p.join(d.path, 'domain')))
          .where((d) => d.existsSync())
          .toList();

      final offenders = <String>[];
      const forbidden = <String>[
        "import 'package:dio/",
        "import 'package:hive_ce/",
        "import 'package:hive_ce_flutter/",
        "import 'package:retrofit/",
      ];
      for (final dir in domainDirs) {
        for (final file in dartFiles(dir)) {
          for (final needle in forbidden) {
            if (fileHas(file, needle)) {
              offenders.add('${rel(file)} -> $needle');
            }
          }
        }
      }
      expect(offenders, isEmpty, reason: 'Domain depends on Data transport');
    });

    test('domain/presentation must not import AppException', () {
      final offenders = <String>[];
      final forbidden = RegExp(
        r"import\s+['\x22]package:flutter_arms/core/error/app_exception(?:_mapper)?\.dart['\x22]",
      );
      final featuresDir = Directory(p.join(libDir.path, 'features'));
      if (!featuresDir.existsSync()) return;

      for (final feature in featuresDir.listSync().whereType<Directory>()) {
        for (final subdir in <String>['domain', 'presentation']) {
          final dir = Directory(p.join(feature.path, subdir));
          if (!dir.existsSync()) continue;
          for (final file in dartFiles(dir)) {
            if (fileHas(file, forbidden)) {
              offenders.add(rel(file));
            }
          }
        }
      }
      expect(
        offenders,
        isEmpty,
        reason: 'Domain/Presentation imports AppException',
      );
    });

    test('core/ must not import features/', () {
      final coreDir = Directory(p.join(libDir.path, 'core'));
      if (!coreDir.existsSync()) return;

      final offenders = <String>[];
      final forbidden = RegExp(
        r"import\s+['\x22]package:flutter_arms/features/",
      );
      for (final file in dartFiles(coreDir)) {
        final content = file.readAsStringSync();
        // 允许在 import 行上一行用 `// arch-exempt` 标注豁免。
        if (content.contains('// arch-exempt')) continue;
        if (forbidden.hasMatch(content)) {
          offenders.add(rel(file));
        }
      }
      expect(offenders, isEmpty, reason: 'core/ imports features/');
    });

    test('features/<X> must not import features/<Y>', () {
      final featuresDir = Directory(p.join(libDir.path, 'features'));
      if (!featuresDir.existsSync()) return;

      final offenders = <String>[];
      for (final feature in featuresDir.listSync().whereType<Directory>()) {
        final featureName = p.basename(feature.path);
        final importRe = RegExp(
          r"import\s+['\x22]package:flutter_arms/features/([^/]+)/",
        );
        for (final file in dartFiles(feature)) {
          final content = file.readAsStringSync();
          // 允许文件级 `// arch-exempt` 豁免（用于 auth 等跨切面能力）。
          if (content.contains('// arch-exempt')) continue;
          for (final match in importRe.allMatches(content)) {
            final importedFeature = match.group(1)!;
            if (importedFeature != featureName) {
              offenders.add(
                '${rel(file)} -> features/$importedFeature',
              );
            }
          }
        }
      }
      expect(
        offenders,
        isEmpty,
        reason: 'Cross-feature import detected (feature isolation broken)',
      );
    });
  });
}
