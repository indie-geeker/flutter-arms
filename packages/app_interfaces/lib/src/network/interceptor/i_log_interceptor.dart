import 'i_request_interceptor.dart';

/// 日志拦截器接口
///
/// 专门处理日志记录的请求拦截
abstract class ILogInterceptor extends IRequestInterceptor {
  /// 是否启用请求体日志
  bool get logRequestBody;

  /// 是否启用请求头日志
  bool get logRequestHeader;

  /// 是否启用响应体日志
  bool get logResponseBody;

  /// 是否启用响应头日志
  bool get logResponseHeader;

  /// 是否启用错误日志
  bool get logError;

  /// 设置日志配置
  ///
  /// [logRequestHeader] 是否记录请求头
  /// [logRequestBody] 是否记录请求体
  /// [logResponseHeader] 是否记录响应头
  /// [logResponseBody] 是否记录响应体
  /// [logError] 是否记录错误
  void setLogConfig({
    bool? logRequestHeader,
    bool? logRequestBody,
    bool? logResponseHeader,
    bool? logResponseBody,
    bool? logError,
  });
}
