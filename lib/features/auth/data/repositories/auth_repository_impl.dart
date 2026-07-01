import 'package:flutter_arms/core/error/app_exception.dart';
import 'package:flutter_arms/core/error/failure.dart';
import 'package:flutter_arms/core/error/failure_code.dart';
import 'package:flutter_arms/core/logger/app_log.dart';
import 'package:flutter_arms/core/logger/app_logger.dart';
import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_arms/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_arms/features/auth/data/datasources/retrofit_auth_remote_datasource.dart';
import 'package:flutter_arms/features/auth/data/models/user_model.dart';
import 'package:flutter_arms/features/auth/domain/entities/user.dart';
import 'package:flutter_arms/features/auth/domain/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository_impl.g.dart';

/// 认证仓储实现。
///
/// 契约：
/// - 只与 [AppException] 子类打交道（由 DataSource adapter 保证）。
/// - 在 `on AppException catch` 处转换为 `Result.failure(Failure.fromException(e))`，
///   不让 `DioException` 暴露给 Domain / Presentation 层。
class AuthRepositoryImpl implements AuthRepository {
  /// 构造函数。
  const AuthRepositoryImpl(this._remote, this._local, this._logger);

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final AppLog _logger;

  @override
  Future<Result<User>> login({
    required String username,
    required String password,
  }) async {
    try {
      final token = await _remote.login(<String, dynamic>{
        'username': username,
        'password': password,
      });
      await _local.saveToken(token);

      final userModel = await _remote.me();
      await _local.saveUser(userModel);
      return Result.success(userModel.toEntity());
    } on AppException catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remote.logout();
    } on AppException catch (e, st) {
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
