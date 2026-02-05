import 'package:test/test.dart';
import 'package:module_storage/src/utils/storage_serializer.dart';

void main() {
  group('StorageSerializer', () {
    late StorageSerializer serializer;

    setUp(() {
      serializer = StorageSerializer();
    });

    group('Basic Types Serialization', () {
      test('should serialize and deserialize String', () {
        const value = 'Hello World';
        final serialized = serializer.serialize(value);
        final deserialized = serializer.deserialize<String>(serialized);
        expect(deserialized, equals(value));
      });

      test('should serialize and deserialize int', () {
        const value = 42;
        final serialized = serializer.serialize(value);
        final deserialized = serializer.deserialize<int>(serialized);
        expect(deserialized, equals(value));
      });

      test('should serialize and deserialize double', () {
        const value = 3.14159;
        final serialized = serializer.serialize(value);
        final deserialized = serializer.deserialize<double>(serialized);
        expect(deserialized, equals(value));
      });

      test('should serialize and deserialize bool', () {
        const value = true;
        final serialized = serializer.serialize(value);
        final deserialized = serializer.deserialize<bool>(serialized);
        expect(deserialized, equals(value));
      });

      test('should serialize and deserialize null', () {
        const String? value = null;
        final serialized = serializer.serialize(value);
        final deserialized = serializer.deserialize<String?>(serialized);
        expect(deserialized, isNull);
      });
    });

    group('Collection Types Serialization', () {
      test('should serialize and deserialize List', () {
        final value = [1, 2, 3, 4, 5];
        final serialized = serializer.serialize(value);
        final deserialized = serializer.deserialize<List>(serialized);
        expect(deserialized, equals(value));
      });

      test('should serialize and deserialize Map', () {
        final value = {'name': 'John', 'age': 30, 'active': true};
        final serialized = serializer.serialize(value);
        final deserialized =
            serializer.deserialize<Map<String, dynamic>>(serialized);
        expect(deserialized, equals(value));
      });

      test('should serialize and deserialize nested structures', () {
        final value = {
          'user': {
            'id': 1,
            'name': 'John Doe',
            'tags': ['admin', 'user'],
          },
          'metadata': {
            'created': '2024-01-01',
            'active': true,
          },
        };
        final serialized = serializer.serialize(value);
        final deserialized =
            serializer.deserialize<Map<String, dynamic>>(serialized);
        expect(deserialized, equals(value));
      });
    });

    group('Custom Serializer', () {
      test('should register and use custom serializer', () {
        // Register custom serializer
        serializer.registerSerializer<User>(UserSerializer());

        final user = User(id: 1, name: 'John Doe', email: 'john@example.com');
        final serialized = serializer.serialize(user);
        final deserialized = serializer.deserialize<User>(serialized);

        expect(deserialized.id, equals(user.id));
        expect(deserialized.name, equals(user.name));
        expect(deserialized.email, equals(user.email));
      });

      test('should check if serializer is registered', () {
        expect(serializer.hasSerializer<User>(), isFalse);

        serializer.registerSerializer<User>(UserSerializer());
        expect(serializer.hasSerializer<User>(), isTrue);
      });

      test('should unregister custom serializer', () {
        serializer.registerSerializer<User>(UserSerializer());
        expect(serializer.hasSerializer<User>(), isTrue);

        serializer.unregisterSerializer<User>();
        expect(serializer.hasSerializer<User>(), isFalse);
      });
    });

    group('Error Handling', () {
      test('should throw SerializationException for unsupported type', () {
        final unsupportedValue = DateTime.now();
        expect(
          () => serializer.serialize(unsupportedValue),
          throwsA(isA<SerializationException>()),
        );
      });

      test('should throw DeserializationException for invalid data', () {
        const invalidJson = 'invalid json {]';
        expect(
          () => serializer.deserialize<Map>(invalidJson),
          throwsA(isA<DeserializationException>()),
        );
      });

      test('trySerialize should return null on error', () {
        final unsupportedValue = DateTime.now();
        final result = serializer.trySerialize(unsupportedValue);
        expect(result, isNull);
      });

      test('tryDeserialize should return null on error', () {
        const invalidJson = 'invalid json {]';
        final result = serializer.tryDeserialize<Map>(invalidJson);
        expect(result, isNull);
      });
    });

    group('Batch Operations', () {
      test('should serialize batch of data', () {
        final data = {
          'name': 'John',
          'age': 30,
          'active': true,
          'score': 98.5,
        };

        final serialized = serializer.serializeBatch(data);

        expect(serialized.keys, equals(data.keys));
      });

      test('should deserialize batch of data', () {
        final data = {
          'name': '"John"',
          'age': '30',
          'active': 'true',
          'score': '98.5',
        };

        final deserialized = serializer.deserializeBatch(data);

        expect(deserialized['name'], equals('John'));
        expect(deserialized['age'], equals(30));
        expect(deserialized['active'], equals(true));
        expect(deserialized['score'], equals(98.5));
      });
    });

    group('Type Conversion', () {
      test('should convert string to int', () {
        const value = '42';
        final deserialized = serializer.deserialize<int>(value);
        expect(deserialized, equals(42));
      });

      test('should convert string to double', () {
        const value = '3.14';
        final deserialized = serializer.deserialize<double>(value);
        expect(deserialized, equals(3.14));
      });

      test('should convert string to bool', () {
        expect(serializer.deserialize<bool>('"true"'), isTrue);
        expect(serializer.deserialize<bool>('"false"'), isFalse);
        expect(serializer.deserialize<bool>('"1"'), isTrue);
        expect(serializer.deserialize<bool>('"0"'), isFalse);
      });

      test('should convert number to bool', () {
        expect(serializer.deserialize<bool>('1'), isTrue);
        expect(serializer.deserialize<bool>('0'), isFalse);
      });
    });
  });
}

// Test classes
class User {
  final int id;
  final String name;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.email,
  });
}

class UserSerializer implements ISerializer<User> {
  @override
  String serialize(User value) {
    return '${value.id}|${value.name}|${value.email}';
  }

  @override
  User deserialize(String value) {
    final parts = value.split('|');
    return User(
      id: int.parse(parts[0]),
      name: parts[1],
      email: parts[2],
    );
  }
}
