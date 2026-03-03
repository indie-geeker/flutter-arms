import 'package:interfaces/core/module_registry.dart';
import 'package:interfaces/logger/log_level.dart';
import 'package:module_cache/module_cache.dart';
import 'package:module_logger/module_logger.dart';
import 'package:module_network/module_network.dart';
import 'package:module_storage/storage.dart';

import 'module_profile.dart';

List<IModule> buildBootstrapModules({
  bool enableFullStackProfile = kEnableFullStackProfile,
}) {
  final modules = <IModule>[
    LoggerModule(initialLevel: LogLevel.debug),
    StorageModule(),
  ];

  if (enableFullStackProfile) {
    modules.addAll([
      CacheModule(),
      NetworkModule(
        baseUrl: 'https://jsonplaceholder.typicode.com',
        enableCache: true,
        connectTimeout: const Duration(seconds: 30),
      ),
    ]);
  }

  return modules;
}
