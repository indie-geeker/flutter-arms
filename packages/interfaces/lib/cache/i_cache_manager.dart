
import 'cache_policy.dart';
import 'cache_stats.dart';

/// 缓存管理器接口
abstract class ICacheManager {
  /// 初始化缓存
  Future<void> init();

  /// 存储数据到缓存
  ///
  /// [key] 缓存键
  /// [value] 缓存值
  /// [duration] 过期时间（null 表示使用默认时间）
  /// [policy] 缓存策略
  Future<void> put<T>(
      String key,
      T value, {
        Duration? duration,
        CachePolicy policy = CachePolicy.normal,
      });

  /// 从缓存获取数据
  Future<T?> get<T>(String key);

  /// 获取数据（带默认值）
  Future<T> getOrDefault<T>(String key, T defaultValue);

  /// 删除缓存
  Future<void> remove(String key);

  /// 清空所有缓存
  Future<void> clear();

  /// 检查键是否存在（且未过期）
  Future<bool> containsKey(String key);

  /// 获取缓存大小（字节）
  Future<int> getCacheSize();

  /// 清理过期缓存
  Future<void> clearExpired();

  /// 获取缓存统计信息
  Future<CacheStats> getStats();
}