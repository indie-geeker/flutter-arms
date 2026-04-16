import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_arms/core/storage/kv_storage.dart';

class _MockKvStorage extends Mock implements KvStorage {}

void main() {
  late _MockKvStorage storage;

  setUp(() {
    storage = _MockKvStorage();
  });

  group('locale persistence', () {
    test('getLocale returns null when no locale saved', () {
      when(() => storage.getLocale()).thenReturn(null);
      expect(storage.getLocale(), isNull);
    });

    test('getLocale returns stored locale string', () {
      when(() => storage.getLocale()).thenReturn('zh');
      expect(storage.getLocale(), equals('zh'));
    });

    test('setLocale persists locale string', () async {
      when(() => storage.setLocale(any())).thenAnswer((_) async {});
      await storage.setLocale('en');
      verify(() => storage.setLocale('en')).called(1);
    });
  });
}
