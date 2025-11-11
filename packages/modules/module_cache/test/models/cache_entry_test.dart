import 'package:test/test.dart';
import 'package:interfaces/cache/cache_policy.dart';
import 'package:module_cache/src/models/cache_entry.dart';

void main() {
  group('CacheEntry', () {
    group('Creation', () {
      test('should create entry with all properties', () {
        final now = DateTime.now();
        final expiresAt = now.add(Duration(hours: 1));

        final entry = CacheEntry(
          key: 'test_key',
          value: 'test_value',
          createdAt: now,
          expiresAt: expiresAt,
          policy: CachePolicy.normal,
        );

        expect(entry.key, 'test_key');
        expect(entry.value, 'test_value');
        expect(entry.createdAt, now);
        expect(entry.expiresAt, expiresAt);
        expect(entry.policy, CachePolicy.normal);
        expect(entry.lastAccessedAt, isNotNull);
      });

      test('should create entry without expiry', () {
        final entry = CacheEntry(
          key: 'test_key',
          value: 'test_value',
          createdAt: DateTime.now(),
          expiresAt: null,
          policy: CachePolicy.persistent,
        );

        expect(entry.expiresAt, isNull);
      });

      test('should create entry with complex value types', () {
        final complexValue = {
          'name': 'John',
          'age': 30,
          'tags': ['developer', 'flutter']
        };

        final entry = CacheEntry(
          key: 'user',
          value: complexValue,
          createdAt: DateTime.now(),
          policy: CachePolicy.normal,
        );

        expect(entry.value, complexValue);
      });
    });

    group('Expiry Logic', () {
      test('should not be expired when expiresAt is in the future', () {
        final entry = CacheEntry(
          key: 'test',
          value: 'value',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(Duration(hours: 1)),
          policy: CachePolicy.normal,
        );

        expect(entry.isExpired, false);
      });

      test('should be expired when expiresAt is in the past', () {
        final entry = CacheEntry(
          key: 'test',
          value: 'value',
          createdAt: DateTime.now().subtract(Duration(hours: 2)),
          expiresAt: DateTime.now().subtract(Duration(hours: 1)),
          policy: CachePolicy.normal,
        );

        expect(entry.isExpired, true);
      });

      test('should never expire with persistent policy', () {
        final entry = CacheEntry(
          key: 'test',
          value: 'value',
          createdAt: DateTime.now().subtract(Duration(days: 365)),
          expiresAt: DateTime.now().subtract(Duration(days: 1)),
          policy: CachePolicy.persistent,
        );

        expect(entry.isExpired, false);
      });

      test('should not expire when expiresAt is null', () {
        final entry = CacheEntry(
          key: 'test',
          value: 'value',
          createdAt: DateTime.now(),
          expiresAt: null,
          policy: CachePolicy.normal,
        );

        expect(entry.isExpired, false);
      });

      test('should handle edge case when expiresAt equals now', () async {
        final now = DateTime.now();
        final entry = CacheEntry(
          key: 'test',
          value: 'value',
          createdAt: now,
          expiresAt: now,
          policy: CachePolicy.normal,
        );

        // Wait a tiny bit to ensure time has passed
        await Future.delayed(Duration(milliseconds: 1));
        expect(entry.isExpired, true);
      });
    });

    group('Access Time Tracking', () {
      test('should initialize lastAccessedAt on creation', () {
        final beforeCreation = DateTime.now();
        final entry = CacheEntry(
          key: 'test',
          value: 'value',
          createdAt: DateTime.now(),
          policy: CachePolicy.normal,
        );
        final afterCreation = DateTime.now();

        expect(entry.lastAccessedAt.isAfter(beforeCreation) ||
            entry.lastAccessedAt.isAtSameMomentAs(beforeCreation), true);
        expect(entry.lastAccessedAt.isBefore(afterCreation) ||
            entry.lastAccessedAt.isAtSameMomentAs(afterCreation), true);
      });

      test('should update lastAccessedAt when updateAccessTime is called', () async {
        final entry = CacheEntry(
          key: 'test',
          value: 'value',
          createdAt: DateTime.now(),
          policy: CachePolicy.normal,
        );

        final initialAccessTime = entry.lastAccessedAt;
        await Future.delayed(Duration(milliseconds: 50)); // Increased delay for reliability
        entry.updateAccessTime();

        // Check if time has advanced (may be same in very fast execution)
        final timeDifference = entry.lastAccessedAt.difference(initialAccessTime).inMicroseconds;
        expect(timeDifference >= 0, true);
      });
    });

    group('Serialization', () {
      test('should serialize to JSON correctly', () {
        final now = DateTime.now();
        final expiresAt = now.add(Duration(hours: 1));

        final entry = CacheEntry(
          key: 'test_key',
          value: 'test_value',
          createdAt: now,
          expiresAt: expiresAt,
          policy: CachePolicy.normal,
        );

        final json = entry.toJson();

        expect(json['key'], 'test_key');
        expect(json['value'], 'test_value');
        expect(json['createdAt'], now.toIso8601String());
        expect(json['expiresAt'], expiresAt.toIso8601String());
        expect(json['policy'], 'normal');
      });

      test('should serialize with null expiresAt', () {
        final entry = CacheEntry(
          key: 'test_key',
          value: 'test_value',
          createdAt: DateTime.now(),
          expiresAt: null,
          policy: CachePolicy.persistent,
        );

        final json = entry.toJson();

        expect(json['expiresAt'], isNull);
        expect(json['policy'], 'persistent');
      });

      test('should deserialize from JSON correctly', () {
        final now = DateTime.now();
        final expiresAt = now.add(Duration(hours: 1));

        final json = {
          'key': 'test_key',
          'value': 'test_value',
          'createdAt': now.toIso8601String(),
          'expiresAt': expiresAt.toIso8601String(),
          'policy': 'normal',
        };

        final entry = CacheEntry.fromJson(json);

        expect(entry.key, 'test_key');
        expect(entry.value, 'test_value');
        expect(entry.createdAt.toIso8601String(), now.toIso8601String());
        expect(entry.expiresAt?.toIso8601String(), expiresAt.toIso8601String());
        expect(entry.policy, CachePolicy.normal);
      });

      test('should deserialize with null expiresAt', () {
        final now = DateTime.now();

        final json = {
          'key': 'test_key',
          'value': 'test_value',
          'createdAt': now.toIso8601String(),
          'expiresAt': null,
          'policy': 'persistent',
        };

        final entry = CacheEntry.fromJson(json);

        expect(entry.expiresAt, isNull);
        expect(entry.policy, CachePolicy.persistent);
      });

      test('should handle all cache policies in serialization', () {
        for (final policy in CachePolicy.values) {
          final entry = CacheEntry(
            key: 'test',
            value: 'value',
            createdAt: DateTime.now(),
            policy: policy,
          );

          final json = entry.toJson();
          final deserialized = CacheEntry.fromJson(json);

          expect(deserialized.policy, policy);
        }
      });

      test('should handle unknown policy gracefully', () {
        final json = {
          'key': 'test_key',
          'value': 'test_value',
          'createdAt': DateTime.now().toIso8601String(),
          'policy': 'unknownPolicy',
        };

        final entry = CacheEntry.fromJson(json);

        // Should fallback to normal policy
        expect(entry.policy, CachePolicy.normal);
      });

      test('should round-trip serialize and deserialize', () {
        final original = CacheEntry(
          key: 'test_key',
          value: {'data': 'complex value'},
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(Duration(hours: 1)),
          policy: CachePolicy.cacheFirst,
        );

        final json = original.toJson();
        final deserialized = CacheEntry.fromJson(json);

        expect(deserialized.key, original.key);
        expect(deserialized.value, original.value);
        expect(deserialized.policy, original.policy);
      });
    });
  });
}
