import 'package:core/core.dart';
import 'package:example/src/features/authentication/data/datasources/auth_local_datasource.dart';
import 'package:example/src/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:example/src/features/authentication/domain/repositories/i_auth_repository.dart';
import 'package:example/src/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:example/src/features/authentication/domain/usecases/login_usecase.dart';
import 'package:example/src/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

@riverpod
AuthLocalDataSource authLocalDataSource(Ref ref) {
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
