/// Unified result type using Dart 3 sealed classes.
///
/// Implemented with Dart 3 sealed classes — no external dependencies needed.
///
/// Usage example:
/// ```dart
/// Future<Result<AuthFailure, UserEntity>> login() async {
///   try {
///     final user = await _dataSource.login();
///     return Success(user);
///   } catch (e) {
///     return Failure(AuthFailure.unexpected(e.toString()));
///   }
/// }
///
/// // Using switch pattern matching
/// final result = await login();
/// switch (result) {
///   case Success(:final value):
///     print('User: $value');
///   case Failure(:final error):
///     print('Error: $error');
/// }
/// ```
sealed class Result<F, S> {
  const Result();
}

/// Success result.
final class Success<F, S> extends Result<F, S> {
  final S value;
  const Success(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<F, S> && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

/// Failure result.
final class Failure<F, S> extends Result<F, S> {
  final F error;
  const Failure(this.error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<F, S> && other.error == error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Failure($error)';
}
