
/// Network request content type enumeration
enum ContentType {
  /// application/json
  json,

  /// application/x-www-form-urlencoded
  formUrlEncoded,

  /// multipart/form-data
  multipart,

  /// text/plain
  text,

  /// text/html
  html,

  /// application/xml
  xml,

  /// application/octet-stream (binary data)
  binary,

  /// Custom content type (use with contentTypeString)
  custom,
}

/// Content type utility extensions
extension ContentTypeExtension on ContentType {
  /// Get MIME type string with optional charset
  String toMimeType({String charset = 'utf-8'}) {
    switch (this) {
      case ContentType.json:
        return 'application/json; charset=$charset';
      case ContentType.formUrlEncoded:
        return 'application/x-www-form-urlencoded; charset=$charset';
      case ContentType.multipart:
        return 'multipart/form-data';
      case ContentType.text:
        return 'text/plain; charset=$charset';
      case ContentType.html:
        return 'text/html; charset=$charset';
      case ContentType.xml:
        return 'application/xml; charset=$charset';
      case ContentType.binary:
        return 'application/octet-stream';
      case ContentType.custom:
        throw StateError('Custom content type requires contentTypeString');
    }
  }

  /// Parse MIME type string to ContentType
  static ContentType? fromMimeType(String mimeType) {
    final baseMime = mimeType.split(';').first.trim().toLowerCase();
    switch (baseMime) {
      case 'application/json':
        return ContentType.json;
      case 'application/x-www-form-urlencoded':
        return ContentType.formUrlEncoded;
      case 'multipart/form-data':
        return ContentType.multipart;
      case 'text/plain':
        return ContentType.text;
      case 'text/html':
        return ContentType.html;
      case 'application/xml':
      case 'text/xml':
        return ContentType.xml;
      case 'application/octet-stream':
        return ContentType.binary;
      default:
        return null;
    }
  }
}