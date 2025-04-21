import 'package:flutter/material.dart';

import '../repositories/locale_preferences_repository.dart';

/// 获取语言设置用例
class GetLocaleUseCase {
  final LocalePreferencesRepository _repository;
  
  GetLocaleUseCase(this._repository);
  
  Future<Locale> call() async {
    final locale = await _repository.getLocale();
    return locale ?? const Locale('zh', 'CN'); // 默认使用简体中文
  }
}

/// 保存语言设置用例
class SaveLocaleUseCase {
  final LocalePreferencesRepository _repository;
  
  SaveLocaleUseCase(this._repository);
  
  Future<bool> call(Locale locale) {
    return _repository.saveLocale(locale);
  }
}
