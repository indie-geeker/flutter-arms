import 'package:example/src/di/providers.dart';
import 'package:example/src/features/authentication/data/datasources/auth_local_datasource.dart';
import 'package:example/src/features/authentication/data/datasources/i_auth_local_datasource.dart';
import 'package:example/src/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:example/src/features/authentication/domain/repositories/i_auth_repository.dart';
import 'package:example/src/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:example/src/features/authentication/domain/usecases/login_usecase.dart';
import 'package:example/src/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:example/src/shared/auth/auth_shared.dart';
import 'package:interfaces/core/result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

@riverpod
IAuthLocalDataSource authLocalDataSource(Ref ref) {
  final storage = ref.watch(kvStorageProvider);
  return AuthLocalDataSource(storage);
}

@riverpod
IAuthRepository authRepository(Ref ref) {
  final localDataSource = ref.watch(authLocalDataSourceProvider);
  return AuthRepositoryImpl(localDataSource);
}

@riverpod
LoginUseCase loginUseCase(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
}

@riverpod
LogoutUseCase logoutUseCase(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
}

@riverpod
GetCurrentUserUseCase getCurrentUserUseCase(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
}

/// Restore authentication state from local storage at startup
///
/// Triggered during app shell construction (via ref.watch), automatically
/// writes the last logged-in user info to [AuthSessionNotifier] so that
/// global auth state is immediately available after startup.
///
/// Uses keepAlive: true to ensure it executes only once and is not
/// re-triggered when widgets are disposed.
@Riverpod(keepAlive: true)
Future<void> sessionRestore(Ref ref) async {
  final getCurrentUser = ref.read(getCurrentUserUseCaseProvider);
  final result = await getCurrentUser();

  switch (result) {
    case Failure():
      ref.read(authSessionProvider.notifier).setUnauthenticated();
    case Success(:final value):
      if (value != null) {
        ref.read(authSessionProvider.notifier).setAuthenticated(
              userId: value.id,
              username: value.username,
            );
      } else {
        ref.read(authSessionProvider.notifier).setUnauthenticated();
      }
  }
}
