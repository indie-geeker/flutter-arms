import 'package:app_interfaces/src/network/parser/response_parser.dart';

abstract class INetWorkConfig{
  String get baseUrl;
  Duration get receiveTimeout;
  Duration get connectTimeout;
  ResponseParser get responseParser;
}