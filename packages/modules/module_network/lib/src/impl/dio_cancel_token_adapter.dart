
import 'package:dio/dio.dart' as dio;
import 'package:interfaces/interfaces.dart';

/// Dio CancelToken 适配器
///
/// 将 interfaces 的 CancelToken 适配到 Dio 的 CancelToken
class DioCancelTokenAdapter implements CancelToken {
  final dio.CancelToken _dioToken;

  DioCancelTokenAdapter() : _dioToken = dio.CancelToken();

  /// 获取内部的 Dio CancelToken
  dio.CancelToken get dioToken => _dioToken;

  @override
  void cancel([String? reason]) {
    _dioToken.cancel(reason);
  }

  @override
  bool get isCancelled => _dioToken.isCancelled;
}