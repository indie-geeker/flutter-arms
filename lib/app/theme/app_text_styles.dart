import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 应用文字样式配置
class AppTextStyles {
  // 标题样式
  final TextStyle headline1;
  final TextStyle headline2;
  final TextStyle headline3;
  final TextStyle headline4;
  final TextStyle headline5;
  final TextStyle headline6;
  
  // 正文样式
  final TextStyle bodyText1;
  final TextStyle bodyText2;
  
  // 其他样式
  final TextStyle subtitle1;
  final TextStyle subtitle2;
  final TextStyle caption;
  final TextStyle button;
  final TextStyle overline;
  
  const AppTextStyles({
    required this.headline1,
    required this.headline2,
    required this.headline3,
    required this.headline4,
    required this.headline5,
    required this.headline6,
    required this.bodyText1,
    required this.bodyText2,
    required this.subtitle1,
    required this.subtitle2,
    required this.caption,
    required this.button,
    required this.overline,
  });
  
  /// 创建浅色主题文字样式
  static AppTextStyles fromLightTheme({
    required String fontFamily,
  }) {
    return AppTextStyles(
      headline1: TextStyle(
        fontFamily: fontFamily,
        fontSize: 96,
        fontWeight: FontWeight.w300,
        color: AppColors.light.textPrimary,
      ),
      headline2: TextStyle(
        fontFamily: fontFamily,
        fontSize: 60,
        fontWeight: FontWeight.w300,
        color: AppColors.light.textPrimary,
      ),
      headline3: TextStyle(
        fontFamily: fontFamily,
        fontSize: 48,
        fontWeight: FontWeight.w400,
        color: AppColors.light.textPrimary,
      ),
      headline4: TextStyle(
        fontFamily: fontFamily,
        fontSize: 34,
        fontWeight: FontWeight.w400,
        color: AppColors.light.textPrimary,
      ),
      headline5: TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: AppColors.light.textPrimary,
      ),
      headline6: TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: AppColors.light.textPrimary,
      ),
      bodyText1: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.light.textPrimary,
      ),
      bodyText2: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.light.textPrimary,
      ),
      subtitle1: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.light.textPrimary,
      ),
      subtitle2: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.light.textPrimary,
      ),
      caption: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.light.textSecondary,
      ),
      button: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.light.textPrimary,
      ),
      overline: TextStyle(
        fontFamily: fontFamily,
        fontSize: 10,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.5,
        color: AppColors.light.textSecondary,
      ),
    );
  }
  
  /// 创建深色主题文字样式
  static AppTextStyles fromDarkTheme({
    required String fontFamily,
  }) {
    return AppTextStyles(
      headline1: TextStyle(
        fontFamily: fontFamily,
        fontSize: 96,
        fontWeight: FontWeight.w300,
        color: AppColors.dark.textPrimary,
      ),
      headline2: TextStyle(
        fontFamily: fontFamily,
        fontSize: 60,
        fontWeight: FontWeight.w300,
        color: AppColors.dark.textPrimary,
      ),
      headline3: TextStyle(
        fontFamily: fontFamily,
        fontSize: 48,
        fontWeight: FontWeight.w400,
        color: AppColors.dark.textPrimary,
      ),
      headline4: TextStyle(
        fontFamily: fontFamily,
        fontSize: 34,
        fontWeight: FontWeight.w400,
        color: AppColors.dark.textPrimary,
      ),
      headline5: TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: AppColors.dark.textPrimary,
      ),
      headline6: TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: AppColors.dark.textPrimary,
      ),
      bodyText1: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.dark.textPrimary,
      ),
      bodyText2: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.dark.textPrimary,
      ),
      subtitle1: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.dark.textPrimary,
      ),
      subtitle2: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.dark.textPrimary,
      ),
      caption: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.dark.textSecondary,
      ),
      button: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.dark.textPrimary,
      ),
      overline: TextStyle(
        fontFamily: fontFamily,
        fontSize: 10,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.5,
        color: AppColors.dark.textSecondary,
      ),
    );
  }
}
