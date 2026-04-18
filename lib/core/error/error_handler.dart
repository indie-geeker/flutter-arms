import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod 全局观察器。
final class AppProviderObserver extends ProviderObserver {
  /// 构造函数。
  const AppProviderObserver();

  @override
  void didAddProvider(
    ProviderObserverContext context,
    Object? value,
  ) {
    if (kDebugMode) {
      debugPrint(
        '[Provider+] ${context.provider.name ?? context.provider.runtimeType} '
        '= $value',
      );
    }
    super.didAddProvider(context, value);
  }

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    if (kDebugMode) {
      debugPrint(
        '[Provider] ${context.provider.name ?? context.provider.runtimeType} '
        '$previousValue -> $newValue',
      );
    }
    super.didUpdateProvider(context, previousValue, newValue);
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    if (kDebugMode) {
      debugPrint(
        '[Provider-] ${context.provider.name ?? context.provider.runtimeType}',
      );
    }
    super.didDisposeProvider(context);
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    if (kDebugMode) {
      debugPrint(
        '[Provider!] ${context.provider.name ?? context.provider.runtimeType} '
        'failed: $error',
      );
    }
    super.providerDidFail(context, error, stackTrace);
  }
}
