import 'package:dio/dio.dart' as dio;
import 'package:interfaces/interfaces.dart';

import 'dio_cancel_token_adapter.dart';

/// Manages active [dio.CancelToken]s for batch cancellation.
///
/// Converts framework-level [CancelToken] instances to Dio-level tokens,
/// tracks them while requests are in-flight, and supports bulk cancellation.
class CancelTokenManager {
  final Set<dio.CancelToken> _activeTokens = {};
  final ILogger _logger;

  CancelTokenManager(this._logger);

  /// Converts a framework [CancelToken] to a Dio cancel token and tracks it.
  ///
  /// If [token] is null, a new Dio token is created for tracking purposes.
  dio.CancelToken trackToken(CancelToken? token) {
    dio.CancelToken dioToken;

    if (token == null) {
      dioToken = dio.CancelToken();
    } else if (token is DioCancelTokenAdapter) {
      dioToken = token.dioToken;
    } else {
      // Adapt non-Dio CancelToken implementations
      dioToken = dio.CancelToken();
      if (token.isCancelled) {
        dioToken.cancel('Cancelled before request');
      } else {
        token.addListener((reason) {
          if (!dioToken.isCancelled) {
            dioToken.cancel(reason);
          }
        });
      }
    }

    _activeTokens.add(dioToken);
    return dioToken;
  }

  /// Removes [token] from active tracking (call after request completes).
  void untrack(dio.CancelToken? token) {
    if (token != null) {
      _activeTokens.remove(token);
    }
  }

  /// Cancels all tracked requests and clears the active set.
  void cancelAll() {
    _logger.info('Cancelling ${_activeTokens.length} active network requests');
    for (final token in _activeTokens.toList()) {
      if (!token.isCancelled) {
        token.cancel('Cancelled by cancelAllRequests()');
      }
    }
    _activeTokens.clear();
  }
}
