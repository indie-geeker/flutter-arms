class ResponseWrapper<T> {
  final int? code;
  final String? message;
  final T data;
  /// 额外信息
  final Map<String, dynamic> extra;
  ResponseWrapper({
    required this.code,
    required this.message,
    required this.data,
    this.extra = const {}
  });
}