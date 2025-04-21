import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di/injection.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/theme_config.dart';

// 生成的代码将在此文件中
part 'theme_providers.g.dart';

/// 主题模式提供者
@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  Future<ThemeMode> build() async {
    // 从持久化存储加载主题模式
    final getThemeModeUseCase = ref.watch(getThemeModeUseCaseProvider);
    return await getThemeModeUseCase();
  }
  
  /// 更新主题模式
  Future<void> updateThemeMode(ThemeMode mode) async {
    // 保存到持久化存储
    final saveThemeModeUseCase = ref.read(saveThemeModeUseCaseProvider);
    await saveThemeModeUseCase(mode);
    
    // 更新状态
    state = AsyncData(mode);
  }
  
  /// 切换主题模式
  Future<void> toggleThemeMode() async {
    if (state.valueOrNull == ThemeMode.light) {
      await updateThemeMode(ThemeMode.dark);
    } else {
      await updateThemeMode(ThemeMode.light);
    }
  }
}

/// 自定义主题颜色提供者
@riverpod
class ThemeColorsNotifier extends _$ThemeColorsNotifier {
  @override
  Future<({Color primary, Color secondary})> build() async {
    // 从持久化存储加载主题颜色
    final getThemeColorsUseCase = ref.watch(getThemeColorsUseCaseProvider);
    final colors = await getThemeColorsUseCase();
    
    // 如果没有保存的颜色，使用默认颜色
    return (
      primary: colors.primary ?? AppColors.light.primary,
      secondary: colors.secondary ?? AppColors.light.secondary,
    );
  }
  
  /// 更新主题颜色
  Future<void> updateColors({required Color primary, required Color secondary}) async {
    // 保存到持久化存储
    final saveThemeColorsUseCase = ref.read(saveThemeColorsUseCaseProvider);
    await saveThemeColorsUseCase(primary: primary, secondary: secondary);
    
    // 更新状态
    state = AsyncData((primary: primary, secondary: secondary));
  }
  
  /// 重置为默认颜色
  Future<void> resetToDefault() async {
    await updateColors(
      primary: AppColors.light.primary,
      secondary: AppColors.light.secondary,
    );
  }
}

/// 字体系列提供者
@riverpod
class FontFamilyNotifier extends _$FontFamilyNotifier {
  @override
  Future<String> build() async {
    // 从持久化存储加载字体
    final getFontFamilyUseCase = ref.watch(getFontFamilyUseCaseProvider);
    return await getFontFamilyUseCase();
  }
  
  /// 更新字体
  Future<void> updateFontFamily(String fontFamily) async {
    // 保存到持久化存储
    final saveFontFamilyUseCase = ref.read(saveFontFamilyUseCaseProvider);
    await saveFontFamilyUseCase(fontFamily);
    
    // 更新状态
    state = AsyncData(fontFamily);
  }
}

/// 主题配置提供者 - 组合以上所有提供者
@riverpod
Future<ThemeConfig> themeConfig(ThemeConfigRef ref) async {
  // 等待所有异步提供者完成
  final themeMode = await ref.watch(themeModeNotifierProvider.future);
  final themeColors = await ref.watch(themeColorsNotifierProvider.future);
  final fontFamily = await ref.watch(fontFamilyNotifierProvider.future);
  
  // 如果使用自定义颜色
  if (themeColors.primary != AppColors.light.primary || 
      themeColors.secondary != AppColors.light.secondary) {
    return ThemeConfig.custom(
      themeMode: themeMode,
      fontFamily: fontFamily,
      primaryColor: themeColors.primary,
      secondaryColor: themeColors.secondary,
    );
  }
  
  // 使用默认主题配置，但应用当前的主题模式和字体
  final defaultConfig = ThemeConfig.defaultConfig();
  return defaultConfig.copyWith(
    themeMode: themeMode,
    fontFamily: fontFamily,
  );
}

/// 当前主题提供者 - 根据环境亮度选择适当的主题
@riverpod
Future<AppTheme> currentTheme(CurrentThemeRef ref, BuildContext context) async {
  final config = await ref.watch(themeConfigProvider.future);
  return config.getCurrentTheme(context);
}
