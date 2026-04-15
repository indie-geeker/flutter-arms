import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('domain files do not import data layer or riverpod wiring', () {
    final domainDir = Directory('lib/features/auth/domain');
    final importPattern = RegExp(
      r'''^\s*import\s+['"]([^'"]+)['"];?''',
      multiLine: true,
    );

    final violations = <String>[];

    for (final entity in domainDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }

      final content = entity.readAsStringSync();
      final imports = importPattern
          .allMatches(content)
          .map((match) => match.group(1)!)
          .toList();
      final riverpodUsagePattern = RegExp(
        r'@riverpod|\bProvider\b|\bNotifierProvider\b|\bConsumer(?:Widget|StatefulWidget|State)?\b|\bRef\b|flutter_riverpod|riverpod_annotation',
      );

      for (final uri in imports) {
        if (uri.contains('/data/') ||
            uri.contains('features/auth/data/') ||
            uri.contains('flutter_riverpod')) {
          violations.add('${entity.path}: imports `$uri`');
        }
      }

      if (riverpodUsagePattern.hasMatch(content)) {
        violations.add('${entity.path}: contains riverpod wiring or API usage');
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
