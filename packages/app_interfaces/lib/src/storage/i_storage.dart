/// 储接口基类
/// 定义所有存储实现的共通方法
abstract class IStorage {
  /// 初始化存储
  ///
  /// 返回是否初始化成功
  Future<bool> init();

  /// 关闭存储并释放资源
  ///
  /// 返回是否关闭成功
  Future<bool> close();

  /// 清空存储中的所有数据
  ///
  /// 返回是否清空成功
  Future<bool> clear();

  /// 检查存储是否已初始化
  bool get isInitialized;

  /// 获取存储名称
  String get storageName;
}
