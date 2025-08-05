import 'package:app_interfaces/src/network/parser/parsed_result.dart';

abstract class ResponseParser{
  ParsedResult<T> parse<T>(Map<String,dynamic> json, T Function(T) fromJson);
}