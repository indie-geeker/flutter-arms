/// 表示操作结果的密封类
///
/// Result 是一个类型安全的结果容器，可以是成功(Success)或失败(Failure)
/// 使用 Result 类型可以强制调用者处理错误情况，避免未捕获的异常
sealed class Result<T> {
  const Result();
}

/// 成功结果
///
/// 包含操作成功时返回的数据
class Success<T> extends Result<T> {
  /// 成功的数据
  final T data;

  const Success(this.data);

  @override
  String toString() => 'Success(data: $data)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Success<T> && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;
}

/// 失败结果
///
/// 包含操作失败时的错误信息
class Failure<T> extends Result<T> {
  /// 错误信息
  final AppError error;

  const Failure(this.error);

  @override
  String toString() => 'Failure(error: $error)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure<T> && other.error == error;
  }

  @override
  int get hashCode => error.hashCode;
}

/// 应用错误基类
///
/// 所有错误类型的基类，提供统一的错误处理接口
abstract class AppError {
  /// 错误消息
  String get message;

  /// 错误代码
  String get code;

  /// 是否可重试
  bool get isRetryable;

  /// 错误详情
  dynamic get details;

  const AppError();
}

/// Result 扩展方法
extension ResultExtension<T> on Result<T> {
  /// 判断是否为成功
  bool get isSuccess => this is Success<T>;

  /// 判断是否为失败
  bool get isFailure => this is Failure<T>;

  /// 获取成功的数据，如果是失败则返回 null
  T? get dataOrNull {
    if (this is Success<T>) {
      return (this as Success<T>).data;
    }
    return null;
  }

  /// 获取失败的错误，如果是成功则返回 null
  AppError? get errorOrNull {
    if (this is Failure<T>) {
      return (this as Failure<T>).error;
    }
    return null;
  }

  /// 如果是成功，执行 onSuccess 回调
  /// 如果是失败，执行 onFailure 回调
  R when<R>({
    required R Function(T data) onSuccess,
    required R Function(AppError error) onFailure,
  }) {
    return switch (this) {
      Success(:final data) => onSuccess(data),
      Failure(:final error) => onFailure(error),
    };
  }

  /// 如果是成功，返回映射后的新 Result
  /// 如果是失败，直接返回失败结果
  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success(:final data) => Success(transform(data)),
      Failure(:final error) => Failure(error),
    };
  }

  /// 如果是成功，执行异步映射
  /// 如果是失败，直接返回失败结果
  Future<Result<R>> mapAsync<R>(Future<R> Function(T data) transform) async {
    return switch (this) {
      Success(:final data) => Success(await transform(data)),
      Failure(:final error) => Failure(error),
    };
  }

  /// 如果是成功，返回 flatMap 后的 Result
  /// 如果是失败，直接返回失败结果
  Result<R> flatMap<R>(Result<R> Function(T data) transform) {
    return switch (this) {
      Success(:final data) => transform(data),
      Failure(:final error) => Failure(error),
    };
  }

  /// 如果是失败，尝试恢复
  /// 如果是成功，直接返回成功结果
  Result<T> recover(T Function(AppError error) recovery) {
    return switch (this) {
      Success() => this,
      Failure(:final error) => Success(recovery(error)),
    };
  }

  /// 如果是失败且满足条件，尝试恢复
  /// 如果是成功或不满足条件，保持原状
  Result<T> recoverWhen(
    bool Function(AppError error) predicate,
    T Function(AppError error) recovery,
  ) {
    return switch (this) {
      Success() => this,
      Failure(:final error) => predicate(error) ? Success(recovery(error)) : this,
    };
  }
}
