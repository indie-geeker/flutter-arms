import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../core/cache/cache_service.dart';
import '../../../../core/constants/storage_keys.dart';

/// 语言偏好本地数据源接口
abstract class LocalePreferencesDataSource {
  /// 保存语言设置
  Future<bool> saveLocale(Locale locale);
  
  /// 获取语言设置
  Future<Locale?> getLocale();
}

/// 语言偏好本地数据源实现
class LocalePreferencesDataSourceImpl implements LocalePreferencesDataSource {
  final CacheService _cacheService;
  
  LocalePreferencesDataSourceImpl(this._cacheService);
  
  @override
  Future<Locale?> getLocale() async {
    final value = await _cacheService.get<String>(StorageKeys.locale);
    if (value == null) return null;
    
    final parts = value.split('_');
    if (parts.length == 1) {
      return Locale(parts[0]);
    } else if (parts.length >= 2) {
      return Locale(parts[0], parts[1]);
    }
    
    return null;
  }
  
  @override
  Future<bool> saveLocale(Locale locale) async {
    String value;
    if (locale.countryCode != null) {
      value = '${locale.languageCode}_${locale.countryCode}';
    } else {
      value = locale.languageCode;
    }
    
    await _cacheService.set<String>(StorageKeys.locale, value);
    return true;
  }
}
