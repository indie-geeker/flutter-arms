// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_token_refresher.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Token 刷新端口依赖。

@ProviderFor(authTokenRefresher)
const authTokenRefresherProvider = AuthTokenRefresherProvider._();

/// Token 刷新端口依赖。

final class AuthTokenRefresherProvider
    extends
        $FunctionalProvider<
          AuthTokenRefresher,
          AuthTokenRefresher,
          AuthTokenRefresher
        >
    with $Provider<AuthTokenRefresher> {
  /// Token 刷新端口依赖。
  const AuthTokenRefresherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authTokenRefresherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authTokenRefresherHash();

  @$internal
  @override
  $ProviderElement<AuthTokenRefresher> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AuthTokenRefresher create(Ref ref) {
    return authTokenRefresher(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthTokenRefresher value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthTokenRefresher>(value),
    );
  }
}

String _$authTokenRefresherHash() =>
    r'c8a5b585da953f6fcc57de6e7b20923bb7f26de5';
