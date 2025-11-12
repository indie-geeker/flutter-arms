import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../failures/auth_failure.dart';
import '../repositories/i_auth_repository.dart';
import '../value_objects/password.dart';
import '../value_objects/username.dart';

/// 登录用例
///
/// 封装登录业务逻辑，协调值对象验证和仓储调用
class LoginUseCase {
  final IAuthRepository _repository;

  const LoginUseCase(this._repository);

  /// 执行登录
  ///
  /// [usernameStr] 用户名字符串
  /// [passwordStr] 密码字符串
  /// 返回 Either<失败, 用户实体>
  Future<Either<AuthFailure, UserEntity>> call({
    required String usernameStr,
    required String passwordStr,
  }) async {
    // 1. 创建并验证用户名
    final username = Username.create(usernameStr);
    final usernameValidation = username.validate();
    if (usernameValidation.isLeft()) {
      return usernameValidation.flatMap(
        (_) => left(const AuthFailure.unexpected('Unexpected error')),
      );
    }

    // 2. 创建并验证密码
    final password = Password.create(passwordStr);
    final passwordValidation = password.validate();
    if (passwordValidation.isLeft()) {
      return passwordValidation.flatMap(
        (_) => left(const AuthFailure.unexpected('Unexpected error')),
      );
    }

    // 3. 调用仓储执行登录
    return await _repository.login(
      username: usernameStr,
      password: passwordStr,
    );
  }
}
