import '../models/user_model.dart';

/// 认证本地数据源接口
///
/// 定义认证相关的本地数据操作契约。
/// 具体实现可基于不同的存储方案（如 IKeyValueStorage、SQLite 等）。
abstract class IAuthLocalDataSource {
  /// 保存当前用户
  Future<void> saveCurrentUser(UserModel user);

  /// 获取当前用户
  Future<UserModel?> getCurrentUser();

  /// 清除当前用户
  Future<void> clearCurrentUser();

  /// 检查是否有已登录用户
  Future<bool> hasCurrentUser();
}
