// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dio_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 无 Token 拦截器的 Dio，专门用于 `/auth/refresh` 等不需要鉴权的端点，
/// 避免 `TokenInterceptor` 在刷新过程中自调用造成递归。

@ProviderFor(authRefreshDio)
const authRefreshDioProvider = AuthRefreshDioProvider._();

/// 无 Token 拦截器的 Dio，专门用于 `/auth/refresh` 等不需要鉴权的端点，
/// 避免 `TokenInterceptor` 在刷新过程中自调用造成递归。

final class AuthRefreshDioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// 无 Token 拦截器的 Dio，专门用于 `/auth/refresh` 等不需要鉴权的端点，
  /// 避免 `TokenInterceptor` 在刷新过程中自调用造成递归。
  const AuthRefreshDioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRefreshDioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRefreshDioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return authRefreshDio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$authRefreshDioHash() => r'923c8ad230e12c66639fcebfff3604b728f3480b';

/// 刷新专用的数据源。仅用于 `TokenInterceptor.refreshAction`。

@ProviderFor(authRefreshDataSource)
const authRefreshDataSourceProvider = AuthRefreshDataSourceProvider._();

/// 刷新专用的数据源。仅用于 `TokenInterceptor.refreshAction`。

final class AuthRefreshDataSourceProvider
    extends
        $FunctionalProvider<
          AuthRemoteDataSource,
          AuthRemoteDataSource,
          AuthRemoteDataSource
        >
    with $Provider<AuthRemoteDataSource> {
  /// 刷新专用的数据源。仅用于 `TokenInterceptor.refreshAction`。
  const AuthRefreshDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRefreshDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRefreshDataSourceHash();

  @$internal
  @override
  $ProviderElement<AuthRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AuthRemoteDataSource create(Ref ref) {
    return authRefreshDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRemoteDataSource>(value),
    );
  }
}

String _$authRefreshDataSourceHash() =>
    r'c53bb176047e1f32e16e3e9630c76adc2f053dbe';

/// 主 Dio 客户端：注入 Token，自动刷新，统一错误拦截。

@ProviderFor(dio)
const dioProvider = DioProvider._();

/// 主 Dio 客户端：注入 Token，自动刷新，统一错误拦截。

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// 主 Dio 客户端：注入 Token，自动刷新，统一错误拦截。
  const DioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioHash() => r'bf70faf3584dd0a1d250bd95188c8a436ee91596';
