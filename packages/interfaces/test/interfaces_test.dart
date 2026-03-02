import 'package:interfaces/cache/cache_stats.dart';
import 'package:interfaces/network/network_cache_options.dart';
import 'package:interfaces/network/network_exception.dart';
import 'package:interfaces/network/network_types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('interfaces contracts', () {
    test('NetworkCacheOptions should have safe defaults', () {
      const options = NetworkCacheOptions();

      expect(options.enabled, isFalse);
      expect(options.duration, isNull);
      expect(options.cacheKey, isNull);
      expect(options.useHashKey, isFalse);
    });

    test(
      'NetworkException helper flags should reflect status code and type',
      () {
        final server = NetworkException(
          message: 'server',
          type: NetworkExceptionType.serverError,
          statusCode: 503,
        );
        final timeout = NetworkException(
          message: 'timeout',
          type: NetworkExceptionType.timeout,
        );

        expect(server.isServerError, isTrue);
        expect(server.isClientError, isFalse);
        expect(timeout.isTimeout, isTrue);
        expect(timeout.isConnectionError, isFalse);
      },
    );

    test('CacheStats should compute hit rate correctly', () {
      final stats = CacheStats(
        totalKeys: 0,
        memoryKeys: 0,
        diskKeys: 0,
        totalSize: 0,
        hitCount: 7,
        missCount: 3,
      );

      expect(stats.hitRate, 0.7);
    });

    test('CancelToken should notify listeners on cancel', () {
      final token = CancelToken();
      String? reason;

      token.addListener((value) {
        reason = value;
      });
      token.cancel('manual');

      expect(token.isCancelled, isTrue);
      expect(reason, 'manual');
    });
  });
}
