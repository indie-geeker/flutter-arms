import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../di/providers.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

part 'home_notifier.freezed.dart';
part 'home_notifier.g.dart';

/// 主页状态
@freezed
class HomeState with _$HomeState {
  const factory HomeState.loading() = _Loading;
  const factory HomeState.loaded(UserEntity user) = _Loaded;
  const factory HomeState.error(String message) = _Error;
  const factory HomeState.loggedOut() = _LoggedOut;
}

/// 主页状态管理器
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

  /// 加载当前用户
  Future<void> _loadUser() async {
    final result = await _getCurrentUserUseCase();
    result.fold((failure) => state = HomeState.error(failure.toString()), (
      user,
    ) {
      if (user != null) {
        state = HomeState.loaded(user);
      } else {
        state = const HomeState.error('No user found');
      }
    });
  }

  /// 登出
  Future<void> logout() async {
    final result = await _logoutUseCase();
    result.fold(
      (failure) => state = HomeState.error(failure.toString()),
      (_) => state = const HomeState.loggedOut(),
    );
  }
}
