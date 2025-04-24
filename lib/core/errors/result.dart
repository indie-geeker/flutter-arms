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

  R fold<R>({
    required R Function(SuccessResult<T> success) onSuccess,
    required R Function(FailureResult<T> failure) onFailure,
  }) {
    return switch(this){
      SuccessResult<T>(data: final data) => onSuccess(SuccessResult(data)),
      FailureResult<T>(failure: final failure) => onFailure(FailureResult(failure)),
    };
  }
}


class SuccessResult<T> extends Result<T> {
  final T data;

  const SuccessResult(this.data);
}

class FailureResult<T> extends Result<T> {
  final Failure failure;

  const FailureResult(this.failure);
}