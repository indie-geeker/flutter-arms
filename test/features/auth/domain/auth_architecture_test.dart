import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('domain files do not import data layer or riverpod wiring', () {
    final domainDir = Directory('lib/features/auth/domain');
    final directivePattern = RegExp(
      r'''^\s*(import|export|part)\s+['"]([^'"]+)['"];?''',
      multiLine: true,
    );
    final blockCommentPattern = RegExp(r'/\*.*?\*/', dotAll: true);
    final lineCommentPattern = RegExp(r'^\s*//.*$', multiLine: true);

    final violations = <String>[];

    for (final entity in domainDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }

      final content = entity.readAsStringSync();
      final code = content
          .replaceAll(blockCommentPattern, '')
          .replaceAll(lineCommentPattern, '');
      final directives = directivePattern
          .allMatches(code)
          .map((match) => match.group(2)!)
          .toList();
      final riverpodUsagePattern = RegExp(
        r'@riverpod|\bProvider\b|\bNotifierProvider\b|\bConsumer(?:Widget|StatefulWidget|State)?\b|\bRef\b|flutter_riverpod|riverpod_annotation',
      );

      for (final uri in directives) {
        if (uri.contains('/data/') ||
            uri.contains('features/auth/data/') ||
            uri.contains('flutter_riverpod')) {
          violations.add('${entity.path}: imports `$uri`');
        }
      }

      if (riverpodUsagePattern.hasMatch(code)) {
        violations.add('${entity.path}: contains riverpod wiring or API usage');
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
