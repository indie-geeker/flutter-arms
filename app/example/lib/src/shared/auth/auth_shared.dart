/// shared/auth — Cross-feature authentication state layer
///
/// Provides global auth state model and manager, shared by features and route guards.
///
/// **Dependency direction**: features/ → shared/auth → di/ → packages/.
library;

export 'auth_status.dart';
export 'auth_session.dart';
export 'auth_session_notifier.dart';
export 'auth_interceptor.dart';
