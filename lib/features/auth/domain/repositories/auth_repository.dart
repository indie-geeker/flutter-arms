import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/auth/domain/entities/user.dart';

/// 认证仓储接口。
abstract class AuthRepository {
  /// 用户登录。
  Future<Result<User>> login({
    required String username,
    required String password,
  });

  /// 用户登出。
  Future<void> logout();

  /// 刷新 Token。
  Future<Result<String>> refreshToken(String refreshToken);

  /// 获取当前用户。
  Future<Result<User>> getCurrentUser();
}
