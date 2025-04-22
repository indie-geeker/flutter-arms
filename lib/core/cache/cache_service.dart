abstract class CacheService {
  // 初始化
  void init();

  bool get hasInitialized;

  // 基础操作
  Future<void> set<T>(String key, T value);
  Future<T?> get<T>(String key);
  Future<bool> remove(String key);
  Future<void> clear();
  
  // 带过期时间的操作
  Future<void> setWithExpiry<T>(String key, T value, Duration expiry);
  Future<T?> getWithExpiry<T>(String key);
  
  // 批量操作
  Future<void> setAll<T>(Map<String, T> entries);
  Future<Map<String, T>> getAll<T>(List<String> keys);
  
  // 缓存状态
  Future<bool> containsKey(String key);
  Future<List<String>> getKeys();
}