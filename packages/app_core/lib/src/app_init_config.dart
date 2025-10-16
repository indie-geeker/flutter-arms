import 'package:app_interfaces/app_interfaces.dart';
import 'package:flutter/material.dart';

import 'setup/network_setup.dart';

/// Application initialization configuration.
///
/// This class contains all configuration needed to initialize the AppManager.
/// It follows the "convention over configuration" principle by providing
/// smart defaults while allowing full customization when needed.
///
/// ## Usage Patterns
///
/// ### Minimal (Auto-Configuration)
/// ```dart
/// AppInitConfig(config: myAppConfig)
/// ```
/// Everything is auto-configured from the config.
///
/// ### Standard (Common Customization)
/// ```dart
/// AppInitConfig(
///   config: myAppConfig,
///   networkSetup: (config) => NetworkSetup.standard(
///     parser: MyResponseParser(),
///   ),
/// )
/// ```
///
/// ### Advanced (Full Control)
/// ```dart
/// AppInitConfig(
///   config: myAppConfig,
///   logger: customLogger,
///   storageFactory: () => CustomStorage(),
///   networkSetup: (config) => NetworkSetup()
///     .withResponseParser(MyParser())
///     .addInterceptor(MyInterceptor()),
/// )
/// ```
class AppInitConfig {
  /// Application configuration that implements BaseConfig.
  ///
  /// This should be your app's main configuration class that extends
  /// BaseConfig and implements IEnvironmentConfig, INetWorkConfig, etc.
  final BaseConfig config;

  /// Default locale for the application.
  ///
  /// Defaults to Locale('zh', 'CN') if not specified.
  final Locale defaultLocale;

  /// List of supported locales.
  ///
  /// Defaults to [Locale('zh', 'CN'), Locale('en', 'US')] if not specified.
  final List<Locale> supportedLocales;

  /// Logger instance for the application.
  ///
  /// If not provided, logging will be disabled.
  final ILogger? logger;

  /// Factory for creating storage instances.
  ///
  /// If not provided, SharedPrefsStorage with default config will be used.
  final IStorage Function()? storageFactory;

  /// Factory for configuring network setup.
  ///
  /// This callback receives the INetWorkConfig and returns a NetworkSetup
  /// with configured interceptors. If not provided, no interceptors are added.
  ///
  /// Example:
  /// ```dart
  /// networkSetup: (config) => NetworkSetup.standard(
  ///   parser: MyResponseParser(),
  ///   deduplicationWindow: Duration(minutes: 3),
  /// )
  /// ```
  final NetworkSetup Function(INetWorkConfig config)? networkSetup;

  /// Signature hash provider for app verification.
  ///
  /// Used in production for security purposes.
  final Future<String> Function()? signatureHashProvider;

  /// App info factory for custom app info implementations.
  ///
  /// Mainly used for testing. Leave null for default implementation.
  final IAppInfo Function()? appInfoFactory;


  final IThemeManager Function()? themeFactory;


  /// Creates an application initialization configuration.
  ///
  /// Only [config] is required. All other parameters have sensible defaults.
  const AppInitConfig({
    required this.config,
    this.logger,
    this.defaultLocale = const Locale('zh', 'CN'),
    this.supportedLocales = const [
      Locale('zh', 'CN'),
      Locale('en', 'US'),
    ],
    this.storageFactory,
    this.networkSetup,
    this.signatureHashProvider,
    this.appInfoFactory,
    this.themeFactory
  });

  /// Creates a quick configuration with just the app config.
  ///
  /// This uses all default values for other parameters.
  /// Perfect for simple apps or quick prototyping.
  ///
  /// Example:
  /// ```dart
  /// final initConfig = AppInitConfig.quick(myAppConfig);
  /// await appManager.initialize(initConfig);
  /// ```
  factory AppInitConfig.quick(BaseConfig config) {
    return AppInitConfig(config: config);
  }

  /// Gets the environment type from the config.
  EnvironmentType get environmentType {
    if (config is IEnvironmentConfig) {
      return (config as IEnvironmentConfig).environmentType;
    }
    return EnvironmentType.development;
  }

  /// Gets the channel from the config.
  String get channel {
    if (config is IEnvironmentConfig) {
      return (config as IEnvironmentConfig).getValue<String>(
        'channel',
        'default',
      );
    }
    return 'default';
  }
}
