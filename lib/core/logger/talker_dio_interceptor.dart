import 'package:dio/dio.dart';
import 'package:flutter_arms/core/logger/app_log.dart';
import 'package:flutter_arms/core/logger/talker_app_logger.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

/// 创建 Dio 日志拦截器。
Interceptor dioLogInterceptor(AppLog logger) {
  if (logger case final TalkerAppLogger talkerLogger) {
    return TalkerDioLogger(
      talker: talkerLogger.talker,
      settings: const TalkerDioLoggerSettings(printRequestData: true),
    );
  }

  return const Interceptor();
}
