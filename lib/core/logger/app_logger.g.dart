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
    extends $FunctionalProvider<AppLog, AppLog, AppLog>
    with $Provider<AppLog> {
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
  $ProviderElement<AppLog> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppLog create(Ref ref) {
    return appLogger(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppLog value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppLog>(value),
    );
  }
}

String _$appLoggerHash() => r'8e0a6862172f1b2117935e7b188d7144f0af9480';
