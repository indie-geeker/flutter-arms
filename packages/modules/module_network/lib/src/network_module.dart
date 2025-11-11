
import 'package:interfaces/cache/i_cache_manager.dart';
import 'package:interfaces/core/i_service_locator.dart';
import 'package:interfaces/core/module_registry.dart';
import 'package:interfaces/logger/i_logger.dart';
import 'package:interfaces/network/i_http_client.dart';

import 'impl/dio_http_client.dart';

/// 网络模块
class NetworkModule implements IModule {
  final String baseUrl;
  final Duration? connectTimeout;
  final Duration? receiveTimeout;

  NetworkModule({
    required this.baseUrl,
    this.connectTimeout,
    this.receiveTimeout,
  });

  @override
  String get name => 'NetworkModule';

  @override
  int get priority => InitPriorities.network; // 在日志、存储、缓存之后初始化

  @override
  List<Type> get dependencies => [ILogger, ICacheManager];

  // 保存 locator 引用以便在 init 中使用
  late IServiceLocator _locator;

  @override
  Future<void> register(IServiceLocator locator) async {
    _locator = locator;

    final logger = locator.get<ILogger>();
    final cacheManager = locator.get<ICacheManager>();

    final httpClient = DioHttpClient(
      baseUrl: baseUrl,
      logger: logger,
      cacheManager: cacheManager,  // 注入缓存管理器
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
    );

    locator.registerSingleton<IHttpClient>(httpClient);
  }

  @override
  Future<void> init() async {
    // Network initialization if needed
  }

  @override
  Future<void> dispose() async {
    final httpClient = _locator.get<IHttpClient>();
    httpClient.cancelAllRequests();
  }
}