
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:interfaces/interfaces.dart';

import '../utils/network_utils.dart';

/// 网络请求缓存拦截器
class CacheInterceptor extends Interceptor {
  final ICacheManager _cacheManager;
  final ILogger _logger;

  CacheInterceptor(this._cacheManager, this._logger);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 只缓存 GET 请求
    if (options.method.toUpperCase() != 'GET') {
      return handler.next(options);
    }

    // 检查是否启用缓存
    final cacheEnabled = options.extra['cache_enabled'] as bool? ?? false;
    if (!cacheEnabled) {
      return handler.next(options);
    }

    // 生成缓存键
    final cacheKey = _generateCacheKey(options);

    try {
      // 尝试从缓存读取
      final cachedData = await _cacheManager.get<String>(cacheKey);
      if (cachedData != null) {
        _logger.debug('Cache hit for: ${options.uri}');

        // 返回缓存数据
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

    // 缓存未命中，继续请求
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    // 只缓存 GET 请求的成功响应
    if (response.requestOptions.method.toUpperCase() != 'GET' ||
        response.statusCode != 200) {
      return handler.next(response);
    }

    // 检查是否启用缓存
    final cacheEnabled = response.requestOptions.extra['cache_enabled'] as bool? ?? false;
    if (!cacheEnabled) {
      return handler.next(response);
    }

    // 生成缓存键
    final cacheKey = _generateCacheKey(response.requestOptions);

    try {
      // 获取缓存时长（默认 5 分钟）
      final cacheDuration = response.requestOptions.extra['cache_duration'] as Duration? ??
          Duration(minutes: 5);

      // 存储到缓存
      await _cacheManager.put(
        cacheKey,
        jsonEncode(response.data),
        duration: cacheDuration,
        policy: CachePolicy.normal,
      );

      _logger.debug('Cached response for: ${response.requestOptions.uri}');
    } catch (e) {
      _logger.warning('Failed to cache response', error: e);
    }

    handler.next(response);
  }

  /// 生成缓存键
  String _generateCacheKey(RequestOptions options) {
    // 使用 NetworkUtils 生成标准缓存键
    return NetworkUtils.generateCacheKey(
      options.uri.toString(),
      options.queryParameters,
    );
  }
}