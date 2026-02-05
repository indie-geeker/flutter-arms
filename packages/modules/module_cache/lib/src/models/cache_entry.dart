
import 'dart:convert';

import 'package:interfaces/cache/cache_policy.dart';

/// 缓存值序列化器
abstract class CacheValueSerializer<T> {
  /// 自定义类型标识
  String get type;

  /// 序列化为 JSON 可编码对象
  dynamic toJson(T value);

  /// 从 JSON 反序列化
  T fromJson(dynamic json);
}

/// 缓存值序列化器注册表
class CacheValueRegistry {
  final Map<Type, CacheValueSerializer> _byRuntimeType = {};
  final Map<String, CacheValueSerializer> _byTypeKey = {};

  void register<T>(CacheValueSerializer<T> serializer) {
    _byRuntimeType[T] = serializer;
    _byTypeKey[serializer.type] = serializer;
  }

  CacheValueSerializer? serializerForValue(Object value) {
    return _byRuntimeType[value.runtimeType];
  }

  CacheValueSerializer? serializerForType(String typeKey) {
    return _byTypeKey[typeKey];
  }
}

/// 缓存条目
///
/// 支持安全的序列化/反序列化，能够处理非 JSON 兼容类型，
/// 并允许通过 CacheValueRegistry 为自定义类型提供序列化器。
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
  Map<String, dynamic> toJson({CacheValueRegistry? registry}) {
    dynamic serializedValue;
    String? valueType;

    final registrySerializer =
        value != null && registry != null ? registry.serializerForValue(value) : null;
    if (registrySerializer != null) {
      try {
        serializedValue = registrySerializer.toJson(value);
        valueType = registrySerializer.type;
        jsonEncode(serializedValue);
      } catch (_) {
        serializedValue = null;
        valueType = registrySerializer.type;
      }
    } else {
      try {
        serializedValue = _serializeValue(value);
        // 验证可以 encode
        jsonEncode(serializedValue);
      } catch (e) {
        // 无法序列化时存储 null 和类型信息
        serializedValue = null;
        valueType = value.runtimeType.toString();
      }
    }

    return {
      'key': key,
      'value': serializedValue,
      'valueType': valueType,  // 使用注册表或序列化失败时非空
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

  factory CacheEntry.fromJson(
    Map<String, dynamic> json, {
    CacheValueRegistry? registry,
  }) {
    final valueType = json['valueType'] as String?;
    dynamic value = json['value'];

    if (valueType != null && registry != null) {
      final serializer = registry.serializerForType(valueType);
      if (serializer != null) {
        try {
          value = serializer.fromJson(value);
        } catch (_) {
          // fallback to raw value
        }
      }
    }

    return CacheEntry(
      key: json['key'],
      value: value,  // 可能为 null 如果原值无法序列化
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
}
