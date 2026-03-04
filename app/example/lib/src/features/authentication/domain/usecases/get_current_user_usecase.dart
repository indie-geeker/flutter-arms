import 'package:interfaces/core/result.dart';
import '../entities/user_entity.dart';
import '../failures/auth_failure.dart';
import '../repositories/i_auth_repository.dart';

/// Get current user use case
///
/// Encapsulates the business logic for retrieving the currently logged-in user.
class GetCurrentUserUseCase {
  final IAuthRepository _repository;

  const GetCurrentUserUseCase(this._repository);

  /// Execute get current user
  ///
  /// Returns Result<failure, user entity or null>
  Future<Result<AuthFailure, UserEntity?>> call() async {
    return await _repository.getCurrentUser();
  }
}
