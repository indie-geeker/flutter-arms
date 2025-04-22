import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../core/cache/cache_service.dart';
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
  final CacheService _cacheService;
  
  ThemePreferencesDataSourceImpl(this._cacheService);
  
  @override
  Future<ThemeMode?> getThemeMode() async {
    final value = await _cacheService.get<String>(StorageKeys.themeMode);
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
    
    await _cacheService.set<String>(StorageKeys.themeMode, value);
    return true;
  }
  
  @override
  Future<Color?> getPrimaryColor() async {
    final value = await _cacheService.get<int>(StorageKeys.primaryColor);
    if (value == null) return null;
    
    return Color(value);
  }
  
  @override
  Future<bool> savePrimaryColor(Color color) async {
    await _cacheService.set<int>(StorageKeys.primaryColor, color.value);
    return true;
  }
  
  @override
  Future<Color?> getSecondaryColor() async {
    final value = await _cacheService.get<int>(StorageKeys.secondaryColor);
    if (value == null) return null;
    
    return Color(value);
  }
  
  @override
  Future<bool> saveSecondaryColor(Color color) async {
    await _cacheService.set<int>(StorageKeys.secondaryColor, color.value);
    return true;
  }
  
  @override
  Future<String?> getFontFamily() async {
    return await _cacheService.get<String>(StorageKeys.fontFamily);
  }
  
  @override
  Future<bool> saveFontFamily(String fontFamily) async {
    await _cacheService.set<String>(StorageKeys.fontFamily, fontFamily);
    return true;
  }
}
