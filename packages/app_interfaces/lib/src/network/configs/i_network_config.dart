import 'package:app_interfaces/src/network/parser/response_parser.dart';

abstract class INetWorkConfig{
  String get baseUrl;
  Duration get receiveTimeout;
  Duration get connectTimeout;

  /// 响应解析器（已弃用，请使用 ResponseParserInterceptor）
  @Deprecated('Use ResponseParserInterceptor instead')
  ResponseParser? get responseParser;
}