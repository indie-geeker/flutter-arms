import 'package:interfaces/storage/i_kv_storage.dart';
import '../models/user_model.dart';

/// 认证本地数据源
///
/// 负责用户认证数据的本地持久化
/// 基于 FlutterArms 的 Storage 模块
class AuthLocalDataSource {
  final IKeyValueStorage _storage;

  static const String _currentUserKey = 'current_user';

  const AuthLocalDataSource(this._storage);

  /// 保存当前用户
  Future<void> saveCurrentUser(UserModel user) async {
    await _storage.setJson(_currentUserKey, user.toJson());
  }

  /// 获取当前用户
  Future<UserModel?> getCurrentUser() async {
    final json = await _storage.getJson(_currentUserKey);
    if (json == null) return null;

    try {
      return UserModel.fromJson(json);
    } catch (e) {
      // 数据损坏，清除并返回 null
      await clearCurrentUser();
      return null;
    }
  }

  /// 清除当前用户
  Future<void> clearCurrentUser() async {
    await _storage.remove(_currentUserKey);
  }

  /// 检查是否有已登录用户
  Future<bool> hasCurrentUser() async {
    return await _storage.containsKey(_currentUserKey);
  }
}
