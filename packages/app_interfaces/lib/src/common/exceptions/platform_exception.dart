import 'app_exception.dart';

/// 平台异常基类
///
/// 表示与特定平台（Android, iOS等）相关的异常
class PlatformException extends AppException {
  /// 创建平台异常
  ///
  /// [message] 异常消息
  /// [platformName] 平台名称
  /// [nativeCode] 原生平台错误代码
  /// [nativeMessage] 原生平台错误消息
  /// [code] 应用异常代码
  /// [details] 详细信息
  /// [stackTrace] 堆栈跟踪
  const PlatformException({
    required super.message,
    required this.platformName,
    this.nativeCode,
    this.nativeMessage,
    super.code = 'platform_error',
    super.details,
    super.stackTrace,
  });

  /// 平台名称（例如：android, ios, web）
  final String platformName;

  /// 原生平台错误代码
  final String? nativeCode;

  /// 原生平台错误消息
  final String? nativeMessage;

  @override
  String toString() {
    final buffer = StringBuffer('PlatformException: [$platformName][$code] $message');
    if (nativeCode != null) {
      buffer.write(' (native code: $nativeCode');
      if (nativeMessage != null) {
        buffer.write(', native message: $nativeMessage');
      }
      buffer.write(')');
    }
    return buffer.toString();
  }
}

/// Android平台异常
class AndroidException extends PlatformException {
  /// 创建Android平台异常
  ///
  /// [message] 异常消息
  /// [nativeCode] 原生Android错误代码
  /// [nativeMessage] 原生Android错误消息
  /// [code] 应用异常代码
  /// [details] 详细信息
  /// [stackTrace] 堆栈跟踪
  const AndroidException({
    required super.message,
    super.nativeCode,
    super.nativeMessage,
    super.code = 'android_error',
    super.details,
    super.stackTrace,
  }) : super(
          platformName: 'android',
        );
}

/// iOS平台异常
class IosException extends PlatformException {
  /// 创建iOS平台异常
  ///
  /// [message] 异常消息
  /// [nativeCode] 原生iOS错误代码
  /// [nativeMessage] 原生iOS错误消息
  /// [code] 应用异常代码
  /// [details] 详细信息
  /// [stackTrace] 堆栈跟踪
  const IosException({
    required super.message,
    super.nativeCode,
    super.nativeMessage,
    super.code = 'ios_error',
    super.details,
    super.stackTrace,
  }) : super(
          platformName: 'ios',
        );
}

/// MacOS 平台异常
class MacOSException extends PlatformException {
  /// 创建MacOS平台异常
  ///
  /// [message] 异常消息
  /// [nativeCode] 原生 MacOS 错误代码
  /// [nativeMessage] 原生 MacOS 错误消息
  /// [code] 应用异常代码
  /// [details] 详细信息
  /// [stackTrace] 堆栈跟踪
  const MacOSException({
    required super.message,
    super.nativeCode,
    super.nativeMessage,
    super.code = 'macos_error',
    super.details,
    super.stackTrace,
  }) : super(
    platformName: 'macos',
  );
}

/// Windows 平台异常
class WindowsException extends PlatformException {
  /// 创建 Windows 平台异常
  ///
  /// [message] 异常消息
  /// [nativeCode] 原生 Windows 错误代码
  /// [nativeMessage] 原生 Windows 错误消息
  /// [code] 应用异常代码
  /// [details] 详细信息
  /// [stackTrace] 堆栈跟踪
  const WindowsException({
    required super.message,
    super.nativeCode,
    super.nativeMessage,
    super.code = 'windows_error',
    super.details,
    super.stackTrace,
  }) : super(
    platformName: 'windows',
  );
}

/// Web平台异常
class WebException extends PlatformException {
  /// 创建Web平台异常
  ///
  /// [message] 异常消息
  /// [errorType] Web错误类型（例如：TypeError, ReferenceError）
  /// [url] 发生错误的URL
  /// [lineNumber] 发生错误的行号
  /// [columnNumber] 发生错误的列号
  /// [code] 应用异常代码
  /// [details] 详细信息
  /// [stackTrace] 堆栈跟踪
  const WebException({
    required super.message,
    this.errorType,
    this.url,
    this.lineNumber,
    this.columnNumber,
    super.code = 'web_error',
    super.details,
    super.stackTrace,
  }) : super(
          platformName: 'web',
        );

  /// Web错误类型
  final String? errorType;

  /// 发生错误的URL
  final String? url;

  /// 发生错误的行号
  final int? lineNumber;

  /// 发生错误的列号
  final int? columnNumber;

  @override
  String toString() {
    final buffer = StringBuffer('WebException: [$code] $message');
    if (errorType != null) {
      buffer.write(' (type: $errorType');
      if (url != null) {
        buffer.write(', url: $url');
      }
      if (lineNumber != null) {
        buffer.write(', line: $lineNumber');
      }
      if (columnNumber != null) {
        buffer.write(', column: $columnNumber');
      }
      buffer.write(')');
    }
    return buffer.toString();
  }
}
