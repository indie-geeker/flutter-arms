import 'dart:convert';

import 'package:app_interfaces/app_interfaces.dart';

import 'encrypt_utils.dart';

/// 存储工具类
///
/// 提供存储相关的通用工具方法
class StorageUtils {
  // 私有构造函数，防止实例化
  StorageUtils._();


  /// 加密字符串
  ///
  /// [config] 存储配置
  /// [value] 原始字符串
  /// 返回加密后的字符串，如果未启用加密则返回原始字符串
  static String? encryptString(StorageConfig config, String? value) {
    if (value == null) return null;
    if (!config.enableEncryption || config.encryptionKey == null) return value;

    return EncryptUtils.encryptText(value, config.encryptionKey!);
  }

  /// 解密字符串
  ///
  /// [config] 存储配置
  /// [value] 加密字符串
  /// 返回解密后的字符串，如果未启用加密则返回原始字符串
  static String? decryptString(StorageConfig config, String? value) {
    if (value == null) return null;
    if (!config.enableEncryption || config.encryptionKey == null) return value;

    return EncryptUtils.decryptText(value, config.encryptionKey!);
  }

  /// 序列化对象为JSON字符串
  ///
  /// [value] 对象
  /// 返回JSON字符串
  static String? encodeJson<T>(T? value) {
    if (value == null) return null;
    return jsonEncode(value);
  }

  /// 反序列化JSON字符串为对象
  ///
  /// [value] JSON字符串
  /// [fromJson] 从JSON转换函数
  /// 返回对象
  static T? decodeJson<T>(String? value, T Function(Map<String, dynamic> json) fromJson) {
    if (value == null) return null;
    try {
      final map = jsonDecode(value) as Map<String, dynamic>;
      return fromJson(map);
    } catch (e) {
      return null;
    }
  }

  /// 生成键名前缀
  ///
  /// [config] 存储配置
  /// [collection] 集合名称（可选）
  /// 返回带有前缀的键名
  static String generateKeyPrefix(StorageConfig config, [String? collection]) {
    if (collection == null || collection.isEmpty) {
      return config.name;
    }
    return '${config.name}_$collection';
  }

  /// 生成完整键名
  ///
  /// [config] 存储配置
  /// [key] 键名
  /// [collection] 集合名称（可选）
  /// 返回带有前缀的完整键名
  static String generateFullKey(StorageConfig config, String key, [String? collection]) {
    final prefix = generateKeyPrefix(config, collection);
    return '${prefix}_$key';
  }
}