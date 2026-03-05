import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'auth_session.dart';
import 'auth_status.dart';

part 'auth_session_notifier.g.dart';

/// Global authentication session state manager.
///
/// Single source of truth for cross-feature authentication state.
///
/// **Writers**: `features/authentication` calls this notifier after login/logout.
/// **Readers**: other features and route guards access via `ref.watch/read(authSessionNotifierProvider)`.
///
/// Usage example:
/// ```dart
/// // After login success (in login_notifier):
/// ref.read(authSessionNotifierProvider.notifier).setAuthenticated(
///   userId: user.id,
///   username: user.username,
/// );
///
/// // Read current auth state (in any feature):
/// final session = ref.watch(authSessionNotifierProvider);
/// if (session.isAuthenticated) { ... }
/// ```
@Riverpod(keepAlive: true)
class AuthSessionNotifier extends _$AuthSessionNotifier {
  @override
  AuthSession build() => const AuthSession();

  /// Sets state to authenticated (called after login success).
  void setAuthenticated({
    required String userId,
    required String username,
  }) {
    state = AuthSession(
      status: AuthStatus.authenticated,
      userId: userId,
      username: username,
    );
  }

  /// Sets state to unauthenticated (called after logout or session expiry).
  void setUnauthenticated() {
    state = const AuthSession(status: AuthStatus.unauthenticated);
  }
}
