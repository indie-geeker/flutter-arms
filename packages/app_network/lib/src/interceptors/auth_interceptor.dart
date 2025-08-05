import 'package:app_interfaces/app_interfaces.dart';
import 'base_interceptor.dart';

/// 认证拦截器
///
/// 负责自动添加认证令牌、处理令牌刷新等认证相关功能
class AuthInterceptor extends BaseInterceptor implements IAuthInterceptor {
  static const String _authorizationHeader = 'Authorization';
  
  String? _token;
  String _tokenType = ''; // e.g: Bearer
  bool _enabled = true;
  bool _isRefreshing = false;
  
  /// 令牌刷新回调
  Future<String?> Function()? onTokenRefresh;
  
  /// 令牌过期回调
  void Function()? onTokenExpired;

  AuthInterceptor({
    String? token,
    bool enabled = true,
    this.onTokenRefresh,
    this.onTokenExpired,
  }) : _token = token, _enabled = enabled;

  @override
  int get priority => 10; // 较高优先级，确保认证信息优先添加

  @override
  bool get enabled => _enabled;

  @override
  void enable() {
    _enabled = true;
  }

  @override
  void disable() {
    _enabled = false;
  }

  @override
  void setToken(String token, {String tokenType = ''}) {
    _token = token;
    _tokenType = tokenType;
  }

  @override
  void clearToken() {
    _token = null;
  }

  @override
  Future<bool> refreshToken() async {
    if (_isRefreshing || onTokenRefresh == null) {
      return false;
    }

    _isRefreshing = true;
    try {
      final newToken = await onTokenRefresh!();
      if (newToken != null) {
        _token = newToken;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  @override
  bool get isRefreshing => _isRefreshing;

  /// 获取令牌
  String? get token => _token;

  @override
  Future<RequestOptions> onRequest(RequestOptions options) async {
    if (!_enabled || _token == null) {
      return options;
    }

    // 添加认证头
    final headers = Map<String, String>.from(options.headers);
    if(_tokenType.isNotEmpty){
      headers[_authorizationHeader] = '$_tokenType $_token';
    }
    else{
      headers[_authorizationHeader] = '$_token';
    }

    return options.copyWith(
      headers: headers,
    );
  }

  @override
  Future<Object> onError(Object error, RequestOptions options) async {
    // 处理 401 未授权错误
    if (error is NetworkException && 
        error.code == 'unauthorized' && 
        _enabled) {
      
      // 尝试刷新令牌
      if (onTokenRefresh != null) {
        try {
          final newToken = await onTokenRefresh!();
          if (newToken != null) {
            setToken(newToken);
            
            // 重新构建请求选项，添加新的令牌
            // 实际的重试逻辑应该在更高层处理
            return const NetworkException(
              message: '令牌已刷新，请重试请求',
              code: 'token_refreshed',
              statusCode: 401,
            );
          }
        } catch (refreshError) {
          // 令牌刷新失败，通知上层
          onTokenExpired?.call();
          return const NetworkException(
            message: '令牌刷新失败',
            code: 'token_refresh_failed',
            statusCode: 401,
          );
        }
      }
      
      // 没有刷新回调或刷新失败，通知令牌过期
      onTokenExpired?.call();
    }

    return error;
  }
}
