import 'package:dio/dio.dart';
import 'package:flutter_arms/app/app_env.dart';
import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_arms/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_arms/features/auth/data/models/token_model.dart';
import 'package:flutter_arms/features/auth/data/models/user_model.dart';
import 'package:flutter_arms/features/auth/domain/entities/user.dart';
import 'package:flutter_arms/features/auth/domain/repositories/auth_repository.dart';

/// 认证仓储实现。
class AuthRepositoryImpl implements AuthRepository {
  /// 构造函数。
  const AuthRepositoryImpl(this._remote, this._local);

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<Result<User>> login({
    required String username,
    required String password,
  }) async {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      return const Result.failure('账号和密码不能为空');
    }

    try {
      final token = await _remote.login(<String, dynamic>{
        'username': username,
        'password': password,
      });
      await _local.saveToken(token);

      final userModel = await _remote.me();
      await _local.saveUser(userModel);
      return Result.success(userModel.toEntity());
    } on DioException {
      if (AppEnv.current.flavor == AppFlavor.dev && password == '123456') {
        const fallbackToken = TokenModel(
          accessToken: 'dev_access_token',
          refreshToken: 'dev_refresh_token',
        );
        final fallbackUser = UserModel(
          id: 'dev_$username',
          name: username,
          email: '$username@example.com',
        );

        await _local.saveToken(fallbackToken);
        await _local.saveUser(fallbackUser);
        return Result.success(fallbackUser.toEntity());
      }

      return const Result.failure('登录失败，请检查账号密码后重试');
    } on Object {
      return const Result.failure('登录失败，请稍后重试');
    }
  }

  @override
  Future<void> logout() async {
    await _local.clearAuth();
  }

  @override
  Future<Result<String>> refreshToken(String refreshToken) async {
    try {
      final token = await _remote.refreshToken(<String, dynamic>{
        'refreshToken': refreshToken,
      });
      await _local.saveToken(token);
      return Result.success(token.accessToken);
    } on Object {
      return const Result.failure('刷新登录态失败');
    }
  }

  @override
  Future<Result<User>> getCurrentUser() async {
    try {
      final localUser = _local.getUser();
      if (localUser == null) {
        return const Result.failure('当前无登录用户');
      }

      return Result.success(localUser.toEntity());
    } on Object {
      return const Result.failure('读取用户信息失败');
    }
  }
}
