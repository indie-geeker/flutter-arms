
/// 网络请求方法枚举
enum RequestMethod {
  /// GET 请求
  get,

  /// POST 请求
  post,

  /// PUT 请求
  put,

  /// DELETE 请求
  delete,

  /// PATCH 请求
  patch,

  /// HEAD 请求
  head,
}

/// 网络请求内容类型枚举
enum ContentType {
  /// application/json
  json,

  /// application/x-www-form-urlencoded
  formUrlEncoded,

  /// multipart/form-data
  multipart,

  /// text/plain
  text,
}

/// 响应类型枚举
enum ResponseType {
  /// JSON响应
  json,

  /// 字符串响应
  string,

  /// 字节流响应
  bytes,
}

