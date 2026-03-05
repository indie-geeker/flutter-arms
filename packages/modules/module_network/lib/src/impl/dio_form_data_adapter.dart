import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:interfaces/interfaces.dart';

/// Dio FormData adapter.
///
/// Adapts interfaces FormData to Dio FormData.
class DioFormDataAdapter implements FormData {
  final Map<String, String> _fields = {};
  final Map<String, FormFile> _files = {};

  /// Creates empty FormData.
  DioFormDataAdapter();

  @override
  void addField(String key, String value) {
    _fields[key] = value;
  }

  @override
  void addFile(String key, FormFile file) {
    _files[key] = file;
  }

  @override
  Map<String, String> get fields => Map.unmodifiable(_fields);

  @override
  Map<String, FormFile> get files => Map.unmodifiable(_files);

  /// Converts to Dio FormData.
  Future<dio.FormData> toDioFormData() async {
    final formDataMap = <String, dynamic>{};

    // Add regular fields.
    _fields.forEach((key, value) {
      formDataMap[key] = value;
    });

    // Add files.
    for (final entry in _files.entries) {
      final file = entry.value;
      final contentType = file.contentType != null
          ? MediaType.parse(file.contentType!)
          : null;

      if (file.hasBytes) {
        formDataMap[entry.key] = dio.MultipartFile.fromBytes(
          file.bytes!,
          filename: file.filename,
          contentType: contentType,
        );
        continue;
      }

      if (!file.hasFilePath) {
        throw ArgumentError('FormFile requires either filePath or bytes.');
      }

      if (kIsWeb) {
        throw UnsupportedError(
          'FormFile.fromPath is not supported on Web. '
          'Use FormFile.fromBytes instead.',
        );
      }

      formDataMap[entry.key] = await dio.MultipartFile.fromFile(
        file.filePath!,
        filename: file.filename,
        contentType: contentType,
      );
    }

    return dio.FormData.fromMap(formDataMap);
  }

  /// Creates from a Map.
  factory DioFormDataAdapter.fromMap(Map<String, dynamic> map) {
    final adapter = DioFormDataAdapter();
    map.forEach((key, value) {
      if (value is String) {
        adapter.addField(key, value);
      } else if (value is FormFile) {
        adapter.addFile(key, value);
      }
    });
    return adapter;
  }
}
