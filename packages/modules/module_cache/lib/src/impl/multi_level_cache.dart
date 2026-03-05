import 'dart:math' show max;

import 'package:interfaces/cache/cache_policy.dart';
import 'package:interfaces/cache/cache_stats.dart';
import 'package:interfaces/cache/i_cache_manager.dart';
import 'package:interfaces/logger/i_logger.dart';
import 'package:interfaces/storage/i_kv_storage.dart';

import '../models/cache_entry.dart';

/// Multi-level cache manager (memory + disk).
/// Key design: persistence based on IKeyValueStorage.
class MultiLevelCacheManager implements ICacheManager {
  final IKeyValueStorage _storage; // Depends on Storage interface.
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
  }) : _storage = storage,
       _logger = logger,
       _valueRegistry = valueRegistry,
       _maxMemoryItems = maxMemoryItems;

  @override
  Future<void> init() async {
    // Storage is already initialized in StorageModule.
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

    // 1. Store in memory.
    _memoryCache[key] = entry;
    _evictIfNeeded();

    // 2. Decide whether to persist based on policy (via Storage).
    if (policy != CachePolicy.memoryOnly) {
      try {
        await _storage.setJson(
          _cacheKey(key),
          entry.toJson(registry: _valueRegistry),
        );
      } catch (e, stackTrace) {
        _logger.error(
          'Failed to persist cache',
          error: e,
          stackTrace: stackTrace,
        );
      }
    }
  }

  @override
  Future<T?> get<T>(String key) async {
    // 1. Read from memory first.
    if (_memoryCache.containsKey(key)) {
      final entry = _memoryCache[key]!;
      if (!entry.isExpired) {
        _hitCount++;
        entry.updateAccessTime(); // Update access time (LRU).
        return entry.value as T?;
      } else {
        // Expired, delete.
        _memoryCache.remove(key);
        await _storage.remove(_cacheKey(key));
      }
    }

    // 2. Read from disk (via Storage).
    try {
      final json = await _storage.getJson(_cacheKey(key));
      if (json != null) {
        final entry = CacheEntry.fromJson(json, registry: _valueRegistry);
        if (!entry.isExpired) {
          // Load into memory.
          _memoryCache[key] = entry;
          _hitCount++;
          return entry.value as T?;
        } else {
          // Expired, delete.
          await _storage.remove(_cacheKey(key));
        }
      }
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to read cache from storage',
        error: e,
        stackTrace: stackTrace,
      );
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

    // Clean all cache keys (filtered by prefix).
    final keys = await _storage.getKeys();
    for (final key in keys) {
      if (key.startsWith('cache:')) {
        await _storage.remove(key);
      }
    }

    _hitCount = 0;
    _missCount = 0;
  }

  /// On module disposal, only clears in-process memory — not persistent disk cache.
  Future<void> disposeMemory() async {
    _memoryCache.clear();
    _hitCount = 0;
    _missCount = 0;
  }

  @override
  Future<bool> containsKey(String key) async {
    final storageKey = _cacheKey(key);

    // Check memory.
    if (_memoryCache.containsKey(key)) {
      final entry = _memoryCache[key]!;
      if (!entry.isExpired) {
        return true;
      }
      _memoryCache.remove(key);
    }

    // Check disk and verify expiration.
    try {
      final json = await _storage.getJson(storageKey);
      if (json == null) {
        return false;
      }

      final entry = CacheEntry.fromJson(json, registry: _valueRegistry);
      if (entry.isExpired) {
        await _storage.remove(storageKey);
        return false;
      }

      return true;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to check cache key existence',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  @override
  Future<int> getCacheSize() async {
    // Return storage size (may include non-cache data).
    return await _storage.getSize();
  }

  @override
  Future<void> clearExpired() async {
    // Clean expired entries in memory.
    _memoryCache.removeWhere((key, entry) => entry.isExpired);

    // Clean expired entries on disk.
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
    final diskCacheKeys = keys
        .where((k) => k.startsWith('cache:'))
        .map((k) => k.substring('cache:'.length))
        .toSet();
    final totalKeys = {..._memoryCache.keys, ...diskCacheKeys}.length;

    return CacheStats(
      totalKeys: totalKeys,
      memoryKeys: _memoryCache.length,
      diskKeys: diskCacheKeys.length,
      totalSize: await getCacheSize(),
      hitCount: _hitCount,
      missCount: _missCount,
    );
  }

  /// LRU eviction policy.
  void _evictIfNeeded() {
    if (_memoryCache.length > _maxMemoryItems) {
      // Find the least recently used entries.
      final sortedEntries = _memoryCache.entries.toList()
        ..sort(
          (a, b) => a.value.lastAccessedAt.compareTo(b.value.lastAccessedAt),
        );

      // Remove the least recently used 10%, at least 1 item (fixes edge case when maxMemoryItems < 10).
      final toRemove = max(1, (_maxMemoryItems * 0.1).toInt());
      for (int i = 0; i < toRemove && i < sortedEntries.length; i++) {
        _memoryCache.remove(sortedEntries[i].key);
      }
    }
  }

  /// Generates a cache key (with prefix).
  String _cacheKey(String key) => 'cache:$key';

  /// Loads frequently used data into memory.
  Future<void> _loadFrequentlyUsed() async {
    // Can preload hot data based on access frequency.
  }
}
