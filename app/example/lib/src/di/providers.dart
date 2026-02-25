import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:core/core.dart';
import 'package:interfaces/storage/i_secure_storage.dart';
import '../data/datasources/auth_local_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/i_auth_repository.dart';
import '../domain/usecases/get_current_user_usecase.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/logout_usecase.dart';

part 'providers.g.dart';

// ============================================================================
// Data Layer - DataSources
// ============================================================================

/// 认证本地数据源 Provider
@riverpod
AuthLocalDataSource authLocalDataSource(Ref ref) {
  final storage = ref.watch(kvStorageProvider);
  final secureStorage = ServiceLocator().isRegistered<ISecureStorage>()
      ? ref.watch(secureStorageProvider)
      : null;
  return AuthLocalDataSource(storage, secureStorage: secureStorage);
}

// ============================================================================
// Data Layer - Repositories
// ============================================================================

/// 认证仓储 Provider
@riverpod
IAuthRepository authRepository(Ref ref) {
  final localDataSource = ref.watch(authLocalDataSourceProvider);
  return AuthRepositoryImpl(localDataSource);
}

// ============================================================================
// Domain Layer - UseCases
// ============================================================================

/// 登录用例 Provider
@riverpod
LoginUseCase loginUseCase(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
}

/// 登出用例 Provider
@riverpod
LogoutUseCase logoutUseCase(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
}

/// 获取当前用户用例 Provider
@riverpod
GetCurrentUserUseCase getCurrentUserUseCase(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
}
