import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('domain files do not import data layer or riverpod wiring', () {
    final domainDir = Directory('lib/features/auth/domain');
    final prohibitedPatterns = <String>[
      'features/auth/data/',
      'flutter_riverpod',
      'Provider<',
    ];

    final violations = <String>[];

    for (final entity in domainDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }

      final content = entity.readAsStringSync();
      for (final pattern in prohibitedPatterns) {
        if (content.contains(pattern)) {
          violations.add('${entity.path}: contains `$pattern`');
        }
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
