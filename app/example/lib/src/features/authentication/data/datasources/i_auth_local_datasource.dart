import '../models/user_model.dart';

/// Authentication local data source interface.
///
/// Defines the contract for local authentication data operations.
/// Implementations can use different storage solutions (e.g. IKeyValueStorage, SQLite).
abstract class IAuthLocalDataSource {
  /// Saves the current user.
  Future<void> saveCurrentUser(UserModel user);

  /// Retrieves the current user.
  Future<UserModel?> getCurrentUser();

  /// Clears the current user.
  Future<void> clearCurrentUser();

  /// Checks whether a user is logged in.
  Future<bool> hasCurrentUser();
}
