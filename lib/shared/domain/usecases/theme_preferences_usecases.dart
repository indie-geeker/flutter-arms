import 'package:flutter/material.dart';

import '../repositories/theme_preferences_repository.dart';

/// 获取主题模式用例
class GetThemeModeUseCase {
  final ThemePreferencesRepository _repository;
  
  GetThemeModeUseCase(this._repository);
  
  Future<ThemeMode> call() async {
    final themeMode = await _repository.getThemeMode();
    return themeMode ?? ThemeMode.system; // 默认使用系统主题
  }
}

/// 保存主题模式用例
class SaveThemeModeUseCase {
  final ThemePreferencesRepository _repository;
  
  SaveThemeModeUseCase(this._repository);
  
  Future<bool> call(ThemeMode themeMode) {
    return _repository.saveThemeMode(themeMode);
  }
}

/// 获取主题颜色用例
class GetThemeColorsUseCase {
  final ThemePreferencesRepository _repository;
  
  GetThemeColorsUseCase(this._repository);
  
  Future<({Color? primary, Color? secondary})> call() async {
    final primaryColor = await _repository.getPrimaryColor();
    final secondaryColor = await _repository.getSecondaryColor();
    
    return (primary: primaryColor, secondary: secondaryColor);
  }
}

/// 保存主题颜色用例
class SaveThemeColorsUseCase {
  final ThemePreferencesRepository _repository;
  
  SaveThemeColorsUseCase(this._repository);
  
  Future<bool> call({required Color primary, required Color secondary}) async {
    final savePrimary = await _repository.savePrimaryColor(primary);
    final saveSecondary = await _repository.saveSecondaryColor(secondary);
    
    return savePrimary && saveSecondary;
  }
}

/// 获取字体用例
class GetFontFamilyUseCase {
  final ThemePreferencesRepository _repository;
  
  GetFontFamilyUseCase(this._repository);
  
  Future<String> call() async {
    final fontFamily = await _repository.getFontFamily();
    return fontFamily ?? 'PingFang SC'; // 默认字体
  }
}

/// 保存字体用例
class SaveFontFamilyUseCase {
  final ThemePreferencesRepository _repository;
  
  SaveFontFamilyUseCase(this._repository);
  
  Future<bool> call(String fontFamily) {
    return _repository.saveFontFamily(fontFamily);
  }
}
