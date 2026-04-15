import 'package:flutter_arms/core/error/failures.dart';

/// 统一结果封装。
sealed class Result<T> {
  /// 构造函数。
  const Result();

  /// 成功结果。
  const factory Result.success(T data) = Success<T>;

  /// 失败结果。
  const factory Result.failure(Failure failure) = FailureResult<T>;

  /// 是否成功。
  bool get isSuccess => this is Success<T>;

  /// 是否失败。
  bool get isFailure => this is FailureResult<T>;

  /// 成功数据。
  T? get data => switch (this) {
    Success<T>(:final data) => data,
    FailureResult<T>() => null,
  };

  /// 失败信息。
  Failure? get failure => switch (this) {
    Success<T>() => null,
    FailureResult<T>(:final failure) => failure,
  };
}

/// 成功结果类型。
final class Success<T> extends Result<T> {
  /// 构造函数。
  const Success(this.data);

  /// 成功数据。
  @override
  final T data;
}

/// 失败结果类型。
final class FailureResult<T> extends Result<T> {
  /// 构造函数。
  const FailureResult(this.failure);

  /// 失败信息。
  @override
  final Failure failure;
}
