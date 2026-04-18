/// 失败分类码。
///
/// 用于在 Domain / Presentation 层承载错误语义，
/// 与 i18n `t.errors.<code>` 一一对应。
enum FailureCode {
  /// 网络连接错误（无法建立连接、连接被中断等）。
  network,

  /// 请求超时（connect / send / receive）。
  timeout,

  /// 服务端响应异常（非 2xx、且非 401）。
  badResponse,

  /// 身份认证失败（401 或刷新失败）。
  auth,

  /// 参数校验失败（Domain/Presentation 侧主动抛出）。
  validation,

  /// 请求已取消。
  cancelled,

  /// 未分类错误。
  unknown,
}
