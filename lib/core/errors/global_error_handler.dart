// lib/core/errors/global_error_handler.dart
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'failures.dart';

class GlobalErrorHandler {
  // 单例模式
  static final GlobalErrorHandler _instance = GlobalErrorHandler._internal();
  factory GlobalErrorHandler() => _instance;
  GlobalErrorHandler._internal();

  // 收集错误信息的回调函数
  Function(Object error, StackTrace stackTrace)? _onError;

  void init({Function(Object error, StackTrace stackTrace)? onError}) {
    _onError = onError;

    // 捕获 Flutter 框架错误
    FlutterError.onError = _handleFlutterError;

    // 捕获异步错误
    PlatformDispatcher.instance.onError = _handlePlatformError;

    // 在应用中捕获未处理的异常
    Isolate.current.addErrorListener(RawReceivePort((pair) {
      final List<dynamic> errorAndStacktrace = pair;
      final error = errorAndStacktrace[0];
      final stackTrace = StackTrace.fromString(errorAndStacktrace[1]);
      _handleError(error, stackTrace);
    }).sendPort);

    // 捕获平台异常
    ErrorWidget.builder = _handleErrorWidget;
  }

  void _handleFlutterError(FlutterErrorDetails details) {
    if (kDebugMode) {
      // 在调试模式下，正常打印错误
      print('_handleFlutterError 捕获到异常: $details');
      FlutterError.dumpErrorToConsole(details);
    } else {
      // 在生产模式下，上报错误
      _handleError(details.exception, details.stack ?? StackTrace.empty);
    }
  }

  bool _handlePlatformError(Object error, StackTrace stack) {
    _handleError(error, stack);
    // 如果返回true，表示异常已处理
    return true;
  }

  void _handleError(Object error, StackTrace stackTrace) {
    // 可以在这里添加日志记录、分析等
    print('_handleError 捕获到异常: $error');
    print('堆栈: $stackTrace');

    if (_onError != null) {
      _onError!(error, stackTrace);
    }

    // 可以在这里添加上报服务，如Firebase Crashlytics
  }

  Widget _handleErrorWidget(FlutterErrorDetails details) {
    // 在UI层显示友好的错误信息
    return Material(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 60),
            SizedBox(height: 16),
            Text(
              '应用发生错误',
              style: TextStyle(fontSize: 20),
            ),
            if (kDebugMode)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(details.exception.toString()),
              ),
          ],
        ),
      ),
    );
  }

  // 显示错误提示
  static void showErrorSnackBar(BuildContext context, Failure failure) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(failure.message ?? '发生错误'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
}


// 初始化全局错误处理器
// main中初始化
// GlobalErrorHandler().init(
// onError: (error, stackTrace) {
// // 错误日志记录
// Logger.error('未捕获异常', error: error, stackTrace: stackTrace);
// // 错误上报服务（可选）
// // CrashReportingService.report(error, stackTrace);
// },
// );