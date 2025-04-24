import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../errors/exceptions.dart';
import 'cache_service.dart';

class PrefsCacheServiceImpl implements CacheService {
  SharedPreferences? _prefs;
  final Map<String, dynamic> _memoryCache;
  final Map<String, DateTime> _expiryTimes;
  
  static const String _expiryPrefix = '_expiry_';

  final Completer<SharedPreferences> initCompleter =
  Completer<SharedPreferences>();

  PrefsCacheServiceImpl()
      : _memoryCache = {},
        _expiryTimes = {};

  @override
  Future<void> init() async {
    if (!initCompleter.isCompleted) {
      initCompleter.complete(SharedPreferences.getInstance());
    }
    _prefs = await initCompleter.future;
  }

  @override
  bool get hasInitialized => _prefs != null;
  
  /// 确保缓存服务已初始化
  Future<void> ensureInitialized() async {
    if (!hasInitialized) {
      await init();
    }
  }

  @override
  Future<void> set<T>(String key, T value) async {
    try {
      await ensureInitialized();
      await _setValue(key, value);
      _memoryCache[key] = value;
    } catch (e) {
      throw CacheException(message: 'Failed to set value for key: $key. Error: $e');
    }
  }

  @override
  Future<T?> get<T>(String key) async {
    try {
      await ensureInitialized();
      // 先检查内存缓存
      if (_memoryCache.containsKey(key)) {
        return _memoryCache[key] as T?;
      }

      // 从持久化存储获取
      final value = await _getValue<T>(key);
      if (value != null) {
        _memoryCache[key] = value;
      }
      return value;
    } catch (e) {
      throw CacheException(message: 'Failed to get value for key: $key. Error: $e');
    }
  }

  @override
  Future<void> setWithExpiry<T>(String key, T value, Duration expiry) async {
    try {
      await ensureInitialized();
      await set<T>(key, value);
      final expiryTime = DateTime.now().add(expiry);
      _expiryTimes[key] = expiryTime;
      await _prefs!.setString('$_expiryPrefix$key', expiryTime.toIso8601String());
    } catch (e) {
      throw CacheException(message: 'Failed to set value with expiry for key: $key. Error: $e');
    }
  }

  @override
  Future<T?> getWithExpiry<T>(String key) async {
    try {
      await ensureInitialized();
      final expiryTimeStr = _prefs!.getString('$_expiryPrefix$key');
      if (expiryTimeStr == null) {
        return get<T>(key);
      }

      final expiryTime = DateTime.parse(expiryTimeStr);
      if (DateTime.now().isAfter(expiryTime)) {
        await remove(key);
        return null;
      }

      return get<T>(key);
    } catch (e) {
      throw CacheException(message: 'Failed to get value with expiry for key: $key. Error: $e');
    }
  }

  @override
  Future<bool> remove(String key) async {
    try {
      await ensureInitialized();
      _memoryCache.remove(key);
      _expiryTimes.remove(key);
      await _prefs!.remove('$_expiryPrefix$key');
      return await _prefs!.remove(key);
    } catch (e) {
      throw CacheException(message: 'Failed to remove key: $key. Error: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await ensureInitialized();
      _memoryCache.clear();
      _expiryTimes.clear();
      await _prefs!.clear();
    } catch (e) {
      throw CacheException(message: 'Failed to clear cache. Error: $e');
    }
  }

  @override
  Future<void> setAll<T>(Map<String, T> entries) async {
    try {
      await ensureInitialized();
      for (final entry in entries.entries) {
        await set<T>(entry.key, entry.value);
      }
    } catch (e) {
      throw CacheException(message: 'Failed to set multiple entries. Error: $e');
    }
  }

  @override
  Future<Map<String, T>> getAll<T>(List<String> keys) async {
    try {
      await ensureInitialized();
      final Map<String, T> result = {};
      for (final key in keys) {
        final value = await get<T>(key);
        if (value != null) {
          result[key] = value;
        }
      }
      return result;
    } catch (e) {
      throw CacheException(message: 'Failed to get multiple entries. Error: $e');
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    await ensureInitialized();
    return _memoryCache.containsKey(key) || _prefs!.containsKey(key);
  }

  @override
  Future<List<String>> getKeys() async {
    await ensureInitialized();
    return _prefs!.getKeys().toList();
  }

  // 私有辅助方法
  Future<void> _setValue<T>(String key, T value) async {
    if (value is String) {
      await _prefs!.setString(key, value);
    } else if (value is int) {
      await _prefs!.setInt(key, value);
    } else if (value is double) {
      await _prefs!.setDouble(key, value);
    } else if (value is bool) {
      await _prefs!.setBool(key, value);
    } else if (value is List<String>) {
      await _prefs!.setStringList(key, value);
    } else {
      final jsonStr = jsonEncode(value);
      await _prefs!.setString(key, jsonStr);
    }
  }

  Future<T?> _getValue<T>(String key) async {
    final value = _prefs!.get(key);
    if (value == null) return null;

    if (T == String) {
      return value as T;
    } else if (T == int) {
      return value as T;
    } else if (T == double) {
      return value as T;
    } else if (T == bool) {
      return value as T;
    } else if (T == List<String>) {
      return value as T;
    } else {
      try {
        final jsonStr = value as String;
        return jsonDecode(jsonStr) as T;
      } catch (e) {
        throw CacheException(message: 'Failed to decode complex object for key: $key');
      }
    }
  }
}
