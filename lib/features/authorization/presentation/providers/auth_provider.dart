import 'package:flutter_arms/core/errors/result.dart';
import 'package:flutter_arms/core/network/providers/network_provider.dart';
import 'package:flutter_arms/core/presentation/base_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/network/adapters/default_response_adapter.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth.dart';
import '../../domain/usecases/auth_usecase.dart';

final loginRemoteDataSourceProvider = Provider((ref) {
  final apiClientWrapper = ref.watch(apiClientWithAdapterProvider(adapter: const DefaultResponseAdapter()));
  final errorHandler = ref.watch(errorHandlerProvider);
  return AuthRemoteDatasource(apiClientWrapper, errorHandler);
});

final authRepositoryProvider = Provider((ref) {
  final remoteDataSource = ref.watch(loginRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource);
});

final authUseCaseProvider = Provider((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthUseCase(repository);
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<Result<Auth>?>>((ref) {
  final loginUseCase = ref.watch(authUseCaseProvider);
  return AuthNotifier(loginUseCase);
});


class AuthNotifier extends BaseNotifier<Auth> {
  final AuthUseCase _loginUseCase;
  // final GetUserInfoUseCase _getUserInfoUseCase;

  AuthNotifier(this._loginUseCase) : super();

  Future<void> login(String username, String password) async {
    final params = AuthParams(username: username, password: password);
    await executeUseCase(
        useCase: _loginUseCase.execute,
        params: params
    );
  }

  // Future<void> getUserInfo() async {
  //   await executeNoParamsUseCase(
  //       useCase: _getUserInfoUseCase.execute
  //   );
  // }
}