import 'dart:ui';

/// 国际化配置
///
/// 用于配置应用的国际化支持
class I18nConfig {
  /// 支持的语言列表
  final List<Locale> supportedLocales;

  /// 回退语言(当请求的语言不支持时使用)
  final Locale fallbackLocale;

  /// 资源文件路径模式
  ///
  /// 例如: 'assets/i18n/${locale.languageCode}.arb'
  /// 或: 'assets/i18n/${locale.languageCode}_${locale.countryCode}.arb'
  final String resourcePathPattern;

  /// 是否使用系统语言
  final bool useSystemLocale;

  /// 是否启用热重载
  final bool enableHotReload;

  const I18nConfig({
    required this.supportedLocales,
    required this.fallbackLocale,
    this.resourcePathPattern = 'assets/i18n/{languageCode}.arb',
    this.useSystemLocale = true,
    this.enableHotReload = false,
  });

  /// 默认配置(中文和英文)
  factory I18nConfig.defaults() => const I18nConfig(
        supportedLocales: [
          Locale('zh', 'CN'),
          Locale('en', 'US'),
        ],
        fallbackLocale: Locale('en', 'US'),
      );

  /// 仅中文配置
  factory I18nConfig.zhOnly() => const I18nConfig(
        supportedLocales: [Locale('zh', 'CN')],
        fallbackLocale: Locale('zh', 'CN'),
      );

  /// 仅英文配置
  factory I18nConfig.enOnly() => const I18nConfig(
        supportedLocales: [Locale('en', 'US')],
        fallbackLocale: Locale('en', 'US'),
      );

  /// 生成资源文件路径
  String getResourcePath(Locale locale) {
    return resourcePathPattern
        .replaceAll('{languageCode}', locale.languageCode)
        .replaceAll('{countryCode}', locale.countryCode ?? '')
        .replaceAll('{locale}', locale.toString());
  }
}

/// 国际化代理接口
///
/// 提供应用国际化支持,加载和管理多语言资源
/// 框架提供加载机制,应用层提供具体的 .arb 资源文件
abstract class II18nDelegate {
  /// 获取当前语言
  Locale get currentLocale;

  /// 获取支持的语言列表
  List<Locale> get supportedLocales;

  /// 获取回退语言
  Locale get fallbackLocale;

  /// 加载指定语言的资源
  ///
  /// [locale] 要加载的语言
  ///
  /// 返回 true 表示加载成功
  Future<bool> load(Locale locale);

  /// 翻译指定的键
  ///
  /// [key] 翻译键
  /// [args] 可选的参数,用于替换占位符
  /// [locale] 可选的语言,不指定则使用当前语言
  ///
  /// 返回翻译后的字符串,如果键不存在则返回键本身
  String translate(
    String key, {
    Map<String, dynamic>? args,
    Locale? locale,
  });

  /// 翻译指定的键(简写)
  ///
  /// 等价于 translate
  String call(String key, {Map<String, dynamic>? args}) =>
      translate(key, args: args);

  /// 检查是否支持指定语言
  ///
  /// [locale] 要检查的语言
  ///
  /// 返回 true 表示支持
  bool isLocaleSupported(Locale locale);

  /// 切换语言
  ///
  /// [locale] 要切换到的语言
  ///
  /// 返回 true 表示切换成功
  Future<bool> switchLocale(Locale locale);

  /// 重新加载当前语言资源
  ///
  /// 用于支持热重载或更新资源
  Future<bool> reload();

  /// 获取所有已加载的翻译键
  ///
  /// [locale] 可选的语言,不指定则使用当前语言
  ///
  /// 返回所有翻译键的列表
  List<String> getKeys({Locale? locale});

  /// 检查指定键是否存在
  ///
  /// [key] 翻译键
  /// [locale] 可选的语言,不指定则使用当前语言
  ///
  /// 返回 true 表示键存在
  bool hasKey(String key, {Locale? locale});

  /// 获取翻译的原始数据
  ///
  /// [locale] 可选的语言,不指定则使用当前语言
  ///
  /// 返回翻译数据的 Map
  Map<String, dynamic> getRawData({Locale? locale});

  /// 清空所有已加载的翻译资源
  void clear();

  /// 语言变更监听器
  ///
  /// 当语言切换时触发
  Stream<Locale> get localeChanges;
}

/// 简单的国际化代理实现
///
/// 提供基本的翻译功能,不依赖 Flutter 的 Localizations 系统
abstract class SimpleI18nDelegate implements II18nDelegate {
  final I18nConfig config;
  final Map<Locale, Map<String, String>> _translations = {};
  Locale _currentLocale;

  SimpleI18nDelegate({
    required this.config,
    Locale? initialLocale,
  }) : _currentLocale = initialLocale ??
            (config.useSystemLocale
                ? PlatformDispatcher.instance.locale
                : config.fallbackLocale);

  @override
  Locale get currentLocale => _currentLocale;

  @override
  List<Locale> get supportedLocales => config.supportedLocales;

  @override
  Locale get fallbackLocale => config.fallbackLocale;

  @override
  bool isLocaleSupported(Locale locale) {
    return supportedLocales.any((l) =>
        l.languageCode == locale.languageCode &&
        (l.countryCode == null || l.countryCode == locale.countryCode));
  }

  @override
  String translate(
    String key, {
    Map<String, dynamic>? args,
    Locale? locale,
  }) {
    final targetLocale = locale ?? currentLocale;
    var translation =
        _translations[targetLocale]?[key] ?? _translations[fallbackLocale]?[key] ?? key;

    // 替换占位符
    if (args != null) {
      args.forEach((k, v) {
        translation = translation.replaceAll('{$k}', v.toString());
      });
    }

    return translation;
  }

  @override
  Future<bool> switchLocale(Locale locale) async {
    if (!isLocaleSupported(locale)) {
      return false;
    }

    final loaded = await load(locale);
    if (loaded) {
      _currentLocale = locale;
    }
    return loaded;
  }

  @override
  List<String> getKeys({Locale? locale}) {
    final targetLocale = locale ?? currentLocale;
    return _translations[targetLocale]?.keys.toList() ?? [];
  }

  @override
  bool hasKey(String key, {Locale? locale}) {
    final targetLocale = locale ?? currentLocale;
    return _translations[targetLocale]?.containsKey(key) ?? false;
  }

  @override
  Map<String, dynamic> getRawData({Locale? locale}) {
    final targetLocale = locale ?? currentLocale;
    return Map<String, dynamic>.from(_translations[targetLocale] ?? {});
  }

  @override
  void clear() {
    _translations.clear();
  }

  /// 注册翻译数据
  ///
  /// [locale] 语言
  /// [translations] 翻译数据
  void registerTranslations(Locale locale, Map<String, String> translations) {
    _translations[locale] = translations;
  }
}
