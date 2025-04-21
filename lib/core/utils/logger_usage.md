# 日志框架使用指南

## 初始化

在应用程序启动时初始化日志系统：

```dart
import 'package:flutter/material.dart';
import 'package:flutter_arms/core/utils/logger_util.dart';
import 'package:logger/logger.dart';

void main() {
  // 可选：配置日志
  if (kDebugMode) {
    // 在调试模式下启用详细日志
    logger.reconfigure(level: Level.verbose);
  } else {
    // 在发布模式下只记录警告和错误
    logger.reconfigure(level: Level.warning);
  }
  
  runApp(const MyApp());
}
```

## 基本用法

在代码中使用日志：

```dart
import 'package:flutter_arms/core/utils/logger_util.dart';

void someFunction() {
  // 不同级别的日志
  logger.v('详细信息'); // 最低级别，详细的调试信息
  logger.d('调试信息'); // 调试信息
  logger.i('一般信息'); // 一般信息
  logger.w('警告信息'); // 警告
  logger.e('错误信息'); // 错误
  logger.wtf('严重错误'); // 最高级别，严重错误
  
  // 记录异常
  try {
    // 一些可能抛出异常的代码
    throw Exception('发生了一个错误');
  } catch (e, stackTrace) {
    logger.e('捕获到异常', e, stackTrace);
  }
}
```

## 在网络请求中使用

在 Dio 中使用日志拦截器：

```dart
import 'package:dio/dio.dart';
import 'package:flutter_arms/core/network/log_interceptor.dart';

Dio createDio() {
  final dio = Dio();
  
  // 添加日志拦截器
  dio.interceptors.add(
    CustomLogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      logFullData: false, // 设置为 true 可以查看完整的请求/响应数据
      maxDataLength: 2000, // 限制日志长度
    ),
  );
  
  return dio;
}
```

## 高级用法

### 自定义输出目标

将日志同时输出到控制台和文件：

```dart
import 'package:flutter_arms/core/utils/log_config.dart';
import 'package:flutter_arms/core/utils/logger_util.dart';
import 'package:logger/logger.dart';

void setupAdvancedLogging() {
  // 创建多目标输出
  final multiOutput = MultiOutput([
    ConsoleOutput(), // 输出到控制台
    FileOutput('/path/to/app.log'), // 输出到文件
  ]);
  
  // 重新配置日志器
  logger.reconfigure(
    output: multiOutput,
  );
}
```

### 在不同环境中使用不同配置

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_arms/core/utils/logger_util.dart';
import 'package:logger/logger.dart';

void configureLoggerForEnvironment() {
  if (kReleaseMode) {
    // 生产环境：只记录警告和错误，简单格式
    logger.reconfigure(
      level: Level.warning,
      printer: SimplePrinter(printTime: true),
    );
  } else if (kProfileMode) {
    // 性能测试环境：记录信息级别以上，简单格式
    logger.reconfigure(
      level: Level.info,
      printer: SimplePrinter(printTime: true),
    );
  } else {
    // 开发环境：记录所有级别，详细格式
    logger.reconfigure(
      level: Level.verbose,
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
    );
  }
}
```

## 最佳实践

1. **合理使用日志级别**：
   - `verbose`：详细的调试信息，通常只在开发环境使用
   - `debug`：调试信息
   - `info`：一般信息，表示程序正常运行
   - `warning`：警告信息，表示可能的问题
   - `error`：错误信息，表示程序出现错误
   - `wtf`：严重错误，表示程序可能无法继续运行

2. **在发布版本中禁用低级别日志**：
   在发布版本中，建议只记录警告和错误级别的日志，以提高性能并减少日志量。

3. **记录有用的上下文信息**：
   日志应该包含足够的上下文信息，以便于调试问题。例如，记录操作、参数、结果等。

4. **避免记录敏感信息**：
   不要记录密码、令牌等敏感信息。如果必须记录包含敏感信息的对象，请先过滤掉敏感字段。

5. **使用结构化日志**：
   尽量使用结构化的日志格式，而不是简单的字符串拼接，以便于日志分析。
