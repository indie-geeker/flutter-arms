import 'package:example/src/app/app.dart';
import 'package:interfaces/cache/i_cache_manager.dart';
import 'package:interfaces/logger/i_logger.dart';
import 'package:interfaces/network/i_http_client.dart';
import 'package:interfaces/storage/i_kv_storage.dart';
import 'package:module_cache/module_cache.dart';
import 'package:module_logger/module_logger.dart';
import 'package:module_network/module_network.dart';
import 'package:module_storage/storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Example bootstrap profiles', () {
    test('minimal profile initializes logger and storage only', () {
      final modules = buildBootstrapModules(
        enableFullStackProfile: false,
        enableSecureStorage: false,
      );

      expect(modules.map((m) => m.runtimeType).toList(), [
        LoggerModule,
        StorageModule,
      ]);

      final providedTypes = modules.expand((m) => m.provides).toSet();
      expect(providedTypes, contains(ILogger));
      expect(providedTypes, contains(IKeyValueStorage));
      expect(providedTypes, isNot(contains(ICacheManager)));
      expect(providedTypes, isNot(contains(IHttpClient)));
    });

    test('full-stack profile includes cache and network providers', () {
      final modules = buildBootstrapModules(
        enableFullStackProfile: true,
        enableSecureStorage: false,
      );

      final moduleTypes = modules.map((m) => m.runtimeType).toSet();
      expect(moduleTypes, containsAll({LoggerModule, StorageModule, CacheModule, NetworkModule}));

      final networkModule = modules.whereType<NetworkModule>().single;
      expect(networkModule.enableCache, isTrue);
      expect(networkModule.dependencies, containsAll([ILogger, ICacheManager]));

      final providedTypes = modules.expand((m) => m.provides).toSet();
      expect(providedTypes, containsAll([ILogger, IKeyValueStorage, ICacheManager, IHttpClient]));
    });
  });
}
