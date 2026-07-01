import 'package:flutter_arms/core/auth/auth_token_refresher.dart';
import 'package:flutter_arms/core/logger/app_log.dart';
import 'package:flutter_arms/core/logger/app_logger.dart';
import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:flutter_arms/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_arms/features/auth/data/datasources/retrofit_auth_remote_datasource.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_token_refresher_impl.g.dart';

/// 远端认证 Token 刷新实现。
final class AuthRemoteTokenRefresher implements AuthTokenRefresher {
  /// 构造函数。
  const AuthRemoteTokenRefresher(this._remote, this._storage, this._logger);

  final AuthRemoteDataSource _remote;
  final KvStorage _storage;
  final AppLog _logger;

  @override
  String get adapterName => 'auth_remote';

  @override
  Future<bool> refresh(String refreshToken) async {
    try {
      final token = await _remote.refreshToken(<String, dynamic>{
        'refreshToken': refreshToken,
      });

      if (token.accessToken.isEmpty) {
        _logger.warning('auth token refresh returned empty access token');
        return false;
      }

      await _storage.saveAccessToken(token.accessToken);
      if (token.refreshToken.isNotEmpty) {
        await _storage.saveRefreshToken(token.refreshToken);
      }
      return true;
    } on Object catch (e, st) {
      _logger.warning('auth token refresh failed', e, st);
      return false;
    }
  }
}

/// 远端认证 Token 刷新依赖。
@Riverpod(keepAlive: true)
AuthTokenRefresher authRemoteTokenRefresher(Ref ref) {
  return AuthRemoteTokenRefresher(
    ref.read(authRefreshRemoteDataSourceProvider),
    ref.read(kvStorageProvider),
    ref.read(appLoggerProvider),
  );
}
