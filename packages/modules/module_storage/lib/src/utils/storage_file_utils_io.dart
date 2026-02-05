import 'dart:io';

Future<int> getFileSizeImpl(String? path) async {
  if (path == null) return 0;
  final file = File(path);
  if (await file.exists()) {
    return await file.length();
  }
  return 0;
}
