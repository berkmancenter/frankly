/// Sanitizes user-provided strings for CSV export to prevent formula injection
String sanitizeTextForCsv(String? value) {
  if (value == null || value.isEmpty) return '';

  final trimmed = value.trim();
  // Remove command characters.
  if (trimmed.startsWith('=') ||
      trimmed.startsWith('+') ||
      trimmed.startsWith('-') ||
      trimmed.startsWith('@') ||
      trimmed.startsWith('\t') ||
      trimmed.startsWith('\r')) {
    // Prefix with a single quote to prevent formula interpretation
    return "'$value";
  }

  return value;
}

/// Sanitizes all string values in a row for CSV export
List<dynamic> sanitizeCsvRow(List<dynamic> row) {
  return row.map((value) {
    if (value is String) {
      return sanitizeTextForCsv(value);
    }
    return value;
  }).toList();
}
