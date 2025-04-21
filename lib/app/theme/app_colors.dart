import 'package:flutter/material.dart';

/// 应用颜色配置
class AppColors {
  // 主要颜色
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  
  // 次要颜色
  final Color secondary;
  final Color secondaryLight;
  final Color secondaryDark;
  
  // 背景颜色
  final Color background;
  final Color surface;
  final Color scaffoldBackground;
  
  // 文字颜色
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  
  // 功能颜色
  final Color error;
  final Color success;
  final Color warning;
  final Color info;
  
  // 其他颜色
  final Color divider;
  final Color disabled;
  
  const AppColors({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.secondary,
    required this.secondaryLight,
    required this.secondaryDark,
    required this.background,
    required this.surface,
    required this.scaffoldBackground,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.error,
    required this.success,
    required this.warning,
    required this.info,
    required this.divider,
    required this.disabled,
  });
  
  /// 浅色主题颜色
  static const AppColors light = AppColors(
    primary: Color(0xFF1E88E5),        // 蓝色
    primaryLight: Color(0xFF64B5F6),
    primaryDark: Color(0xFF0D47A1),
    secondary: Color(0xFFE91E63),      // 粉色
    secondaryLight: Color(0xFFF48FB1),
    secondaryDark: Color(0xFFAD1457),
    background: Color(0xFFFFFFFF),     // 白色
    surface: Color(0xFFF5F5F5),
    scaffoldBackground: Color(0xFFF0F0F0),
    textPrimary: Color(0xFF212121),    // 近黑色
    textSecondary: Color(0xFF757575),  // 灰色
    textHint: Color(0xFF9E9E9E),       // 浅灰色
    error: Color(0xFFD32F2F),          // 红色
    success: Color(0xFF388E3C),        // 绿色
    warning: Color(0xFFFFA000),        // 琥珀色
    info: Color(0xFF0288D1),           // 蓝色
    divider: Color(0xFFBDBDBD),        // 浅灰色
    disabled: Color(0xFFE0E0E0),       // 更浅的灰色
  );
  
  /// 深色主题颜色
  static const AppColors dark = AppColors(
    primary: Color(0xFF42A5F5),        // 亮蓝色
    primaryLight: Color(0xFF90CAF9),
    primaryDark: Color(0xFF1565C0),
    secondary: Color(0xFFEC407A),      // 亮粉色
    secondaryLight: Color(0xFFF8BBD0),
    secondaryDark: Color(0xFFC2185B),
    background: Color(0xFF121212),     // 深灰色
    surface: Color(0xFF1E1E1E),
    scaffoldBackground: Color(0xFF121212),
    textPrimary: Color(0xFFFFFFFF),    // 白色
    textSecondary: Color(0xFFB0B0B0),  // 浅灰色
    textHint: Color(0xFF757575),       // 灰色
    error: Color(0xFFEF5350),          // 亮红色
    success: Color(0xFF66BB6A),        // 亮绿色
    warning: Color(0xFFFFCA28),        // 亮琥珀色
    info: Color(0xFF29B6F6),           // 亮蓝色
    divider: Color(0xFF424242),        // 深灰色
    disabled: Color(0xFF757575),       // 灰色
  );
}
