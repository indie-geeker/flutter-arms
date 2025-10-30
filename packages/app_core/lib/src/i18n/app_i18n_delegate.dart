import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:app_interfaces/app_interfaces.dart';
import 'package:flutter/services.dart';

/// Flutter ARMS i18n delegate implementation
///
/// Loads .arb (Application Resource Bundle) files from app assets and provides
/// translation capabilities. This is a framework-provided implementation that
/// loads app-layer .arb files.
///
/// ## Usage
///
/// ```dart
/// final i18n = AppI18nDelegate(
///   config: I18nConfig(
///     supportedLocales: [Locale('zh', 'CN'), Locale('en', 'US')],
///     fallbackLocale: Locale('en', 'US'),
///     resourcePathPattern: 'assets/i18n/{languageCode}_{countryCode}.arb',
///   ),
/// );
///
/// await i18n.load(Locale('zh', 'CN'));
/// print(i18n.translate('app_name')); // "我的应用"
/// print(i18n.translate('welcome', args: {'name': 'John'})); // "欢迎 John"
/// ```
///
/// ## .arb File Format
///
/// .arb files are JSON files with translations:
///
/// ```json
/// {
///   "app_name": "My App",
///   "welcome": "Welcome {name}",
///   "@welcome": {
///     "description": "Welcome message with user name",
///     "placeholders": {
///       "name": {
///         "type": "String"
///       }
///     }
///   }
/// }
/// ```
///
/// Keys starting with "@" are metadata and are ignored during translation.
class AppI18nDelegate extends SimpleI18nDelegate {
  final StreamController<Locale> _localeController =
      StreamController<Locale>.broadcast();

  final ILogger? _logger;

  /// Creates an i18n delegate that loads .arb files from assets.
  ///
  /// [config] Configuration for supported locales and resource paths
  /// [initialLocale] Optional initial locale (uses system locale if null)
  /// [logger] Optional logger for debugging
  AppI18nDelegate({
    required super.config,
    super.initialLocale,
    ILogger? logger,
  })  : _logger = logger;

  @override
  Future<bool> load(Locale locale) async {
    try {
      _logger?.debug('Loading translations for locale: $locale');

      if (!isLocaleSupported(locale)) {
        _logger?.warning('Locale not supported: $locale');
        return false;
      }

      final resourcePath = config.getResourcePath(locale);
      _logger?.debug('Loading resource from: $resourcePath');

      final jsonString = await rootBundle.loadString(resourcePath);
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;

      // Filter out metadata keys (starting with @)
      final translations = <String, String>{};
      jsonMap.forEach((key, value) {
        if (!key.startsWith('@') && value is String) {
          translations[key] = value;
        }
      });

      registerTranslations(locale, translations);
      _logger?.info('Loaded ${translations.length} translations for $locale');

      return true;
    } catch (e, stackTrace) {
      _logger?.error(
        'Failed to load translations for locale: $locale',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  @override
  Future<bool> switchLocale(Locale locale) async {
    final result = await super.switchLocale(locale);
    if (result) {
      _localeController.add(locale);
      _logger?.info('Switched locale to: $locale');
    }
    return result;
  }

  @override
  Future<bool> reload() async {
    _logger?.debug('Reloading current locale: $currentLocale');
    final result = await load(currentLocale);
    if (result) {
      _localeController.add(currentLocale);
    }
    return result;
  }

  @override
  Stream<Locale> get localeChanges => _localeController.stream;

  @override
  String call(String key, {Map<String, dynamic>? args}) {
    return translate(key, args: args);
  }

  /// Dispose resources
  ///
  /// Call this when the i18n delegate is no longer needed to clean up
  /// the locale change stream controller.
  void dispose() {
    _localeController.close();
    _logger?.debug('AppI18nDelegate disposed');
  }

  /// Preload all supported locales
  ///
  /// This is useful for apps that want to ensure all translations are
  /// available immediately without lazy loading.
  ///
  /// Returns the number of successfully loaded locales.
  Future<int> preloadAll() async {
    _logger?.info('Preloading all supported locales');
    int loadedCount = 0;

    for (final locale in supportedLocales) {
      final success = await load(locale);
      if (success) {
        loadedCount++;
      }
    }

    _logger?.info('Preloaded $loadedCount/${supportedLocales.length} locales');
    return loadedCount;
  }

  /// Get translation statistics
  ///
  /// Returns information about loaded translations for debugging purposes.
  Map<String, dynamic> getStatistics() {
    final stats = <String, dynamic>{
      'current_locale': currentLocale.toString(),
      'supported_locales':
          supportedLocales.map((l) => l.toString()).toList(),
      'fallback_locale': fallbackLocale.toString(),
      'loaded_locales': <String, int>{},
    };

    for (final locale in supportedLocales) {
      final keys = getKeys(locale: locale);
      stats['loaded_locales'][locale.toString()] = keys.length;
    }

    return stats;
  }
}
