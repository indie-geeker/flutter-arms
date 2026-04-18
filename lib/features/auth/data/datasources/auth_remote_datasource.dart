import 'package:dio/dio.dart';
import 'package:flutter_arms/core/network/dio_client.dart';
import 'package:flutter_arms/features/auth/data/models/token_model.dart';
import 'package:flutter_arms/features/auth/data/models/user_model.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_remote_datasource.g.dart';

/// 认证远程数据源（Retrofit 示例）。
@RestApi()
abstract class AuthRemoteDataSource {
  /// 构造函数。
  factory AuthRemoteDataSource(Dio dio, {String baseUrl}) =
      _AuthRemoteDataSource;

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

/// 认证远程数据源依赖注入。
@Riverpod(keepAlive: true)
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  return AuthRemoteDataSource(ref.read(dioProvider));
}
