// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dev_log_viewer.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 开发日志面板入口依赖。

@ProviderFor(devLogViewer)
const devLogViewerProvider = DevLogViewerProvider._();

/// 开发日志面板入口依赖。

final class DevLogViewerProvider
    extends $FunctionalProvider<DevLogViewer, DevLogViewer, DevLogViewer>
    with $Provider<DevLogViewer> {
  /// 开发日志面板入口依赖。
  const DevLogViewerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'devLogViewerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$devLogViewerHash();

  @$internal
  @override
  $ProviderElement<DevLogViewer> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DevLogViewer create(Ref ref) {
    return devLogViewer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DevLogViewer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DevLogViewer>(value),
    );
  }
}

String _$devLogViewerHash() => r'c242743d3c9964dc0b251857a70231b508280113';
