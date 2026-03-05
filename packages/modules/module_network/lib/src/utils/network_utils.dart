import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Network utilities.
class NetworkUtils {
  /// Generates a cache key.
  ///
  /// Generates a unique cache key based on URL and query parameters.
  static String generateCacheKey(
    String url,
    Map<String, dynamic>? queryParameters,
  ) {
    final uri = Uri.parse(url);
    final params = queryParameters ?? {};

    // Merge query parameters from the URL and additional parameters.
    final allParams = Map<String, dynamic>.from(uri.queryParameters)
      ..addAll(params);

    // Sort by key to ensure identical parameters produce the same key.
    final sortedParams = Map.fromEntries(
      allParams.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    final baseUrl = '${uri.scheme}://${uri.host}${uri.path}';
    final paramString = sortedParams.isEmpty ? '' : jsonEncode(sortedParams);

    return 'http_cache:$baseUrl:$paramString';
  }

  /// Generates an MD5 hash of the cache key (shorter).
  static String generateCacheKeyHash(
    String url,
    Map<String, dynamic>? queryParameters,
  ) {
    final cacheKey = generateCacheKey(url, queryParameters);
    final bytes = utf8.encode(cacheKey);
    final digest = md5.convert(bytes);
    return 'http_cache:${digest.toString()}';
  }

  /// URL joining.
  ///
  /// Safely joins a base URL and path.
  static String joinUrl(String baseUrl, String path) {
    // Remove trailing slash from baseUrl.
    final base = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    // Ensure path starts with a slash.
    final p = path.startsWith('/') ? path : '/$path';

    return '$base$p';
  }

  /// Serializes query parameters.
  ///
  /// Converts a Map to a URL query string.
  static String encodeQueryParameters(Map<String, dynamic> params) {
    if (params.isEmpty) return '';

    final encodedParams = params.entries
        .map((entry) {
          final key = Uri.encodeComponent(entry.key);
          final value = Uri.encodeComponent(entry.value.toString());
          return '$key=$value';
        })
        .join('&');

    return encodedParams;
  }

  /// Parses query parameters.
  ///
  /// Converts a URL query string to a Map.
  static Map<String, String> decodeQueryParameters(String query) {
    if (query.isEmpty) return {};

    return Uri.splitQueryString(query);
  }

  /// Formats a file size.
  ///
  /// Converts bytes to a human-readable format.
  static String formatBytes(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (bytes.bitLength - 1) ~/ 10;

    if (i >= suffixes.length) {
      return '${(bytes / (1 << 40)).toStringAsFixed(decimals)} TB';
    }

    return '${(bytes / (1 << (i * 10))).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  /// Calculates download/upload progress percentage.
  static double calculateProgress(int current, int total) {
    if (total <= 0) return 0.0;
    return (current / total * 100).clamp(0.0, 100.0);
  }

  /// Validates a URL format.
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (_) {
      return false;
    }
  }

  /// Extracts a filename from a URL.
  static String? extractFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      return segments.isNotEmpty ? segments.last : null;
    } catch (_) {
      return null;
    }
  }

  /// Determines whether a URL is a network image URL.
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

  /// Adds query parameters to a URL.
  static String addQueryParameters(String url, Map<String, dynamic> params) {
    if (params.isEmpty) return url;

    final uri = Uri.parse(url);
    final queryParams = Map<String, String>.from(uri.queryParameters)
      ..addEntries(
        params.entries.map(
          (entry) => MapEntry(entry.key, entry.value.toString()),
        ),
      );

    return uri.replace(queryParameters: queryParams).toString();
  }
}
