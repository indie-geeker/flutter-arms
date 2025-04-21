import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di/injection.dart';

// 生成的代码将在此文件中
part 'locale_providers.g.dart';

/// 支持的语言列表
final supportedLocales = [
  const Locale('zh', 'CN'), // 简体中文
  const Locale('en', 'US'), // 英文（美国）
];

/// 语言设置提供者
@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Future<Locale> build() async {
    // 从持久化存储加载语言设置
    final getLocaleUseCase = ref.watch(getLocaleUseCaseProvider);
    return await getLocaleUseCase();
  }
  
  /// 更新语言设置
  Future<void> updateLocale(Locale locale) async {
    // 检查是否支持该语言
    if (!_isSupportedLocale(locale)) {
      throw UnsupportedError('不支持的语言: $locale');
    }
    
    // 保存到持久化存储
    final saveLocaleUseCase = ref.read(saveLocaleUseCaseProvider);
    await saveLocaleUseCase(locale);
    
    // 更新状态
    state = AsyncData(locale);
  }
  
  /// 切换到下一个语言
  Future<void> toggleNextLocale() async {
    final currentLocale = state.valueOrNull;
    if (currentLocale == null) {
      await updateLocale(supportedLocales.first);
      return;
    }
    
    // 找到当前语言在支持列表中的索引
    final currentIndex = supportedLocales.indexWhere(
      (locale) => locale.languageCode == currentLocale.languageCode && 
                  locale.countryCode == currentLocale.countryCode
    );
    
    // 如果找不到当前语言，或者当前语言是最后一个，则切换到第一个语言
    // 否则切换到下一个语言
    final nextIndex = (currentIndex == -1 || currentIndex == supportedLocales.length - 1) 
        ? 0 
        : currentIndex + 1;
    
    await updateLocale(supportedLocales[nextIndex]);
  }
  
  /// 检查是否支持该语言
  bool _isSupportedLocale(Locale locale) {
    return supportedLocales.any(
      (supportedLocale) => 
        supportedLocale.languageCode == locale.languageCode && 
        supportedLocale.countryCode == locale.countryCode
    );
  }
}

/// 当前语言名称提供者
@riverpod
String currentLocaleName(CurrentLocaleNameRef ref) {
  final localeAsync = ref.watch(localeNotifierProvider);
  
  return localeAsync.when(
    data: (locale) {
      if (locale.languageCode == 'zh' && locale.countryCode == 'CN') {
        return '简体中文';
      } else if (locale.languageCode == 'en' && locale.countryCode == 'US') {
        return 'English (US)';
      } else {
        return '${locale.languageCode}_${locale.countryCode}';
      }
    },
    loading: () => '加载中...',
    error: (_, __) => '未知',
  );
}
