// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_logger.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 日志依赖注入。根据 `appEnvProvider.enableLog` 决定是否启用。

@ProviderFor(appLogger)
const appLoggerProvider = AppLoggerProvider._();

/// 日志依赖注入。根据 `appEnvProvider.enableLog` 决定是否启用。

final class AppLoggerProvider
    extends $FunctionalProvider<Talker, Talker, Talker>
    with $Provider<Talker> {
  /// 日志依赖注入。根据 `appEnvProvider.enableLog` 决定是否启用。
  const AppLoggerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLoggerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLoggerHash();

  @$internal
  @override
  $ProviderElement<Talker> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Talker create(Ref ref) {
    return appLogger(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Talker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Talker>(value),
    );
  }
}

String _$appLoggerHash() => r'4d294512150d518579b6e6b875e7354029ee4ccf';
