import 'storage_file_utils_stub.dart'
    if (dart.library.io) 'storage_file_utils_io.dart';

Future<int> getFileSize(String? path) => getFileSizeImpl(path);
