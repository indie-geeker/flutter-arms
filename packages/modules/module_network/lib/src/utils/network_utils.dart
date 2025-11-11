
import 'dart:convert';
import 'package:crypto/crypto.dart';

/// 网络工具类
class NetworkUtils {
  /// 生成缓存键
  ///
  /// 基于 URL 和查询参数生成唯一的缓存键
  static String generateCacheKey(
      String url,
      Map<String, dynamic>? queryParameters,
      ) {
    final uri = Uri.parse(url);
    final params = queryParameters ?? {};

    // 合并 URL 中的查询参数和额外的查询参数
    final allParams = Map<String, dynamic>.from(uri.queryParameters)
      ..addAll(params);

    // 按键排序以确保相同参数生成相同的键
    final sortedParams = Map.fromEntries(
      allParams.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    final baseUrl = '${uri.scheme}://${uri.host}${uri.path}';
    final paramString = sortedParams.isEmpty ? '' : jsonEncode(sortedParams);

    return 'http_cache:$baseUrl:$paramString';
  }

  /// 生成缓存键的 MD5 哈希（更短）
  static String generateCacheKeyHash(
      String url,
      Map<String, dynamic>? queryParameters,
      ) {
    final cacheKey = generateCacheKey(url, queryParameters);
    final bytes = utf8.encode(cacheKey);
    final digest = md5.convert(bytes);
    return 'http_cache:${digest.toString()}';
  }

  /// URL 拼接
  ///
  /// 安全地拼接基础 URL 和路径
  static String joinUrl(String baseUrl, String path) {
    // 移除 baseUrl 末尾的斜杠
    final base = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;

    // 确保 path 以斜杠开头
    final p = path.startsWith('/') ? path : '/$path';

    return '$base$p';
  }

  /// 序列化查询参数
  ///
  /// 将 Map 转换为 URL 查询字符串
  static String encodeQueryParameters(Map<String, dynamic> params) {
    if (params.isEmpty) return '';

    final encodedParams = params.entries.map((entry) {
      final key = Uri.encodeComponent(entry.key);
      final value = Uri.encodeComponent(entry.value.toString());
      return '$key=$value';
    }).join('&');

    return encodedParams;
  }

  /// 解析查询参数
  ///
  /// 将 URL 查询字符串转换为 Map
  static Map<String, String> decodeQueryParameters(String query) {
    if (query.isEmpty) return {};

    return Uri.splitQueryString(query);
  }

  /// 格式化文件大小
  ///
  /// 将字节数转换为人类可读的格式
  static String formatBytes(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (bytes.bitLength - 1) ~/ 10;

    if (i >= suffixes.length) {
      return '${(bytes / (1 << 40)).toStringAsFixed(decimals)} TB';
    }

    return '${(bytes / (1 << (i * 10))).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  /// 计算下载/上传进度百分比
  static double calculateProgress(int current, int total) {
    if (total <= 0) return 0.0;
    return (current / total * 100).clamp(0.0, 100.0);
  }

  /// 验证 URL 格式
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (_) {
      return false;
    }
  }

  /// 从 URL 提取文件名
  static String? extractFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      return segments.isNotEmpty ? segments.last : null;
    } catch (_) {
      return null;
    }
  }

  /// 判断是否为网络图片 URL
  static bool isNetworkImageUrl(String url) {
    if (!isValidUrl(url)) return false;

    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.jpg') ||
        lowerUrl.endsWith('.jpeg') ||
        lowerUrl.endsWith('.png') ||
        lowerUrl.endsWith('.gif') ||
        lowerUrl.endsWith('.webp') ||
        lowerUrl.endsWith('.bmp') ||
        lowerUrl.endsWith('.svg');
  }

  /// 添加查询参数到 URL
  static String addQueryParameters(
      String url,
      Map<String, dynamic> params,
      ) {
    if (params.isEmpty) return url;

    final uri = Uri.parse(url);
    final queryParams = Map<String, dynamic>.from(uri.queryParameters)
      ..addAll(params);

    return uri.replace(queryParameters: queryParams).toString();
  }
}