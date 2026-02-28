import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:core/core.dart';
import 'package:interfaces/cache/i_cache_manager.dart';
import 'package:interfaces/network/i_http_client.dart';
import 'package:interfaces/storage/i_secure_storage.dart';
import '../data/datasources/auth_local_datasource.dart';
import '../data/datasources/network_demo_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/network_demo_repository_impl.dart';
import '../domain/repositories/i_auth_repository.dart';
import '../domain/repositories/i_network_demo_repository.dart';
import '../domain/usecases/fetch_demo_posts_usecase.dart';
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

@riverpod
bool fullStackDemoAvailable(Ref ref) {
  final locator = ServiceLocator();
  return locator.isRegistered<IHttpClient>() &&
      locator.isRegistered<ICacheManager>();
}

@riverpod
NetworkDemoDataSource? networkDemoDataSource(Ref ref) {
  if (!ref.watch(fullStackDemoAvailableProvider)) {
    return null;
  }
  final httpClient = ref.watch(httpClientProvider);
  return NetworkDemoDataSource(httpClient);
}

@riverpod
INetworkDemoRepository? networkDemoRepository(Ref ref) {
  final dataSource = ref.watch(networkDemoDataSourceProvider);
  if (dataSource == null) {
    return null;
  }
  final cacheManager = ref.watch(cacheManagerProvider);
  return NetworkDemoRepositoryImpl(dataSource, cacheManager);
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

@riverpod
FetchDemoPostsUseCase? fetchDemoPostsUseCase(Ref ref) {
  final repository = ref.watch(networkDemoRepositoryProvider);
  if (repository == null) {
    return null;
  }
  return FetchDemoPostsUseCase(repository);
}
