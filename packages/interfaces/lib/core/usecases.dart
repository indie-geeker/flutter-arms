import 'result.dart';

/// UseCase base class — with parameters.
///
/// [F] Failure type
/// [S] Success return type
/// [Params] Parameter type
///
/// Usage example:
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

/// NoParamsUseCase base class — without parameters.
///
/// [F] Failure type
/// [S] Success return type
///
/// Usage example:
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
