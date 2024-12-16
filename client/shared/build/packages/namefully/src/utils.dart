import 'constants.dart';
import 'types.dart';

/// A fixed set of values to handle specific positions for list of names.
///
/// As for list of names, this helps to follow a specific order based on the
/// count of elements. It is expected that the list has to be between two and
/// five elements. Also, the order of appearance set in the [Config]uration
/// influences how the parsing is carried out.
///
/// Ordered by first name, the parser works as follows:
/// - 2 elements: firstName lastName
/// - 3 elements: firstName middleName lastName
/// - 4 elements: prefix firstName middleName lastName
/// - 5 elements: prefix firstName middleName lastName suffix
///
/// Ordered by last name, the parser works as follows:
/// - 2 elements: lastName firstName
/// - 3 elements: lastName firstName middleName
/// - 4 elements: prefix lastName firstName middleName
/// - 5 elements: prefix lastName firstName middleName suffix
///
/// For example, `Jane Smith` (ordered by first name) is expected to be indexed:
/// `['Jane', 'Smith']`.
class NameIndex {
  final int prefix, firstName, middleName, lastName, suffix;

  /// Disable the constructor to prevent instantiation.
  const NameIndex._(
    this.prefix,
    this.firstName,
    this.middleName,
    this.lastName,
    this.suffix,
  );

  /// The default or base index for the [NameIndex].
  const NameIndex.base() : this._(-1, 0, -1, 1, -1);

  /// The minimum number of parts in a list of names.
  static const int min = kMinNumberOfNameParts;

  /// The maximum number of parts in a list of names.
  static const int max = kMaxNumberOfNameParts;

  /// Gets the name index for a list of names based on the [count] of elements
  /// and their [order] of appearance.
  static NameIndex when(NameOrder order, [int count = 2]) {
    if (order == NameOrder.firstName) {
      switch (count) {
        case 2: // first name + last name
          return const NameIndex._(-1, 0, -1, 1, -1);
        case 3: // first name + middle name + last name
          return const NameIndex._(-1, 0, 1, 2, -1);
        case 4: // prefix + first name + middle name + last name
          return const NameIndex._(0, 1, 2, 3, -1);
        case 5: // prefix + first name + middle name + last name + suffix
          return const NameIndex._(0, 1, 2, 3, 4);
        default:
          return NameIndex.base();
      }
    } else {
      switch (count) {
        case 2: // last name + first name
          return const NameIndex._(-1, 1, -1, 0, -1);
        case 3: // last name + first name + middle name
          return const NameIndex._(-1, 1, 2, 0, -1);
        case 4: // prefix + last name + first name + middle name
          return const NameIndex._(0, 2, 3, 1, -1);
        case 5: // prefix + last name + first name + middle name + suffix
          return const NameIndex._(0, 2, 3, 1, 4);
        default:
          return NameIndex.base();
      }
    }
  }
}

/// Capitalizes a [string] via a [CapsRange] option.
String capitalize(String string, [CapsRange range = CapsRange.initial]) {
  if (string.isEmpty || range == CapsRange.none) return string;
  final initial = string[0].toUpperCase();
  final rest = string.substring(1).toLowerCase();
  return range == CapsRange.initial ? (initial + rest) : string.toUpperCase();
}

/// De-capitalizes a [string] via a [CapsRange] option.
String decapitalize(String string, [CapsRange range = CapsRange.initial]) {
  if (string.isEmpty || range == CapsRange.none) return string;
  final initial = string[0].toLowerCase();
  final rest = string.substring(1);
  return range == CapsRange.initial ? (initial + rest) : string.toLowerCase();
}

/// Toggles a [string] representation.
String toggleCase(String string) {
  return <String>[
    for (var c in string.chars)
      c == c.toUpperCase() ? c.toLowerCase() : c.toUpperCase()
  ].join();
}

// Borrowed from the dart sdk: sdk/lib/math/jenkins_smi_hash.dart.
int hashValues(Object arg01, Object arg02) {
  int hash = arg01.hashCode + arg02.hashCode;
  hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
  hash = hash ^ (hash >> 11);
  return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
}

/// Add validation capabilities to [String].
extension StringValidation on String {
  /// A minimum of 2 characters must be provided.
  bool get isValid => trim().isNotEmpty && trim().length > 1;

  /// A minimum of 2 characters must be provided.
  bool get isInvalid => !isValid;

  /// Transforms a string into a list of characters.
  List<String> get chars => split('');
}

/// Enable nullable check for first values on [Iterable]s.
extension FirstOrNullIterable<E> on Iterable<E> {
  /// The first value if any.
  E? get firstOrNull => length == 0 ? null : elementAt(0);
}
