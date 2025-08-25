
import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
abstract class Failure with _$Failure {
  const factory Failure({
    required String message,
    int? code,
    dynamic details,
  }) = _Failure;

  /// 缓存错误
  const factory Failure.cache({
    required String message,
    int? code,
    dynamic details,
  }) = CacheFailure;

  /// 网络错误
  const factory Failure.network({
    required String message,
    int? code,
    dynamic details,
    int? statusCode,
  }) = NetworkFailure;

  /// 未授权错误
  const factory Failure.unauthorized({
    required String message,
    int? code,
    dynamic details,
  }) = UnauthorizedFailure;

  /// 服务器错误
  const factory Failure.server({
    required String message,
    int? code,
    dynamic details,
  }) = ServerFailure;

  /// 解析错误
  const factory Failure.parse({
    required String message,
    int? code,
    dynamic details,
  }) = ParseFailure;

  /// 未知错误
  const factory Failure.unknown({
    required String message,
    int? code,
    dynamic details,
  }) = UnknownFailure;
}