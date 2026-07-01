/// JSON 解码函数。
typedef JsonDecoder<T> = T Function(Object? json);

/// API 请求方法。
enum ApiMethod {
  /// GET 请求。
  get,

  /// POST 请求。
  post,

  /// PUT 请求。
  put,

  /// PATCH 请求。
  patch,

  /// DELETE 请求。
  delete,
}

/// 应用级 API 请求描述。
final class ApiRequest<T> {
  /// 构造函数。
  const ApiRequest({
    required this.method,
    required this.path,
    required this.decode,
    this.query,
    this.body,
    this.headers,
    this.requiresAuth = true,
  });

  /// GET 请求构造函数。
  const ApiRequest.get(
    String path, {
    required JsonDecoder<T> decode,
    Map<String, Object?>? query,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) : this(
         method: ApiMethod.get,
         path: path,
         query: query,
         headers: headers,
         requiresAuth: requiresAuth,
         decode: decode,
       );

  /// POST 请求构造函数。
  const ApiRequest.post(
    String path, {
    required JsonDecoder<T> decode,
    Object? body,
    Map<String, Object?>? query,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) : this(
         method: ApiMethod.post,
         path: path,
         body: body,
         query: query,
         headers: headers,
         requiresAuth: requiresAuth,
         decode: decode,
       );

  /// 请求方法。
  final ApiMethod method;

  /// 相对路径。
  final String path;

  /// 查询参数。
  final Map<String, Object?>? query;

  /// 请求体。
  final Object? body;

  /// 请求头。
  final Map<String, String>? headers;

  /// 是否需要认证。
  final bool requiresAuth;

  /// 响应解码函数。
  final JsonDecoder<T> decode;
}
