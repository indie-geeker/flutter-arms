
import 'dart:math' show max;

import 'package:interfaces/cache/cache_policy.dart';
import 'package:interfaces/cache/cache_stats.dart';
import 'package:interfaces/cache/i_cache_manager.dart';
import 'package:interfaces/logger/i_logger.dart';
import 'package:interfaces/storage/i_kv_storage.dart';

import '../models/cache_entry.dart';

/// 多级缓存管理器（内存 + 磁盘）
/// 关键：基于 IKeyValueStorage 实现持久化
class MultiLevelCacheManager implements ICacheManager {
  final IKeyValueStorage _storage;  // 依赖 Storage 接口
  final ILogger _logger;
  final CacheValueRegistry? _valueRegistry;
  final Map<String, CacheEntry> _memoryCache = {};
  final int _maxMemoryItems;

  int _hitCount = 0;
  int _missCount = 0;

  MultiLevelCacheManager({
    required IKeyValueStorage storage,
    required ILogger logger,
    int maxMemoryItems = 100,
    CacheValueRegistry? valueRegistry,
  })  : _storage = storage,
        _logger = logger,
        _valueRegistry = valueRegistry,
        _maxMemoryItems = maxMemoryItems;

  @override
  Future<void> init() async {
    // Storage 已经在 StorageModule 中初始化
    await _loadFrequentlyUsed();
    _logger.info('Multi-level cache initialized');
  }

  @override
  Future<void> put<T>(
      String key,
      T value, {
        Duration? duration,
        CachePolicy policy = CachePolicy.normal,
      }) async {
    final entry = CacheEntry(
      key: key,
      value: value,
      createdAt: DateTime.now(),
      expiresAt: policy == CachePolicy.persistent
          ? null
          : DateTime.now().add(duration ?? Duration(hours: 1)),
      policy: policy,
    );

    // 1. 存入内存
    _memoryCache[key] = entry;
    _evictIfNeeded();

    // 2. 根据策略决定是否持久化（通过 Storage）
    if (policy != CachePolicy.memoryOnly) {
      try {
        await _storage.setJson(
          _cacheKey(key),
          entry.toJson(registry: _valueRegistry),
        );
      } catch (e, stackTrace) {
        _logger.error('Failed to persist cache',
            error: e, stackTrace: stackTrace);
      }
    }
  }

  @override
  Future<T?> get<T>(String key) async {
    // 1. 先从内存读取
    if (_memoryCache.containsKey(key)) {
      final entry = _memoryCache[key]!;
      if (!entry.isExpired) {
        _hitCount++;
        entry.updateAccessTime(); // 更新访问时间（LRU）
        return entry.value as T?;
      } else {
        // 已过期，删除
        _memoryCache.remove(key);
        await _storage.remove(_cacheKey(key));
      }
    }

    // 2. 从磁盘读取（通过 Storage）
    try {
      final json = await _storage.getJson(_cacheKey(key));
      if (json != null) {
        final entry = CacheEntry.fromJson(json, registry: _valueRegistry);
        if (!entry.isExpired) {
          // 加载到内存
          _memoryCache[key] = entry;
          _hitCount++;
          return entry.value as T?;
        } else {
          // 已过期，删除
          await _storage.remove(_cacheKey(key));
        }
      }
    } catch (e, stackTrace) {
      _logger.error('Failed to read cache from storage',
          error: e, stackTrace: stackTrace);
    }

    _missCount++;
    return null;
  }

  @override
  Future<T> getOrDefault<T>(String key, T defaultValue) async {
    final value = await get<T>(key);
    return value ?? defaultValue;
  }

  @override
  Future<void> remove(String key) async {
    _memoryCache.remove(key);
    await _storage.remove(_cacheKey(key));
  }

  @override
  Future<void> clear() async {
    _memoryCache.clear();

    // 清理所有缓存键（通过前缀过滤）
    final keys = await _storage.getKeys();
    for (final key in keys) {
      if (key.startsWith('cache:')) {
        await _storage.remove(key);
      }
    }

    _hitCount = 0;
    _missCount = 0;
  }

  @override
  Future<bool> containsKey(String key) async {
    // 检查内存
    if (_memoryCache.containsKey(key)) {
      final entry = _memoryCache[key]!;
      if (!entry.isExpired) {
        return true;
      }
    }

    // 检查磁盘
    return await _storage.containsKey(_cacheKey(key));
  }

  @override
  Future<int> getCacheSize() async {
    // 返回存储大小（可能包含非缓存数据）
    return await _storage.getSize();
  }

  @override
  Future<void> clearExpired() async {
    // 清理内存中的过期项
    _memoryCache.removeWhere((key, entry) => entry.isExpired);

    // 清理磁盘中的过期项
    final keys = await _storage.getKeys();
    for (final key in keys) {
      if (key.startsWith('cache:')) {
        try {
          final json = await _storage.getJson(key);
          if (json != null) {
            final entry = CacheEntry.fromJson(json, registry: _valueRegistry);
            if (entry.isExpired) {
              await _storage.remove(key);
            }
          }
        } catch (e) {
          _logger.warning('Failed to check expiry for key: $key', error: e);
        }
      }
    }
  }

  @override
  Future<CacheStats> getStats() async {
    final keys = await _storage.getKeys();
    final diskKeys = keys.where((k) => k.startsWith('cache:')).length;

    return CacheStats(
      totalKeys: _memoryCache.length + diskKeys,
      memoryKeys: _memoryCache.length,
      diskKeys: diskKeys,
      totalSize: await getCacheSize(),
      hitCount: _hitCount,
      missCount: _missCount,
    );
  }

  /// LRU 淘汰策略
  void _evictIfNeeded() {
    if (_memoryCache.length > _maxMemoryItems) {
      // 找出最久未使用的项
      final sortedEntries = _memoryCache.entries.toList()
        ..sort((a, b) => a.value.lastAccessedAt.compareTo(b.value.lastAccessedAt));

      // 删除最久未使用的 10%，至少删除 1 项 (修复 maxMemoryItems < 10 时的边界条件)
      final toRemove = max(1, (_maxMemoryItems * 0.1).toInt());
      for (int i = 0; i < toRemove && i < sortedEntries.length; i++) {
        _memoryCache.remove(sortedEntries[i].key);
      }
    }
  }

  /// 生成缓存键（添加前缀）
  String _cacheKey(String key) => 'cache:$key';

  /// 加载常用数据到内存
  Future<void> _loadFrequentlyUsed() async {
    // 可以根据访问频率预加载热点数据
  }
}
