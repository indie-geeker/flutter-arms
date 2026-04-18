import 'package:flutter_arms/core/error/app_exception.dart';
import 'package:flutter_arms/core/error/failure.dart';
import 'package:flutter_arms/core/error/failure_code.dart';
import 'package:flutter_arms/core/logger/app_logger.dart';
import 'package:flutter_arms/core/network/dio_ext.dart';
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
///
/// 契约：
/// - 只与 [AppException] 子类打交道（由 DataSource 的 `.asApi()` 保证）。
/// - 在 `on AppException catch` 处转换为 `Result.failure(Failure.fromException(e))`，
///   不让 `DioException` 暴露给 Domain / Presentation 层。
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
    try {
      final token = await _remote
          .login(<String, dynamic>{'username': username, 'password': password})
          .asApi();
      await _local.saveToken(token);

      final userModel = await _remote.me().asApi();
      await _local.saveUser(userModel);
      return Result.success(userModel.toEntity());
    } on AppException catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remote.logout().asApi();
    } on AppException catch (e, st) {
      _logger.warning('remote logout failed, clearing local anyway', e, st);
    }
    await _local.clearAuth();
  }

  @override
  Future<Result<String>> refreshToken(String refreshToken) async {
    try {
      final token = await _remote
          .refreshToken(<String, dynamic>{'refreshToken': refreshToken})
          .asApi();
      await _local.saveToken(token);
      return Result.success(token.accessToken);
    } on AppException catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  @override
  Future<Result<User>> getCurrentUser() async {
    final localUser = _local.getUser();
    if (localUser == null) {
      return const Result.failure(Failure(code: FailureCode.auth));
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
