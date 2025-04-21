import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/storage_keys.dart';

/// 主题偏好本地数据源接口
abstract class ThemePreferencesDataSource {
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

/// 主题偏好本地数据源实现
class ThemePreferencesDataSourceImpl implements ThemePreferencesDataSource {
  final SharedPreferences _preferences;
  
  ThemePreferencesDataSourceImpl(this._preferences);
  
  @override
  Future<ThemeMode?> getThemeMode() async {
    final value = _preferences.getString(StorageKeys.themeMode);
    if (value == null) return null;
    
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return null;
    }
  }
  
  @override
  Future<bool> saveThemeMode(ThemeMode themeMode) async {
    String value;
    switch (themeMode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.system:
        value = 'system';
        break;
    }
    
    return await _preferences.setString(StorageKeys.themeMode, value);
  }
  
  @override
  Future<Color?> getPrimaryColor() async {
    final value = _preferences.getInt(StorageKeys.primaryColor);
    if (value == null) return null;
    
    return Color(value);
  }
  
  @override
  Future<bool> savePrimaryColor(Color color) async {
    return await _preferences.setInt(StorageKeys.primaryColor, color.value);
  }
  
  @override
  Future<Color?> getSecondaryColor() async {
    final value = _preferences.getInt(StorageKeys.secondaryColor);
    if (value == null) return null;
    
    return Color(value);
  }
  
  @override
  Future<bool> saveSecondaryColor(Color color) async {
    return await _preferences.setInt(StorageKeys.secondaryColor, color.value);
  }
  
  @override
  Future<String?> getFontFamily() async {
    return _preferences.getString(StorageKeys.fontFamily);
  }
  
  @override
  Future<bool> saveFontFamily(String fontFamily) async {
    return await _preferences.setString(StorageKeys.fontFamily, fontFamily);
  }
}
