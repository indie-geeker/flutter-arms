enum ResponseStatus {
  success(1, 'success'),
  unauthorized(401, '未授权'),
  forbidden(403, '无权限'),
  notFound(404, '未找到'),
  serverError(500, '服务器错误'),
  networkError(600, '网络错误'),
  parseError(700, '解析错误'),
  unknownError(999, '未知错误');

  final int code;
  final String message;

  const ResponseStatus(this.code, this.message);
}