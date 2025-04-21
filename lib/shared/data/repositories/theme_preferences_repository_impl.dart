import 'package:flutter/material.dart';

import '../../domain/repositories/theme_preferences_repository.dart';
import '../datasources/local/theme_preferences_data_source.dart';

/// 主题偏好仓库实现
class ThemePreferencesRepositoryImpl implements ThemePreferencesRepository {
  final ThemePreferencesDataSource _dataSource;
  
  ThemePreferencesRepositoryImpl(this._dataSource);
  
  @override
  Future<ThemeMode?> getThemeMode() {
    return _dataSource.getThemeMode();
  }
  
  @override
  Future<bool> saveThemeMode(ThemeMode themeMode) {
    return _dataSource.saveThemeMode(themeMode);
  }
  
  @override
  Future<Color?> getPrimaryColor() {
    return _dataSource.getPrimaryColor();
  }
  
  @override
  Future<bool> savePrimaryColor(Color color) {
    return _dataSource.savePrimaryColor(color);
  }
  
  @override
  Future<Color?> getSecondaryColor() {
    return _dataSource.getSecondaryColor();
  }
  
  @override
  Future<bool> saveSecondaryColor(Color color) {
    return _dataSource.saveSecondaryColor(color);
  }
  
  @override
  Future<String?> getFontFamily() {
    return _dataSource.getFontFamily();
  }
  
  @override
  Future<bool> saveFontFamily(String fontFamily) {
    return _dataSource.saveFontFamily(fontFamily);
  }
}
