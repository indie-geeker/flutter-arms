import 'package:core/core.dart' show ServiceLocator;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interfaces/analytics/i_analytics.dart';
import 'package:interfaces/crash/i_crash_reporter.dart';
import 'package:interfaces/logger/i_logger.dart';
import 'package:interfaces/storage/i_kv_storage.dart';
import 'package:interfaces/cache/i_cache_manager.dart';
import 'package:interfaces/network/i_http_client.dart';

/// Infrastructure provider bridge (GetIt → Riverpod).
///
/// Bridges infrastructure services registered in GetIt to Riverpod providers,
/// so that the feature layer can access infrastructure services via ref.watch.
final loggerProvider = Provider<ILogger>((ref) {
  return ServiceLocator().get<ILogger>();
});

final kvStorageProvider = Provider<IKeyValueStorage>((ref) {
  return ServiceLocator().get<IKeyValueStorage>();
});

final cacheManagerProvider = Provider<ICacheManager>((ref) {
  return ServiceLocator().get<ICacheManager>();
});

final httpClientProvider = Provider<IHttpClient>((ref) {
  return ServiceLocator().get<IHttpClient>();
});

final analyticsProvider = Provider<IAnalytics>((ref) {
  return ServiceLocator().get<IAnalytics>();
});

final crashReporterProvider = Provider<ICrashReporter>((ref) {
  return ServiceLocator().get<ICrashReporter>();
});

final fullStackDemoAvailableProvider = Provider<bool>((ref) {
  final locator = ServiceLocator();
  return locator.isRegistered<IHttpClient>() &&
      locator.isRegistered<ICacheManager>();
});
