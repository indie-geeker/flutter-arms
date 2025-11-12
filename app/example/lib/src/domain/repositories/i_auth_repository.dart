import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../failures/auth_failure.dart';

/// 认证仓储接口 - Domain Layer
///
/// 定义认证相关的业务操作契约
/// Data Layer 负责实现此接口
abstract class IAuthRepository {
  /// 用户登录
  ///
  /// [username] 用户名
  /// [password] 密码
  /// 返回 Either<失败, 用户实体>
  Future<Either<AuthFailure, UserEntity>> login({
    required String username,
    required String password,
  });

  /// 用户登出
  Future<Either<AuthFailure, Unit>> logout();

  /// 获取当前登录用户
  ///
  /// 如果未登录则返回 null
  Future<Either<AuthFailure, UserEntity?>> getCurrentUser();

  /// 检查是否已登录
  Future<bool> isLoggedIn();
}
