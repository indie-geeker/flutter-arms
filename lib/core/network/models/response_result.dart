import 'package:freezed_annotation/freezed_annotation.dart';

part 'response_result.freezed.dart';
part 'response_result.g.dart';

@Freezed(genericArgumentFactories: true)
class ResponseResult<T> with _$ResponseResult<T> {
  const factory ResponseResult({
    required int success,
    required String message,
    T? data,
  }) = _ResponseResult;

  factory ResponseResult.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$ResponseResultFromJson(json, fromJsonT);

  // 成功的响应
  factory ResponseResult.success(T data) => ResponseResult(
         success: 1,
        message: 'success',
        data: data,
      );

  // 失败的响应
  factory ResponseResult.failure({
    required int code,
    required String message,
  }) =>
      ResponseResult(
        success: code,
        message: message,
      );
}