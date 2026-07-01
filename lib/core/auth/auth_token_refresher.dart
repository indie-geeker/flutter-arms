import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_token_refresher.g.dart';

/// Token 刷新端口。
abstract interface class AuthTokenRefresher {
  /// 实现名称，用于日志或诊断。
  String get adapterName;

  /// 使用 refresh token 刷新凭证。
  Future<bool> refresh(String refreshToken);
}

/// 空刷新器，用于测试或未接入认证实现的场景。
final class NoopAuthTokenRefresher implements AuthTokenRefresher {
  /// 构造函数。
  const NoopAuthTokenRefresher();

  @override
  String get adapterName => 'noop';

  @override
  Future<bool> refresh(String refreshToken) async => false;
}

/// Token 刷新端口依赖。
@Riverpod(keepAlive: true)
AuthTokenRefresher authTokenRefresher(Ref ref) {
  return const NoopAuthTokenRefresher();
}
