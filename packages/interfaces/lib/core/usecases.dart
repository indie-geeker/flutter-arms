import 'result.dart';

/// UseCase 基类 - 有参数
///
/// [F] 失败类型
/// [S] 成功返回类型
/// [Params] 参数类型
///
/// 用法示例：
/// ```dart
/// class LoginUseCase extends UseCase<AuthFailure, UserEntity, LoginParams> {
///   final IAuthRepository _repository;
///   LoginUseCase(this._repository);
///
///   @override
///   Future<Result<AuthFailure, UserEntity>> call(LoginParams params) {
///     return _repository.login(
///       username: params.username,
///       password: params.password,
///     );
///   }
/// }
/// ```
abstract class UseCase<F, S, Params> {
  Future<Result<F, S>> call(Params params);
}

/// NoParamsUseCase 基类 - 无参数
///
/// [F] 失败类型
/// [S] 成功返回类型
///
/// 用法示例：
/// ```dart
/// class LogoutUseCase extends NoParamsUseCase<AuthFailure, void> {
///   final IAuthRepository _repository;
///   LogoutUseCase(this._repository);
///
///   @override
///   Future<Result<AuthFailure, void>> call() {
///     return _repository.logout();
///   }
/// }
/// ```
abstract class NoParamsUseCase<F, S> {
  Future<Result<F, S>> call();
}
