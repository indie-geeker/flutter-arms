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
  /// 存储模块
  IStorage? _storage;
  //
  // /// 状态管理模块
  // late final IAppState _stateContainer;

  /// 私有构造函数，避免直接实例化
  AppManager._();

  /// 单例实例
  static AppManager? _instance;

  /// 获取单例实例
  static AppManager get instance {
    _instance ??= AppManager._();
    return _instance!;
  }

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

  /// 存储接口
  // IStorage get storage => _storage!;
  T getStorage<T extends IStorage>() {
    if (_storage is T) {
      return _storage as T;
    }
    throw StateError('当前存储实现不支持 ${T.toString()} 接口。'
        '当前实现: ${_storage.runtimeType}');
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
    _storage = config.storageFactory();
    
    // 创建各组件实例
    // 检查是否有自定义的 appInfoFactory，用于测试环境
    if (config.appInfoFactory != null) {
      _appInfo = config.appInfoFactory!();
    } else {
      _appInfo = AppInfo(
        channel: config.channel,
        signatureHashProvider: config.signatureHashProvider,
        storage: _storage as IKeyValueStorage?,
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

    // 注册初始化步骤
    _appInitializer!.registerInitializer(
      name: 'app_storage',
      initializer: () async {
        // 如果存储模块实现了 initialize 方法
        try {
          await (_storage! as dynamic).init();
        } catch (e) {
          debugPrint('存储模块初始化失败: $e');
          return false;
        }
        return true;
      },
      priority: 10, // 存储优先级最高，其他模块依赖存储功能
    );
    
    _appInitializer!.registerInitializer(
      name: 'app_info',
      initializer: () async {
        // 使用反射检查是否有 initialize 方法
        try {
          // 尝试调用 initialize 方法
          final dynamic appInfo = _appInfo;
          if (appInfo.runtimeType.toString().contains('AppInfo')) {
            await appInfo.initialize();
          }
        } catch (e) {
          // 如果调用失败，记录错误但不阻断初始化
          if (kDebugMode) {
            print('AppInfo 初始化警告: $e');
          }
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
    _instance = null;
    
    // 重置所有字段为 null，以便重新初始化
    _appInfo = null;
    _appInitializer = null;
    _environmentConfig = null;
    _storage = null;
  }
}
