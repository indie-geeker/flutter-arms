import 'dart:io';

/// 平台工具。
class PlatformUtils {
  PlatformUtils._();

  /// 是否 Android。
  static bool get isAndroid => Platform.isAndroid;

  /// 是否 iOS。
  static bool get isIOS => Platform.isIOS;

  /// 是否桌面端。
  static bool get isDesktop => Platform.isMacOS || Platform.isWindows || Platform.isLinux;
}
