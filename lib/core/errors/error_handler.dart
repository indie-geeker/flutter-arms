
import 'package:flutter_arms/core/errors/failures.dart';
import 'package:flutter_arms/core/errors/result.dart';

import 'exceptions.dart';

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