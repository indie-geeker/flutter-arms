import 'package:freezed_annotation/freezed_annotation.dart';
import 'auth_status.dart';

part 'auth_session.freezed.dart';

/// Global authentication session model (immutable).
///
/// Stores cross-feature shared session info such as user identity and auth status.
/// Managed by [AuthSessionNotifier]; other features access via watch/read.
@freezed
abstract class AuthSession with _$AuthSession {
  const factory AuthSession({
    /// Current authentication status.
    @Default(AuthStatus.unknown) AuthStatus status,

    /// Current user ID (null when unauthenticated).
    String? userId,

    /// Current username (null when unauthenticated).
    String? username,

    // If a real backend token is added later, add it here:
    // String? accessToken,
    // DateTime? tokenExpiry,
  }) = _AuthSession;
}

/// Extension methods.
extension AuthSessionX on AuthSession {
  /// Whether authenticated.
  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// Whether in initial unknown state (at app startup).
  bool get isUnknown => status == AuthStatus.unknown;
}
