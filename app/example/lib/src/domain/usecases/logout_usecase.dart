import 'package:dartz/dartz.dart';
import '../failures/auth_failure.dart';
import '../repositories/i_auth_repository.dart';

/// 登出用例
///
/// 封装登出业务逻辑
class LogoutUseCase {
  final IAuthRepository _repository;

  const LogoutUseCase(this._repository);

  /// 执行登出
  Future<Either<AuthFailure, Unit>> call() async {
    return await _repository.logout();
  }
}
