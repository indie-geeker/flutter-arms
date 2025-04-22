import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/cache/cache_service.dart';
import '../core/cache/provider/cache_providers.dart';
import '../shared/data/datasources/local/theme_preferences_data_source.dart';
import '../shared/data/repositories/theme_preferences_repository_impl.dart';
import '../shared/domain/repositories/theme_preferences_repository.dart';
import '../shared/domain/usecases/theme_preferences_usecases.dart';

import '../shared/data/datasources/local/locale_preferences_data_source.dart';
import '../shared/data/repositories/locale_preferences_repository_impl.dart';
import '../shared/domain/repositories/locale_preferences_repository.dart';
import '../shared/domain/usecases/locale_preferences_usecases.dart';
part 'injection.g.dart';

/// 缓存服务提供者
@riverpod
CacheService cacheService(Ref ref) {
  // 使用 cacheServiceNotifierProvider 获取缓存服务
  return ref.watch(cacheServiceNotifierProvider).value!;
}

// ==================== 主题相关提供者 ====================

/// 主题偏好数据源提供者
@riverpod
ThemePreferencesDataSource themePreferencesDataSource(Ref ref) {
  // 使用缓存服务替代 SharedPreferences
  final cacheService = ref.watch(cacheServiceNotifierProvider).value!;
  return ThemePreferencesDataSourceImpl(cacheService);
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
  // 使用缓存服务替代 SharedPreferences
  final cacheService = ref.watch(cacheServiceNotifierProvider).value!;
  return LocalePreferencesDataSourceImpl(cacheService);
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
