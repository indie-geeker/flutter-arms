import '../repositories/i_network_demo_repository.dart';

class FetchDemoPostsUseCase {
  final INetworkDemoRepository _repository;

  const FetchDemoPostsUseCase(this._repository);

  Future<DemoPostsResult> call({required DemoCacheMode cacheMode}) {
    return _repository.fetchPosts(cacheMode: cacheMode);
  }
}
