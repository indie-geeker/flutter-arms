import 'i_request_interceptor.dart';

/// 认证拦截器接口
///
/// 专门处理认证相关的请求拦截，如添加token、处理401错误等
abstract class IAuthInterceptor extends IRequestInterceptor {
  /// 是否启用认证拦截
  bool get enabled;

  /// 启用认证拦截
  void enable();

  /// 禁用认证拦截
  void disable();

  /// 设置认证令牌
  ///
  /// [token] 认证令牌
  /// [tokenType] 令牌类型，例如 "Bearer"
  void setToken(String token, {String tokenType = 'Bearer'});

  /// 清除认证令牌
  void clearToken();

  /// 刷新令牌
  ///
  /// 当令牌过期时调用，用于获取新的令牌
  /// 返回是否刷新成功
  Future<bool> refreshToken();

  /// 是否正在刷新令牌
  bool get isRefreshing;
}