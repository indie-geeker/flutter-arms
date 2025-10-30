class ApiResponse<T> {
  final int? code;
  final String? message;
  final T data;
  /// 额外信息
  final Map<String, dynamic> extra;

  ApiResponse({
    required this.code,
    required this.message,
    required this.data,
    this.extra = const {}
  });

  /// Creates a copy of this ApiResponse with the given fields replaced.
  ApiResponse<T> copyWith({
    int? code,
    String? message,
    T? data,
    Map<String, dynamic>? extra,
  }) {
    return ApiResponse<T>(
      code: code ?? this.code,
      message: message ?? this.message,
      data: data ?? this.data,
      extra: extra ?? this.extra,
    );
  }
}