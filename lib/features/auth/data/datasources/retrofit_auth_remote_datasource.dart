import 'package:dio/dio.dart';
import 'package:flutter_arms/core/network/dio_client.dart';
import 'package:flutter_arms/core/network/dio_ext.dart';
import 'package:flutter_arms/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_arms/features/auth/data/models/token_model.dart';
import 'package:flutter_arms/features/auth/data/models/user_model.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'retrofit_auth_remote_datasource.g.dart';

/// Retrofit 认证 API。
@RestApi()
abstract class RetrofitAuthApi {
  /// 构造函数。
  factory RetrofitAuthApi(Dio dio, {String baseUrl}) = _RetrofitAuthApi;

  /// 登录。
  @POST('/auth/login')
  Future<TokenModel> login(@Body() Map<String, dynamic> body);

  /// 刷新 Token。
  @POST('/auth/refresh')
  Future<TokenModel> refreshToken(@Body() Map<String, dynamic> body);

  /// 获取当前用户。
  @GET('/auth/me')
  Future<UserModel> me();

  /// 登出。
  @POST('/auth/logout')
  Future<void> logout();
}

/// Retrofit 认证远程数据源。
final class RetrofitAuthRemoteDataSource implements AuthRemoteDataSource {
  /// 构造函数。
  const RetrofitAuthRemoteDataSource(this._api);

  final RetrofitAuthApi _api;

  @override
  Future<TokenModel> login(Map<String, dynamic> body) {
    return _api.login(body).asApi();
  }

  @override
  Future<UserModel> me() {
    return _api.me().asApi();
  }

  @override
  Future<TokenModel> refreshToken(Map<String, dynamic> body) {
    return _api.refreshToken(body).asApi();
  }

  @override
  Future<void> logout() {
    return _api.logout().asApi();
  }
}

/// 默认认证远程数据源：Retrofit 写法，适合快速 REST CRUD。
@Riverpod(keepAlive: true)
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  return RetrofitAuthRemoteDataSource(RetrofitAuthApi(ref.read(dioProvider)));
}

/// 刷新专用认证远程数据源：不挂 TokenInterceptor，避免刷新递归。
@Riverpod(keepAlive: true)
AuthRemoteDataSource authRefreshRemoteDataSource(Ref ref) {
  return RetrofitAuthRemoteDataSource(
    RetrofitAuthApi(ref.read(authRefreshDioProvider)),
  );
}
