// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_client_auth_remote_datasource_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ApiClient 认证远程数据源依赖：适合作为长期替换网络库的对照接线。

@ProviderFor(apiClientAuthRemoteDataSource)
const apiClientAuthRemoteDataSourceProvider =
    ApiClientAuthRemoteDataSourceProvider._();

/// ApiClient 认证远程数据源依赖：适合作为长期替换网络库的对照接线。

final class ApiClientAuthRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          AuthRemoteDataSource,
          AuthRemoteDataSource,
          AuthRemoteDataSource
        >
    with $Provider<AuthRemoteDataSource> {
  /// ApiClient 认证远程数据源依赖：适合作为长期替换网络库的对照接线。
  const ApiClientAuthRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiClientAuthRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiClientAuthRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<AuthRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AuthRemoteDataSource create(Ref ref) {
    return apiClientAuthRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRemoteDataSource>(value),
    );
  }
}

String _$apiClientAuthRemoteDataSourceHash() =>
    r'd17fb19cacc8464d7a4ce8295861fb382cd84ec2';
