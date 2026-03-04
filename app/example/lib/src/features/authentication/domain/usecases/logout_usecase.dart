import 'package:interfaces/core/result.dart';
import '../failures/auth_failure.dart';
import '../repositories/i_auth_repository.dart';

/// Logout use case
///
/// Encapsulates logout business logic.
class LogoutUseCase {
  final IAuthRepository _repository;

  const LogoutUseCase(this._repository);

  /// Execute logout
  Future<Result<AuthFailure, void>> call() async {
    return await _repository.logout();
  }
}
