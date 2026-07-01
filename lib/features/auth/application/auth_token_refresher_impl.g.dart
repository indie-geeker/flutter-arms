// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_token_refresher_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 远端认证 Token 刷新依赖。

@ProviderFor(authRemoteTokenRefresher)
const authRemoteTokenRefresherProvider = AuthRemoteTokenRefresherProvider._();

/// 远端认证 Token 刷新依赖。

final class AuthRemoteTokenRefresherProvider
    extends
        $FunctionalProvider<
          AuthTokenRefresher,
          AuthTokenRefresher,
          AuthTokenRefresher
        >
    with $Provider<AuthTokenRefresher> {
  /// 远端认证 Token 刷新依赖。
  const AuthRemoteTokenRefresherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRemoteTokenRefresherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRemoteTokenRefresherHash();

  @$internal
  @override
  $ProviderElement<AuthTokenRefresher> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AuthTokenRefresher create(Ref ref) {
    return authRemoteTokenRefresher(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthTokenRefresher value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthTokenRefresher>(value),
    );
  }
}

String _$authRemoteTokenRefresherHash() =>
    r'ebedfdd126829f95ae08a9a4c1ee23b8da625328';
