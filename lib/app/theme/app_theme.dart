import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// 应用主题配置
class AppTheme {
  final AppColors colors;
  final AppTextStyles textStyles;
  final ThemeData themeData;
  
  AppTheme({
    required this.colors,
    required this.textStyles,
    required this.themeData,
  });
  
  /// 创建浅色主题
  factory AppTheme.light({String fontFamily = 'PingFang SC'}) {
    final colors = AppColors.light;
    final textStyles = AppTextStyles.fromLightTheme(fontFamily: fontFamily);
    
    return AppTheme(
      colors: colors,
      textStyles: textStyles,
      themeData: _createThemeData(colors, textStyles, Brightness.light),
    );
  }
  
  /// 创建深色主题
  factory AppTheme.dark({String fontFamily = 'PingFang SC'}) {
    final colors = AppColors.dark;
    final textStyles = AppTextStyles.fromDarkTheme(fontFamily: fontFamily);
    
    return AppTheme(
      colors: colors,
      textStyles: textStyles,
      themeData: _createThemeData(colors, textStyles, Brightness.dark),
    );
  }
  
  /// 创建自定义主题
  factory AppTheme.custom({
    required AppColors colors,
    required String fontFamily,
    required Brightness brightness,
  }) {
    final textStyles = brightness == Brightness.light
        ? AppTextStyles.fromLightTheme(fontFamily: fontFamily)
        : AppTextStyles.fromDarkTheme(fontFamily: fontFamily);
    
    return AppTheme(
      colors: colors,
      textStyles: textStyles,
      themeData: _createThemeData(colors, textStyles, brightness),
    );
  }
  
  /// 创建 ThemeData
  static ThemeData _createThemeData(
    AppColors colors,
    AppTextStyles textStyles,
    Brightness brightness,
  ) {
    return ThemeData(
      // 亮度
      brightness: brightness,
      
      // 主色调
      primaryColor: colors.primary,
      primaryColorLight: colors.primaryLight,
      primaryColorDark: colors.primaryDark,
      
      // 背景色
      scaffoldBackgroundColor: colors.scaffoldBackground,
      canvasColor: colors.background,
      
      // 错误色
      cardColor: colors.error,
      
      // 分隔线
      dividerColor: colors.divider,
      
      // 禁用状态
      disabledColor: colors.disabled,
      
      // 文字主题
      textTheme: TextTheme(
        displayLarge: textStyles.headline1,
        displayMedium: textStyles.headline2,
        displaySmall: textStyles.headline3,
        headlineMedium: textStyles.headline4,
        headlineSmall: textStyles.headline5,
        titleLarge: textStyles.headline6,
        bodyLarge: textStyles.bodyText1,
        bodyMedium: textStyles.bodyText2,
        titleMedium: textStyles.subtitle1,
        titleSmall: textStyles.subtitle2,
        bodySmall: textStyles.caption,
        labelLarge: textStyles.button,
        labelSmall: textStyles.overline,
      ),
      
      // 主要文字主题
      primaryTextTheme: TextTheme(
        titleLarge: textStyles.headline6.copyWith(
          color: brightness == Brightness.light ? Colors.white : Colors.black,
        ),
        titleMedium: textStyles.subtitle1.copyWith(
          color: brightness == Brightness.light ? Colors.white : Colors.black,
        ),
        bodyLarge: textStyles.bodyText1.copyWith(
          color: brightness == Brightness.light ? Colors.white : Colors.black,
        ),
      ),
      
      // 按钮主题
      buttonTheme: ButtonThemeData(
        buttonColor: colors.primary,
        disabledColor: colors.disabled,
        textTheme: ButtonTextTheme.primary,
      ),
      
      // 输入框装饰
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        hintStyle: textStyles.bodyText2.copyWith(color: colors.textHint),
        errorStyle: textStyles.caption.copyWith(color: colors.error),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.error),
        ),
      ),
      
      // 卡片主题
      cardTheme: CardTheme(
        color: colors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // AppBar 主题
      appBarTheme: AppBarTheme(
        color: colors.primary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textStyles.headline6.copyWith(
          color: brightness == Brightness.light ? Colors.white : Colors.black,
        ),
      ),
      
      // 底部导航栏主题
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textSecondary,
      ), colorScheme: ColorScheme(
        primary: colors.primary,
        primaryContainer: colors.primaryDark,
        secondary: colors.secondary,
        secondaryContainer: colors.secondaryDark,
        surface: colors.surface,
        background: colors.background,
        error: colors.error,
        onPrimary: brightness == Brightness.light ? Colors.white : Colors.black,
        onSecondary: brightness == Brightness.light ? Colors.white : Colors.black,
        onSurface: colors.textPrimary,
        onBackground: colors.textPrimary,
        onError: Colors.white,
        brightness: brightness,
      ).copyWith(background: colors.background),
    );
  }
}
