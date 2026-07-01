import 'package:flutter_arms/core/network/api_client.dart';
import 'package:flutter_arms/core/network/api_request.dart';
import 'package:flutter_arms/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_arms/features/auth/data/models/token_model.dart';
import 'package:flutter_arms/features/auth/data/models/user_model.dart';

/// ApiClient 认证远程数据源。
final class ApiClientAuthRemoteDataSource implements AuthRemoteDataSource {
  /// 构造函数。
  const ApiClientAuthRemoteDataSource(this._client);

  final ApiClient _client;

  @override
  Future<TokenModel> login(Map<String, dynamic> body) {
    return _client.send(
      ApiRequest<TokenModel>.post(
        '/auth/login',
        body: body,
        requiresAuth: false,
        decode: _decodeToken,
      ),
    );
  }

  @override
  Future<UserModel> me() {
    return _client.send(
      const ApiRequest<UserModel>.get('/auth/me', decode: _decodeUser),
    );
  }

  @override
  Future<TokenModel> refreshToken(Map<String, dynamic> body) {
    return _client.send(
      ApiRequest<TokenModel>.post(
        '/auth/refresh',
        body: body,
        requiresAuth: false,
        decode: _decodeToken,
      ),
    );
  }

  @override
  Future<void> logout() {
    return _client.send(
      ApiRequest<void>.post(
        '/auth/logout',
        requiresAuth: false,
        decode: (_) {},
      ),
    );
  }

  static TokenModel _decodeToken(Object? json) {
    return TokenModel.fromJson(json! as Map<String, dynamic>);
  }

  static UserModel _decodeUser(Object? json) {
    return UserModel.fromJson(json! as Map<String, dynamic>);
  }
}
