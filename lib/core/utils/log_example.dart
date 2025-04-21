import 'logger_util.dart';

/// 日志使用示例
class LogExample {
  /// 演示各种日志级别的使用
  void demonstrateLogging() {
    // 详细日志 - 用于详细的调试信息
    logger.v('这是一个详细日志');
    
    // 调试日志 - 用于一般调试信息
    logger.d('这是一个调试日志');
    
    // 信息日志 - 用于一般信息
    logger.i('这是一个信息日志');
    
    // 警告日志 - 用于警告信息
    logger.w('这是一个警告日志');
    
    // 错误日志 - 用于错误信息
    logger.e('这是一个错误日志', Exception('发生了一个错误'));
    
    // 严重错误日志 - 用于严重错误信息
    try {
      throw Exception('发生了一个严重错误');
    } catch (e, stackTrace) {
      logger.wtf('这是一个严重错误日志', e, stackTrace);
    }
  }
  
  /// 演示在网络请求中使用日志
  void logNetworkRequest(String url, Map<String, dynamic> params, dynamic response) {
    logger.d('发送请求: $url');
    logger.v('请求参数: $params');
    
    if (response != null) {
      logger.i('请求成功: $url');
      logger.v('响应数据: $response');
    } else {
      logger.e('请求失败: $url');
    }
  }
  
  /// 演示在异常处理中使用日志
  void handleException(String operation, dynamic error, StackTrace? stackTrace) {
    logger.e('$operation 失败', error, stackTrace);
    
    // 可以在这里添加其他异常处理逻辑
    // 例如上报错误到服务器、显示错误提示等
  }
}
