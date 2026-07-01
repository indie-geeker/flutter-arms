bool hasArchExemptForImport(List<String> lines, int importLineIndex) {
  if (importLineIndex <= 0 || importLineIndex >= lines.length) {
    return false;
  }

  return RegExp(
    r'^\s*//\s*arch-exempt:\s*\S',
  ).hasMatch(lines[importLineIndex - 1]);
}
