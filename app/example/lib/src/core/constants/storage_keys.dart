/// 存储键常量
///
/// 用于持久化设置的键名
abstract final class StorageKeys {
  /// 主题模式 (ThemeMode.index: 0=system, 1=light, 2=dark)
  static const String themeMode = 'theme_mode';

  /// 配色方案 (AppColorScheme.index)
  static const String colorScheme = 'color_scheme';

  /// 语言设置 (AppLocale.index)
  static const String locale = 'locale';
}
