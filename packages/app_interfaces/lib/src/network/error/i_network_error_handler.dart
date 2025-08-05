
import '../models/request_options.dart';
import 'network_error_type.dart';

/// 网络错误处理接口
///
/// 用于处理网络请求过程中发生的各种错误，提供统一的错误处理机制
abstract class INetworkErrorHandler {
  /// 处理网络错误
  /// 
  /// [error] 原始错误对象
  /// [stackTrace] 错误堆栈
  /// [options] 请求选项
  /// 
  /// 返回处理后的错误对象，可以是自定义的网络错误
  Future<Object> handleError(
      Object error,
      StackTrace stackTrace,
      RequestOptions options,
      );

  /// 获取错误类型
  /// 
  /// [error] 错误对象
  /// 
  /// 返回错误类型枚举
  NetworkErrorType getErrorType(Object error);

  /// 获取错误消息
  /// 
  /// [error] 错误对象
  /// [fallbackMessage] 默认错误消息
  /// 
  /// 返回用户友好的错误消息
  String getErrorMessage(Object error, [String fallbackMessage = '网络请求失败，请稍后重试']);

  /// 获取错误状态码
  /// 
  /// [error] 错误对象
  /// 
  /// 返回HTTP状态码，如果无法获取则返回null
  int? getStatusCode(Object error);

  /// 是否为未授权错误(401)
  /// 
  /// [error] 错误对象
  bool isUnauthorizedError(Object error);

  /// 是否为网络连接错误
  /// 
  /// [error] 错误对象
  bool isConnectionError(Object error);

  /// 是否为业务逻辑错误
  /// 
  /// [error] 错误对象
  bool isBusinessError(Object error);

  /// 是否为服务器错误(5xx)
  /// 
  /// [error] 错误对象
  bool isServerError(Object error);

  /// 获取业务错误码
  /// 
  /// [error] 错误对象
  /// 
  /// 返回业务错误码，如果不是业务错误则返回null
  String? getBusinessErrorCode(Object error);

  /// 注册特定错误的处理函数
  /// 
  /// [errorType] 错误类型
  /// [handler] 处理函数
  void registerErrorHandler(
      NetworkErrorType errorType,
      Future<Object> Function(Object error, RequestOptions options) handler,
      );
}