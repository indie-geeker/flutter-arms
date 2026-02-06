import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

Future<void> triggerWebDownload({
  required List<int> bytes,
  required String fileName,
  String? mimeType,
}) async {
  final safeName = fileName.trim().isEmpty ? 'download.bin' : fileName.trim();
  final blobBytes = [Uint8List.fromList(bytes).toJS].toJS;
  final blob = mimeType == null
      ? web.Blob(blobBytes)
      : web.Blob(blobBytes, web.BlobPropertyBag(type: mimeType));
  final url = web.URL.createObjectURL(blob);

  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = safeName
    ..style.display = 'none';

  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
}
