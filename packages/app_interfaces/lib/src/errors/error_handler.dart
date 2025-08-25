import '../errors/exceptions.dart';
import '../errors/failures.dart';
import '../errors/result.dart';

/// 用于捕获和处理各种异常类型，并将其转换为统一的失败结果
/// 通过 Repository 转换成 Domain 层的 Failure
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
    }
    on ServerException catch (e) {
      return Result.failure(ServerFailure(
        message: e.message,
        code: e.code,
        details: e.details,
      ));
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(
        message: e.message,
        code: e.code,
        details: e.details,
      ));
    } on ParseException catch (e) {
      return Result.failure(ParseFailure(
        message: e.message,
        code: e.code,
        details: e.details,
      ));
    }
    on Exception catch (e) {
      return Result.failure(UnknownFailure(
        message: e.toString(),
      ));
    }
  }
}