import 'package:example/src/app/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:module_cache/module_cache.dart';
import 'package:module_logger/module_logger.dart';
import 'package:module_network/module_network.dart';
import 'package:module_storage/storage.dart';

const bool kExpectedFullStackProfile = bool.fromEnvironment(
  'ARMS_EXPECT_FULL_STACK',
  defaultValue: false,
);

void main() {
  test('compile-time profile flag controls default bootstrap modules', () {
    final modules = buildBootstrapModules();
    final moduleTypes = modules.map((module) => module.runtimeType).toSet();

    expect(kEnableFullStackProfile, kExpectedFullStackProfile);

    if (kExpectedFullStackProfile) {
      expect(
        moduleTypes,
        containsAll({LoggerModule, StorageModule, CacheModule, NetworkModule}),
      );
      return;
    }

    expect(moduleTypes, equals({LoggerModule, StorageModule}));
  });
}
