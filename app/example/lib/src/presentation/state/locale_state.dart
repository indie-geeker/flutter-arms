import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'locale_state.freezed.dart';

/// 应用语言枚举
enum AppLocale {
  english(Locale('en', 'US'), 'English'),
  chinese(Locale('zh', 'CN'), '中文');

  const AppLocale(this.locale, this.displayName);

  final Locale locale;
  final String displayName;
}

/// 语言状态
///
/// 管理应用的语言设置
@freezed
abstract class LocaleState with _$LocaleState {
  const factory LocaleState({
    @Default(true) bool isLoading,
    @Default(AppLocale.english) AppLocale appLocale,
  }) = _LocaleState;
}
