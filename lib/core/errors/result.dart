import 'package:flutter_arms/core/errors/failures.dart';

sealed class Result<T> {
  const Result();

  factory Result.success(T data) = SuccessResult<T>;
  factory Result.failure(Failure failure) = FailureResult<T>;

  bool get isSuccess => this is SuccessResult<T>;
  bool get isFailure => this is FailureResult<T>;

  T? getOrNull(){
    return switch(this){
      SuccessResult<T>(data: final data) => data,
      FailureResult<T>() => null,
    };
  }

  /// 使用 pattern matching 处理结果
  /// 或 map 进行转换
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    return switch(this){
      SuccessResult<T>(data: final data) => onSuccess(data),
      FailureResult<T>(failure: final f) => onFailure(f),
    };
  }

  /// 使用 pattern matching 处理结果
  // R when<R>({
  //   required R Function(T data) success,
  //   required R Function(Failure failure) failure,
  // }) {
  //   return switch (this) {
  //     SuccessResult<T>(data: final data) => success(data),
  //     FailureResult<T>(failure: final f) => failure(f),
  //   };
  // }

  /// 转换成功值类型
  Result<R> map<R>(R Function(T data) transform) => switch (this) {
    SuccessResult<T>(data: final data) => Result.success(transform(data)),
    FailureResult<T>(failure: final f) => Result.failure(f),
  };

}


class SuccessResult<T> extends Result<T> {
  final T data;

  const SuccessResult(this.data);
}

class FailureResult<T> extends Result<T> {
  final Failure failure;

  const FailureResult(this.failure);
}