import 'package:flutter/material.dart';

/// 主题配置接口
///
/// 应用配置类可以实现此接口来提供主题设置
abstract class IThemeConfig {
  /// 默认主题模式
  ThemeMode get defaultThemeMode;

  /// 主题持久化存储的键名
  String get themeModeStorageKey => 'app_theme_mode';

  /// 是否启用主题动画
  bool get enableThemeAnimation => true;

  /// 主题切换动画时长
  Duration get themeAnimationDuration => const Duration(milliseconds: 300);

  /// 默认主题色（Material 3 种子色）
  ///
  /// 使用 ColorScheme.fromSeed 生成完整色彩方案
  Color get defaultSeedColor => Colors.deepPurple;

  /// 主题色持久化存储的键名
  String get themeColorStorageKey => 'app_theme_color';

  /// 是否启用自定义主题色功能
  bool get enableCustomThemeColor => false;

  /// 预设主题色方案（可选）
  ///
  /// 提供一组预定义的主题色供用户快速选择
  List<Color>? get presetThemeColors => null;
}