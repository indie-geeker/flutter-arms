import 'package:interfaces/cache/cache_policy.dart';
import 'package:interfaces/network/i_http_client.dart';
import 'package:interfaces/network/network_cache_options.dart';

import '../../domain/repositories/i_network_demo_repository.dart';

class NetworkDemoDataSource {
  static const String networkCacheKey = 'example:network-demo:posts';

  final IHttpClient _httpClient;

  const NetworkDemoDataSource(this._httpClient);

  Future<List<Map<String, dynamic>>> fetchPosts({
    required DemoCacheMode cacheMode,
  }) async {
    final response = await _httpClient.get<dynamic>(
      '/posts',
      queryParameters: <String, dynamic>{'_limit': 10},
      cacheOptions: _cacheOptionsFor(cacheMode),
    );

    if (!response.isSuccess || response.data == null) {
      final message = response.error?.message ?? 'Request failed.';
      throw StateError(message);
    }

    final data = response.data;
    if (data is! List) {
      throw const FormatException('Unexpected response payload.');
    }

    return data
        .map<Map<String, dynamic>>((dynamic item) {
          if (item is Map<String, dynamic>) {
            return Map<String, dynamic>.from(item);
          }
          if (item is Map) {
            return item.map<String, dynamic>(
              (dynamic key, dynamic value) => MapEntry(key.toString(), value),
            );
          }
          throw const FormatException('Unexpected post item.');
        })
        .toList(growable: false);
  }

  NetworkCacheOptions _cacheOptionsFor(DemoCacheMode cacheMode) {
    switch (cacheMode) {
      case DemoCacheMode.cacheFirst:
        return const NetworkCacheOptions(
          enabled: true,
          policy: CachePolicy.cacheFirst,
          cacheKey: networkCacheKey,
        );
      case DemoCacheMode.networkFirst:
        return const NetworkCacheOptions(
          enabled: true,
          policy: CachePolicy.networkFirst,
          cacheKey: networkCacheKey,
        );
      case DemoCacheMode.disabled:
        return const NetworkCacheOptions(enabled: false);
    }
  }
}
