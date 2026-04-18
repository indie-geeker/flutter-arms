import 'package:flutter_arms/core/error/failure_code.dart';

/// Data 层统一异常基类。
///
/// 约定：
/// - Data/DataSource 只抛 [AppException] 子类，不向上泄露 `DioException` / `HiveError`。
/// - Repository 在 `on AppException catch` 处转换为 `Result.failure(Failure.fromException(e))`。
/// - Domain / Presentation 不 import 本文件。
sealed class AppException implements Exception {
  /// 构造函数。
  const AppException({
    required this.code,
    this.cause,
    this.stackTrace,
    this.detail,
  });

  /// 失败分类码。
  final FailureCode code;

  /// 原始异常（可选）。
  final Object? cause;

  /// 原始堆栈（可选）。
  final StackTrace? stackTrace;

  /// 详情文案（可选，服务端下发 message / 校验详情）。
  final String? detail;

  @override
  String toString() => 'AppException(code: $code, detail: $detail, cause: $cause)';
}

/// 网络连接异常。
final class NetworkException extends AppException {
  /// 构造函数。
  const NetworkException({super.cause, super.stackTrace, super.detail})
    : super(code: FailureCode.network);
}

/// 请求超时异常。
final class TimeoutException extends AppException {
  /// 构造函数。
  const TimeoutException({super.cause, super.stackTrace, super.detail})
    : super(code: FailureCode.timeout);
}

/// 服务端响应异常（非 2xx，非 401）。
final class BadResponseException extends AppException {
  /// 构造函数。
  const BadResponseException({super.cause, super.stackTrace, super.detail})
    : super(code: FailureCode.badResponse);
}

/// 身份认证异常（401 或刷新失败）。
final class AuthException extends AppException {
  /// 构造函数。
  const AuthException({super.cause, super.stackTrace, super.detail})
    : super(code: FailureCode.auth);
}

/// 校验异常（参数非法等）。
final class ValidationException extends AppException {
  /// 构造函数。
  const ValidationException({super.cause, super.stackTrace, super.detail})
    : super(code: FailureCode.validation);
}

/// 请求已取消异常。
final class CancelledException extends AppException {
  /// 构造函数。
  const CancelledException({super.cause, super.stackTrace, super.detail})
    : super(code: FailureCode.cancelled);
}

/// 未知异常。
final class UnknownException extends AppException {
  /// 构造函数。
  const UnknownException({super.cause, super.stackTrace, super.detail})
    : super(code: FailureCode.unknown);
}
