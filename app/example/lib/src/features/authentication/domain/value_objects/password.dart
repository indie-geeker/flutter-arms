import 'package:interfaces/core/result.dart';
import '../failures/auth_failure.dart';

/// Password value object
///
/// Encapsulates password validation logic and business rules
class Password {
  final String value;

  const Password._(this.value);

  /// Create a password (with validation)
  factory Password.create(String input) {
    return Password._(input);
  }

  /// Validate the password
  ///
  /// Rule: length >= 3
  Result<AuthFailure, Password> validate() {
    if (value.isEmpty) {
      return const Failure(AuthFailure.emptyPassword());
    }

    if (value.length < 3) {
      return const Failure(
        AuthFailure.invalidPassword(
          'Password must be at least 3 characters',
        ),
      );
    }

    return Success(this);
  }

  @override
  String toString() => '***'; // Hide password content

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Password &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}
