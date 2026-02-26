import 'dart:io';

import 'package:module_network/src/impl/dio_form_data_adapter.dart';
import 'package:interfaces/interfaces.dart';
import 'package:test/test.dart';

void main() {
  group('DioFormDataAdapter', () {
    test('stores fields and files as unmodifiable maps', () {
      final adapter = DioFormDataAdapter();
      adapter.addField('name', 'alice');
      adapter.addFile(
        'avatar',
        FormFile.fromBytes([1, 2, 3], filename: 'a.bin'),
      );

      expect(adapter.fields, {'name': 'alice'});
      expect(adapter.files.keys, contains('avatar'));
      expect(() => adapter.fields['extra'] = 'x', throwsUnsupportedError);
      expect(
        () => adapter.files['extra'] = FormFile.fromBytes([9]),
        throwsUnsupportedError,
      );
    });

    test('converts byte-backed FormFile to Dio FormData', () async {
      final adapter = DioFormDataAdapter()
        ..addField('user', 'alice')
        ..addFile(
          'avatar',
          FormFile.fromBytes(
            [1, 2, 3, 4],
            filename: 'avatar.png',
            contentType: 'image/png',
          ),
        );

      final formData = await adapter.toDioFormData();
      final fields = Map<String, String>.fromEntries(formData.fields);

      expect(fields['user'], 'alice');
      expect(formData.files.length, 1);
      expect(formData.files.first.key, 'avatar');
      expect(formData.files.first.value.filename, 'avatar.png');
      expect(formData.files.first.value.contentType?.mimeType, 'image/png');
    });

    test(
      'converts path-backed FormFile to Dio FormData on io platforms',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'dio-formdata-test',
        );
        addTearDown(() => tempDir.delete(recursive: true));
        final file = File('${tempDir.path}/payload.txt');
        await file.writeAsString('payload');

        final adapter = DioFormDataAdapter()
          ..addFile(
            'file',
            FormFile.fromPath(
              file.path,
              filename: 'payload.txt',
              contentType: 'text/plain',
            ),
          );

        final formData = await adapter.toDioFormData();

        expect(formData.files.length, 1);
        expect(formData.files.first.key, 'file');
        expect(formData.files.first.value.filename, 'payload.txt');
        expect(formData.files.first.value.contentType?.mimeType, 'text/plain');
        expect(formData.files.first.value.length, greaterThan(0));
      },
    );

    test('fromMap only imports string fields and FormFile entries', () async {
      final adapter = DioFormDataAdapter.fromMap({
        'name': 'alice',
        'avatar': FormFile.fromBytes([1, 2, 3], filename: 'a.bin'),
        'ignored-int': 1,
        'ignored-map': {'k': 'v'},
      });

      final formData = await adapter.toDioFormData();
      final fields = Map<String, String>.fromEntries(formData.fields);

      expect(adapter.fields, {'name': 'alice'});
      expect(adapter.files.keys, contains('avatar'));
      expect(adapter.fields.containsKey('ignored-int'), isFalse);
      expect(fields['name'], 'alice');
      expect(formData.files.length, 1);
    });
  });
}
