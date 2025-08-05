/// 网络错误类型枚举
enum NetworkErrorType {
  /// 连接超时
  connectionTimeout,

  /// 接收数据超时
  receiveTimeout,

  /// 发送数据超时
  sendTimeout,

  /// 网络连接错误
  connectionError,

  /// 服务端错误(5xx)
  serverError,

  /// 客户端错误(4xx)
  clientError,

  /// 未授权(401)
  unauthorized,

  /// 禁止访问(403)
  forbidden,

  /// 资源不存在(404)
  notFound,

  /// 请求冲突(409)
  conflict,

  /// 请求取消
  cancel,

  /// 解析错误
  parseError,

  /// 业务逻辑错误(服务端返回的业务错误)
  businessError,

  /// 未知错误
  unknown,
}