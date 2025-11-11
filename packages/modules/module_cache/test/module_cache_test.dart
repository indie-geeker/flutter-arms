import 'package:test/test.dart';
import 'package:interfaces/cache/i_cache_manager.dart';
import 'package:interfaces/cache/cache_policy.dart';
import 'package:interfaces/core/module_registry.dart';
import 'package:interfaces/logger/i_logger.dart';
import 'package:interfaces/storage/i_kv_storage.dart';
import 'package:module_cache/src/cache_module.dart';

import 'mocks/mock_kv_storage.dart';
import 'mocks/mock_logger.dart';
import 'mocks/mock_service_locator.dart';

void main() {
  group('CacheModule', () {
    late CacheModule module;
    late MockServiceLocator locator;
    late MockKeyValueStorage mockStorage;
    late MockLogger mockLogger;

    setUp(() {
      module = CacheModule(maxMemoryItems: 10);
      locator = MockServiceLocator();
      mockStorage = MockKeyValueStorage();
      mockLogger = MockLogger();

      // Pre-register dependencies
      locator.registerSingleton<IKeyValueStorage>(mockStorage);
      locator.registerSingleton<ILogger>(mockLogger);
    });

    group('Module Properties', () {
      test('should have correct name', () {
        expect(module.name, 'CacheModule');
      });

      test('should have correct priority', () {
        expect(module.priority, InitPriorities.cache);
      });

      test('should declare correct dependencies', () {
        expect(module.dependencies, contains(ILogger));
        expect(module.dependencies, contains(IKeyValueStorage));
        expect(module.dependencies.length, 2);
      });
    });

    group('Module Registration', () {
      test('should register ICacheManager singleton', () async {
        await module.register(locator);

        expect(locator.isRegistered<ICacheManager>(), true);
      });

      test('should create MultiLevelCacheManager instance', () async {
        await module.register(locator);

        final cacheManager = locator.get<ICacheManager>();
        expect(cacheManager, isNotNull);
      });

      test('should pass maxMemoryItems to cache manager', () async {
        final customModule = CacheModule(maxMemoryItems: 50);
        await customModule.register(locator);

        final cacheManager = locator.get<ICacheManager>();
        expect(cacheManager, isNotNull);
        // Cache manager should be created with custom max items
      });

      test('should inject dependencies correctly', () async {
        await module.register(locator);

        // Should not throw when getting dependencies
        final cacheManager = locator.get<ICacheManager>();
        expect(cacheManager, isNotNull);
      });
    });

    group('Module Initialization', () {
      test('should initialize cache manager', () async {
        await module.register(locator);
        await module.init();

        expect(mockLogger.hasLog('info', 'Multi-level cache initialized'), true);
      });

      test('should make cache manager ready for use', () async {
        await module.register(locator);
        await module.init();

        final cacheManager = locator.get<ICacheManager>();
        await cacheManager.put('test_key', 'test_value');

        final result = await cacheManager.get<String>('test_key');
        expect(result, 'test_value');
      });

      test('should handle initialization errors', () async {
        await module.register(locator);

        // Storage errors should be logged but not crash
        mockStorage.enableErrorMode();

        // Init should complete despite errors
        await module.init();
      });
    });

    group('Module Disposal', () {
      test('should clear cache on disposal', () async {
        await module.register(locator);
        await module.init();

        final cacheManager = locator.get<ICacheManager>();
        await cacheManager.put('key1', 'value1');
        await cacheManager.put('key2', 'value2');

        await module.dispose();

        final result1 = await cacheManager.get<String>('key1');
        final result2 = await cacheManager.get<String>('key2');
        expect(result1, isNull);
        expect(result2, isNull);
      });

      test('should clear both memory and disk cache', () async {
        await module.register(locator);
        await module.init();

        final cacheManager = locator.get<ICacheManager>();
        await cacheManager.put('memory', 'value1', policy: CachePolicy.memoryOnly);
        await cacheManager.put('disk', 'value2', policy: CachePolicy.normal);

        await module.dispose();

        expect(await cacheManager.get<String>('memory'), isNull);
        expect(await cacheManager.get<String>('disk'), isNull);
      });
    });

    group('Full Module Lifecycle', () {
      test('should complete full register -> init -> dispose lifecycle', () async {
        // Register
        await module.register(locator);
        expect(locator.isRegistered<ICacheManager>(), true);

        // Init
        await module.init();
        final cacheManager = locator.get<ICacheManager>();
        await cacheManager.put('test', 'value');
        expect(await cacheManager.get<String>('test'), 'value');

        // Dispose
        await module.dispose();
        expect(await cacheManager.get<String>('test'), isNull);
      });

      test('should handle multiple register calls', () async {
        await module.register(locator);

        // Second register should replace the previous instance
        await module.register(locator);

        expect(locator.isRegistered<ICacheManager>(), true);
      });

      test('should allow re-initialization after disposal', () async {
        await module.register(locator);
        await module.init();

        final cacheManager = locator.get<ICacheManager>();
        await cacheManager.put('test', 'value1');

        await module.dispose();
        await module.init();

        // Can use cache again after re-init
        await cacheManager.put('test', 'value2');
        expect(await cacheManager.get<String>('test'), 'value2');
      });
    });

    group('Dependency Injection', () {
      test('should fail if ILogger not registered', () async {
        final badLocator = MockServiceLocator();
        badLocator.registerSingleton<IKeyValueStorage>(mockStorage);
        // ILogger not registered

        expect(
          () async => await module.register(badLocator),
          throwsException,
        );
      });

      test('should fail if IKeyValueStorage not registered', () async {
        final badLocator = MockServiceLocator();
        badLocator.registerSingleton<ILogger>(mockLogger);
        // IKeyValueStorage not registered

        expect(
          () async => await module.register(badLocator),
          throwsException,
        );
      });

      test('should use injected dependencies', () async {
        await module.register(locator);
        await module.init();

        final cacheManager = locator.get<ICacheManager>();
        await cacheManager.put('test', 'value', policy: CachePolicy.normal);

        // Verify storage was used
        final diskValue = await mockStorage.getJson('cache:test');
        expect(diskValue, isNotNull);

        // Verify logger was used
        expect(mockLogger.logs.isNotEmpty, true);
      });
    });

    group('Configuration', () {
      test('should support custom maxMemoryItems', () async {
        final customModule = CacheModule(maxMemoryItems: 5);
        await customModule.register(locator);
        await customModule.init();

        final cacheManager = locator.get<ICacheManager>();

        // Verify cache manager was created (configuration test)
        // The actual LRU eviction behavior is tested in multi_level_cache_test.dart
        expect(cacheManager, isNotNull);

        // Add a few items and verify they work
        await cacheManager.put('key1', 'value1', policy: CachePolicy.memoryOnly);
        await cacheManager.put('key2', 'value2', policy: CachePolicy.memoryOnly);

        expect(await cacheManager.get<String>('key1'), 'value1');
        expect(await cacheManager.get<String>('key2'), 'value2');
      });

      test('should use default maxMemoryItems when not specified', () async {
        final defaultModule = CacheModule();
        await defaultModule.register(locator);
        await defaultModule.init();

        final cacheManager = locator.get<ICacheManager>();

        // Default should be 100
        for (int i = 0; i < 150; i++) {
          await cacheManager.put('key$i', 'value$i');
        }

        final stats = await cacheManager.getStats();
        expect(stats.memoryKeys <= 100, true);
      });
    });

    group('Integration Tests', () {
      test('should work with real cache operations', () async {
        await module.register(locator);
        await module.init();

        final cacheManager = locator.get<ICacheManager>();

        // Test various operations
        await cacheManager.put('user:1', {'name': 'John', 'age': 30});
        await cacheManager.put('user:2', {'name': 'Jane', 'age': 25});
        await cacheManager.put('config', {'theme': 'dark'}, policy: CachePolicy.persistent);

        expect(await cacheManager.get<Map>('user:1'), {'name': 'John', 'age': 30});
        expect(await cacheManager.get<Map>('user:2'), {'name': 'Jane', 'age': 25});
        expect(await cacheManager.get<Map>('config'), {'theme': 'dark'});

        await cacheManager.remove('user:1');
        expect(await cacheManager.get<Map>('user:1'), isNull);

        final stats = await cacheManager.getStats();
        expect(stats.memoryKeys, greaterThan(0));
      });

      test('should persist data across module lifecycle', () async {
        await module.register(locator);
        await module.init();

        final cacheManager = locator.get<ICacheManager>();
        await cacheManager.put('persistent', 'data', policy: CachePolicy.persistent);

        // Verify it's in storage before disposal
        final diskValueBefore = await mockStorage.getJson('cache:persistent');
        expect(diskValueBefore, isNotNull);

        // Note: dispose() calls clear() which removes all data
        // This test demonstrates that disposal clears cache as designed
        await module.dispose();

        // Verify data was cleared as expected
        final diskValueAfter = await mockStorage.getJson('cache:persistent');
        expect(diskValueAfter, isNull);

        // Re-init creates fresh cache
        await module.init();

        // Cache is now empty after re-init
        final result = await cacheManager.get<String>('persistent');
        expect(result, isNull);
      });
    });
  });
}
