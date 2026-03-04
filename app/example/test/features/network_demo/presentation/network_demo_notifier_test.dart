import 'package:example/src/features/network_demo/di/network_demo_providers.dart';
import 'package:example/src/features/network_demo/domain/entities/demo_post_entity.dart';
import 'package:example/src/features/network_demo/domain/repositories/i_network_demo_repository.dart';
import 'package:example/src/features/network_demo/domain/usecases/fetch_demo_posts_usecase.dart';
import 'package:example/src/features/network_demo/presentation/notifiers/network_demo_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NetworkDemoNotifier', () {
    test('emits loading then success and marks cache source', () async {
      final repository = FakeNetworkDemoRepository()
        ..onFetch = ({required cacheMode}) async {
          return const DemoPostsResult(
            posts: [
              DemoPostEntity(id: 1, title: 'cached-title', body: 'cached-body'),
            ],
            fromCache: true,
          );
        };
      final container = ProviderContainer(
        overrides: [
          fetchDemoPostsUseCaseProvider.overrideWithValue(
            FetchDemoPostsUseCase(repository),
          ),
        ],
      );
      addTearDown(container.dispose);

      final states = <NetworkDemoState>[];
      final subscription = container.listen<NetworkDemoState>(
        networkDemoProvider,
        (_, next) => states.add(next),
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      await container.read(networkDemoProvider.notifier).fetch();

      expect(states.any((state) => state.isLoading), isTrue);
      expect(states.last.fromCache, isTrue);
      expect(states.last.posts, const [
        DemoPostEntity(id: 1, title: 'cached-title', body: 'cached-body'),
      ]);
      expect(repository.callCount, 1);
      expect(repository.lastMode, DemoCacheMode.cacheFirst);
    });

    test(
      'returns unavailable state when full-stack dependencies are absent',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        await container.read(networkDemoProvider.notifier).fetch();

        final state = container.read(networkDemoProvider);
        expect(state.available, isFalse);
        expect(state.errorMessage, contains('ARMS_EXAMPLE_FULL_STACK=true'));
      },
    );
  });
}

class FakeNetworkDemoRepository implements INetworkDemoRepository {
  Future<DemoPostsResult> Function({required DemoCacheMode cacheMode})? onFetch;
  int callCount = 0;
  DemoCacheMode? lastMode;

  @override
  Future<DemoPostsResult> fetchPosts({required DemoCacheMode cacheMode}) async {
    callCount += 1;
    lastMode = cacheMode;
    final fetchHandler = onFetch;
    if (fetchHandler != null) {
      return fetchHandler(cacheMode: cacheMode);
    }
    throw StateError('Missing fetch stub.');
  }
}
