/// Generates a unique template title by appending a number suffix if needed.
///
/// Given an original title and a set of existing titles, returns a title
/// in the format "Copy of [originalTitle]" or "Copy of [originalTitle] (n)"
/// where n is the smallest integer that makes the title unique.
///
/// Example:
/// - Original: "My Template", existing: {} → "Copy of My Template"
/// - Original: "My Template", existing: {"Copy of My Template"} → "Copy of My Template (2)"
/// - Original: "My Template", existing: {"Copy of My Template", "Copy of My Template (2)"} → "Copy of My Template (3)"
String generateUniqueCopyTitle(String originalTitle, Set<String?> existingTitles) {
  final baseTitle = 'Copy of $originalTitle';
  String newTitle = baseTitle;
  int counter = 2;

  while (existingTitles.contains(newTitle)) {
    newTitle = '$baseTitle ($counter)';
    counter++;
  }

  return newTitle;
}