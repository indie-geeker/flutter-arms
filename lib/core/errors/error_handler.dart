
import 'package:flutter_arms/core/errors/failures.dart';
import 'package:flutter_arms/core/errors/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'exceptions.dart';

/// 处理网络请求中的异常
class ErrorHandler {
  Result<T> handleException<T>(Function() action) {
    try {
      return Result.success(action());
    } on UnauthorizedException catch (e) {
      return Result.failure(UnauthorizedFailure(
        message: e.message,
        code: e.code,
        details: e.details,
      ));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(
        message: e.message,
        code: e.code,
        details: e.details,
        statusCode: e.statusCode,
      ));
    } // ...其他异常类型
    on Exception catch (e) {
      return Result.failure(UnknownFailure(
        message: e.toString(),
      ));
    }
  }
}

/// 提供全局错误处理器的provider
final errorHandlerProvider = Provider<ErrorHandler>((ref) {
  return ErrorHandler();
});