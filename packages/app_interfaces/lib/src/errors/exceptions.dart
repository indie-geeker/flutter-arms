
import 'package:freezed_annotation/freezed_annotation.dart';

part 'exceptions.freezed.dart';

@freezed
abstract class AppException with _$AppException implements Exception{
  const factory AppException({
    required String message,
    int? code,
    dynamic details,
  }) = _AppException;

  /// 缓存异常
  const factory AppException.cache({
    required String message,
    int? code,
    dynamic details,
  }) = CacheException;

  /// 网络异常
  const factory AppException.network({
    required String message,
    int? code,
    dynamic details,
    int? statusCode,
  }) = NetworkException;

  /// 未授权异常
  const factory AppException.unauthorized({
    required String message,
    int? code,
    dynamic details,
  }) = UnauthorizedException;


  /// 解析异常
  const factory AppException.parse({
    required String message,
    int? code,
    dynamic details,
  }) = ParseException;

  /// 服务器异常
  const factory AppException.server({
    required String message,
    int? code,
    dynamic details,
  }) = ServerException;


  /// 未知异常
  const factory AppException.unknown({
    required String message,
    int? code,
    dynamic details,
  }) = UnknownException;
}

