// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_env.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 应用环境 Provider。bootstrap 时通过 override 注入。

@ProviderFor(appEnv)
const appEnvProvider = AppEnvProvider._();

/// 应用环境 Provider。bootstrap 时通过 override 注入。

final class AppEnvProvider extends $FunctionalProvider<AppEnv, AppEnv, AppEnv>
    with $Provider<AppEnv> {
  /// 应用环境 Provider。bootstrap 时通过 override 注入。
  const AppEnvProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appEnvProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appEnvHash();

  @$internal
  @override
  $ProviderElement<AppEnv> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppEnv create(Ref ref) {
    return appEnv(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppEnv value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppEnv>(value),
    );
  }
}

String _$appEnvHash() => r'51a0d17e3a7750c994e294ed23370efd32f6f823';
