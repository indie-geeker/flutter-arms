import 'package:flutter_arms/core/network/dio_api_client.dart';
import 'package:flutter_arms/features/auth/data/datasources/api_client_auth_remote_datasource.dart';
import 'package:flutter_arms/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_client_auth_remote_datasource_provider.g.dart';

/// ApiClient 认证远程数据源依赖：适合作为长期替换网络库的对照接线。
@Riverpod(keepAlive: true)
AuthRemoteDataSource apiClientAuthRemoteDataSource(Ref ref) {
  return ApiClientAuthRemoteDataSource(ref.read(apiClientProvider));
}
