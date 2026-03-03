import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../failures/auth_failure.dart';
import '../repositories/i_auth_repository.dart';

/// 获取当前用户用例
///
/// 封装获取当前登录用户的业务逻辑
class GetCurrentUserUseCase {
  final IAuthRepository _repository;

  const GetCurrentUserUseCase(this._repository);

  /// 执行获取当前用户
  ///
  /// 返回 Either<失败, 用户实体或null>
  Future<Either<AuthFailure, UserEntity?>> call() async {
    return await _repository.getCurrentUser();
  }
}
