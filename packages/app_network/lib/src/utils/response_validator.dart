import 'package:app_interfaces/app_interfaces.dart';
import 'package:dio/dio.dart' hide ResponseType;

/// Validator for response content type
class ResponseValidator {
  /// Validate response content type against expected type
  static void validateContentType(
      Response response,
      ResponseType expectedType, {
        required bool strict,
      }) {
    if (!strict) return;

    final contentType = response.headers['content-type']?.first;
    if (contentType == null) return;

    final isValid = _isCompatible(contentType, expectedType);
    if (!isValid) {
      throw NetworkException(
        message: 'Response content-type mismatch: '
            'expected ${expectedType.name}, got $contentType',
        code: 'content_type_mismatch',
        statusCode: response.statusCode,
      );
    }
  }

  static bool _isCompatible(String actualType, ResponseType expectedType) {
    final baseMime = actualType.split(';').first.trim().toLowerCase();

    switch (expectedType) {
      case ResponseType.json:
        return baseMime.contains('json');
      case ResponseType.string:
        return baseMime.contains('text') || baseMime.contains('html');
      case ResponseType.bytes:
        return true; // Bytes can handle any type
    }
  }
}