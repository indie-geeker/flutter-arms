
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/**
 * Description: 主题管理器接口
 * Author: wen
 * Date: 10/16/25
 **/

/// 定义应用主题管理的规范，由应用层实现具体逻辑
abstract class IThemeManager {
  /// 当前主题模式（浅色/深色/跟随系统）
  ThemeMode get currentThemeMode;

  /// 浅色主题数据
  ThemeData get lightTheme;

  /// 深色主题数据
  ThemeData get darkTheme;

  /// 主题模式变化通知器
  ///
  /// 应用层可以使用 ValueNotifier、ChangeNotifier 或状态管理库实现
  ValueListenable<ThemeMode> get themeModeNotifier;

  /// 当前自定义主题色（可选）
  ///
  /// 返回 null 表示使用默认主题色
  Color? get customThemeColor;

  /// 主题色变化通知器（可选）
  ///
  /// 用于监听主题色的动态变化，支持实时预览
  ValueListenable<Color?>? get themeColorNotifier;

  /// 初始化主题管理器
  ///
  /// 从存储恢复用户主题偏好，加载主题资源等
  Future<void> initialize();

  /// 切换主题模式
  ///
  /// [mode] 新的主题模式
  /// 返回是否切换成功
  Future<bool> setThemeMode(ThemeMode mode);

  /// 设置自定义主题色（可选功能）
  ///
  /// [color] 自定义主题色，传 null 表示恢复默认色
  /// 返回是否设置成功
  Future<bool> setThemeColor(Color? color);

  /// 重置为默认主题
  Future<void> resetTheme();

  /// 获取当前激活的主题数据
  ///
  /// 根据 [currentThemeMode] 和系统设置返回实际使用的主题
  ThemeData getCurrentTheme(Brightness platformBrightness);
}

