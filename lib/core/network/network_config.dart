import 'package:dio/dio.dart';

class NetworkConfig {
  static const String baseUrl = 'https://api.example.com'; // 替换为实际的API基础URL
  static const int connectTimeout = 5000;
  static const int receiveTimeout = 3000;
  static const int sendTimeout = 3000;

  static BaseOptions get options => BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(milliseconds: connectTimeout),
        receiveTimeout: Duration(milliseconds: receiveTimeout),
        sendTimeout: Duration(milliseconds: sendTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
}
