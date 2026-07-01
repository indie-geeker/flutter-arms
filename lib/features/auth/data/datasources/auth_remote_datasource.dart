import 'package:flutter_arms/features/auth/data/models/token_model.dart';
import 'package:flutter_arms/features/auth/data/models/user_model.dart';

/// 认证远程数据源接口。
abstract interface class AuthRemoteDataSource {
  /// 登录。
  Future<TokenModel> login(Map<String, dynamic> body);

  /// 刷新 Token。
  Future<TokenModel> refreshToken(Map<String, dynamic> body);

  /// 获取当前用户。
  Future<UserModel> me();

  /// 登出。
  Future<void> logout();
}
