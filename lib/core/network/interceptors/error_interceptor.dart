import 'package:dio/dio.dart';
import 'package:flutter_arms/core/errors/exceptions.dart';

class ErrorInterceptor extends Interceptor{
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 转换Dio 错误为自定义错误
    final exception = _mapDioErrorToAppException(err);
    throw exception;
  }

  Exception _mapDioErrorToAppException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(message:'网络连接超时');
      case DioExceptionType.badResponse:
        return _handleResponseError(error);
      case DioExceptionType.cancel:
        return NetworkException(message: '网络请求被取消');
      case DioExceptionType.connectionError:
        return NetworkException(message: '网络连接失败');
      default:
        return UnknownException(message: error.message ?? '未知错误');
    }
  }

  Exception _handleResponseError(DioException error) {
    final statusCode = error.response?.statusCode;
    final message = error.response?.statusMessage ?? '未知错误';
    switch (statusCode) {
      case 400:
        return ValidationException(message: message);
      case 401:
        return UnauthorizedException(message: message);
      case 403:
        return ForbiddenException(message: message);
      case 404:
        return NotFoundException(message: message);
      case 500:
        return ServerException(message: message);
      default:
        return UnknownException(message: message);
    }
  }
}