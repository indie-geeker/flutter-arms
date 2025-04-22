import 'dart:io';
import 'package:dio/dio.dart';

import '../../errors/failures.dart';

/// 对 Dio 异常进行处理
class DioErrorHandler {
  static Failure handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('连接超时');

      case DioExceptionType.badResponse:
        return _handleResponseError(error.response?.statusCode, error.message);

      case DioExceptionType.cancel:
        return const NetworkFailure('请求已取消');

      case DioExceptionType.connectionError:
        return const NetworkFailure('网络连接失败');

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return const NetworkFailure('网络连接失败');
        }
        return UnknownFailure(error.message);

      default:
        return UnknownFailure(error.message);
    }
  }

  static Failure _handleResponseError(int? statusCode, String? message) {
    switch (statusCode) {
      case 400:
        return ValidationFailure(message ?? '请求参数错误');
      case 401:
        return UnauthorizedFailure(message ?? '未授权');
      case 403:
        return UnauthorizedFailure(message ?? '访问被拒绝');
      case 404:
        return ServerFailure(message ?? '请求的资源不存在');
      case 500:
        return ServerFailure(message ?? '服务器内部错误');
      default:
        return ServerFailure(
          message ?? '服务器错误 ${statusCode ?? "未知状态码"}',
        );
    }
  }
}