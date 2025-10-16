import 'package:app_interfaces/app_interfaces.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyThemeManager implements IThemeManager {
  final IThemeConfig config;
  final IKeyValueStorage? storage;

  late final ValueNotifier<ThemeMode> _themeModeNotifier;
  late final ValueNotifier<Color?> _themeColorNotifier;

  MyThemeManager({
    required this.config,
    this.storage,
  })  : _themeModeNotifier = ValueNotifier(config.defaultThemeMode),
        _themeColorNotifier = ValueNotifier(null);

  @override
  ThemeMode get currentThemeMode => _themeModeNotifier.value;

  @override
  ValueListenable<ThemeMode> get themeModeNotifier => _themeModeNotifier;

  @override
  Color? get customThemeColor => _themeColorNotifier.value;

  @override
  ValueListenable<Color?> get themeColorNotifier => _themeColorNotifier;

  /// 获取当前有效的种子色（自定义色优先，否则使用默认色）
  Color get _effectiveSeedColor =>
      customThemeColor ?? config.defaultSeedColor;

  @override
  ThemeData get lightTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _effectiveSeedColor,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );

  @override
  ThemeData get darkTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _effectiveSeedColor,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );

  @override
  Future<void> initialize() async {
    if (storage == null) return;

    // 从存储恢复主题模式
    final savedMode = await storage!.getString(config.themeModeStorageKey);
    if (savedMode != null) {
      _themeModeNotifier.value = _parseThemeMode(savedMode);
    }

    // 从存储恢复自定义主题色（如果启用）
    if (config.enableCustomThemeColor) {
      final savedColorValue = await storage!.getInt(config.themeColorStorageKey);
      if (savedColorValue != null) {
        _themeColorNotifier.value = Color(savedColorValue);
      }
    }
  }

  @override
  Future<bool> setThemeMode(ThemeMode mode) async {
    _themeModeNotifier.value = mode;

    // 持久化到存储
    if (storage != null) {
      await storage!.setString(config.themeModeStorageKey, mode.toString());
    }

    return true;
  }

  @override
  Future<bool> setThemeColor(Color? color) async {
    if (!config.enableCustomThemeColor) {
      return false; // 功能未启用
    }

    _themeColorNotifier.value = color;

    // 持久化到存储
    if (storage != null) {
      if (color != null) {
        await storage!.setInt(config.themeColorStorageKey, color.value);
      } else {
        await storage!.remove(config.themeColorStorageKey);
      }
    }

    return true;
  }

  @override
  Future<void> resetTheme() async {
    await setThemeMode(config.defaultThemeMode);
    await setThemeColor(null); // 恢复默认主题色
  }

  @override
  ThemeData getCurrentTheme(Brightness platformBrightness) {
    switch (currentThemeMode) {
      case ThemeMode.light:
        return lightTheme;
      case ThemeMode.dark:
        return darkTheme;
      case ThemeMode.system:
        return platformBrightness == Brightness.dark ? darkTheme : lightTheme;
    }
  }

  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'ThemeMode.light':
        return ThemeMode.light;
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      case 'ThemeMode.system':
        return ThemeMode.system;
      default:
        return config.defaultThemeMode;
    }
  }
}