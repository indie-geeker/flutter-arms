/// Global authentication status enum.
enum AuthStatus {
  /// Initial unknown state (at app startup).
  unknown,

  /// Authenticated.
  authenticated,

  /// Unauthenticated (logged out or never logged in).
  unauthenticated,
}
