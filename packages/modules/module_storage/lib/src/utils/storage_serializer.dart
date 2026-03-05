import 'dart:convert';

/// Custom serializer interface.
/// Supports serialization and deserialization of custom types.
abstract class ISerializer<T> {
  /// Serializes an object to a string.
  String serialize(T value);

  /// Deserializes from a string to an object.
  T deserialize(String value);
}

/// Storage serialization utility.
/// Provides type-safe serialization/deserialization.
class StorageSerializer {
  /// Registered custom serializers.
  final Map<Type, ISerializer> _serializers = {};

  /// Registers a custom serializer.
  ///
  /// Example:
  /// ```dart
  /// serializer.registerSerializer<User>(UserSerializer());
  /// ```
  void registerSerializer<T>(ISerializer<T> serializer) {
    _serializers[T] = serializer;
  }

  /// Unregisters a custom serializer.
  void unregisterSerializer<T>() {
    _serializers.remove(T);
  }

  /// Checks whether a serializer is registered for the given type.
  bool hasSerializer<T>() {
    return _serializers.containsKey(T);
  }

  /// Serializes an object to a string.
  ///
  /// Supported types:
  /// - Primitive types: String, int, double, bool
  /// - Collection types: List, Map, Set
  /// - Custom types (serializer registration required)
  ///
  /// Throws [SerializationException] if the type is unsupported or serialization fails.
  String serialize<T>(T value) {
    try {
      // Handle null value.
      if (value == null) {
        return jsonEncode(null);
      }

      // Use custom serializer.
      if (_serializers.containsKey(T)) {
        final serializer = _serializers[T] as ISerializer<T>;
        return serializer.serialize(value);
      }

      // Handle primitive types and JSON-serializable types.
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
      throw SerializationException('Failed to serialize value of type $T: $e');
    }
  }

  /// Deserializes from a string to an object.
  ///
  /// Throws [DeserializationException] if deserialization fails.
  T deserialize<T>(String value) {
    try {
      // Use custom serializer.
      if (_serializers.containsKey(T)) {
        final serializer = _serializers[T] as ISerializer<T>;
        return serializer.deserialize(value);
      }

      // Decode JSON.
      final decoded = jsonDecode(value);

      // Handle null value.
      if (decoded == null) {
        return null as T;
      }

      // Type check and conversion.
      if (decoded is T) {
        return decoded;
      }

      // Attempt type conversion.
      return _castValue<T>(decoded);
    } catch (e) {
      throw DeserializationException(
        'Failed to deserialize value to type $T: $e',
      );
    }
  }

  /// Attempts type conversion.
  T _castValue<T>(dynamic value) {
    // String conversion.
    if (T == String) {
      return value.toString() as T;
    }

    // Integer conversion.
    if (T == int) {
      if (value is int) return value as T;
      if (value is num) return value.toInt() as T;
      if (value is String) return int.parse(value) as T;
      throw DeserializationException('Cannot convert $value to int');
    }

    // Double conversion.
    if (T == double) {
      if (value is double) return value as T;
      if (value is num) return value.toDouble() as T;
      if (value is String) return double.parse(value) as T;
      throw DeserializationException('Cannot convert $value to double');
    }

    // Boolean conversion.
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

    // List conversion.
    if (value is List) {
      return value as T;
    }

    // Map conversion.
    if (value is Map) {
      return value as T;
    }

    throw DeserializationException('Cannot cast value to type $T');
  }

  /// Batch serialization.
  ///
  /// Serializes multiple key-value pairs to `Map<String, String>`.
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

  /// Batch deserialization.
  ///
  /// Deserializes a `Map<String, String>` to `Map<String, dynamic>`.
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

  /// Safe serialization.
  ///
  /// Returns null instead of throwing an exception.
  String? trySerialize<T>(T value) {
    try {
      return serialize(value);
    } catch (_) {
      return null;
    }
  }

  /// Safe deserialization.
  ///
  /// Returns null instead of throwing an exception.
  T? tryDeserialize<T>(String value) {
    try {
      return deserialize<T>(value);
    } catch (_) {
      return null;
    }
  }
}

/// Serialization exception.
class SerializationException implements Exception {
  final String message;

  SerializationException(this.message);

  @override
  String toString() => 'SerializationException: $message';
}

/// Deserialization exception.
class DeserializationException implements Exception {
  final String message;

  DeserializationException(this.message);

  @override
  String toString() => 'DeserializationException: $message';
}

/// Default global serializer instance.
final globalSerializer = StorageSerializer();
