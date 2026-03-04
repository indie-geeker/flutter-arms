import 'package:interfaces/core/result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/i_auth_local_datasource.dart';
import '../models/user_model.dart';

/// Authentication repository implementation - Data Layer
///
/// Implements the Domain Layer's IAuthRepository interface.
/// Coordinates local and remote data sources (this example uses local only).
class AuthRepositoryImpl implements IAuthRepository {
  final IAuthLocalDataSource _localDataSource;

  const AuthRepositoryImpl(this._localDataSource);

  @override
  Future<Result<AuthFailure, UserEntity>> login({
    required String username,
    required String password,
  }) async {
    try {
      // Create user model
      final userModel = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: username,
        loginTime: DateTime.now(),
      );

      // Save to local storage
      await _localDataSource.saveCurrentUser(userModel);

      // Convert to Domain Entity and return
      return Success(userModel.toDomain());
    } catch (e) {
      return Failure(AuthFailure.storageError(e.toString()));
    }
  }

  @override
  Future<Result<AuthFailure, void>> logout() async {
    try {
      await _localDataSource.clearCurrentUser();
      return const Success(null);
    } catch (e) {
      return Failure(AuthFailure.storageError(e.toString()));
    }
  }

  @override
  Future<Result<AuthFailure, UserEntity?>> getCurrentUser() async {
    try {
      final userModel = await _localDataSource.getCurrentUser();
      if (userModel == null) {
        return const Success(null);
      }
      return Success(userModel.toDomain());
    } catch (e) {
      return Failure(AuthFailure.storageError(e.toString()));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      return await _localDataSource.hasCurrentUser();
    } catch (e) {
      return false;
    }
  }
}
