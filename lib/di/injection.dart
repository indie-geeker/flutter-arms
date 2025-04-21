import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../shared/data/datasources/local/theme_preferences_data_source.dart';
import '../shared/data/repositories/theme_preferences_repository_impl.dart';
import '../shared/domain/repositories/theme_preferences_repository.dart';
import '../shared/domain/usecases/theme_preferences_usecases.dart';

import '../shared/data/datasources/local/locale_preferences_data_source.dart';
import '../shared/data/repositories/locale_preferences_repository_impl.dart';
import '../shared/domain/repositories/locale_preferences_repository.dart';
import '../shared/domain/usecases/locale_preferences_usecases.dart';
part 'injection.g.dart';

/// SharedPreferences 提供者
@riverpod
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError('需要在 ProviderScope.overrides 中初始化');
}

// ==================== 主题相关提供者 ====================

/// 主题偏好数据源提供者
@riverpod
ThemePreferencesDataSource themePreferencesDataSource(Ref ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return ThemePreferencesDataSourceImpl(sharedPreferences);
}

/// 主题偏好仓库提供者
@riverpod
ThemePreferencesRepository themePreferencesRepository(Ref ref) {
  final dataSource = ref.watch(themePreferencesDataSourceProvider);
  return ThemePreferencesRepositoryImpl(dataSource);
}

/// 获取主题模式用例提供者
@riverpod
GetThemeModeUseCase getThemeModeUseCase(Ref ref) {
  final repository = ref.watch(themePreferencesRepositoryProvider);
  return GetThemeModeUseCase(repository);
}

/// 保存主题模式用例提供者
@riverpod
SaveThemeModeUseCase saveThemeModeUseCase(Ref ref) {
  final repository = ref.watch(themePreferencesRepositoryProvider);
  return SaveThemeModeUseCase(repository);
}

/// 获取主题颜色用例提供者
@riverpod
GetThemeColorsUseCase getThemeColorsUseCase(Ref ref) {
  final repository = ref.watch(themePreferencesRepositoryProvider);
  return GetThemeColorsUseCase(repository);
}

/// 保存主题颜色用例提供者
@riverpod
SaveThemeColorsUseCase saveThemeColorsUseCase(Ref ref) {
  final repository = ref.watch(themePreferencesRepositoryProvider);
  return SaveThemeColorsUseCase(repository);
}

/// 获取字体用例提供者
@riverpod
GetFontFamilyUseCase getFontFamilyUseCase(Ref ref) {
  final repository = ref.watch(themePreferencesRepositoryProvider);
  return GetFontFamilyUseCase(repository);
}

/// 保存字体用例提供者
@riverpod
SaveFontFamilyUseCase saveFontFamilyUseCase(Ref ref) {
  final repository = ref.watch(themePreferencesRepositoryProvider);
  return SaveFontFamilyUseCase(repository);
}

// ==================== 语言相关提供者 ====================

/// 语言偏好数据源提供者
@riverpod
LocalePreferencesDataSource localePreferencesDataSource(Ref ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return LocalePreferencesDataSourceImpl(sharedPreferences);
}

/// 语言偏好仓库提供者
@riverpod
LocalePreferencesRepository localePreferencesRepository(Ref ref) {
  final dataSource = ref.watch(localePreferencesDataSourceProvider);
  return LocalePreferencesRepositoryImpl(dataSource);
}

/// 获取语言设置用例提供者
@riverpod
GetLocaleUseCase getLocaleUseCase(Ref ref) {
  final repository = ref.watch(localePreferencesRepositoryProvider);
  return GetLocaleUseCase(repository);
}

/// 保存语言设置用例提供者
@riverpod
SaveLocaleUseCase saveLocaleUseCase(Ref ref) {
  final repository = ref.watch(localePreferencesRepositoryProvider);
  return SaveLocaleUseCase(repository);
}
