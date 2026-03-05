import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('help output only documents dart run usage', () async {
    final result = await Process.run('dart', [
      'run',
      'scripts/create_app.dart',
      '--help',
    ]);

    expect(result.exitCode, 0);
    final output = result.stdout.toString();
    expect(output, contains('dart run scripts/create_app.dart --name shop_app'));
    expect(output, isNot(contains('melos run create:app')));
  });
}
