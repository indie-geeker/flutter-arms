import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:example/src/di/providers.dart';
import 'package:example/src/features/network_demo/domain/entities/demo_post_entity.dart';
import 'package:example/src/features/network_demo/domain/repositories/i_network_demo_repository.dart';
import 'package:example/src/features/network_demo/domain/usecases/fetch_demo_posts_usecase.dart';

part 'network_demo_notifier.freezed.dart';
part 'network_demo_notifier.g.dart';

@freezed
abstract class NetworkDemoState with _$NetworkDemoState {
  const factory NetworkDemoState({
    @Default(true) bool available,
    @Default(DemoCacheMode.cacheFirst) DemoCacheMode cacheMode,
    @Default(<DemoPostEntity>[]) List<DemoPostEntity> posts,
    @Default(false) bool isLoading,
    @Default(false) bool fromCache,
    String? errorMessage,
  }) = _NetworkDemoState;
}

@riverpod
class NetworkDemoNotifier extends _$NetworkDemoNotifier {
  FetchDemoPostsUseCase? _useCase;

  @override
  NetworkDemoState build() {
    _useCase = ref.read(fetchDemoPostsUseCaseProvider);
    return NetworkDemoState(available: _useCase != null);
  }

  Future<void> fetch({DemoCacheMode? cacheMode}) async {
    final selectedMode = cacheMode ?? state.cacheMode;
    final useCase = _useCase;
    if (useCase == null) {
      state = state.copyWith(
        available: false,
        cacheMode: selectedMode,
        isLoading: false,
        errorMessage:
            'Full-stack profile is disabled. Run with ARMS_EXAMPLE_FULL_STACK=true.',
      );
      return;
    }

    state = state.copyWith(
      available: true,
      cacheMode: selectedMode,
      isLoading: true,
      errorMessage: null,
    );

    try {
      final result = await useCase(cacheMode: selectedMode);
      state = state.copyWith(
        isLoading: false,
        posts: result.posts,
        fromCache: result.fromCache,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }
}
