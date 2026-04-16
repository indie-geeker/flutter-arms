// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 全局语言状态管理。

@ProviderFor(LocaleNotifier)
const localeProvider = LocaleNotifierProvider._();

/// 全局语言状态管理。
final class LocaleNotifierProvider
    extends $NotifierProvider<LocaleNotifier, AppLocale> {
  /// 全局语言状态管理。
  const LocaleNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localeNotifierHash();

  @$internal
  @override
  LocaleNotifier create() => LocaleNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppLocale value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppLocale>(value),
    );
  }
}

String _$localeNotifierHash() => r'5287ed9512a68f9151a4b24dada520c4e470e96f';

/// 全局语言状态管理。

abstract class _$LocaleNotifier extends $Notifier<AppLocale> {
  AppLocale build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AppLocale, AppLocale>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppLocale, AppLocale>,
              AppLocale,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
