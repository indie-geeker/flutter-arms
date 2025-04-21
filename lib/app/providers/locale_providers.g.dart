// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentLocaleNameHash() => r'c0b7905fc3a74f4fecef4628e7a2ee1d2ec822c0';

/// 当前语言名称提供者
///
/// Copied from [currentLocaleName].
@ProviderFor(currentLocaleName)
final currentLocaleNameProvider = AutoDisposeProvider<String>.internal(
  currentLocaleName,
  name: r'currentLocaleNameProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentLocaleNameHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentLocaleNameRef = AutoDisposeProviderRef<String>;
String _$localeNotifierHash() => r'62564662cc17e67e4d71ff3b15499735e08851ba';

/// 语言设置提供者
///
/// Copied from [LocaleNotifier].
@ProviderFor(LocaleNotifier)
final localeNotifierProvider =
    AutoDisposeAsyncNotifierProvider<LocaleNotifier, Locale>.internal(
  LocaleNotifier.new,
  name: r'localeNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$localeNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LocaleNotifier = AutoDisposeAsyncNotifier<Locale>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
