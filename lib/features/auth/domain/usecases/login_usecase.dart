import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/auth/domain/entities/user.dart';
import 'package:flutter_arms/features/auth/domain/repositories/auth_repository.dart';

/// 登录用例。
class LoginUseCase {
  /// 构造函数。
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  /// 执行登录。
  Future<Result<User>> call({
    required String username,
    required String password,
  }) {
    return _repository.login(username: username, password: password);
  }
}
