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

      for (final uri in imports) {
        if (uri.contains('/data/') ||
            uri.contains('features/auth/data/') ||
            uri.contains('flutter_riverpod')) {
          violations.add('${entity.path}: imports `$uri`');
        }
      }

      if (content.contains('Provider<')) {
        violations.add('${entity.path}: declares provider wiring inside domain');
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
