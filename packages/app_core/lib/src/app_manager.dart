import 'package:app_interfaces/app_interfaces.dart';
import 'package:flutter/foundation.dart';

import 'app_config.dart';
import 'app_info.dart';
import 'app_initializer.dart';
import 'environment_config.dart';

/// 应用核心实现
///
/// 统一管理应用的核心功能，包括初始化、环境配置、主题、国际化、路由、存储、网络和状态管理等

class AppManager {
  /// 应用信息
  IAppInfo? _appInfo;

  /// 应用初始化器
  AppInitializer? _appInitializer;

  /// 环境配置
  EnvironmentConfig? _environmentConfig;
  //
  // /// 应用主题
  // late final AppTheme _appTheme;
  //
  // /// 应用国际化
  // late final AppLocalizations _appLocalizations;
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
  // /// 应用主题
  // AppTheme get appTheme => _appTheme;
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

  /// 使用应用配置初始化核心组件
  Future<bool> initialize(
    AppConfig config, {
    ValueChanged<double>? onProgress,
    void Function(String stepName, bool success)? onStepCompleted,
  }) async {
    if (_isInitialized) {
      return true;
    }

    // 先创建存储实例，因为其他组件可能依赖存储
    final storage = config.storageFactory();
    registerStorage(storage);
    
    // 创建各组件实例
    // 检查是否有自定义的 appInfoFactory，用于测试环境
    if (config.appInfoFactory != null) {
      _appInfo = config.appInfoFactory!();
    } else {
      _appInfo = AppInfo(
        channel: config.channel,
        signatureHashProvider: config.signatureHashProvider,
        storage: tryGetStorage<IKeyValueStorage>(),
      );
    }

    _environmentConfig = EnvironmentConfig(
      defaultEnvironment: config.defaultEnvironment,
      configs: config.environmentConfigs,
    );

    // _appTheme = AppTheme(
    //   lightTheme: config.lightTheme ?? ThemeData.light(useMaterial3: true),
    //   darkTheme: config.darkTheme ?? ThemeData.dark(useMaterial3: true),
    //   initialPrimaryColor: config.defaultPrimaryColor,
    // );
    //
    // _appLocalizations = AppLocalizations(
    //   defaultLocale: config.defaultLocale,
    //   supportedLocales: config.supportedLocales,
    // );

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
      priority: 10, // 存储优先级最高，其他模块依赖存储功能
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
      priority: 20,
      dependsOn: ['app_storage'], // 依赖存储
    );

    _appInitializer!.registerInitializer(
      name: 'environment_config',
      initializer: () async {
        await _environmentConfig!.initialize();
        return true;
      },
      priority: 30,
    );

    _appInitializer!.registerInitializer(
      name: 'app_network',
      initializer: () async {
        // 构建网络模块，可能需要环境配置信息
        // 使用 config.apiBaseUrl 而非从环境配置获取
        _networkClient = config.networkClientFactory();

        // // 如果网络模块实现了 initialize 方法
        // try {
        //   await (_networkClient as dynamic).initialize();
        // } catch (e) {
        //   debugPrint('网络模块初始化失败: $e');
        //   return false;
        // }

        return true;
      },
      priority: 40,
      dependsOn: ['environment_config'], // 依赖环境配置
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
    // _appInitializer.registerInitializer(
    //   name: 'app_theme',
    //   initializer: () async {
    //     await _appTheme.initialize();
    //     return true;
    //   },
    //   priority: 60,
    // );
    //
    // _appInitializer.registerInitializer(
    //   name: 'app_localizations',
    //   initializer: () async {
    //     await _appLocalizations.initialize();
    //     return true;
    //   },
    //   priority: 60,
    // );
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
