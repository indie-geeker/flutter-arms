// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_session.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 当前缓存用户。

@ProviderFor(cachedCurrentUser)
const cachedCurrentUserProvider = CachedCurrentUserProvider._();

/// 当前缓存用户。

final class CachedCurrentUserProvider
    extends $FunctionalProvider<User?, User?, User?>
    with $Provider<User?> {
  /// 当前缓存用户。
  const CachedCurrentUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cachedCurrentUserProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cachedCurrentUserHash();

  @$internal
  @override
  $ProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  User? create(Ref ref) {
    return cachedCurrentUser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(User? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<User?>(value),
    );
  }
}

String _$cachedCurrentUserHash() => r'2634e621ef14877eb78ece19857c499248b82542';
