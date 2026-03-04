/// 统一结果类型，替代 dartz Either
///
/// 使用 Dart 3 sealed class 实现，无需外部依赖。
///
/// 用法示例：
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
/// // 使用 switch 模式匹配
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

/// 成功结果
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

/// 失败结果
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
