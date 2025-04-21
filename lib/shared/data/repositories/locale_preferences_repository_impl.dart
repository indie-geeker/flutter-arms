import 'package:flutter/material.dart';

import '../../domain/repositories/locale_preferences_repository.dart';
import '../datasources/local/locale_preferences_data_source.dart';

/// 语言偏好仓库实现
class LocalePreferencesRepositoryImpl implements LocalePreferencesRepository {
  final LocalePreferencesDataSource _dataSource;
  
  LocalePreferencesRepositoryImpl(this._dataSource);
  
  @override
  Future<Locale?> getLocale() {
    return _dataSource.getLocale();
  }
  
  @override
  Future<bool> saveLocale(Locale locale) {
    return _dataSource.saveLocale(locale);
  }
}
