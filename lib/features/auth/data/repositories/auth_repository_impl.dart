import 'package:dio/dio.dart';
import 'package:flutter_arms/core/error/failures.dart';
import 'package:flutter_arms/core/logger/app_logger.dart';
import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_arms/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_arms/features/auth/data/models/user_model.dart';
import 'package:flutter_arms/features/auth/domain/entities/user.dart';
import 'package:flutter_arms/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_arms/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_arms/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_arms/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talker/talker.dart';

part 'auth_repository_impl.g.dart';

/// 认证仓储实现。
class AuthRepositoryImpl implements AuthRepository {
  /// 构造函数。
  const AuthRepositoryImpl(this._remote, this._local, this._logger);

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final Talker _logger;

  @override
  Future<Result<User>> login({
    required String username,
    required String password,
  }) async {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      return const Result.failure(AuthFailure('账号和密码不能为空'));
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
    } on DioException catch (e) {
      final failure = e.error is Failure
          ? e.error! as Failure
          : NetworkFailure(e.message ?? '登录失败，请检查账号密码后重试');
      return Result.failure(failure);
    } on Object {
      return const Result.failure(UnknownFailure('登录失败，请稍后重试'));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remote.logout();
    } on Object catch (e, st) {
      _logger.warning('remote logout failed, clearing local anyway', e, st);
    }
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
    } on DioException catch (e) {
      final failure = e.error is Failure
          ? e.error! as Failure
          : NetworkFailure(e.message ?? '刷新登录态失败');
      return Result.failure(failure);
    } on Object {
      return const Result.failure(UnknownFailure('刷新登录态失败'));
    }
  }

  @override
  Future<Result<User>> getCurrentUser() async {
    final localUser = _local.getUser();
    if (localUser == null) {
      return const Result.failure(AuthFailure('当前无登录用户'));
    }
    return Result.success(localUser.toEntity());
  }
}

/// 认证仓储依赖注入。
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    ref.read(authRemoteDataSourceProvider),
    ref.read(authLocalDataSourceProvider),
    ref.read(appLoggerProvider),
  );
}

/// 登录用例依赖注入。
@Riverpod(keepAlive: true)
LoginUseCase loginUseCase(Ref ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
}

/// 登出用例依赖注入。
@Riverpod(keepAlive: true)
LogoutUseCase logoutUseCase(Ref ref) {
  return LogoutUseCase(ref.read(authRepositoryProvider));
}

/// 刷新 Token 用例依赖注入。
///
/// 当前 UI 未直接消费（刷新由 `TokenInterceptor` 自动处理），
/// 保留用例以供未来业务主动刷新场景与单元测试复用。
@Riverpod(keepAlive: true)
RefreshTokenUseCase refreshTokenUseCase(Ref ref) {
  return RefreshTokenUseCase(ref.read(authRepositoryProvider));
}
