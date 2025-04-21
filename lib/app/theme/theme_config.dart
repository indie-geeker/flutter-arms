import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_theme.dart';

/// 主题配置类
class ThemeConfig {
  // 当前主题模式
  final ThemeMode themeMode;
  
  // 浅色主题
  final AppTheme lightTheme;
  
  // 深色主题
  final AppTheme darkTheme;
  
  // 当前字体
  final String fontFamily;
  
  // 自定义主色调
  final Color? customPrimaryColor;
  
  // 自定义次要色调
  final Color? customSecondaryColor;
  
  const ThemeConfig({
    this.themeMode = ThemeMode.system,
    required this.lightTheme,
    required this.darkTheme,
    this.fontFamily = 'PingFang SC',
    this.customPrimaryColor,
    this.customSecondaryColor,
  });
  
  /// 创建默认主题配置
  factory ThemeConfig.defaultConfig() {
    return ThemeConfig(
      themeMode: ThemeMode.system,
      lightTheme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
    );
  }
  
  /// 创建自定义主题配置
  factory ThemeConfig.custom({
    required ThemeMode themeMode,
    required String fontFamily,
    required Color primaryColor,
    required Color secondaryColor,
  }) {
    // 创建自定义浅色主题颜色
    final customLightColors = AppColors.light.copyWith(
      primary: primaryColor,
      primaryLight: _lightenColor(primaryColor, 0.2),
      primaryDark: _darkenColor(primaryColor, 0.2),
      secondary: secondaryColor,
      secondaryLight: _lightenColor(secondaryColor, 0.2),
      secondaryDark: _darkenColor(secondaryColor, 0.2),
    );
    
    // 创建自定义深色主题颜色
    final customDarkColors = AppColors.dark.copyWith(
      primary: primaryColor,
      primaryLight: _lightenColor(primaryColor, 0.2),
      primaryDark: _darkenColor(primaryColor, 0.2),
      secondary: secondaryColor,
      secondaryLight: _lightenColor(secondaryColor, 0.2),
      secondaryDark: _darkenColor(secondaryColor, 0.2),
    );
    
    return ThemeConfig(
      themeMode: themeMode,
      fontFamily: fontFamily,
      customPrimaryColor: primaryColor,
      customSecondaryColor: secondaryColor,
      lightTheme: AppTheme.custom(
        colors: customLightColors,
        fontFamily: fontFamily,
        brightness: Brightness.light,
      ),
      darkTheme: AppTheme.custom(
        colors: customDarkColors,
        fontFamily: fontFamily,
        brightness: Brightness.dark,
      ),
    );
  }
  
  /// 获取当前主题
  AppTheme getCurrentTheme(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    
    switch (themeMode) {
      case ThemeMode.light:
        return lightTheme;
      case ThemeMode.dark:
        return darkTheme;
      case ThemeMode.system:
      default:
        return brightness == Brightness.light ? lightTheme : darkTheme;
    }
  }
  
  /// 创建更新后的配置
  ThemeConfig copyWith({
    ThemeMode? themeMode,
    AppTheme? lightTheme,
    AppTheme? darkTheme,
    String? fontFamily,
    Color? customPrimaryColor,
    Color? customSecondaryColor,
  }) {
    return ThemeConfig(
      themeMode: themeMode ?? this.themeMode,
      lightTheme: lightTheme ?? this.lightTheme,
      darkTheme: darkTheme ?? this.darkTheme,
      fontFamily: fontFamily ?? this.fontFamily,
      customPrimaryColor: customPrimaryColor ?? this.customPrimaryColor,
      customSecondaryColor: customSecondaryColor ?? this.customSecondaryColor,
    );
  }
  
  /// 辅助方法：使颜色变亮
  static Color _lightenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }
  
  /// 辅助方法：使颜色变暗
  static Color _darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}

/// AppColors 扩展方法
extension AppColorsExtension on AppColors {
  /// 创建更新后的颜色
  AppColors copyWith({
    Color? primary,
    Color? primaryLight,
    Color? primaryDark,
    Color? secondary,
    Color? secondaryLight,
    Color? secondaryDark,
    Color? background,
    Color? surface,
    Color? scaffoldBackground,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? error,
    Color? success,
    Color? warning,
    Color? info,
    Color? divider,
    Color? disabled,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryDark: primaryDark ?? this.primaryDark,
      secondary: secondary ?? this.secondary,
      secondaryLight: secondaryLight ?? this.secondaryLight,
      secondaryDark: secondaryDark ?? this.secondaryDark,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      scaffoldBackground: scaffoldBackground ?? this.scaffoldBackground,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      error: error ?? this.error,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      divider: divider ?? this.divider,
      disabled: disabled ?? this.disabled,
    );
  }
}
