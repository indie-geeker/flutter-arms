import '../entities/demo_post_entity.dart';

enum DemoCacheMode {
  cacheFirst,
  networkFirst,
  disabled,
}

class DemoPostsResult {
  final List<DemoPostEntity> posts;
  final bool fromCache;

  const DemoPostsResult({
    required this.posts,
    required this.fromCache,
  });
}

abstract class INetworkDemoRepository {
  Future<DemoPostsResult> fetchPosts({required DemoCacheMode cacheMode});
}
