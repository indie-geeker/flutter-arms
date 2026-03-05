import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'locale_state.freezed.dart';

/// Application locale enum.
enum AppLocale {
  english(Locale('en', 'US'), 'English'),
  chinese(Locale('zh', 'CN'), '中文');

  const AppLocale(this.locale, this.displayName);

  final Locale locale;
  final String displayName;
}

/// Locale state.
///
/// Manages the application locale setting.
@freezed
abstract class LocaleState with _$LocaleState {
  const factory LocaleState({
    @Default(true) bool isLoading,
    @Default(AppLocale.english) AppLocale appLocale,
  }) = _LocaleState;
}
