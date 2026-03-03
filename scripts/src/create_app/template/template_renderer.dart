String renderTemplate(String input, Map<String, String> values) {
  var output = input;
  for (final entry in values.entries) {
    output = output.replaceAll('{{${entry.key}}}', entry.value);
  }

  final unresolved = RegExp(r'\{\{[^}]+\}\}');
  if (unresolved.hasMatch(output)) {
    final first = unresolved.firstMatch(output)?.group(0) ?? 'unknown';
    throw StateError('Unresolved template token: $first');
  }

  return output;
}
