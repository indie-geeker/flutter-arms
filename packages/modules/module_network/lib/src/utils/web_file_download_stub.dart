Future<void> triggerWebDownload({
  required List<int> bytes,
  required String fileName,
  String? mimeType,
}) {
  throw UnsupportedError('Web download is not supported on this platform.');
}
