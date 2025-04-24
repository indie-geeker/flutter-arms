/// 响应适配器接口
/// 用于适配不同格式的API响应
abstract class ResponseAdapter {
  /// 检查响应是否成功
  bool isSuccess(Map<String, dynamic> response);

  /// 获取响应中的消息
  String getMessage(Map<String, dynamic> response);

  /// 获取响应中的状态码
  dynamic getStatusCode(Map<String, dynamic> response);

  /// 获取响应中的数据部分
  dynamic getData(Map<String, dynamic> response);
}

