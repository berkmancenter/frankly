
/// Get a subset of fields after a model is converted to json. This is used
/// when updating to make sure an update only updates the fields it cares
/// about.
Map<String, dynamic> jsonSubset(
    Iterable<String> keys, Map<String, dynamic> json) {
  return Map.fromEntries(
      json.entries.where((entry) => keys.contains(entry.key)));
}

/// This is used for our datetimes when converting to json for cloud functions.
/// For cloud functions we convert to this. For firestore we convert to the
/// firestore type Timestamp.
// TODO: Clean up datetime serialization/deserialization throughout app.
dynamic encodeDateTimeForJson(dynamic dateTime) {
  if (dateTime is DateTime) {
    return dateTime.toUtc().toIso8601String();
  }
  return dateTime;
}

dynamic toNull(dynamic _) => null;

String? firstAndLastInitial(String? fullName) {
  if (fullName == null || fullName.isEmpty) return null;

  final nameParts = fullName.split(" ");
  final lastInitial = nameParts.last[0];
  if (nameParts.length == 1 || lastInitial.isEmpty) {
    return nameParts[0];
  }

  return '${nameParts[0]} $lastInitial';
}

// Non-cryptographic hash to convert our string uids into integers for Agora
int uidToInt(String uid) {
  int base =
      257; // A prime number slightly larger than the number of printable ASCII characters
  int hash = 0;
  int modValue = 1 << 30; // Allow 30 bit integers

  for (int i = 0; i < uid.length; i++) {
    hash = (hash * base + uid.codeUnitAt(i)) % modValue;
  }

  return hash;
}
