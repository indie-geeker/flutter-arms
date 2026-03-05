import 'network_exception.dart';
import 'network_request.dart';
import 'network_response.dart';

/// Network interceptor abstract interface.
///
/// Intercepts requests before they are sent, responses after they are
/// received, and errors when they occur. Implement this interface to
/// customize request/response handling (e.g. adding authentication
/// headers, logging, etc.).
abstract class INetworkInterceptor {
  /// Request interceptor.
  ///
  /// Called before the request is sent. Can modify request parameters.
  /// Return the modified request, or null to cancel the request.
  Future<NetworkRequest?> onRequest(NetworkRequest request);

  /// Response interceptor.
  ///
  /// Called after the response is received and before it is returned to
  /// the caller. Can modify response data.
  /// Returns the modified response.
  Future<NetworkResponse<T>> onResponse<T>(NetworkResponse<T> response);

  /// Error interceptor.
  ///
  /// Called when a request error occurs. Can handle or transform the error.
  /// Returns the processed error, or a recovered response.
  Future<NetworkResponse<T>> onError<T>(NetworkException error);
}
