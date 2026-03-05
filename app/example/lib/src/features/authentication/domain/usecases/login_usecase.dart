import 'package:interfaces/core/result.dart';
import '../entities/user_entity.dart';
import '../failures/auth_failure.dart';
import '../repositories/i_auth_repository.dart';
import '../value_objects/password.dart';
import '../value_objects/username.dart';

/// Login use case
///
/// Encapsulates login business logic, coordinating value object validation
/// and repository calls.
class LoginUseCase {
  final IAuthRepository _repository;

  const LoginUseCase(this._repository);

  /// Execute login
  ///
  /// [usernameStr] Username string
  /// [passwordStr] Password string
  /// Returns `Result<AuthFailure, UserEntity>`.
  Future<Result<AuthFailure, UserEntity>> call({
    required String usernameStr,
    required String passwordStr,
  }) async {
    // 1. Create and validate username
    final username = Username.create(usernameStr);
    final usernameValidation = username.validate();
    switch (usernameValidation) {
      case Failure(:final error):
        return Failure(error);
      case Success():
        break;
    }

    // 2. Create and validate password
    final password = Password.create(passwordStr);
    final passwordValidation = password.validate();
    switch (passwordValidation) {
      case Failure(:final error):
        return Failure(error);
      case Success():
        break;
    }

    // 3. Call repository to execute login
    return await _repository.login(
      username: usernameStr,
      password: passwordStr,
    );
  }
}
