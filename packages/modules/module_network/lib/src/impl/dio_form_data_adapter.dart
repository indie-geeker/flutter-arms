
import 'package:dio/dio.dart' as dio;
import 'package:http_parser/http_parser.dart';
import 'package:interfaces/interfaces.dart';

/// Dio FormData 适配器
///
/// 将 interfaces 的 FormData 适配到 Dio 的 FormData
class DioFormDataAdapter implements FormData {
  final Map<String, String> _fields = {};
  final Map<String, FormFile> _files = {};

  /// 创建空的 FormData
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

  /// 转换为 Dio FormData
  Future<dio.FormData> toDioFormData() async {
    final formDataMap = <String, dynamic>{};

    // 添加普通字段
    _fields.forEach((key, value) {
      formDataMap[key] = value;
    });

    // 添加文件
    for (final entry in _files.entries) {
      final file = entry.value;
      formDataMap[entry.key] = await dio.MultipartFile.fromFile(
        file.filePath,
        filename: file.filename,
        contentType: file.contentType != null
            ? MediaType.parse(file.contentType!)
            : null,
      );
    }

    return dio.FormData.fromMap(formDataMap);
  }

  /// 从 Map 创建
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