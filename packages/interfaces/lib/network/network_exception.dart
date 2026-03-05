/// Network exception type.
enum NetworkExceptionType {
  /// Timeout.
  timeout,

  /// No internet connection.
  noInternet,

  /// Server error (4xx, 5xx).
  serverError,

  /// Request cancelled.
  cancelled,

  /// Parse error.
  parseError,

  /// Unknown error.
  unknown,
}

/// Network exception.
class NetworkException implements Exception {
  /// Error message.
  final String message;

  /// Exception type.
  final NetworkExceptionType type;

  /// HTTP status code.
  final int? statusCode;

  /// Original error object.
  final dynamic originalError;

  NetworkException({
    required this.message,
    required this.type,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() {
    return 'NetworkException: $message (type: $type, statusCode: $statusCode)';
  }

  /// Whether this is a client error (4xx).
  bool get isClientError =>
      statusCode != null && statusCode! >= 400 && statusCode! < 500;

  /// Whether this is a server error (5xx).
  bool get isServerError =>
      statusCode != null && statusCode! >= 500 && statusCode! < 600;

  /// Whether this is a timeout error.
  bool get isTimeout => type == NetworkExceptionType.timeout;

  /// Whether this is a connection error.
  bool get isConnectionError => type == NetworkExceptionType.noInternet;
}
