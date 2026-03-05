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
  final String? Function(AuthSession session)? _tokenResolver;

  const AuthInterceptor(this._ref, {
    String? Function(AuthSession session)? tokenResolver,
  }) : _tokenResolver = tokenResolver;

  /// Returns authentication headers for the current request.
  ///
  /// Returns `null` when not authenticated or token is unavailable.
  Map<String, String>? buildAuthHeaders() {
    final session = _ref.read(authSessionProvider);
    if (!session.isAuthenticated) return null;

    final token = _tokenResolver?.call(session);
    if (token == null || token.trim().isEmpty) {
      return null;
    }

    return <String, String>{'Authorization': 'Bearer ${token.trim()}'};
  }

  /// Whether the current session is authenticated.
  bool get isAuthenticated =>
      _ref.read(authSessionProvider).isAuthenticated;
}
