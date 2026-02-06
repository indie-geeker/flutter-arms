
/// 请求取消令牌
///
/// 用于取消正在进行的网络请求
abstract class CancelToken {
  /// 取消请求
  void cancel([String? reason]);

  /// 请求是否已取消
  bool get isCancelled;

  /// 注册取消监听器
  ///
  /// 当取消发生时回调，并传入取消原因（可空）
  void addListener(void Function(String? reason) listener);

  /// 创建新的取消令牌
  factory CancelToken() = _CancelTokenImpl;
}

/// 默认的取消令牌实现
class _CancelTokenImpl implements CancelToken {
  bool _cancelled = false;
  String? _cancelReason;
  final List<void Function(String? reason)> _listeners = [];

  @override
  void cancel([String? reason]) {
    _cancelled = true;
    _cancelReason = reason;
    for (final listener in _listeners) {
      listener(reason);
    }
  }

  @override
  bool get isCancelled => _cancelled;

  @override
  void addListener(void Function(String? reason) listener) {
    _listeners.add(listener);
    if (_cancelled) {
      listener(_cancelReason);
    }
  }

  String? get cancelReason => _cancelReason;
}

/// 进度回调函数类型
///
/// [current] 当前进度（字节数）
/// [total] 总大小（字节数）
typedef ProgressCallback = void Function(int current, int total);

/// 表单数据抽象接口
///
/// 用于文件上传等场景
abstract class FormData {
  /// 添加字段
  void addField(String key, String value);

  /// 添加文件
  void addFile(String key, FormFile file);

  /// 获取所有字段
  Map<String, String> get fields;

  /// 获取所有文件
  Map<String, FormFile> get files;
}

/// 表单文件
class FormFile {
  /// 文件路径（原生平台可用）
  final String? filePath;

  /// 文件字节（Web 推荐）
  final List<int>? bytes;

  /// 文件名（可选，默认从路径提取）
  final String? filename;

  /// 内容类型（可选）
  final String? contentType;

  FormFile({
    this.filePath,
    this.bytes,
    this.filename,
    this.contentType,
  }) : assert(
          (filePath != null && filePath != '') || bytes != null,
          'Either filePath or bytes must be provided.',
        );

  /// 是否包含文件路径
  bool get hasFilePath => filePath != null && filePath!.isNotEmpty;

  /// 是否包含文件字节
  bool get hasBytes => bytes != null;

  /// 从文件路径创建
  factory FormFile.fromPath(
      String filePath, {
        String? filename,
        String? contentType,
      }) {
    return FormFile(
      filePath: filePath,
      filename: filename,
      contentType: contentType,
    );
  }

  /// 从文件字节创建
  factory FormFile.fromBytes(
    List<int> bytes, {
    String? filename,
    String? contentType,
  }) {
    return FormFile(
      bytes: bytes,
      filename: filename,
      contentType: contentType,
    );
  }
}
