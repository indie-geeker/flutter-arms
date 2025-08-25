abstract class ICache {
  // 初始化
  void init();

  bool get hasInitialized;

  // 基础操作
  Future<void> set<T>(String key, T value);
  Future<T?> get<T>(String key);
  Future<bool> remove(String key);
  Future<void> clear();

  // 缓存状态
  Future<bool> containsKey(String key);
  Future<List<String>> getKeys();
}