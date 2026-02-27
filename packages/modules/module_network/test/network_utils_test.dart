import 'package:module_network/src/utils/network_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NetworkUtils', () {
    test('generateCacheKey is order-insensitive for query parameters', () {
      final keyA = NetworkUtils.generateCacheKey(
        'https://api.example.com/users',
        {'b': 2, 'a': 1},
      );
      final keyB = NetworkUtils.generateCacheKey(
        'https://api.example.com/users',
        {'a': 1, 'b': 2},
      );

      expect(keyA, keyB);
      expect(keyA.startsWith('http_cache:'), isTrue);
    });

    test('generateCacheKey merges url query and external query parameters', () {
      final key = NetworkUtils.generateCacheKey(
        'https://api.example.com/items?lang=en',
        {'page': 2},
      );

      expect(key, contains('"lang":"en"'));
      expect(key, contains('"page":2'));
    });

    test('generateCacheKeyHash returns stable md5 cache key', () {
      final hash = NetworkUtils.generateCacheKeyHash(
        'https://api.example.com/users',
        {'q': 'abc'},
      );

      expect(hash.startsWith('http_cache:'), isTrue);
      expect(hash.length, 43);
    });

    test('joinUrl safely joins base and path slashes', () {
      expect(
        NetworkUtils.joinUrl('https://api.example.com/', '/users'),
        'https://api.example.com/users',
      );
      expect(
        NetworkUtils.joinUrl('https://api.example.com', 'users'),
        'https://api.example.com/users',
      );
    });

    test('encode and decode query parameters', () {
      final encoded = NetworkUtils.encodeQueryParameters({
        'q': 'hello world',
        'page': 2,
      });

      expect(encoded, contains('q=hello%20world'));
      expect(encoded, contains('page=2'));
      expect(NetworkUtils.decodeQueryParameters(encoded)['q'], 'hello world');
      expect(NetworkUtils.decodeQueryParameters(''), isEmpty);
    });

    test('formatBytes formats ranges and limits', () {
      expect(NetworkUtils.formatBytes(0), '0 B');
      expect(NetworkUtils.formatBytes(1024), '1.00 KB');
      expect(NetworkUtils.formatBytes(1536, decimals: 1), '1.5 KB');
      expect(NetworkUtils.formatBytes(1 << 50, decimals: 2), '1024.00 TB');
    });

    test('calculateProgress handles invalid totals and clamps result', () {
      expect(NetworkUtils.calculateProgress(10, 0), 0.0);
      expect(NetworkUtils.calculateProgress(5, 10), 50.0);
      expect(NetworkUtils.calculateProgress(20, 10), 100.0);
      expect(NetworkUtils.calculateProgress(-5, 10), 0.0);
    });

    test('isValidUrl validates http/https urls only', () {
      expect(NetworkUtils.isValidUrl('https://example.com'), isTrue);
      expect(NetworkUtils.isValidUrl('http://example.com'), isTrue);
      expect(NetworkUtils.isValidUrl('ftp://example.com'), isFalse);
      expect(NetworkUtils.isValidUrl('not-a-url'), isFalse);
    });

    test('extractFileNameFromUrl returns trailing path segment', () {
      expect(
        NetworkUtils.extractFileNameFromUrl(
          'https://cdn.example.com/a/b/c.png',
        ),
        'c.png',
      );
      expect(
        NetworkUtils.extractFileNameFromUrl('https://cdn.example.com/'),
        isNull,
      );
    });

    test('isNetworkImageUrl checks image extension and valid protocol', () {
      expect(
        NetworkUtils.isNetworkImageUrl('https://cdn.example.com/avatar.JPG'),
        isTrue,
      );
      expect(
        NetworkUtils.isNetworkImageUrl('https://cdn.example.com/data.json'),
        isFalse,
      );
      expect(NetworkUtils.isNetworkImageUrl('file:///tmp/a.png'), isFalse);
    });

    test('addQueryParameters merges with existing query parameters', () {
      final result = NetworkUtils.addQueryParameters(
        'https://api.example.com/users?lang=en',
        {'page': 2, 'lang': 'zh'},
      );

      final uri = Uri.parse(result);
      expect(uri.queryParameters['page'], '2');
      expect(uri.queryParameters['lang'], 'zh');
      expect(
        NetworkUtils.addQueryParameters('https://api.example.com/users', {}),
        'https://api.example.com/users',
      );
    });
  });
}
