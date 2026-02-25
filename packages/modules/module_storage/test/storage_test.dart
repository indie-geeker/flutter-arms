import 'package:interfaces/logger/i_logger.dart';
import 'package:interfaces/storage/i_kv_storage.dart';
import 'package:interfaces/storage/i_secure_storage.dart';
import 'package:module_storage/src/storage_module.dart';
import 'package:test/test.dart';

void main() {
  group('StorageModule', () {
    test('should expose logger dependency and key-value storage provider', () {
      final module = StorageModule();

      expect(module.dependencies, [ILogger]);
      expect(module.provides, [IKeyValueStorage]);
    });

    test('should expose secure storage when enabled', () {
      final module = StorageModule(
        config: StorageConfig(enableSecureStorage: true),
      );

      expect(module.provides, contains(IKeyValueStorage));
      expect(module.provides, contains(ISecureStorage));
    });

    test('StorageConfig should provide expected defaults', () {
      final config = StorageConfig();

      expect(config.kvStorageBoxName, 'app_storage');
      expect(config.baseDir, isNull);
      expect(config.enableSecureStorage, isFalse);
      expect(config.enableRelationalStorage, isFalse);
      expect(config.databaseName, 'app.db');
    });
  });
}
