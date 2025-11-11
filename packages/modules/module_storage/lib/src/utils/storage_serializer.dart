import 'dart:convert';

/// 自定义序列化器接口
/// 用于支持自定义类型的序列化和反序列化
abstract class ISerializer<T> {
  /// 将对象序列化为字符串
  String serialize(T value);

  /// 从字符串反序列化为对象
  T deserialize(String value);
}

/// 存储序列化工具类
/// 提供类型安全的序列化/反序列化功能
class StorageSerializer {
  /// 注册的自定义序列化器
  final Map<Type, ISerializer> _serializers = {};

  /// 注册自定义序列化器
  ///
  /// Example:
  /// ```dart
  /// serializer.registerSerializer<User>(UserSerializer());
  /// ```
  void registerSerializer<T>(ISerializer<T> serializer) {
    _serializers[T] = serializer;
  }

  /// 注销自定义序列化器
  void unregisterSerializer<T>() {
    _serializers.remove(T);
  }

  /// 检查是否注册了指定类型的序列化器
  bool hasSerializer<T>() {
    return _serializers.containsKey(T);
  }

  /// 序列化对象为字符串
  ///
  /// 支持的类型：
  /// - 基本类型：String, int, double, bool
  /// - 集合类型：List, Map, Set
  /// - 自定义类型（需要注册序列化器）
  ///
  /// Throws [SerializationException] 如果类型不支持或序列化失败
  String serialize<T>(T value) {
    try {
      // 处理 null 值
      if (value == null) {
        return jsonEncode(null);
      }

      // 使用自定义序列化器
      if (_serializers.containsKey(T)) {
        final serializer = _serializers[T] as ISerializer<T>;
        return serializer.serialize(value);
      }

      // 处理基本类型和可 JSON 序列化的类型
      if (value is String ||
          value is int ||
          value is double ||
          value is bool ||
          value is List ||
          value is Map) {
        return jsonEncode(value);
      }

      throw SerializationException(
        'Type $T is not supported. Register a custom serializer.',
      );
    } catch (e) {
      throw SerializationException(
        'Failed to serialize value of type $T: $e',
      );
    }
  }

  /// 从字符串反序列化为对象
  ///
  /// Throws [DeserializationException] 如果反序列化失败
  T deserialize<T>(String value) {
    try {
      // 使用自定义序列化器
      if (_serializers.containsKey(T)) {
        final serializer = _serializers[T] as ISerializer<T>;
        return serializer.deserialize(value);
      }

      // 解码 JSON
      final decoded = jsonDecode(value);

      // 处理 null 值
      if (decoded == null) {
        return null as T;
      }

      // 类型检查和转换
      if (decoded is T) {
        return decoded;
      }

      // 尝试类型转换
      return _castValue<T>(decoded);
    } catch (e) {
      throw DeserializationException(
        'Failed to deserialize value to type $T: $e',
      );
    }
  }

  /// 尝试类型转换
  T _castValue<T>(dynamic value) {
    // 字符串转换
    if (T == String) {
      return value.toString() as T;
    }

    // 整数转换
    if (T == int) {
      if (value is int) return value as T;
      if (value is num) return value.toInt() as T;
      if (value is String) return int.parse(value) as T;
      throw DeserializationException('Cannot convert $value to int');
    }

    // 浮点数转换
    if (T == double) {
      if (value is double) return value as T;
      if (value is num) return value.toDouble() as T;
      if (value is String) return double.parse(value) as T;
      throw DeserializationException('Cannot convert $value to double');
    }

    // 布尔值转换
    if (T == bool) {
      if (value is bool) return value as T;
      if (value is String) {
        final lower = value.toLowerCase();
        if (lower == 'true' || lower == '1') return true as T;
        if (lower == 'false' || lower == '0') return false as T;
      }
      if (value is int) return (value != 0) as T;
      throw DeserializationException('Cannot convert $value to bool');
    }

    // 列表转换
    if (value is List) {
      return value as T;
    }

    // Map 转换
    if (value is Map) {
      return value as T;
    }

    throw DeserializationException(
      'Cannot cast value to type $T',
    );
  }

  /// 批量序列化
  ///
  /// 将多个键值对序列化为 Map<String, String>
  Map<String, String> serializeBatch(Map<String, dynamic> data) {
    final result = <String, String>{};
    for (final entry in data.entries) {
      try {
        result[entry.key] = serialize(entry.value);
      } catch (e) {
        throw SerializationException(
          'Failed to serialize key "${entry.key}": $e',
        );
      }
    }
    return result;
  }

  /// 批量反序列化
  ///
  /// 将 Map<String, String> 反序列化为 Map<String, dynamic>
  Map<String, dynamic> deserializeBatch(Map<String, String> data) {
    final result = <String, dynamic>{};
    for (final entry in data.entries) {
      try {
        result[entry.key] = deserialize(entry.value);
      } catch (e) {
        throw DeserializationException(
          'Failed to deserialize key "${entry.key}": $e',
        );
      }
    }
    return result;
  }

  /// 安全序列化
  ///
  /// 返回 null 而不是抛出异常
  String? trySerialize<T>(T value) {
    try {
      return serialize(value);
    } catch (_) {
      return null;
    }
  }

  /// 安全反序列化
  ///
  /// 返回 null 而不是抛出异常
  T? tryDeserialize<T>(String value) {
    try {
      return deserialize<T>(value);
    } catch (_) {
      return null;
    }
  }
}

/// 序列化异常
class SerializationException implements Exception {
  final String message;

  SerializationException(this.message);

  @override
  String toString() => 'SerializationException: $message';
}

/// 反序列化异常
class DeserializationException implements Exception {
  final String message;

  DeserializationException(this.message);

  @override
  String toString() => 'DeserializationException: $message';
}

/// 默认的全局序列化器实例
final globalSerializer = StorageSerializer();
