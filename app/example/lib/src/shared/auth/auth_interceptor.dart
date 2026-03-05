import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_shared.dart';

/// HTTP request authentication interceptor helper.
///
/// Reads authentication credentials from the global [AuthSessionNotifier]
/// for use with NetworkModule configuration.
///
/// The example app uses local mock auth with no real token. This class
/// serves as the extension point for integrating a real backend.
///
/// After integrating real tokens, replace the body of [buildAuthHeaders]:
/// ```dart
/// return {'Authorization': 'Bearer ${session.accessToken}'};
/// ```
class AuthInterceptor {
  final Ref _ref;

  const AuthInterceptor(this._ref);

  /// Returns authentication headers for the current request.
  ///
  /// Returns `null` when not authenticated.
  /// Throws [UnimplementedError] when authenticated, because the
  /// template does not include real token logic — replace this stub
  /// with your actual token header before using in production.
  Map<String, String>? buildAuthHeaders() {
    final session = _ref.read(authSessionProvider);
    if (!session.isAuthenticated) return null;

    // TODO(auth): Replace with real token logic:
    // return {'Authorization': 'Bearer ${session.accessToken}'};
    throw UnimplementedError(
      'AuthInterceptor.buildAuthHeaders() is a stub. '
      'Replace with real token logic before using in production.',
    );
  }

  /// Whether the current session is authenticated.
  bool get isAuthenticated =>
      _ref.read(authSessionProvider).isAuthenticated;
}
