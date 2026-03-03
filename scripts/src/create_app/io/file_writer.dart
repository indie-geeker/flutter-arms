import 'dart:io';

class FileWriteResult {
  const FileWriteResult({required this.path, required this.written});

  final String path;
  final bool written;
}

Future<FileWriteResult> writeFile(
  String path,
  String content, {
  required bool overwrite,
}) async {
  final file = File(path);
  if (await file.exists() && !overwrite) {
    return FileWriteResult(path: path, written: false);
  }

  await file.parent.create(recursive: true);
  await file.writeAsString(content);
  return FileWriteResult(path: path, written: true);
}
