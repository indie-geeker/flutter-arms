import 'dart:async';
import 'dart:convert';
import 'package:app_interfaces/app_interfaces.dart';

/// 内存缓存策略
///
/// 将响应数据缓存在内存中，提供快速访问，但应用重启后缓存会丢失
class MemoryCacheStrategy implements ICacheStrategy {
  final Map<String, _CacheEntry> _cache = {};
  final Duration _defaultTtl;
  final int _maxCacheSize;

  MemoryCacheStrategy({
    Duration defaultTtl = const Duration(minutes: 5),
    int maxCacheSize = 100,
  })  : _defaultTtl = defaultTtl,
        _maxCacheSize = maxCacheSize;

  @override
  Future<ApiResponse<T>?> getCache<T>(RequestOptions options) async {
    final key = generateCacheKey(options);
    final entry = _cache[key];

    if (entry == null) {
      return null;
    }

    // 检查是否过期
    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }

    try {
      // 尝试反序列化数据
      return ApiResponse<T>(
        data: entry.response.data as T,
        code: entry.response.code,
        message: entry.response.message,
        extra: entry.response.extra,
      );
    } catch (e) {
      // 反序列化失败，移除缓存
      _cache.remove(key);
      return null;
    }
  }

  @override
  Future<bool> saveCache<T>(ApiResponse<T> response) async {
    try {
      final options = response.extra['_request_options'] as RequestOptions?;
      if (options == null || !isCacheSupported(options)) {
        return false;
      }

      final key = generateCacheKey(options);
      
      // 如果缓存已满，移除最旧的条目
      if (_cache.length >= _maxCacheSize) {
        _evictOldest();
      }

      // 获取 TTL
      final ttl = _getTtl(options);
      
      _cache[key] = _CacheEntry(
        response: response,
        createdAt: DateTime.now(),
        ttl: ttl,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  bool shouldFetchFromNetwork<T>(
    RequestOptions options,
      ApiResponse<T>? cachedResponse,
  ) {
    // 如果没有缓存，从网络获取
    if (cachedResponse == null) {
      return true;
    }

    // 如果强制刷新，从网络获取
    if (options.extra['force_refresh'] == true) {
      return true;
    }

    // 如果是 POST/PUT/DELETE 等修改操作，从网络获取
    if (_isModifyingMethod(options.method)) {
      return true;
    }

    // 其他情况使用缓存
    return false;
  }

  @override
  bool isCacheSupported(RequestOptions options) {
    // 只缓存 GET 请求
    if (_methodToString(options.method) != 'GET') {
      return false;
    }

    // 检查是否明确禁用缓存
    if (options.extra['no_cache'] == true) {
      return false;
    }

    // 检查响应类型是否支持缓存
    if (options.responseType == ResponseType.bytes) {
      return false;
    }

    return true;
  }

  @override
  String generateCacheKey(RequestOptions options) {
    final buffer = StringBuffer();
    buffer.write(_methodToString(options.method));
    buffer.write('|');
    buffer.write(options.path);
    
    // 添加查询参数
    if (options.queryParameters?.isNotEmpty == true) {
      final sortedParams = Map.fromEntries(
        options.queryParameters!.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key)),
      );
      buffer.write('|');
      buffer.write(Uri(queryParameters: sortedParams.map((k, v) => MapEntry(k, v.toString()))).query);
    }

    // 添加相关请求头
    final relevantHeaders = _getRelevantHeaders(options.headers);
    if (relevantHeaders.isNotEmpty) {
      buffer.write('|');
      buffer.write(jsonEncode(relevantHeaders));
    }

    return buffer.toString();
  }

  Future<void> clearCache([RequestOptions? options]) async {
    if (options == null) {
      _cache.clear();
    } else {
      final key = generateCacheKey(options);
      _cache.remove(key);
    }
  }

  Future<void> clearExpiredCache() async {
    _cache.removeWhere((key, entry) => entry.isExpired);
  }

  /// 获取缓存 TTL
  Duration _getTtl(RequestOptions options) {
    final customTtl = options.extra['cache_ttl'] as Duration?;
    return customTtl ?? _defaultTtl;
  }

  /// 检查是否为修改性方法
  bool _isModifyingMethod(RequestMethod method) {
    return method == RequestMethod.post ||
           method == RequestMethod.put ||
           method == RequestMethod.delete ||
           method == RequestMethod.patch;
  }

  /// 将 RequestMethod 转换为字符串
  String _methodToString(RequestMethod method) {
    switch (method) {
      case RequestMethod.get:
        return 'GET';
      case RequestMethod.post:
        return 'POST';
      case RequestMethod.put:
        return 'PUT';
      case RequestMethod.delete:
        return 'DELETE';
      case RequestMethod.patch:
        return 'PATCH';
      case RequestMethod.head:
        return 'HEAD';
    }
  }

  /// 获取相关的请求头（用于缓存键生成）
  Map<String, dynamic> _getRelevantHeaders(Map<String, dynamic> headers) {
    final relevantHeaders = <String, dynamic>{};
    
    // 只包含影响响应内容的请求头
    const relevantHeaderKeys = {
      'accept',
      'accept-language',
      'accept-encoding',
      'user-agent',
    };

    for (final entry in headers.entries) {
      if (relevantHeaderKeys.contains(entry.key.toLowerCase())) {
        relevantHeaders[entry.key] = entry.value;
      }
    }

    return relevantHeaders;
  }

  /// 移除最旧的缓存条目
  void _evictOldest() {
    if (_cache.isEmpty) return;

    String? oldestKey;
    DateTime? oldestTime;

    for (final entry in _cache.entries) {
      if (oldestTime == null || entry.value.createdAt.isBefore(oldestTime)) {
        oldestTime = entry.value.createdAt;
        oldestKey = entry.key;
      }
    }

    if (oldestKey != null) {
      _cache.remove(oldestKey);
    }
  }

  /// 获取缓存统计信息
  Map<String, dynamic> getCacheStats() {
    int expiredCount = 0;

    for (final entry in _cache.values) {
      if (entry.isExpired) {
        expiredCount++;
      }
    }

    return {
      'total_entries': _cache.length,
      'expired_entries': expiredCount,
      'max_cache_size': _maxCacheSize,
      'default_ttl_seconds': _defaultTtl.inSeconds,
    };
  }

  @override
  Future<bool> invalidateCache(RequestOptions options) async {
    final key = generateCacheKey(options);
    return _cache.remove(key) != null;
  }

  @override
  Future<bool> clearAllCache() async {
    _cache.clear();
    return true;
  }

  @override
  Future<CacheStatistics> getCacheStatistics() async {
    int expiredCount = 0;
    for (final entry in _cache.values) {
      if (entry.isExpired) {
        expiredCount++;
      }
    }

    return CacheStatistics(
      entryCount: _cache.length - expiredCount, // 有效条目数量
      totalSize: (_cache.length - expiredCount) * 1024, // 估算大小
      maxEntries: _maxCacheSize,
      maxSize: _maxCacheSize * 1024, // 估算最大大小
      hitCount: 0, // 简化实现，不统计命中次数
      missCount: 0, // 简化实现，不统计未命中次数
    );
  }

  @override
  void setMaxEntries(int maxEntries) {
    // 简化实现，不动态调整最大条目数
  }

  @override
  void setMaxSize(int maxSize) {
    // 简化实现，不动态调整最大大小
  }
}

/// 缓存条目
class _CacheEntry {
  final ApiResponse response;
  final DateTime createdAt;
  final Duration ttl;

  _CacheEntry({
    required this.response,
    required this.createdAt,
    required this.ttl,
  });

  bool get isExpired => DateTime.now().isAfter(createdAt.add(ttl));
}
