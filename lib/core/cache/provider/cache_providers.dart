import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../cache_service.dart';
import '../prefs_cache_service_impl.dart';

// 生成的代码将在此文件中
part 'cache_providers.g.dart';

/// 缓存服务提供者
@riverpod
class CacheServiceNotifier extends _$CacheServiceNotifier {
  late PrefsCacheServiceImpl _cacheService;
  
  @override
  Future<CacheService> build() async {
    _cacheService = PrefsCacheServiceImpl();
    // 异步初始化缓存服务
    await _cacheService.init();
    return _cacheService;
  }
  
  /// 设置缓存
  Future<void> set<T>(String key, T value) async {
    final service = await future;
    return service.set<T>(key, value);
  }
  
  /// 获取缓存
  Future<T?> get<T>(String key) async {
    final service = await future;
    return service.get<T>(key);
  }
  
  /// 设置带过期时间的缓存
  Future<void> setWithExpiry<T>(String key, T value, Duration expiry) async {
    final service = await future;
    return service.setWithExpiry<T>(key, value, expiry);
  }
  
  /// 获取带过期时间的缓存
  Future<T?> getWithExpiry<T>(String key) async {
    final service = await future;
    return service.getWithExpiry<T>(key);
  }
  
  /// 移除缓存
  Future<bool> remove(String key) async {
    final service = await future;
    return service.remove(key);
  }
  
  /// 清除所有缓存
  Future<void> clear() async {
    final service = await future;
    return service.clear();
  }
  
  /// 批量设置缓存
  Future<void> setAll<T>(Map<String, T> entries) async {
    final service = await future;
    return service.setAll<T>(entries);
  }
  
  /// 批量获取缓存
  Future<Map<String, T>> getAll<T>(List<String> keys) async {
    final service = await future;
    return service.getAll<T>(keys);
  }
  
  /// 检查是否包含指定键
  Future<bool> containsKey(String key) async {
    final service = await future;
    return service.containsKey(key);
  }
  
  /// 获取所有缓存键
  Future<List<String>> getKeys() async {
    final service = await future;
    return service.getKeys();
  }
}
