// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kv_storage.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 存储依赖注入。

@ProviderFor(kvStorage)
const kvStorageProvider = KvStorageProvider._();

/// 存储依赖注入。

final class KvStorageProvider
    extends $FunctionalProvider<KvStorage, KvStorage, KvStorage>
    with $Provider<KvStorage> {
  /// 存储依赖注入。
  const KvStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kvStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kvStorageHash();

  @$internal
  @override
  $ProviderElement<KvStorage> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  KvStorage create(Ref ref) {
    return kvStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KvStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KvStorage>(value),
    );
  }
}

String _$kvStorageHash() => r'69fa86c5f40ac7717549ffcd55bc931fac0926e9';
