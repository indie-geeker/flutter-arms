import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:interfaces/interfaces.dart';

import '../utils/network_utils.dart';

/// Network request cache interceptor.
///
/// Cache configuration is passed via [NetworkCacheOptions].
class CacheInterceptor extends Interceptor {
  final ICacheManager _cacheManager;
  final ILogger _logger;
  final Duration _defaultDuration;

  CacheInterceptor(
    this._cacheManager,
    this._logger, {
    Duration defaultDuration = const Duration(minutes: 5),
  }) : _defaultDuration = defaultDuration;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Only cache GET requests.
    if (options.method.toUpperCase() != 'GET') {
      return handler.next(options);
    }

    final cacheOptions =
        options.extra[NetworkCacheOptions.extraKey] as NetworkCacheOptions?;
    if (cacheOptions == null || !cacheOptions.enabled) {
      return handler.next(options);
    }

    // networkFirst: skip pre-request cache read, prefer network.
    if (cacheOptions.policy == CachePolicy.networkFirst) {
      return handler.next(options);
    }

    // Generate cache key.
    final cacheKey = _resolveCacheKey(options, cacheOptions);

    try {
      // Try reading from cache.
      final cachedData = await _cacheManager.get<String>(cacheKey);
      if (cachedData != null) {
        _logger.debug('Cache hit for: ${options.uri}');

        // Return cached data.
        return handler.resolve(
          Response(
            requestOptions: options,
            data: jsonDecode(cachedData),
            statusCode: 200,
            extra: {'from_cache': true},
          ),
        );
      }
    } catch (e) {
      _logger.warning('Failed to read cache', error: e);
    }

    // Cache miss, proceed with request.
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    if (request.method.toUpperCase() != 'GET') {
      return handler.next(err);
    }

    final cacheOptions =
        request.extra[NetworkCacheOptions.extraKey] as NetworkCacheOptions?;
    if (cacheOptions == null ||
        !cacheOptions.enabled ||
        cacheOptions.policy != CachePolicy.networkFirst) {
      return handler.next(err);
    }

    final cacheKey = _resolveCacheKey(request, cacheOptions);
    try {
      final cachedData = await _cacheManager.get<String>(cacheKey);
      if (cachedData != null) {
        _logger.warning(
          'Network failed, fallback to cache for: ${request.uri}',
          error: err,
        );
        return handler.resolve(
          Response(
            requestOptions: request,
            data: jsonDecode(cachedData),
            statusCode: 200,
            extra: {'from_cache': true},
          ),
        );
      }
    } catch (e) {
      _logger.warning('Failed to load fallback cache', error: e);
    }

    handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    // Only cache successful GET responses.
    if (response.requestOptions.method.toUpperCase() != 'GET' ||
        response.statusCode != 200) {
      return handler.next(response);
    }

    final cacheOptions =
        response.requestOptions.extra[NetworkCacheOptions.extraKey]
            as NetworkCacheOptions?;
    if (cacheOptions == null || !cacheOptions.enabled) {
      return handler.next(response);
    }

    // Generate cache key.
    final cacheKey = _resolveCacheKey(response.requestOptions, cacheOptions);

    try {
      // Get cache duration (falls back to client default).
      final cacheDuration = cacheOptions.duration ?? _defaultDuration;

      final encoded = _encodeResponseData(response.data);
      if (encoded == null) {
        _logger.warning(
          'Skip caching non-JSON response for: ${response.requestOptions.uri}',
        );
        return handler.next(response);
      }

      // Store in cache.
      await _cacheManager.put(
        cacheKey,
        encoded,
        duration: cacheDuration,
        policy: cacheOptions.policy,
      );

      _logger.debug('Cached response for: ${response.requestOptions.uri}');
    } catch (e) {
      _logger.warning('Failed to cache response', error: e);
    }

    handler.next(response);
  }

  String _resolveCacheKey(
    RequestOptions options,
    NetworkCacheOptions cacheOptions,
  ) {
    if (cacheOptions.cacheKey != null) {
      return cacheOptions.cacheKey!;
    }
    if (cacheOptions.useHashKey) {
      return NetworkUtils.generateCacheKeyHash(
        options.uri.toString(),
        options.queryParameters,
      );
    }
    return NetworkUtils.generateCacheKey(
      options.uri.toString(),
      options.queryParameters,
    );
  }

  String? _encodeResponseData(dynamic data) {
    try {
      return jsonEncode(data);
    } catch (_) {
      return null;
    }
  }
}
