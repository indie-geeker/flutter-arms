import 'package:flutter_test/flutter_test.dart';
import 'package:interfaces/cache/cache_policy.dart';
import 'package:module_cache/src/impl/multi_level_cache.dart';

import '../mocks/mock_kv_storage.dart';
import '../mocks/mock_logger.dart';

/// Boundary condition tests for MultiLevelCacheManager.
///
/// Covers edge cases not handled by the main test suite:
/// concurrent access, large values, rapid writes, and error resilience.
void main() {
  group('MultiLevelCacheManager boundary conditions', () {
    late MultiLevelCacheManager cache;
    late MockKeyValueStorage storage;
    late MockLogger logger;

    setUp(() async {
      storage = MockKeyValueStorage();
      logger = MockLogger();
      cache = MultiLevelCacheManager(
        storage: storage,
        logger: logger,
        maxMemoryItems: 5,
      );
      await cache.init();
    });

    tearDown(() async {
      storage.disableErrorMode();
      await cache.clear();
    });

    group('concurrent operations', () {
      test('parallel puts do not corrupt cache state', () async {
        final futures = List.generate(
          20,
          (i) => cache.put('key$i', 'value$i'),
        );
        await Future.wait(futures);

        final stats = await cache.getStats();
        // Memory should be bounded by maxMemoryItems
        expect(stats.memoryKeys, lessThanOrEqualTo(5));
      });

      test('parallel gets return consistent values', () async {
        await cache.put('stable', 'expected');

        final results = await Future.wait(
          List.generate(10, (_) => cache.get<String>('stable')),
        );

        for (final result in results) {
          expect(result, 'expected');
        }
      });

      test('parallel put and get on same key', () async {
        await cache.put('race', 'initial');

        // Fire concurrent reads and writes
        final futures = <Future>[];
        for (int i = 0; i < 10; i++) {
          futures.add(cache.put('race', 'write_$i'));
          futures.add(cache.get<String>('race'));
        }
        await Future.wait(futures);

        // Final value should be one of the writes
        final final_ = await cache.get<String>('race');
        expect(final_, isNotNull);
        expect(final_, startsWith('write_'));
      });
    });

    group('large values', () {
      test('stores and retrieves large string values', () async {
        final largeValue = 'x' * 100000; // 100KB string
        await cache.put('large', largeValue);

        final result = await cache.get<String>('large');
        expect(result, largeValue);
      });

      test('stores and retrieves deeply nested map', () async {
        Map<String, dynamic> nested = {'leaf': 'value'};
        for (int i = 0; i < 20; i++) {
          nested = {'level_$i': nested};
        }
        await cache.put('nested', nested);

        final result = await cache.get<Map>('nested');
        expect(result, isNotNull);
      });

      test('stores and retrieves large list', () async {
        final largeList = List.generate(1000, (i) => 'item_$i');
        await cache.put('big_list', largeList);

        final result = await cache.get<List>('big_list');
        expect(result, isNotNull);
        expect(result!.length, 1000);
      });
    });

    group('rapid overwrites', () {
      test('rapid overwrites of same key settle to final value', () async {
        for (int i = 0; i < 50; i++) {
          await cache.put('overwrite', 'value_$i');
        }

        final result = await cache.get<String>('overwrite');
        expect(result, 'value_49');
      });

      test('alternating put-remove cycles leave cache clean', () async {
        for (int i = 0; i < 20; i++) {
          await cache.put('cycle', 'value_$i');
          await cache.remove('cycle');
        }

        final result = await cache.get<String>('cycle');
        expect(result, isNull);

        final exists = await cache.containsKey('cycle');
        expect(exists, false);
      });
    });

    group('edge-case keys', () {
      test('empty string key', () async {
        await cache.put('', 'empty_key_value');
        final result = await cache.get<String>('');
        expect(result, 'empty_key_value');
      });

      test('very long key', () async {
        final longKey = 'k' * 10000;
        await cache.put(longKey, 'long_key_value');
        final result = await cache.get<String>(longKey);
        expect(result, 'long_key_value');
      });

      test('special characters in key', () async {
        const specialKey = 'key/with:special@chars#and\$symbols!';
        await cache.put(specialKey, 'special_value');
        final result = await cache.get<String>(specialKey);
        expect(result, 'special_value');
      });
    });

    group('error resilience', () {
      test('storage error during put still caches in memory', () async {
        storage.enableErrorMode();
        await cache.put('memory_fallback', 'value',
            policy: CachePolicy.normal);
        storage.disableErrorMode();

        // Should still be in memory even though disk write failed
        final result = await cache.get<String>('memory_fallback');
        expect(result, 'value');
      });

      test('storage error during get falls back gracefully', () async {
        await cache.put('disk_item', 'value', policy: CachePolicy.normal);
        // Clear memory to force disk read
        await cache.clear();
        // Restore disk data
        await storage.setJson('cache:disk_item', {
          'key': 'disk_item',
          'value': 'value',
          'createdAt': DateTime.now().toIso8601String(),
          'expiresAt':
              DateTime.now().add(Duration(hours: 1)).toIso8601String(),
          'policy': 'normal',
        });

        storage.enableErrorMode();
        final result = await cache.get<String>('disk_item');
        storage.disableErrorMode();

        // Should return null when disk read fails (not throw)
        expect(result, isNull);
      });

      test('stats still work after error conditions', () async {
        storage.enableErrorMode();
        await cache.put('error_item', 'value');
        storage.disableErrorMode();

        // Stats should not throw
        final stats = await cache.getStats();
        expect(stats.memoryKeys, greaterThanOrEqualTo(0));
      });
    });
  });
}
