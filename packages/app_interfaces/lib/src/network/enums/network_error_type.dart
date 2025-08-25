/// 网络错误类型枚举
enum NetworkErrorType {
  /// 连接超时
  connectionTimeout('Connection timeout'),

  /// 接收数据超时
  receiveTimeout('Receive timeout'),

  /// 发送数据超时
  sendTimeout('Send timeout'),

  /// 网络连接错误
  connectionError('Connection error'),

  /// 服务端错误(5xx)
  serverError('Server error'),

  /// 客户端错误(4xx)
  clientError('Client error'),

  /// 未授权(401)
  unauthorized('Unauthorized'),

  /// 禁止访问(403)
  forbidden('Forbidden'),

  /// 资源不存在(404)
  notFound('Not found'),

  /// 请求冲突(409)
  conflict('Conflict'),

  /// 请求取消
  cancel('Cancel'),

  /// 解析错误
  parseError('Parse error'),

  /// 业务逻辑错误(服务端返回的业务错误)
  businessError('Business error'),

  /// 未知错误
  unknown('Unknown error'),

  ;

  final String message;

  const NetworkErrorType(this.message);
}