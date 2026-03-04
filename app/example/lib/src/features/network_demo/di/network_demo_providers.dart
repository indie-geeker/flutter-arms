import 'package:core/core.dart' show ServiceLocator;
import 'package:example/src/di/providers.dart';
import 'package:example/src/features/network_demo/data/datasources/network_demo_datasource.dart';
import 'package:example/src/features/network_demo/data/repositories/network_demo_repository_impl.dart';
import 'package:example/src/features/network_demo/domain/repositories/i_network_demo_repository.dart';
import 'package:example/src/features/network_demo/domain/usecases/fetch_demo_posts_usecase.dart';
import 'package:interfaces/cache/i_cache_manager.dart';
import 'package:interfaces/network/i_http_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_demo_providers.g.dart';

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

@riverpod
FetchDemoPostsUseCase? fetchDemoPostsUseCase(Ref ref) {
  final repository = ref.watch(networkDemoRepositoryProvider);
  if (repository == null) {
    return null;
  }
  return FetchDemoPostsUseCase(repository);
}
