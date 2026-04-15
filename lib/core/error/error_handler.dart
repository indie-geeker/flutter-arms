import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_arms/core/error/failures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 全局错误处理。
class ErrorHandler {
  ErrorHandler._();

  /// 将异常映射为 Failure 子类。
  static Failure map(Object error) {
    if (error is DioException) {
      return _mapDioException(error);
    }
    return const UnknownFailure('发生未知错误，请稍后重试');
  }

  static Failure _mapDioException(DioException exception) {
    if (exception.response?.statusCode == 401) {
      return const AuthFailure('身份认证失败，请重新登录');
    }
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('请求超时，请检查网络后重试');
      case DioExceptionType.connectionError:
        return const NetworkFailure('网络连接失败，请检查网络设置');
      case DioExceptionType.badResponse:
        return NetworkFailure('服务响应异常（${exception.response?.statusCode ?? '-'}）');
      case DioExceptionType.cancel:
        return const UnknownFailure('请求已取消');
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const NetworkFailure('请求失败，请稍后重试');
    }
  }
}

/// Riverpod 全局观察器。
final class AppProviderObserver extends ProviderObserver {
  /// 构造函数。
  const AppProviderObserver();

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    if (kDebugMode) {
      debugPrint(
        '[Provider] ${context.provider.name ?? context.provider.runtimeType} '
        '$previousValue -> $newValue',
      );
    }

    super.didUpdateProvider(context, previousValue, newValue);
  }
}
