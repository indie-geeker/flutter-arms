import 'package:app_interfaces/app_interfaces.dart';
import 'package:app_network/app_network.dart';
import 'package:app_storage/app_storage.dart';
import 'package:flutter/foundation.dart';

import 'app_info.dart';
import 'app_init_config.dart';
import 'app_initializer.dart';
import 'builders/network_client_builder.dart';
import 'constants/init_priorities.dart';

/// 应用核心实现
///
/// 统一管理应用的核心功能，包括初始化、环境配置、主题、国际化、路由、存储、网络和状态管理等

class AppManager {
  /// 应用信息
  IAppInfo? _appInfo;

  /// 应用初始化器
  AppInitializer? _appInitializer;

  /// 环境配置
  IEnvironmentConfig? _environmentConfig;

  /// 应用主题
  IThemeManager? _themeManager;

  /// 尝试获取主题管理器（可能为 null）
  IThemeManager? get themeManager => _themeManager;

  /// 应用国际化
  II18nDelegate? _i18n;

  /// 尝试获取国际化代理（可能为 null）
  II18nDelegate? get i18n => _i18n;
  //
  // /// 路由模块
  // late final IRouter _router;
  //
  // /// 网络模块
  late final INetworkClient _networkClient;
  //
  /// 存储模块（支持多种存储类型）
  final Map<Type, IStorage> _storages = {};
  //
  // /// 状态管理模块
  // late final IAppState _stateContainer;

  /// 公共构造函数，支持直接实例化
  AppManager();

  /// 应用信息接口
  IAppInfo get appInfo => _appInfo!;

  /// 应用初始化器接口
  IAppInitializer get appInitializer => _appInitializer!;

  /// 环境配置接口
  IEnvironmentConfig get environmentConfig => _environmentConfig!;

  //
  // /// 应用国际化
  // AppLocalizations get appLocalizations => _appLocalizations;
  //
  // /// 路由接口
  // IRouter get router => _router;
  //
  // /// 网络接口
  INetworkClient get networkClient => _networkClient;

  /// 注册存储实例
  ///
  /// 支持注册多个不同类型的存储实例，如 SharedPreferences、SecureStorage 等
  /// 会同时注册具体类型和其运行时类型
  void registerStorage<T extends IStorage>(T storage) {
    // 注册泛型类型
    _storages[T] = storage;
    // 同时注册运行时类型，确保可以通过具体类型获取
    _storages[storage.runtimeType] = storage;
  }

  /// 获取指定类型的存储实例
  ///
  /// 类型安全的存储访问方法，支持同时使用多种存储类型
  /// 如果未注册指定类型，则抛出 StateError
  T getStorage<T extends IStorage>() {
    final storage = _storages[T];
    if (storage == null) {
      throw StateError(
        'Storage type $T not registered. '
        'Please register it using registerStorage<$T>() before accessing.'
      );
    }
    return storage as T;
  }

  /// 尝试获取指定类型的存储实例
  ///
  /// 如果未注册指定类型，返回 null 而不是抛出异常
  T? tryGetStorage<T extends IStorage>() {
    final storage = _storages[T];
    return storage as T?;
  }

  /// 检查是否已注册指定类型的存储
  bool hasStorage<T extends IStorage>() {
    return _storages.containsKey(T);
  }

  // /// 状态管理接口
  // IAppState get stateContainer => _stateContainer;

  /// 应用是否已初始化
  bool _isInitialized = false;

  /// 获取应用是否已初始化
  bool get isInitialized => _isInitialized;

  /// Initializes core components using application configuration.
  ///
  /// This method simplifies app initialization by automatically configuring
  /// components from your BaseConfig implementation.
  ///
  /// ## Usage Patterns
  ///
  /// ### Minimal (Auto-Configuration)
  /// ```dart
  /// await appManager.initialize(
  ///   AppInitConfig(config: myAppConfig),
  /// );
  /// ```
  ///
  /// ### Standard (Common Customization)
  /// ```dart
  /// await appManager.initialize(
  ///   AppInitConfig(
  ///     config: myAppConfig,
  ///     logger: Logger(),
  ///     networkSetup: (config) => NetworkSetup.standard(
  ///       parser: MyResponseParser(),
  ///     ),
  ///   ),
  /// );
  /// ```
  ///
  /// ### Advanced (Full Control)
  /// ```dart
  /// await appManager.initialize(
  ///   AppInitConfig(
  ///     config: myAppConfig,
  ///     logger: customLogger,
  ///     storageFactory: () => CustomStorage(),
  ///     networkSetup: (config) => NetworkSetup()
  ///       .withResponseParser(MyParser())
  ///       .addInterceptor(MyInterceptor()),
  ///   ),
  /// );
  /// ```
  Future<bool> initialize(
    AppInitConfig initConfig, {
    ValueChanged<double>? onProgress,
    void Function(String stepName, bool success)? onStepCompleted,
  }) async {
    if (_isInitialized) {
      return true;
    }

    // 1. Create storage instance (default to SharedPrefsStorage if not provided)
    final storage = initConfig.storageFactory?.call() ??
        SharedPrefsStorage(
          StorageConfig.defaultConfig(),
          logger: initConfig.logger,
        );
    registerStorage(storage);

    // 2. Create app info
    if (initConfig.appInfoFactory != null) {
      _appInfo = initConfig.appInfoFactory!();
    } else {
      _appInfo = AppInfo(
        channel: initConfig.channel,
        signatureHashProvider: initConfig.signatureHashProvider,
        storage: tryGetStorage<IKeyValueStorage>(),
      );
    }

    // 3. Store environment config reference (if config implements IEnvironmentConfig)
    if (initConfig.config is IEnvironmentConfig) {
      _environmentConfig = initConfig.config as IEnvironmentConfig;
    }





    _appInitializer = AppInitializer();

    // 注册初始化步骤 - 初始化所有已注册的存储
    _appInitializer!.registerInitializer(
      name: 'app_storage',
      initializer: () async {
        // 初始化所有已注册的存储模块
        for (final storage in _storages.values) {
          try {
            await storage.init();
          } catch (e) {
            debugPrint('存储模块初始化失败 (${storage.runtimeType}): $e');
            return false;
          }
        }
        return true;
      },
      priority: InitPriorities.storage,
    );
    
    _appInitializer!.registerInitializer(
      name: 'app_info',
      initializer: () async {
        // 直接调用接口定义的 initialize 方法
        try {
          await _appInfo!.initialize();
        } catch (e) {
          debugPrint('AppInfo 初始化失败: $e');
          return false;
        }
        return true;
      },
      priority: InitPriorities.appInfo,
      dependsOn: ['app_storage'],
    );

    // Only register environment_config initialization if it has an initialize method
    // (Some configs may not need initialization)
    if (_environmentConfig != null) {
      _appInitializer!.registerInitializer(
        name: 'environment_config',
        initializer: () async {
          // Config is already set, no additional initialization needed
          // unless the config implements a specific initialize method
          return true;
        },
        priority: InitPriorities.environmentConfig,
      );
    }

    _appInitializer!.registerInitializer(
      name: 'app_network',
      initializer: () async {
        try {
          // 4. Auto-create network client from config if it implements INetWorkConfig
          if (initConfig.config is INetWorkConfig) {
            final networkConfig = initConfig.config as INetWorkConfig;

            // Create base network client
            _networkClient = NetworkClientBuilder.fromConfig(
              networkConfig,
              logger: initConfig.logger,
            );

            // Apply network setup (interceptors) if provided
            if (initConfig.networkSetup != null) {
              final setup = initConfig.networkSetup!(networkConfig);
              for (final interceptor in setup.interceptors) {
                _networkClient.addInterceptor(interceptor);
              }
            }
          } else {
            // Network is optional - use no-op client if config doesn't implement INetWorkConfig
            debugPrint(
              'Network not configured: ${initConfig.config.runtimeType} does not implement INetWorkConfig. '
              'Using NoOpNetworkClient. Network calls will throw UnsupportedError.',
            );
            _networkClient = NoOpNetworkClient();
          }

          return true;
        } catch (e, stackTrace) {
          debugPrint('Network client initialization failed: $e');
          debugPrint('Stack trace: $stackTrace');
          return false;
        }
      },
      priority: InitPriorities.network,
      dependsOn: _environmentConfig != null ? ['environment_config'] : [],
    );


    // _appInitializer.registerInitializer(
    //   name: 'app_state_providers',
    //   initializer: () async {
    //     _stateContainer = config.appStateFactory();
    //
    //     // 如果状态容器实现了 initialize 方法
    //     try {
    //       await (_stateContainer as dynamic).initialize();
    //     } catch (e) {
    //       debugPrint('状态管理模块初始化失败: $e');
    //       return false;
    //     }
    //
    //     return true;
    //   },
    //   priority: 50,
    //   dependsOn: ['app_storage'], // 状态管理可能依赖存储以持久化状态
    // );
    //
    if(initConfig.themeFactory != null) {
      _appInitializer!.registerInitializer(
        name: 'app_theme',
        initializer: () async {
          _themeManager = initConfig.themeFactory!();
          await _themeManager!.initialize();
          return true;
        },
        priority: InitPriorities.theme,
        dependsOn: ['app_storage'],
      );
    }

    // Register i18n initialization if provided
    if (initConfig.i18nDelegate != null) {
      _appInitializer!.registerInitializer(
        name: 'app_i18n',
        initializer: () async {
          _i18n = initConfig.i18nDelegate;

          try {
            // Load initial locale
            final success = await _i18n!.load(initConfig.defaultLocale);
            if (!success) {
              debugPrint('Failed to load initial locale: ${initConfig.defaultLocale}');
              // Try fallback locale
              final fallbackSuccess = await _i18n!.load(_i18n!.fallbackLocale);
              return fallbackSuccess;
            }
            return true;
          } catch (e) {
            debugPrint('i18n initialization failed: $e');
            return false;
          }
        },
        priority: InitPriorities.theme + 5, // After theme, before router
        dependsOn: [],
      );
    }
    //
    // _appInitializer.registerInitializer(
    //   name: 'app_router',
    //   initializer: () async {
    //     _router = config.routerFactory();
    //
    //     // 如果路由实现了 initialize 方法
    //     try {
    //       await (_router as dynamic).initialize();
    //     } catch (e) {
    //       debugPrint('路由模块初始化失败: $e');
    //       return false;
    //     }
    //
    //     return true;
    //   },
    //   priority: 70, // 路由优先级最低，因为它可能依赖其他所有模块
    //   dependsOn: ['app_state_providers'], // 路由可能依赖状态管理
    // );

    // 执行初始化
    final result = await _appInitializer!.initialize(
      onProgress: onProgress, // 将外部传入的回调函数传给初始化器
      onStepCompleted: onStepCompleted, // 将外部传入的回调函数传给初始化器
    );

    _isInitialized = result;
    return result;
  }

  /// 重置核心组件，主要用于测试
  void reset() {
    if (_isInitialized) {
      _appInitializer?.reset();
    }
    _isInitialized = false;

    // 重置所有字段为 null，以便重新初始化
    _appInfo = null;
    _appInitializer = null;
    _environmentConfig = null;
    _storages.clear();
  }
}
