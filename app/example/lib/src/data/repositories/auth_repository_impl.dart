import 'package:dartz/dartz.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/user_model.dart';

/// 认证仓储实现 - Data Layer
///
/// 实现 Domain Layer 的 IAuthRepository 接口
/// 协调本地数据源和远程数据源（本示例仅使用本地）
class AuthRepositoryImpl implements IAuthRepository {
  final AuthLocalDataSource _localDataSource;

  const AuthRepositoryImpl(this._localDataSource);

  @override
  Future<Either<AuthFailure, UserEntity>> login({
    required String username,
    required String password,
  }) async {
    try {
      // 简化的登录逻辑：只验证长度
      // 实际项目中应该调用远程 API
      if (username.length < 3) {
        return left(
          const AuthFailure.invalidUsername(
            'Username must be at least 3 characters',
          ),
        );
      }

      if (password.length < 3) {
        return left(
          const AuthFailure.invalidPassword(
            'Password must be at least 3 characters',
          ),
        );
      }

      // 创建用户模型
      final userModel = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: username,
        loginTime: DateTime.now(),
      );

      // 保存到本地存储
      await _localDataSource.saveCurrentUser(userModel);

      // 转换为 Domain Entity 并返回
      return right(userModel.toDomain());
    } catch (e) {
      return left(AuthFailure.storageError(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> logout() async {
    try {
      await _localDataSource.clearCurrentUser();
      return right(unit);
    } catch (e) {
      return left(AuthFailure.storageError(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, UserEntity?>> getCurrentUser() async {
    try {
      final userModel = await _localDataSource.getCurrentUser();
      if (userModel == null) {
        return right(null);
      }
      return right(userModel.toDomain());
    } catch (e) {
      return left(AuthFailure.storageError(e.toString()));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      return await _localDataSource.hasCurrentUser();
    } catch (e) {
      return false;
    }
  }
}
