class StringUtils {
  /// Convert camelCase naming to more readable format
  /// Example: 'reminderEmails' -> 'Reminder Emails'
  static String humanizeString(String text) {
    if (text.isEmpty) return text;
    
    // Add spaces before capital letters
    final result = text.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    );
    
    // Capitalize the first letter and trim any leading spaces
    return result[0].toUpperCase() + result.substring(1).trim();
  }
} 