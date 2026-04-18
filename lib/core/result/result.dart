import 'package:flutter_arms/core/error/failure.dart';

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

/// Result 常用操作扩展。
extension ResultX<T> on Result<T> {
  /// 模式匹配：根据成功 / 失败分别返回结果。
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    final self = this;
    return switch (self) {
      Success<T>() => success(self.data),
      FailureResult<T>() => failure(self.failure),
    };
  }

  /// 在成功分支上转换数据，失败原样透传。
  Result<R> map<R>(R Function(T data) transform) {
    final self = this;
    return switch (self) {
      Success<T>() => Result.success(transform(self.data)),
      FailureResult<T>() => Result.failure(self.failure),
    };
  }

  /// 在失败分支上转换失败值，成功原样透传。
  Result<T> mapFailure(Failure Function(Failure) transform) {
    final self = this;
    return switch (self) {
      Success<T>() => self,
      FailureResult<T>() => Result.failure(transform(self.failure)),
    };
  }

  /// 成功则返回数据，失败则返回兜底值。
  T getOrElse(T fallback) {
    final self = this;
    return self is Success<T> ? self.data : fallback;
  }

  /// 成功则返回数据，失败则返回 null。
  T? getOrNull() {
    final self = this;
    return self is Success<T> ? self.data : null;
  }
}
