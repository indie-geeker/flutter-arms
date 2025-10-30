import 'package:app_interfaces/app_interfaces.dart';

class CachePolicyResolver implements ICachePolicyResolver {
  @override
  CacheDecision resolve<T>({
    required CachePolicy policy,
    required RequestOptions options,
    ApiResponse<T>? cachedResponse,
    bool isCacheExpired = false,
    bool isCacheStale = false,
  }) {
    // Handle force refresh
    if (options.extra['force_refresh'] == true) {
      return CacheDecision.networkOnly;
    }

    // Handle modifying methods
    if (_isModifyingMethod(options.method)) {
      return CacheDecision.networkOnly;
    }

    switch (policy) {
      case CachePolicy.networkOnly:
        return CacheDecision.networkOnly;

      case CachePolicy.cacheOnly:
        return CacheDecision.cacheOnly;

      case CachePolicy.cacheFirst:
      // If cache exists and not expired, use it; otherwise fetch
        if (cachedResponse != null && !isCacheExpired) {
          return const CacheDecision(
            useCache: true,
            fetchFromNetwork: false,
            updateCache: false,
          );
        }
        return CacheDecision.networkFirst;

      case CachePolicy.networkFirst:
      // Always try network first, use cache as fallback
        return const CacheDecision(
          useCache: false,
          fetchFromNetwork: true,
          updateCache: true,
        );

      case CachePolicy.cacheAndNetwork:
      // Return cache immediately, fetch network in background
        return CacheDecision.cacheAndNetwork;
    }
  }

  bool _isModifyingMethod(RequestMethod method) {
    return method == RequestMethod.post ||
        method == RequestMethod.put ||
        method == RequestMethod.delete ||
        method == RequestMethod.patch;
  }
}