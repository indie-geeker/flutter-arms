import 'package:example/src/shared/auth/auth_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _interceptorProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor(ref);
});

final _emptyTokenInterceptorProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor(ref, tokenResolver: (_) => '');
});

final _tokenInterceptorProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor(ref, tokenResolver: (_) => 'token-123');
});

void main() {
  group('AuthInterceptor', () {
    test('returns null when unauthenticated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final interceptor = container.read(_interceptorProvider);
      expect(interceptor.buildAuthHeaders(), isNull);
    });

    test('returns null when authenticated but no token resolver configured', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(authSessionProvider.notifier).setAuthenticated(
            userId: 'u-1',
            username: 'alice',
          );

      final interceptor = container.read(_interceptorProvider);
      expect(interceptor.buildAuthHeaders(), isNull);
    });

    test('returns null when resolver returns empty token', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(authSessionProvider.notifier).setAuthenticated(
            userId: 'u-1',
            username: 'alice',
          );

      final interceptor = container.read(_emptyTokenInterceptorProvider);

      expect(interceptor.buildAuthHeaders(), isNull);
    });

    test('returns bearer header when resolver returns token', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(authSessionProvider.notifier).setAuthenticated(
            userId: 'u-1',
            username: 'alice',
          );

      final interceptor = container.read(_tokenInterceptorProvider);

      expect(
        interceptor.buildAuthHeaders(),
        equals(<String, String>{'Authorization': 'Bearer token-123'}),
      );
    });
  });
}
