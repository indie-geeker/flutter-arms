import 'package:flutter/material.dart';

/// 主题偏好仓库接口
abstract class ThemePreferencesRepository {
  /// 保存主题模式
  Future<bool> saveThemeMode(ThemeMode themeMode);
  
  /// 获取主题模式
  Future<ThemeMode?> getThemeMode();
  
  /// 保存主色调
  Future<bool> savePrimaryColor(Color color);
  
  /// 获取主色调
  Future<Color?> getPrimaryColor();
  
  /// 保存次要色调
  Future<bool> saveSecondaryColor(Color color);
  
  /// 获取次要色调
  Future<Color?> getSecondaryColor();
  
  /// 保存字体
  Future<bool> saveFontFamily(String fontFamily);
  
  /// 获取字体
  Future<String?> getFontFamily();
}
