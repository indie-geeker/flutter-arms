import 'package:app_interfaces/app_interfaces.dart';

/// 默认响应适配器实现
/// 可通过构造函数参数自定义字段名
class DefaultResponseAdapter implements IResponseAdapter {
  /// 状态码字段名
  final String statusCodeField;

  /// 成功状态码值
  final dynamic successStatusValue;

  /// 消息字段名
  final String messageField;

  /// 数据字段名
  /// 构造函数，允许自定义字段名和成功状态值
  const DefaultResponseAdapter({
    this.statusCodeField = 'code',
    this.successStatusValue = 200,
    this.dataField = 'data',
    this.messageField = 'message',
  });

  final String dataField;

  @override
  bool isSuccess(Map<String, dynamic> response) {
    return response.containsKey(statusCodeField) &&
        response[statusCodeField] == successStatusValue;
  }

  @override
  String getMessage(Map<String, dynamic> response) {
    return response[messageField]?.toString() ?? '';
  }

  @override
  dynamic getStatusCode(Map<String, dynamic> response) {
    return response[statusCodeField];
  }

  @override
  dynamic getData(Map<String, dynamic> response) {
    return response[dataField];
  }
}