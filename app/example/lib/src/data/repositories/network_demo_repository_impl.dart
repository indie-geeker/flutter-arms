import 'dart:convert';

import 'package:interfaces/cache/cache_policy.dart';
import 'package:interfaces/cache/i_cache_manager.dart';

import '../../domain/entities/demo_post_entity.dart';
import '../../domain/repositories/i_network_demo_repository.dart';
import '../datasources/network_demo_datasource.dart';

class NetworkDemoRepositoryImpl implements INetworkDemoRepository {
  static const String _cacheKey = 'example:network-demo:posts';

  final NetworkDemoDataSource _dataSource;
  final ICacheManager _cacheManager;

  const NetworkDemoRepositoryImpl(this._dataSource, this._cacheManager);

  @override
  Future<DemoPostsResult> fetchPosts({required DemoCacheMode cacheMode}) async {
    switch (cacheMode) {
      case DemoCacheMode.cacheFirst:
        final cachedPosts = await _readCachedPosts();
        if (cachedPosts != null) {
          return DemoPostsResult(posts: cachedPosts, fromCache: true);
        }
        final freshPosts = await _fetchAndCache(cacheMode: cacheMode);
        return DemoPostsResult(posts: freshPosts, fromCache: false);
      case DemoCacheMode.networkFirst:
        try {
          final freshPosts = await _fetchAndCache(cacheMode: cacheMode);
          return DemoPostsResult(posts: freshPosts, fromCache: false);
        } catch (_) {
          final cachedPosts = await _readCachedPosts();
          if (cachedPosts != null) {
            return DemoPostsResult(posts: cachedPosts, fromCache: true);
          }
          rethrow;
        }
      case DemoCacheMode.disabled:
        final freshPosts = await _fetchFromNetwork(cacheMode: cacheMode);
        return DemoPostsResult(posts: freshPosts, fromCache: false);
    }
  }

  Future<List<DemoPostEntity>> _fetchAndCache({
    required DemoCacheMode cacheMode,
  }) async {
    final posts = await _fetchFromNetwork(cacheMode: cacheMode);
    await _cacheManager.put<String>(
      _cacheKey,
      jsonEncode(posts.map(_toJson).toList(growable: false)),
      duration: const Duration(minutes: 5),
      policy: CachePolicy.normal,
    );
    return posts;
  }

  Future<List<DemoPostEntity>> _fetchFromNetwork({
    required DemoCacheMode cacheMode,
  }) async {
    final rawPosts = await _dataSource.fetchPosts(cacheMode: cacheMode);
    return rawPosts.map(_toEntity).toList(growable: false);
  }

  Future<List<DemoPostEntity>?> _readCachedPosts() async {
    final cachedRaw = await _cacheManager.get<dynamic>(_cacheKey);
    if (cachedRaw == null) {
      return null;
    }

    final Object? decoded;
    if (cachedRaw is String) {
      decoded = jsonDecode(cachedRaw);
    } else if (cachedRaw is List<dynamic>) {
      decoded = cachedRaw;
    } else {
      decoded = null;
    }

    if (decoded is! List) {
      return null;
    }

    return decoded
        .map<DemoPostEntity>((dynamic item) {
          if (item is! Map) {
            throw const FormatException('Invalid cached post item.');
          }
          return _toEntity(
            item.map<String, dynamic>(
              (dynamic key, dynamic value) => MapEntry(key.toString(), value),
            ),
          );
        })
        .toList(growable: false);
  }

  DemoPostEntity _toEntity(Map<String, dynamic> json) {
    return DemoPostEntity(
      id: (json['id'] as num?)?.toInt() ?? -1,
      title: json['title']?.toString() ?? '(untitled)',
      body: json['body']?.toString() ?? '',
    );
  }

  Map<String, dynamic> _toJson(DemoPostEntity post) {
    return <String, dynamic>{
      'id': post.id,
      'title': post.title,
      'body': post.body,
    };
  }
}
