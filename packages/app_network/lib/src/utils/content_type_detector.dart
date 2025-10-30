import 'package:app_interfaces/app_interfaces.dart';
import 'package:dio/dio.dart';

/// Utility for detecting content type from request data
class ContentTypeDetector {
  /// Detect content type from request data
  static ContentType detect(dynamic data) {
    if (data == null) {
      return ContentType.json;
    }

    if (data is String) {
      return ContentType.text;
    }

    if (data is Map || data is List) {
      return ContentType.json;
    }

    if (data is FormData) {
      return ContentType.multipart;
    }

    if (data is List<int>) {
      return ContentType.binary;
    }

    // Default to JSON for complex objects
    return ContentType.json;
  }

  /// Get appropriate charset for content type
  static String getCharset(ContentType type, String? customCharset) {
    return customCharset ?? 'utf-8';
  }
}