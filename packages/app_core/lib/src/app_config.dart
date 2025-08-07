import 'package:app_interfaces/app_interfaces.dart';
import 'package:flutter/material.dart';

/// 应用配置类
/// 
/// 包含应用的基本配置信息，作为模块初始化的参数
class AppConfig {
  /// 应用渠道
  final String channel;

  /// 默认环境
  final EnvironmentType defaultEnvironment;

  /// 各环境配置
  final Map<EnvironmentType, Map<String, dynamic>> environmentConfigs;

  /// 签名哈希提供器
  final Future<String> Function()? signatureHashProvider;

  /// 默认语言
  final Locale defaultLocale;

  /// 支持的语言列表
  final List<Locale> supportedLocales;

  /// 默认主题模式
  final ThemeMode defaultThemeMode;

  /// 默认主色调
  final Color defaultPrimaryColor;

  /// 浅色主题定义
  final ThemeData? lightTheme;

  /// 深色主题定义
  final ThemeData? darkTheme;

  /// 存储模块工厂方法
  final IStorage Function() storageFactory;

  /// 应用信息模块工厂方法（可选，主要用于测试）
  final IAppInfo Function()? appInfoFactory;

  /// 网络模块工厂方法
  final INetworkClient Function() networkClientFactory;

  /// 状态管理模块工厂方法
  // final IAppState Function() appStateFactory;

  /// 路由模块工厂方法
  // final IRouter Function() routerFactory;

  /// 创建应用配置实例
  const AppConfig({
    required this.channel,
    required this.defaultEnvironment,
    required this.environmentConfigs,
    required this.defaultLocale,
    required this.supportedLocales,
    required this.storageFactory,
    required this.networkClientFactory,
    // required this.appStateFactory,
    // required this.routerFactory,
    this.signatureHashProvider,
    this.appInfoFactory,
    this.defaultThemeMode = ThemeMode.system,
    this.defaultPrimaryColor = Colors.blue,
    this.lightTheme,
    this.darkTheme,
  });

  /// 创建开发环境配置
  factory AppConfig.development({
    required String channel,
    Locale? defaultLocale,
    List<Locale>? supportedLocales,
    ThemeData? lightTheme,
    ThemeData? darkTheme,
    Color defaultPrimaryColor = Colors.blue,
    IStorage Function()? storageFactory,
    INetworkClient Function()? networkClientFactory,
    // IAppState Function()? appStateFactory,
    // IRouter Function()? routerFactory,
  }) {
    return AppConfig(
      channel: channel,
      defaultEnvironment: EnvironmentType.development,
      environmentConfigs: {
        EnvironmentType.development: {
          'channel':channel,
          'enableVerboseLogging': true,
        },
      },
      defaultLocale: defaultLocale ?? const Locale('zh', 'CN'),
      supportedLocales: supportedLocales ?? [const Locale('zh', 'CN'), const Locale('en', 'US')],
      defaultPrimaryColor: defaultPrimaryColor,
      lightTheme: lightTheme,
      darkTheme: darkTheme,
      // 提供默认的工厂方法，实际应用中需替换为真实的实现
      storageFactory: storageFactory ?? () {
        throw UnimplementedError('存储模块工厂未提供，请在AppConfig中设置storageFactory');
      },
      networkClientFactory: networkClientFactory ?? () {
        throw UnimplementedError('网络模块工厂未提供，请在AppConfig中设置networkClientFactory');
      },
      // appStateFactory: appStateFactory ?? () {
      //   throw UnimplementedError('状态管理模块工厂未提供，请在AppConfig中设置appStateFactory');
      // },
      // routerFactory: routerFactory ?? () {
      //   throw UnimplementedError('路由模块工厂未提供，请在AppConfig中设置routerFactory');
      // },
    );
  }

  /// 创建生产环境配置
  factory AppConfig.production({
    // required String apiBaseUrl,
    required String channel,
    Locale? defaultLocale,
    List<Locale>? supportedLocales,
    Future<String> Function()? signatureHashProvider,
    ThemeData? lightTheme,
    ThemeData? darkTheme,
    Color defaultPrimaryColor = Colors.blue,
    IStorage Function()? storageFactory,
    INetworkClient Function()? networkClientFactory,
    // IAppState Function()? appStateFactory,
    // IRouter Function()? routerFactory,
  }) {
    return AppConfig(
      channel: channel,
      defaultEnvironment: EnvironmentType.production,
      environmentConfigs: {
        EnvironmentType.production: {
          'channel':channel,
          'enableCrashReporting': true,
          'enablePerformanceMonitoring': true,
        },
      },
      signatureHashProvider: signatureHashProvider,
      defaultLocale: defaultLocale ?? const Locale('zh', 'CN'),
      supportedLocales: supportedLocales ?? [const Locale('zh', 'CN'), const Locale('en', 'US')],
      defaultPrimaryColor: defaultPrimaryColor,
      lightTheme: lightTheme,
      darkTheme: darkTheme,
      // 提供默认的工厂方法，实际应用中需替换为真实的实现
      storageFactory: storageFactory ?? () {
        throw UnimplementedError('存储模块工厂未提供，请在AppConfig中设置storageFactory');
      },
      networkClientFactory: networkClientFactory ?? () {
        throw UnimplementedError('网络模块工厂未提供，请在AppConfig中设置networkClientFactory');
      },
      // appStateFactory: appStateFactory ?? () {
      //   throw UnimplementedError('状态管理模块工厂未提供，请在AppConfig中设置appStateFactory');
      // },
      // routerFactory: routerFactory ?? () {
      //   throw UnimplementedError('路由模块工厂未提供，请在AppConfig中设置routerFactory');
      // },
    );
  }
}
