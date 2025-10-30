import '../models/request_options.dart';
import 'http_request.dart';
import 'http_response.dart';

/// HTTP 客户端接口
///
/// 抽象底层 HTTP 实现,支持 Dio、http package 等多种客户端
/// 解耦具体 HTTP 库依赖,提供统一的 HTTP 请求接口
abstract class IHttpClient {
  /// 执行 HTTP 请求
  ///
  /// [request] HTTP 请求对象
  ///
  /// 返回 HTTP 响应对象
  /// 抛出具体的 HTTP 异常(如 NetworkException)
  Future<HttpResponse> execute(HttpRequest request);

  /// 取消指定标识的请求
  ///
  /// [tag] 请求标识
  void cancelRequest(Object tag);

  /// 取消所有请求
  void cancelAll();

  /// 关闭客户端,释放资源
  void close();

  /// 获取客户端类型标识
  ///
  /// 用于调试和日志记录,如 'dio', 'http', 'custom'
  String get clientType;
}

/// HTTP 客户端工厂接口
///
/// 创建不同类型的 HTTP 客户端实例
abstract class IHttpClientFactory {
  /// 创建 HTTP 客户端
  ///
  /// [options] 请求配置选项
  ///
  /// 返回 HTTP 客户端实例
  IHttpClient create(RequestOptions options);

  /// 获取工厂支持的客户端类型
  String get supportedType;
}
