/// The abbreviation type to indicate whether or not to add period to a prefix
/// using the American or British way.
enum Title {
  /// A period after the prefix.
  us,

  /// No period after the prefix.
  uk
}

/// An option indicating how to format a surname.
///
/// This enum can be set via [Config] or when creating a [LastName]. As this can
/// become ambiguous at the time of handling it, the value set in [Config] is
/// prioritized and viewed as the source of truth for future considerations.
enum Surname {
  /// The fatherly surname only.
  father,

  /// The motherly surname only.
  mother,

  /// The junction of both the fatherly and motherly surnames with a hyphen.
  hyphenated,

  /// The junction of both the fatherly and motherly surnames with a space.
  all
}

/// The order of appearance of a [FullName].
enum NameOrder {
  /// The first part of a full name, usually the first piece of a person name.
  firstName,

  /// The last part of a full name, usually the last piece of a person name.
  lastName
}

/// The types of name handled in this according the name standards.
enum NameType { firstName, middleName, lastName, birthName }

/// The possible variants to indicate how to flatten a [FullName].
enum Flat {
  /// Use the first name's initial combined with the remaining parts.
  firstName,

  /// Use the middle name's initial combined with the remaining parts.
  middleName,

  /// Use the last name's initial combined with the remaining parts.
  lastName,

  /// Use both the first and middle names' initials combined with the remaining parts.
  firstMid,

  /// Use both the last and middle names' initials combined with the remaining parts.
  midLast,

  /// Use the first, middle and last names' initials combined with the remaining parts.
  all
}

/// The range to use when capitalizing a string content.
enum CapsRange {
  /// No capitalization.
  none,

  /// Apply capitalization to the first letter.
  initial,

  /// Apply capitalization to all the letters.
  all
}

/// The types of name handled in this utility according the name standards.
enum Namon {
  prefix,
  firstName,
  middleName,
  lastName,
  suffix;

  /// All the predefined name types.
  static final Map<String, Namon> all = Map<String, Namon>.unmodifiable({
    prefix.name: prefix,
    firstName.name: firstName,
    middleName.name: middleName,
    lastName.name: lastName,
    suffix.name: suffix,
  });

  @override
  String toString() => 'Namon.$name';

  /// Whether this string [key] is part of the predefined keys.
  static bool containsKey(String key) => all.containsKey(key);

  /// Makes a string [key] a namon type.
  static Namon? cast(String key) => containsKey(key) ? all[key] : null;
}

/// The token used to indicate how to split string values.
enum Separator {
  comma(','),
  colon(':'),
  doubleQuote('"'),
  empty(''),
  hyphen('-'),
  period('.'),
  semiColon(';'),
  singleQuote("'"),
  space(' '),
  underscore('_');

  /// The character representative of the separator.
  final String token;

  const Separator(this.token);

  /// All the available separators.
  static final Map<String, Separator> all = Map.unmodifiable({
    comma.name: comma,
    colon.name: colon,
    doubleQuote.name: doubleQuote,
    empty.name: empty,
    hyphen.name: hyphen,
    period.name: period,
    semiColon.name: semiColon,
    singleQuote.name: singleQuote,
    space.name: space,
    underscore.name: underscore,
  });

  /// All the available tokens.
  static final Set<String> tokens = all.values.map((s) => s.token).toSet();

  @override
  String toString() => 'Separator.$name';
}

/// A convenient void callback function definition.
typedef VoidCallback = void Function();

/// A convenient callback function receiving a [P]aram and [R]eturning a value.
typedef Callback<P, R> = R Function(P param);
