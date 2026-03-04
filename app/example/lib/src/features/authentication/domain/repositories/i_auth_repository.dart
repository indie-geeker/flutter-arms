import 'package:interfaces/core/result.dart';
import '../entities/user_entity.dart';
import '../failures/auth_failure.dart';

/// Authentication repository interface - Domain Layer
///
/// Defines the contract for authentication-related business operations.
/// Data Layer is responsible for implementing this interface.
abstract class IAuthRepository {
  /// User login
  ///
  /// [username] Username
  /// [password] Password
  /// Returns Result<failure, user entity>
  Future<Result<AuthFailure, UserEntity>> login({
    required String username,
    required String password,
  });

  /// User logout
  Future<Result<AuthFailure, void>> logout();

  /// Get currently logged-in user
  ///
  /// Returns null if not logged in
  Future<Result<AuthFailure, UserEntity?>> getCurrentUser();

  /// Check if user is logged in
  Future<bool> isLoggedIn();
}
