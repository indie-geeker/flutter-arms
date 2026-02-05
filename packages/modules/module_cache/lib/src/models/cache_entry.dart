
import 'dart:convert';

import 'package:interfaces/cache/cache_policy.dart';

/// 缓存条目
/// 
/// 支持安全的序列化/反序列化，能够处理非 JSON 兼容类型
class CacheEntry {
  final String key;
  final dynamic value;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final CachePolicy policy;
  DateTime lastAccessedAt;

  CacheEntry({
    required this.key,
    required this.value,
    required this.createdAt,
    this.expiresAt,
    required this.policy,
  }) : lastAccessedAt = DateTime.now();

  bool get isExpired {
    if (policy == CachePolicy.persistent) return false;
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  void updateAccessTime() {
    lastAccessedAt = DateTime.now();
  }

  /// 检查值是否可安全序列化为 JSON
  bool get isSerializable {
    try {
      jsonEncode(_serializeValue(value));
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 安全序列化为 JSON Map
  /// 
  /// 如果 value 无法序列化，将存储 null 值并记录类型信息
  Map<String, dynamic> toJson() {
    dynamic serializedValue;
    String? valueType;
    
    try {
      serializedValue = _serializeValue(value);
      // 验证可以 encode
      jsonEncode(serializedValue);
    } catch (e) {
      // 无法序列化时存储 null 和类型信息
      serializedValue = null;
      valueType = value.runtimeType.toString();
    }
    
    return {
      'key': key,
      'value': serializedValue,
      'valueType': valueType,  // 仅当序列化失败时非空
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'policy': policy.name,
    };
  }

  /// 尝试序列化常见类型
  dynamic _serializeValue(dynamic val) {
    if (val == null) return null;
    if (val is String || val is num || val is bool) return val;
    if (val is DateTime) return val.toIso8601String();
    if (val is List) return val.map(_serializeValue).toList();
    if (val is Map) {
      return val.map((k, v) => MapEntry(k.toString(), _serializeValue(v)));
    }
    // 尝试调用 toJson (如 freezed/json_serializable 生成的类)
    if (val is Object) {
      try {
        final dynamic toJsonMethod = (val as dynamic).toJson;
        if (toJsonMethod != null) {
          return toJsonMethod();
        }
      } catch (_) {
        // 无 toJson 方法，直接返回原值让 jsonEncode 处理
      }
    }
    return val;
  }

  factory CacheEntry.fromJson(Map<String, dynamic> json) => CacheEntry(
    key: json['key'],
    value: json['value'],  // 可能为 null 如果原值无法序列化
    createdAt: DateTime.parse(json['createdAt']),
    expiresAt: json['expiresAt'] != null
        ? DateTime.parse(json['expiresAt'])
        : null,
    policy: CachePolicy.values.firstWhere(
          (e) => e.name == json['policy'],
      orElse: () => CachePolicy.normal,
    ),
  );
}