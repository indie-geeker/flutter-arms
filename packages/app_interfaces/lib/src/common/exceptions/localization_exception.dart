import 'app_exception.dart';

/// 国际化异常
///
/// 表示与国际化、本地化相关的异常
class LocalizationException extends AppException {
  /// 创建国际化异常
  ///
  /// [message] 异常消息
  /// [locale] 相关的语言区域代码
  /// [key] 本地化键值
  /// [code] 异常代码
  /// [details] 详细信息
  /// [stackTrace] 堆栈跟踪
  const LocalizationException({
    required super.message,
    this.locale,
    this.key,
    super.code = 'localization_error',
    super.details,
    super.stackTrace,
  });

  /// 语言区域代码
  final String? locale;

  /// 本地化键值
  final String? key;

  @override
  String toString() {
    final buffer = StringBuffer('LocalizationException: [$code] $message');
    if (locale != null || key != null) {
      buffer.write(' (');
      if (locale != null) {
        buffer.write('locale: $locale');
      }
      if (locale != null && key != null) {
        buffer.write(', ');
      }
      if (key != null) {
        buffer.write('key: $key');
      }
      buffer.write(')');
    }
    return buffer.toString();
  }
}

/// 缺失翻译异常
///
/// 当请求的翻译键不存在时抛出
class MissingTranslationException extends LocalizationException {
  /// 创建缺失翻译异常
  ///
  /// [key] 缺失的翻译键
  /// [locale] 当前语言区域代码
  /// [fallback] 回退使用的值
  /// [details] 详细信息
  /// [stackTrace] 堆栈跟踪
  const MissingTranslationException({
    required String super.key,
    required String super.locale,
    this.fallback,
    super.details,
    super.stackTrace,
  }) : super(
          message: '找不到翻译键 "$key" (区域: $locale)',
          code: 'missing_translation',
        );

  /// 回退使用的值
  final String? fallback;

  @override
  String toString() {
    final buffer = StringBuffer(
        'MissingTranslationException: [$code] $message');
    if (fallback != null) {
      buffer.write(' (fallback: "$fallback")');
    }
    return buffer.toString();
  }
}

/// 不支持的区域异常
///
/// 当请求的语言区域不受支持时抛出
class UnsupportedLocaleException extends LocalizationException {
  /// 创建不支持的区域异常
  ///
  /// [locale] 不支持的语言区域代码
  /// [supportedLocales] 支持的语言区域代码列表
  /// [details] 详细信息
  /// [stackTrace] 堆栈跟踪
  const UnsupportedLocaleException({
    required String super.locale,
    this.supportedLocales,
    super.details,
    super.stackTrace,
  }) : super(
          message: '不支持的语言区域: $locale',
          code: 'unsupported_locale',
        );

  /// 支持的语言区域代码列表
  final List<String>? supportedLocales;

  @override
  String toString() {
    final buffer = StringBuffer(
        'UnsupportedLocaleException: [$code] $message');
    if (supportedLocales != null && supportedLocales!.isNotEmpty) {
      buffer.write(' (支持的区域: ${supportedLocales!.join(', ')})');
    }
    return buffer.toString();
  }
}
