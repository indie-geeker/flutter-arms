import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:interfaces/core/result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:example/src/features/authentication/di/auth_providers.dart';
import 'package:example/src/features/authentication/domain/entities/user_entity.dart';
import 'package:example/src/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:example/src/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:example/src/shared/auth/auth_shared.dart';

part 'home_notifier.freezed.dart';
part 'home_notifier.g.dart';

/// Home page state
@freezed
class HomeState with _$HomeState {
  const factory HomeState.loading() = _Loading;
  const factory HomeState.loaded(UserEntity user) = _Loaded;
  const factory HomeState.error(String message) = _Error;
  const factory HomeState.loggedOut() = _LoggedOut;
}

/// Home page state manager
@riverpod
class HomeNotifier extends _$HomeNotifier {
  late final GetCurrentUserUseCase _getCurrentUserUseCase;
  late final LogoutUseCase _logoutUseCase;

  @override
  HomeState build() {
    _getCurrentUserUseCase = ref.read(getCurrentUserUseCaseProvider);
    _logoutUseCase = ref.read(logoutUseCaseProvider);
    _loadUser();
    return const HomeState.loading();
  }

  /// Load current user
  Future<void> _loadUser() async {
    final result = await _getCurrentUserUseCase();
    switch (result) {
      case Failure(:final error):
        state = HomeState.error(error.toString());
      case Success(:final value):
        if (value != null) {
          state = HomeState.loaded(value);
        } else {
          state = const HomeState.loggedOut();
        }
    }
  }

  /// Logout
  Future<void> logout() async {
    final result = await _logoutUseCase();
    switch (result) {
      case Failure(:final error):
        state = HomeState.error(error.toString());
      case Success():
        // Logout success: clear global session state
        ref.read(authSessionProvider.notifier).setUnauthenticated();
        state = const HomeState.loggedOut();
    }
  }
}
