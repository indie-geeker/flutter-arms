import 'package:flutter_arms/core/domain/base_usecase.dart';
import 'package:flutter_arms/core/errors/result.dart';
import 'package:flutter_arms/shared/domain/entities/user.dart';
import '../entities/auth.dart';
import '../repositories/auth_repository.dart';

// 带参数用例示例
class AuthUseCase extends BaseUseCase<AuthParams,Auth>{
  final AuthRepository repository;

  AuthUseCase(this.repository);

  @override
  Future<Result<Auth>> execute(AuthParams params) {
    return repository.login(params.username, params.password);
  }

}


// 无参数用例示例
// class GetUserInfoUseCase extends NoParamsUseCase<User> {
//   final AuthRepository repository;
//
//   GetUserInfoUseCase(this.repository);
//
//   @override
//   Future<Result<User>> execute() {
//     return repository.getUserInfo();
//   }
// }



// 参数类
class AuthParams {
  final String username;
  final String password;

  AuthParams({required this.username, required this.password});
}