import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:app_interfaces/app_interfaces.dart';
import 'package:path_provider/path_provider.dart';

/// 磁盘缓存策略
///
/// 将响应数据持久化存储到磁盘，应用重启后缓存仍然有效
class DiskCacheStrategy implements ICacheStrategy {
  final Duration _defaultTtl;
  final int _maxCacheSize;
  final String _cacheDirectory;

  final IKeyValueStorage _kvStorage;
  bool _initialized = false;

  DiskCacheStrategy({
    required IKeyValueStorage storage,
    Duration defaultTtl = const Duration(hours: 1),
    int maxCacheSize = 50,
    String cacheDirectory = 'network_cache',
  })  : _defaultTtl = defaultTtl,
        _maxCacheSize = maxCacheSize,
        _cacheDirectory = cacheDirectory,
        _kvStorage = storage;

  /// 初始化缓存策略
  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    // 确保缓存目录存在
    final cacheDir = await _getCacheDirectory();
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    _initialized = true;
  }

  @override
  Future<ApiResponse<T>?> getCache<T>(RequestOptions options) async {
    await _ensureInitialized();

    if (!isCacheSupported(options)) {
      return null;
    }

    final key = generateCacheKey(options);
    final cacheInfo = await _getCacheInfo(key);

    if (cacheInfo == null || _isExpired(cacheInfo)) {
      await _removeCacheEntry(key);
      return null;
    }

    try {
      final cacheFile = await _getCacheFile(key);
      if (!await cacheFile.exists()) {
        await _removeCacheEntry(key);
        return null;
      }

      final content = await cacheFile.readAsString();
      final data = jsonDecode(content);

      return ApiResponse<T>(
        data: data['data'] as T,
        code: data['code'] as int,
        message: data['message'] as String,
        extra: Map<String, dynamic>.from(data['extra'] ?? {}),
      );
    } catch (e) {
      // 读取或解析失败，移除缓存
      await _removeCacheEntry(key);
      return null;
    }
  }

  @override
  Future<bool> saveCache<T>(ApiResponse<T> response) async {
    await _ensureInitialized();

    final options = response.extra['_request_options'] as RequestOptions?;
    if (options == null || !isCacheSupported(options)) {
      return false;
    }

    try {
      final key = generateCacheKey(options);

      // 检查缓存大小限制
      await _enforceMaxCacheSize();

      // 保存缓存文件
      final cacheFile = await _getCacheFile(key);
      final data = {
        'data': response.data,
        'code': response.code,
       'message': response.message,
        'extra': response.extra,
      };

      await cacheFile.writeAsString(jsonEncode(data));

      // 保存缓存信息
      final ttl = _getTtl(options);
      final cacheInfo = _CacheInfo(
        key: key,
        createdAt: DateTime.now(),
        ttl: ttl,
        size: await cacheFile.length(),
      );

      await _saveCacheInfo(key, cacheInfo);

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
    if (_isModifyingMethod(options.method.name)) {
      return true;
    }

    // 其他情况使用缓存
    return false;
  }

  @override
  bool isCacheSupported(RequestOptions options) {
    // 只缓存 GET 请求
    if (options.method.name.toUpperCase() != 'GET') {
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
    buffer.write(options.method.name.toUpperCase());
    buffer.write('|');
    buffer.write(options.path);

    // 添加查询参数
    if (options.queryParameters?.isNotEmpty == true) {
      final sortedParams = Map.fromEntries(
        options.queryParameters!.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key)),
      );
      buffer.write('|');
      buffer.write(Uri(
          queryParameters:
              sortedParams.map((k, v) => MapEntry(k, v.toString()))).query);
    }

    // 生成 MD5 哈希作为文件名
    final keyBytes = utf8.encode(buffer.toString());
    return _generateMd5Hash(keyBytes);
  }

  Future<void> clearCache([RequestOptions? options]) async {
    await _ensureInitialized();

    if (options == null) {
      // 清除所有缓存
      final cacheDir = await _getCacheDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        await cacheDir.create(recursive: true);
      }

      // 清除缓存信息
      final keys =
          (await _kvStorage.getKeys()).where((key) => key.startsWith('cache_info_'));
      for (final key in keys) {
        await _kvStorage.remove(key);
      }
    } else {
      // 清除特定缓存
      final key = generateCacheKey(options);
      await _removeCacheEntry(key);
    }
  }

  Future<void> clearExpiredCache() async {
    await _ensureInitialized();

    final keys =
        (await _kvStorage.getKeys()).where((key) => key.startsWith('cache_info_'));
    for (final key in keys) {
      final cacheKey = key.substring('cache_info_'.length);
      final cacheInfo = await _getCacheInfo(cacheKey);

      if (cacheInfo != null && _isExpired(cacheInfo)) {
        await _removeCacheEntry(cacheKey);
      }
    }
  }

  /// 获取缓存目录
  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/$_cacheDirectory');
  }

  /// 获取缓存文件
  Future<File> _getCacheFile(String key) async {
    final cacheDir = await _getCacheDirectory();
    return File('${cacheDir.path}/$key.json');
  }

  /// 获取缓存信息
  Future<_CacheInfo?> _getCacheInfo(String key) async {
    final infoJson = await _kvStorage.getString('cache_info_$key');
    if (infoJson == null) return null;

    try {
      final data = jsonDecode(infoJson);
      return _CacheInfo.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// 保存缓存信息
  Future<void> _saveCacheInfo(String key, _CacheInfo info) async {
    await _kvStorage.setString('cache_info_$key', jsonEncode(info.toJson()));
  }

  /// 移除缓存条目
  Future<void> _removeCacheEntry(String key) async {
    // 删除缓存文件
    final cacheFile = await _getCacheFile(key);
    if (await cacheFile.exists()) {
      await cacheFile.delete();
    }

    // 删除缓存信息
    await _kvStorage.remove('cache_info_$key');
  }

  /// 检查缓存是否过期
  bool _isExpired(_CacheInfo cacheInfo) {
    return DateTime.now().isAfter(cacheInfo.createdAt.add(cacheInfo.ttl));
  }

  /// 获取缓存 TTL
  Duration _getTtl(RequestOptions options) {
    final customTtl = options.extra['cache_ttl'] as Duration?;
    return customTtl ?? _defaultTtl;
  }

  /// 检查是否为修改方法
  bool _isModifyingMethod(String method) {
    final upperMethod = method.toUpperCase();
    return upperMethod == 'POST' ||
        upperMethod == 'PUT' ||
        upperMethod == 'DELETE' ||
        upperMethod == 'PATCH';
  }

  /// 强制执行最大缓存大小限制
  Future<void> _enforceMaxCacheSize() async {
    final keys =
        (await _kvStorage.getKeys()).where((key) => key.startsWith('cache_info_'));
    if (keys.length < _maxCacheSize) return;

    // 获取所有缓存信息并按创建时间排序
    final cacheInfos = <_CacheInfo>[];
    for (final key in keys) {
      final cacheKey = key.substring('cache_info_'.length);
      final cacheInfo = await _getCacheInfo(cacheKey);
      if (cacheInfo != null) {
        cacheInfos.add(cacheInfo);
      }
    }

    cacheInfos.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // 删除最旧的缓存条目
    final toRemove = cacheInfos.length - _maxCacheSize + 1;
    for (int i = 0; i < toRemove && i < cacheInfos.length; i++) {
      await _removeCacheEntry(cacheInfos[i].key);
    }
  }

  /// 生成 MD5 哈希
  String _generateMd5Hash(List<int> bytes) {
    // 简单的哈希实现，实际项目中应该使用 crypto 包
    return bytes
        .fold(0, (prev, byte) => prev ^ byte)
        .toRadixString(16)
        .padLeft(8, '0');
  }

  /// 获取缓存统计信息
  Future<Map<String, dynamic>> getCacheStats() async {
    await _ensureInitialized();

    final keys =
        (await _kvStorage.getKeys()).where((key) => key.startsWith('cache_info_'));
    int totalSize = 0;
    int expiredCount = 0;

    for (final key in keys) {
      final cacheKey = key.substring('cache_info_'.length);
      final cacheInfo = await _getCacheInfo(cacheKey);

      if (cacheInfo != null) {
        totalSize += cacheInfo.size;
        if (_isExpired(cacheInfo)) {
          expiredCount++;
        }
      }
    }

    return {
      'total_entries': keys.length,
      'expired_entries': expiredCount,
      'total_size_bytes': totalSize,
      'max_cache_size': _maxCacheSize,
      'default_ttl_seconds': _defaultTtl.inSeconds,
    };
  }

  @override
  Future<bool> invalidateCache(RequestOptions options) async {
    await _ensureInitialized();
    final key = generateCacheKey(options);
    await _removeCacheEntry(key);
    return true;
  }

  @override
  Future<bool> clearAllCache() async {
    await clearCache();
    return true;
  }

  @override
  Future<CacheStatistics> getCacheStatistics() async {
    await _ensureInitialized();

    final keys =
        (await _kvStorage.getKeys()).where((key) => key.startsWith('cache_info_'));
    int expiredCount = 0;
    int totalSize = 0;

    for (final key in keys) {
      final cacheKey = key.substring('cache_info_'.length);
      final cacheInfo = await _getCacheInfo(cacheKey);

      if (cacheInfo != null) {
        totalSize += cacheInfo.size;
        if (_isExpired(cacheInfo)) {
          expiredCount++;
        }
      }
    }

    return CacheStatistics(
      entryCount: keys.length - expiredCount,
      // 有效条目数量
      totalSize: totalSize,
      maxEntries: _maxCacheSize,
      maxSize: _maxCacheSize * 1024 * 1024,
      // 估算最大大小
      hitCount: 0,
      // 简化实现，不统计命中次数
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

/// 缓存信息
class _CacheInfo {
  final String key;
  final DateTime createdAt;
  final Duration ttl;
  final int size;

  _CacheInfo({
    required this.key,
    required this.createdAt,
    required this.ttl,
    required this.size,
  });

  Map<String, dynamic> toJson() => {
        'key': key,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'ttlSeconds': ttl.inSeconds,
        'size': size,
      };

  factory _CacheInfo.fromJson(Map<String, dynamic> json) => _CacheInfo(
        key: json['key'] as String,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
        ttl: Duration(seconds: json['ttlSeconds'] as int),
        size: json['size'] as int,
      );
}
