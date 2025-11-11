/// 通用存储抽象基类
abstract class IStorage {
  /// 初始化存储
  Future<void> init();

  /// 关闭存储
  Future<void> close();

  /// 清空所有数据
  Future<void> clear();

  /// 获取存储大小（字节）
  Future<int> getSize();
}