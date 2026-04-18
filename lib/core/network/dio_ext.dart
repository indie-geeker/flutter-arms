import 'package:dio/dio.dart';
import 'package:flutter_arms/core/error/app_exception.dart';

/// `Future<T>` 的 Dio 错误统一转换扩展。
///
/// 使用方式：DataSource / Repository 调用 Retrofit / 自建 Dio 方法时，
/// 在其返回的 Future 上链式调用 `.asApi()`，将 [DioException] 统一转换为
/// [AppException]，从而不让 `DioException` 泄漏到 Data 层以外。
///
/// `ApiInterceptor` 已将 [DioException.error] 填充为 [AppException]，
/// 本扩展只需将其解封即可；任何未匹配场景兜底为 [UnknownException]。
extension ThrowAppExceptionX<T> on Future<T> {
  /// 将底层 Dio 异常转换为 [AppException]。
  Future<T> asApi() {
    return catchError((Object e, StackTrace st) {
      if (e is AppException) {
        throw e;
      }
      if (e is DioException) {
        final inner = e.error;
        if (inner is AppException) {
          throw inner;
        }
        throw UnknownException(cause: e, stackTrace: st);
      }
      throw UnknownException(cause: e, stackTrace: st);
    });
  }
}
