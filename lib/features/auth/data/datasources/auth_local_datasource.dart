import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:flutter_arms/features/auth/data/models/token_model.dart';
import 'package:flutter_arms/features/auth/data/models/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_local_datasource.g.dart';

/// 认证本地数据源。
class AuthLocalDataSource {
  /// 构造函数。
  const AuthLocalDataSource(this._storage);

  final KvStorage _storage;

  /// 保存 Token。
  Future<void> saveToken(TokenModel model) async {
    await _storage.saveAccessToken(model.accessToken);
    await _storage.saveRefreshToken(model.refreshToken);
  }

  /// 读取访问令牌。
  String? get accessToken => _storage.getAccessToken();

  /// 读取刷新令牌。
  String? get refreshToken => _storage.getRefreshToken();

  /// 保存用户。
  Future<void> saveUser(UserModel model) async {
    await _storage.saveUserMap(model.toJson());
  }

  /// 读取用户。
  UserModel? getUser() {
    final map = _storage.getUserMap();
    if (map == null) {
      return null;
    }

    return UserModel.fromJson(map);
  }

  /// 清理认证信息。
  Future<void> clearAuth() async {
    await _storage.clearTokens();
    await _storage.clearUser();
  }
}

/// 认证本地数据源依赖注入。
@Riverpod(keepAlive: true)
AuthLocalDataSource authLocalDataSource(Ref ref) {
  return AuthLocalDataSource(ref.read(kvStorageProvider));
}
