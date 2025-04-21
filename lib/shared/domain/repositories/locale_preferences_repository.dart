import 'package:flutter/material.dart';

/// 语言偏好仓库接口
abstract class LocalePreferencesRepository {
  /// 保存语言设置
  Future<bool> saveLocale(Locale locale);
  
  /// 获取语言设置
  Future<Locale?> getLocale();
}
