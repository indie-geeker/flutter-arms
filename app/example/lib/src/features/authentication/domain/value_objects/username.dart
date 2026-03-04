import 'package:interfaces/core/result.dart';
import '../failures/auth_failure.dart';

/// Username value object
///
/// Encapsulates username validation logic and business rules
class Username {
  final String value;

  const Username._(this.value);

  /// Create a username (with validation)
  factory Username.create(String input) {
    return Username._(input);
  }

  /// Validate the username
  ///
  /// Rule: length >= 3
  Result<AuthFailure, Username> validate() {
    if (value.isEmpty) {
      return const Failure(AuthFailure.emptyUsername());
    }

    if (value.length < 3) {
      return const Failure(
        AuthFailure.invalidUsername(
          'Username must be at least 3 characters',
        ),
      );
    }

    return Success(this);
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Username &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}
