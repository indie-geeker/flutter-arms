import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('example app uses shared directory instead of core directory', () {
    expect(Directory('lib/src/shared').existsSync(), isTrue);
    expect(Directory('lib/src/core').existsSync(), isFalse);
  });

  test('di providers facade imports ServiceLocator from core', () {
    final providersFile = File('lib/src/di/providers.dart').readAsStringSync();

    expect(providersFile.contains('package:core/core.dart'), isTrue);
    expect(providersFile.contains('auth_providers.dart'), isFalse);
    expect(providersFile.contains('network_demo_providers.dart'), isFalse);
  });

  test('router imports feature entrypoints instead of screen internals', () {
    final routerFile = File(
      'lib/src/router/app_router.dart',
    ).readAsStringSync();

    expect(
      routerFile.contains(
        'package:example/src/features/authentication/authentication.dart',
      ),
      isTrue,
    );
    expect(
      routerFile.contains(
        'package:example/src/features/network_demo/network_demo.dart',
      ),
      isTrue,
    );
    expect(
      routerFile.contains(
        'package:example/src/features/settings/settings.dart',
      ),
      isTrue,
    );
    expect(routerFile.contains('/presentation/screens/'), isFalse);
  });
}
