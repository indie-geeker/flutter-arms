import 'package:app_interfaces/app_interfaces.dart';
import 'package:flutter/material.dart';

import '../app_init_config.dart';
import '../setup/network_setup.dart';

/// AppInitConfig 构建器
///
/// 使用流畅的 API 构建应用初始化配置
/// 提供合理的默认值,减少样板代码
class AppInitConfigBuilder {
  final BaseConfig _config;

  // 核心配置
  ILogger? _logger;
  Locale _defaultLocale = const Locale('zh', 'CN');
  List<Locale> _supportedLocales = const [
    Locale('zh', 'CN'),
    Locale('en', 'US'),
  ];

  // 工厂配置
  IStorageFactory? _storageFactory;

  // 网络配置
  NetworkSetup Function(INetWorkConfig config)? _networkSetup;
  final List<IErrorRecoveryStrategy> _errorRecoveryStrategies = [];
  final List<IRequestInterceptor> _interceptors = [];

  // 其他配置
  Future<String> Function()? _signatureHashProvider;
  IAppInfo Function()? _appInfoFactory;
  IThemeManager Function()? _themeFactory;

  /// 创建构建器
  AppInitConfigBuilder(this._config);

  /// 设置日志实例
  AppInitConfigBuilder withLogger(ILogger logger) {
    _logger = logger;
    return this;
  }

  /// 设置默认语言
  AppInitConfigBuilder withDefaultLocale(Locale locale) {
    _defaultLocale = locale;
    return this;
  }

  /// 设置支持的语言列表
  AppInitConfigBuilder withSupportedLocales(List<Locale> locales) {
    _supportedLocales = locales;
    return this;
  }

  /// 设置存储工厂
  AppInitConfigBuilder withStorageFactory(IStorageFactory factory) {
    _storageFactory = factory;
    return this;
  }

  /// 设置网络配置
  AppInitConfigBuilder withNetworkSetup(
    NetworkSetup Function(INetWorkConfig config) setup,
  ) {
    _networkSetup = setup;
    return this;
  }

  /// 添加错误恢复策略
  AppInitConfigBuilder addErrorRecoveryStrategy(IErrorRecoveryStrategy strategy) {
    _errorRecoveryStrategies.add(strategy);
    return this;
  }

  /// 添加多个错误恢复策略
  AppInitConfigBuilder withErrorRecoveryStrategies(
    List<IErrorRecoveryStrategy> strategies,
  ) {
    _errorRecoveryStrategies.addAll(strategies);
    return this;
  }

  /// 添加拦截器
  AppInitConfigBuilder addInterceptor(IRequestInterceptor interceptor) {
    _interceptors.add(interceptor);
    return this;
  }

  /// 添加多个拦截器
  AppInitConfigBuilder withInterceptors(List<IRequestInterceptor> interceptors) {
    _interceptors.addAll(interceptors);
    return this;
  }

  /// 设置签名哈希提供者
  AppInitConfigBuilder withSignatureHashProvider(
    Future<String> Function() provider,
  ) {
    _signatureHashProvider = provider;
    return this;
  }

  /// 设置应用信息工厂
  AppInitConfigBuilder withAppInfoFactory(IAppInfo Function() factory) {
    _appInfoFactory = factory;
    return this;
  }

  /// 设置主题管理器工厂
  AppInitConfigBuilder withThemeFactory(IThemeManager Function() factory) {
    _themeFactory = factory;
    return this;
  }

  /// 构建配置
  AppInitConfig build() {
    // 如果没有设置存储工厂,尝试从注册表获取
    IStorage Function()? storageFactory;
    if (_storageFactory != null) {
      storageFactory = () async {
        // Use config type name as storage name
        final storageName = _config.runtimeType.toString().toLowerCase();
        final factoryConfig = StorageFactoryConfig.defaults(storageName);
        return await _storageFactory!.createStorage(factoryConfig);
      } as IStorage Function()?;
    } else {
      // 使用默认的 SharedPreferences
      storageFactory = null; // AppManager 会使用默认实现
    }

    // 如果设置了拦截器或错误恢复策略,合并到 networkSetup 中
    NetworkSetup Function(INetWorkConfig config)? networkSetup = _networkSetup;
    if (_interceptors.isNotEmpty || _errorRecoveryStrategies.isNotEmpty) {
      networkSetup = (config) {
        NetworkSetup setup = _networkSetup?.call(config) ?? NetworkSetup();

        // 添加拦截器
        for (final interceptor in _interceptors) {
          setup = setup.addInterceptor(interceptor);
        }

        // 添加错误恢复策略拦截器
        if (_errorRecoveryStrategies.isNotEmpty) {
          // 需要导入 app_network 包来使用 ErrorRecoveryInterceptor
          // final errorRecoveryInterceptor = ErrorRecoveryInterceptor(
          //   strategies: _errorRecoveryStrategies,
          //   logger: _logger,
          // );
          // setup = setup.addInterceptor(errorRecoveryInterceptor);

          // 注意: 当前由于架构限制,错误恢复策略通过 RetryInterceptor 实现
          // ErrorRecoveryInterceptor 需要能够重新执行请求,这在拦截器中较难实现
        }

        return setup;
      };
    }

    return AppInitConfig(
      config: _config,
      logger: _logger,
      defaultLocale: _defaultLocale,
      supportedLocales: _supportedLocales,
      storageFactory: storageFactory,
      networkSetup: networkSetup,
      signatureHashProvider: _signatureHashProvider,
      appInfoFactory: _appInfoFactory,
      themeFactory: _themeFactory,
    );
  }
}
