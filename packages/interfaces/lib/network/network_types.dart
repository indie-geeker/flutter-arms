/// Request cancellation token.
///
/// Used to cancel an in-progress network request.
abstract class CancelToken {
  /// Cancels the request.
  void cancel([String? reason]);

  /// Whether the request has been cancelled.
  bool get isCancelled;

  /// Registers a cancellation listener.
  ///
  /// The callback is invoked when cancellation occurs, passing the cancel
  /// reason (nullable).
  void addListener(void Function(String? reason) listener);

  /// Creates a new cancel token.
  factory CancelToken() = _CancelTokenImpl;
}

/// Default cancel token implementation.
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

/// Progress callback function type.
///
/// [current] Current progress in bytes.
/// [total] Total size in bytes.
typedef ProgressCallback = void Function(int current, int total);

/// Abstract form data interface.
///
/// Used for file uploads and similar scenarios.
abstract class FormData {
  /// Adds a field.
  void addField(String key, String value);

  /// Adds a file.
  void addFile(String key, FormFile file);

  /// Returns all fields.
  Map<String, String> get fields;

  /// Returns all files.
  Map<String, FormFile> get files;
}

/// Form file.
class FormFile {
  /// File path (available on native platforms).
  final String? filePath;

  /// File bytes (recommended for Web).
  final List<int>? bytes;

  /// File name (optional, defaults to extracting from path).
  final String? filename;

  /// Content type (optional).
  final String? contentType;

  FormFile({this.filePath, this.bytes, this.filename, this.contentType})
    : assert(
        (filePath != null && filePath != '') || bytes != null,
        'Either filePath or bytes must be provided.',
      );

  /// Whether a file path is available.
  bool get hasFilePath => filePath != null && filePath!.isNotEmpty;

  /// Whether file bytes are available.
  bool get hasBytes => bytes != null;

  /// Creates from a file path.
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

  /// Creates from file bytes.
  factory FormFile.fromBytes(
    List<int> bytes, {
    String? filename,
    String? contentType,
  }) {
    return FormFile(bytes: bytes, filename: filename, contentType: contentType);
  }
}
